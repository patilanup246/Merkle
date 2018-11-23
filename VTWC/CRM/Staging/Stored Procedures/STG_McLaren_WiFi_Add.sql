/*===========================================================================================
Name:			Staging.STG_McLaren_WiFi_Add
Purpose:		Reads McLaren WiFi data from preprocessing tables and loads that data into
				CRM tables for future usage. 
				Objectives:
					- Capture prospects data
					- Capture WiFi usage
Parameters:		@userid - The key for the user executing the proc.
				@pDataImportDetailID - Unique ID for the data that we want to load
				@PkgExecKey The key for identifying package which ran the procedure
Notes:			 
			
Created:		2018-09-26	Juanjo Diaz (jdiaz@merkleinc.com)
Modified:		
Peer Review:	
Call script:	EXEC Staging.STG_McLaren_WiFi_Add @userid, @PkgExecKey, @DataImportDetailID
=================================================================================================*/ 
CREATE PROCEDURE [Staging].[STG_McLaren_WiFi_Add]
(
	@userid              INTEGER = 0,
	@PkgExecKey          INTEGER = -1,
	@DataImportDetailID  INTEGER

) AS
BEGIN TRY
	BEGIN TRAN
    SET NOCOUNT ON;

	/* Variables */
	DECLARE @ProcessedValues                 TABLE( id INT , Email VARCHAR(256));
	DECLARE @vTodayTimestamp                 DATETIME = GETDATE();
	DECLARE @vMcLarenWiFiInformationSourceID INT;
	DECLARE @vEmailAddressTypeID             INT;
	DECLARE @vPostalAddressTypeID            INT;
	DECLARE @vMPNAddressTypeID               INT;
	DECLARE @vMcLarenWiFiPrefernceID         INT;
	DECLARE @vMcLarenWiFiChannelID           INT;
	DECLARE @CVIQuestionID                   INT;
	DECLARE @Name                            NVARCHAR(50)  = 'McLarenWiFi';
	DECLARE @Description                     NVARCHAR(256) = 'Mclaren - WiFi Data';

	/* Error handleing variables */
	DECLARE @ErrorMsg NVARCHAR(MAX);
	DECLARE @ErrorNum INTEGER;
	DECLARE @Procname NVARCHAR(MAX);
	DECLARE @StepName NVARCHAR(MAX);

	/* Gather basic data to run this process*/
	BEGIN TRY
		SET @StepName = 'Gather basic data to run this process';
		-- Setting stored procedure name for logging
		SET @ProcName = 'Staging.STG_McLarenWiFi_Add';

		-- Information Source ID for McLarenWiFi
		SELECT @vMcLarenWiFiInformationSourceID = iso.InformationSourceID 
		  FROM Reference.InformationSource iso WITH (NOLOCK)
		 WHERE iso.Name = 'McLaren';
	
		-- Preference ID for General Marketing Opt-In
		SELECT @vMcLarenWiFiPrefernceID = p.PreferenceID       
		  FROM Reference.Preference p WITH (NOLOCK)
		 WHERE p.Name = 'General Marketing Opt-In';

		-- Channel ID for EMAIL 
		SELECT @vMcLarenWiFiChannelID = c.ChannelID
		  FROM Reference.Channel c WITH (NOLOCK)
		 WHERE c.Name = 'Email'

		-- Email Address Type ID
		SELECT @vEmailAddressTypeID = adrt.AddressTypeID             
		  FROM Reference.AddressType adrt WITH (NOLOCK)      
		 WHERE adrt.Name = 'EMAIL';

		-- Postal Address Type ID
		SELECT @vPostalAddressTypeID = adrt.AddressTypeID             
		  FROM Reference.AddressType adrt WITH (NOLOCK)      
		 WHERE adrt.Name = 'Contact';

		-- Mobile Phone Number Address Type ID
		SELECT @vMPNAddressTypeID = adrt.AddressTypeID             
		  FROM Reference.AddressType adrt WITH (NOLOCK)      
		 WHERE adrt.Name = 'Mobile';
	END TRY
	BEGIN CATCH
		SELECT @ErrorMsg = 'Unable to gather basic data to run this process.';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Read McLarenWiFi not processed rows */
	BEGIN TRY
	
		SET @StepName = 'Read McLarenWiFi not processed rows';	
	
		DROP TABLE IF EXISTS #McLarenWiFiData2Process;
		
		SELECT RANK() OVER (PARTITION BY mw.UserID ORDER BY mw.TransactionDateTime DESC) IsLatest
			 , CASE 
				WHEN ea.ElectronicAddressID IS NULL THEN
				'NEW_INDIVIDUAL'
				WHEN ea.CustomerID IS NULL AND ea.IndividualID IS NOT NULL THEN
				'EXISTING_INDIVIDUAL'
				WHEN ea.CustomerID IS NOT NULL THEN
				'EXISTING_CUSTOMER'
				ELSE 
				'UNKNOWN'
			  END RowType
			, ea.IndividualID
			, ea.CustomerID
			, km.KeyMappingID
			, mw.McLaren_WiFi_ID 
			, mw.TransactionDateTime
			, mw.DeviceID
			, mw.UserID AS Email
			, mw.Title
			, mw.FirstName
			, mw.LastName
			, mw.MobilePhoneNumber
			, mw.AddressLine1
			, mw.AddressLine2
			, mw.City
			, mw.Postcode
			, mw.CountryOfOrigin
			, mw.Language
			, CASE 
			    WHEN ISNULL(mw.MarketingOptInflag, '') = '' THEN 
				   0 
				ELSE 
				   mw.MarketingOptInflag 
			  END MarketingOptInflag
			, mw.LoyaltyMember
			, mw.DateOfBirth
			, mw.AgeGroup
			, mw.SiteID
			, mw.Location
			, mw.SSID
			, mw.ProductName
			, mw.Duration
			, mw.PaymentMethod
			, mw.PaymentAmount
			, mw.PaymentReference
			, mw.FlightNumber
			, mw.Destination
			, mw.DeviceDetails
			, mw.CreatedDateETL
			, mw.LastModifiedDateETL
			, mw.DataImportDetailID
			, mw.ProcessedInd
	  INTO #McLarenWiFiData2Process
	  FROM PreProcessing.McLaren_WiFi mw
	  LEFT JOIN Staging.STG_ElectronicAddress ea ON ea.Address = mw.UserID AND ea.AddressTypeID = 3 -- Only EMAIL
	  LEFT JOIN Staging.STG_KeyMapping km ON ea.CustomerID = km.CustomerID OR ea.IndividualID = km.IndividualID
	 WHERE mw.ProcessedInd = 0;
		 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to read McLarenWiFi rows for PreProcessing.McLaren_WiFi table.';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH
	
	/* Inserting / Updating individuals */
	BEGIN TRY
		SET @StepName = 'Inserting new individuals into Staging.STG_Individual table';
		MERGE INTO [Staging].[STG_Individual] AS TARGET
		USING (SELECT COALESCE(IndividualID,-99)       AS IndividualID
					, @Description                     AS Description
					, @vTodayTimestamp                 AS CreatedDate
					, @DataImportDetailID              AS CreatedBy
					, @vTodayTimestamp                 AS LastModifiedDate
					, @DataImportDetailID              AS LastModifiedBy
					, TransactionDateTime              AS SourceCreatedDate
					, TransactionDateTime              AS SourceModifiedDate
					, TransactionDateTime              AS DateFirstPurchase
					, TransactionDateTime              AS DateLastPurchase
                    , @vMcLarenWiFiInformationSourceID AS InformationSourceID
					, Email                            AS Email
					, Title                            AS Title
					, FirstName                        AS FirstName
					, LastName                         AS LastName
					, YEAR(DateOfBirth)                AS YearOfBirth
				FROM #McLarenWiFiData2Process tmp 
				WHERE tmp.RowType <> 'EXISTING_CUSTOMER'
				 AND IsLatest = 1) AS SOURCE
				( IndividualID
				, Description
				, CreatedDate
				, CreatedBy
				, LastModifiedDate
				, LastModifiedBy
				, SourceCreatedDate
				, SourceModifiedDate
				, DateFirstPurchase
				, DateLastPurchase
				, InformationSourceID
				, Email
				, Title
				, FirstName
				, LastName
				, YearOfBirth) 
			ON (TARGET.IndividualID = SOURCE.IndividualID) 
		  WHEN MATCHED AND TARGET.[SourceModifiedDate] < SOURCE.SourceModifiedDate THEN
		      UPDATE SET [Description]         = ISNULL(SOURCE.Description, TARGET.Description),
			             [Salutation]          = ISNULL(SOURCE.Title,       TARGET.Salutation),
			             [FirstName]           = ISNULL(SOURCE.FirstName,   TARGET.FirstName),
						 [LastName]            = ISNULL(SOURCE.LastName,    TARGET.LastName),
						 [YearOfBirth]         = ISNULL(SOURCE.YearOfBirth, TARGET.YearOfBirth),
						 [LastModifiedBy]      = SOURCE.LastModifiedBy,
						 [LastModifiedDate]    = SOURCE.LastModifiedDate,
						 [InformationSourceID] = @vMcLarenWiFiInformationSourceID,
						 -- Only update Last Purchase Date if it SOURCE is newer then TARGET otherwise use TARGET
						 [DateLastPurchase]    = 
							CASE 
								WHEN COALESCE(TARGET.DateLastPurchase,SOURCE.DateLastPurchase) < SOURCE.DateLastPurchase THEN
									TARGET.DateLastPurchase
								ELSE 
									SOURCE.DateLastPurchase
							END,
						 [SourceModifiedDate]  = SOURCE.SourceModifiedDate
		  WHEN NOT MATCHED THEN
			  INSERT 
				( [Description]
				, [CreatedDate]
				, [CreatedBy]
				, [LastModifiedDate]
				, [LastModifiedBy]
				, [SourceCreatedDate]
				, [SourceModifiedDate]
				, [DateFirstPurchase]
				, [DateLastPurchase]
				, [InformationSourceID]
				, [Salutation]
				, [FirstName]
				, [LastName]
				, [YearOfBirth])
			  VALUES 
			   ( SOURCE.Description
			   , SOURCE.CreatedDate
			   , SOURCE.CreatedBy
			   , SOURCE.LastModifiedDate
			   , SOURCE.LastModifiedBy
			   , SOURCE.SourceCreatedDate
			   , SOURCE.SourceModifiedDate
			   , SOURCE.DateFirstPurchase
			   , SOURCE.DateLastPurchase
			   , SOURCE.InformationSourceID
			   , SOURCE.Title
			   , SOURCE.FirstName
			   , SOURCE.LastName
			   , SOURCE.YearOfBirth)
			OUTPUT INSERTED.IndividualID, SOURCE.Email
			INTO @ProcessedValues (ID, Email);

		/* Updating source temporary table to populate new individual ids */
		SET @StepName = 'Updating source temporary table to populate new individual ids';
		UPDATE mw
		   SET IndividualID =  ii.ID
		     , ProcessedInd = 1
		  FROM #McLarenWiFiData2Process mw
		 INNER JOIN @ProcessedValues ii ON ii.Email = mw.Email;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals from McLarenWiFi';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting Electronic Address for those that are new Individuals as well as Inserting or updating
	   the mobile phone number (if provided) */
	BEGIN TRY
		SET @StepName = 'Inserting Electronic Address for those that are new Individuals';
		-- Inserting Email Addresses 
		INSERT INTO Staging.STG_ElectronicAddress 
			( Name
			, Description
			, CreatedDate
			, CreatedBy
			, LastModifiedDate
			, LastModifiedBy
			, InformationSourceID
			, SourceChangeDate
			, Address
			, AddressTypeID
			, PrimaryInd
			, UsedInCommunicationInd
			, IndividualID
			, HashedAddress
			, EncryptedAddress)
			SELECT DISTINCT @Name                   AS Name
				 , @Description                     AS Description
				 , @vTodayTimestamp                 AS CreatedDate
				 , @DataImportDetailID              AS CreatedBy
				 , @vTodayTimestamp                 AS LastModifiedDate
				 , @DataImportDetailID              AS LastModifiedBy
				 , @vMcLarenWiFiInformationSourceID AS InformationSourceID
				 , mw.TransactionDateTime           AS SourceChangeDate
				 , mw.Email                         AS Address
				 , @vEmailAddressTypeID             AS AddressTypeID
				 , 1                                AS PrimaryInd
				 , 1                                AS UsedInCommunicationInd
				 , mw.IndividualID                  AS IndividualID
				 , Staging.VT_HASH(mw.Email)        AS HashedAddress
				 , NEWID()                          AS EncryptedAddress
			  FROM #McLarenWiFiData2Process mw
			 WHERE mw.RowType = 'NEW_INDIVIDUAL'
			   AND mw.IsLatest = 1;

		-- Inserting or Updating MPN 
		MERGE Staging.STG_ElectronicAddress AS TARGET
		USING (SELECT DISTINCT @Name                     AS Name
				 , @Description                          AS Description
				 , @vTodayTimestamp                      AS CreatedDate
				 , @DataImportDetailID                   AS CreatedBy
				 , @vTodayTimestamp                      AS LastModifiedDate
				 , @DataImportDetailID                   AS LastModifiedBy
				 , @vMcLarenWiFiInformationSourceID      AS InformationSourceID
				 , mw.TransactionDateTime                AS SourceChangeDate
				 , mw.MobilePhoneNumber                  AS Address
				 , @vMPNAddressTypeID                    AS AddressTypeID
				 , 1                                     AS PrimaryInd
				 , 1                                     AS UsedInCommunicationInd
				 , mw.IndividualID                       AS IndividualID
				 , Staging.VT_HASH(mw.MobilePhoneNumber) AS HashedAddress
				 , NEWID()                               AS EncryptedAddress
			  FROM #McLarenWiFiData2Process mw
			 -- Only select those rows that have Mobile Phone Number and it is flagged to the latest information 
			 WHERE mw.RowType <> 'EXISTING_CUSTOMER'
			   AND mw.MobilePhoneNumber IS NOT NULL
			   AND mw.IsLatest = 1) AS SOURCE
					(  Name
					 , Description
					 , CreatedDate
					 , CreatedBy
					 , LastModifiedDate
					 , LastModifiedBy
					 , InformationSourceID
					 , SourceChangeDate
					 , Address
					 , AddressTypeID
					 , PrimaryInd
					 , UsedInCommunicationInd
					 , IndividualID
					 , HashedAddress
					 , EncryptedAddress ) 
			ON (TARGET.IndividualID = SOURCE.IndividualID)
		WHEN MATCHED 
		 AND TARGET.AddressTypeID = @vMPNAddressTypeID
		 AND TARGET.Address <> ISNULL(SOURCE.Address, TARGET.Address)
		 AND TARGET.LastModifiedDate < SOURCE.LastModifiedDate THEN
			UPDATE 
			   SET Name = SOURCE.Name
			     , Description         = SOURCE.Description
				 , LastModifiedDate    = SOURCE.LastModifiedDate
				 , LastModifiedBy      = SOURCE.LastModifiedBy
				 , SourceChangeDate    = SOURCE.SourceChangeDate
				 , Address             = SOURCE.Address
				 , InformationSourceID = @vMcLarenWiFiInformationSourceID
		WHEN NOT MATCHED THEN
			INSERT 
				( Name
				, Description
				, CreatedDate
				, CreatedBy
				, LastModifiedDate
				, LastModifiedBy
				, InformationSourceID
				, SourceChangeDate
				, Address
				, AddressTypeID
				, PrimaryInd
				, UsedInCommunicationInd
				, IndividualID
				, HashedAddress
				, EncryptedAddress)
			 VALUES
				( SOURCE.Name
				, SOURCE.Description
				, SOURCE.CreatedDate
				, SOURCE.CreatedBy
				, SOURCE.LastModifiedDate
				, SOURCE.LastModifiedBy
				, SOURCE.InformationSourceID
				, SOURCE.SourceChangeDate
				, SOURCE.Address
				, SOURCE.AddressTypeID
				, SOURCE.PrimaryInd
				, SOURCE.UsedInCommunicationInd
				, SOURCE.IndividualID
				, SOURCE.HashedAddress
				, SOURCE.EncryptedAddress );
		

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals Electronic Addresses from McLarenWiFi';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Updating or Inserting Address */
	BEGIN TRY
		SET @StepName = 'Inserting or Updating Address for Individuals';
		
		MERGE Staging.STG_Address AS TARGET  
		USING (SELECT mw.IndividualID        AS IndividualID
					, mw.AddressLine1        AS AddressLine1
					, mw.AddressLine2        AS AddressLine2
					, mw.City                AS City
					, mw.Postcode            AS PostalCode
					, mw.TransactionDateTime AS SourceCreatedDate
					, mw.TransactionDateTime AS SourceModifiedDate
				 FROM #McLarenWiFiData2Process mw
				WHERE mw.RowType <> 'EXISTING_CUSTOMER'
				  AND mw.IsLatest = 1
				  -- Check that we've something to insert on Address
				  AND ( ISNULL(mw.AddressLine1, '') != ''
			         OR ISNULL(mw.AddressLine2, '') != ''
			         OR ISNULL(mw.City,         '') != ''
					 OR ISNULL(mw.PostCode,     '') != '' ) )  AS SOURCE 
			  ( IndividualID 
			  , AddressLine1 
			  , AddressLine2
			  , City
			  , PostalCode
			  , SourceCreatedDate
			  , SourceModifiedDate )  
			ON (TARGET.IndividualID  = SOURCE.IndividualID 
			AND TARGET.AddressTypeID =  @vPostalAddressTypeID) 
		WHEN MATCHED 
			AND TARGET.SourceModifiedDate < SOURCE.SourceModifiedDate 
			AND ( SOURCE.AddressLine1 <> TARGET.AddressLine1
			   OR SOURCE.AddressLine2 <> TARGET.AddressLine2
			   OR SOURCE.City         <> TARGET.TownCity
			   OR SOURCE.PostalCode   <> TARGET.PostalCode ) THEN
				UPDATE SET AddressLine1        = ISNULL(SOURCE.AddressLine1, TARGET.AddressLine1),
				           AddressLine2        = ISNULL(SOURCE.AddressLine2, TARGET.AddressLine2),
						   TownCity            = ISNULL(SOURCE.City        , TARGET.TownCity),
						   PostalCode          = ISNULL(SOURCE.PostalCode  , TARGET.PostalCode),
						   InformationSourceID = @vMcLarenWiFiInformationSourceID,
						   SourceModifiedDate  = SOURCE.SourceModifiedDate,
						   LastModifiedBy      = @DataImportDetailID
		WHEN NOT MATCHED THEN  
				INSERT ( IndividualID
					   , Name
					   , Description
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate
					   , SourceCreatedDate
					   , SourceModifiedDate
					   , AddressLine1
					   , AddressLine2
					   , TownCity
					   , PostalCode
					   , InformationSourceID
					   , AddressTypeID)
				VALUES ( SOURCE.IndividualID
					   , @Name
					   , @Description
					   , @DataImportDetailID
					   , @vTodayTimestamp
					   , @DataImportDetailID
					   , @vTodayTimestamp
					   , SOURCE.SourceCreatedDate
					   , SOURCE.SourceModifiedDate
					   , SOURCE.AddressLine1
					   , SOURCE.AddressLine2
					   , SOURCE.City
					   , SOURCE.PostalCode
					   , @vMcLarenWiFiInformationSourceID
					   , @vPostalAddressTypeID)
			OUTPUT INSERTED.IndividualID
			INTO @ProcessedValues (ID);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals Addresses from McLarenWiFi';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting new Individuals into KeyMapping table */
	BEGIN TRY
		
		DECLARE @NewKeyMappings TABLE(KeyMappingID INT NOT NULL, IndividualID INT NOT NULL);

		SET @StepName = 'Inserting new Individuals into KeyMapping table';

		INSERT INTO Staging.STG_KeyMapping
			( Description
			, CreatedDate
			, CreatedBy
			, LastModifiedDate
			, LastModifiedBy
			, IndividualID
			, InformationSourceID
			, IsVerifiedInd
			, IsParentInd )
		 OUTPUT INSERTED.KeyMappingID
		      , INSERTED.IndividualID
		 INTO @NewKeyMappings(KeyMappingID,IndividualID)
			SELECT @Description                     AS Description
				 , @vTodayTimestamp                 AS CreatedDate
				 , @DataImportDetailID              AS CreatedBy
				 , @vTodayTimestamp                 AS LastModifiedDate
				 , @DataImportDetailID              AS LastModifiedBy
				 , mw.IndividualID                  AS IndividualID
				 , @vMcLarenWiFiInformationSourceID AS InformationSourceID
				 , 0                                AS IsVerifiedInd
				 , 0                                AS IsParentInd
			  FROM #McLarenWiFiData2Process mw
			 WHERE mw.RowType = 'NEW_INDIVIDUAL'
			   AND mw.IsLatest = 1;

		-- Adding new KeyMappingIDs
		UPDATE mw
		   SET mw.KeyMappingID = nkm.KeyMappingID
		 FROM #McLarenWiFiData2Process mw 
		 INNER JOIN @NewKeyMappings nkm ON nkm.IndividualID = mw.IndividualID;



	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals into Staging.STG_KeyMapping table from McLarenWiFi';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

    /* Inserting or Updating Individual Preference for Email channel
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		DELETE FROM @ProcessedValues;
		
		SET @StepName = 'Inserting Individual Preferences';

		MERGE Staging.STG_IndividualPreference AS TARGET  
		USING (SELECT mw.IndividualID                AS IndividualID
					, @vMcLarenWiFiPrefernceID       AS PreferenceID
					, @vMcLarenWiFiChannelID         AS ChannelID
					, mw.TransactionDateTime         AS LastModifiedDate
					, mw.MarketingOptInflag          AS Value
				 FROM #McLarenWiFiData2Process mw
				WHERE mw.RowType <> 'EXISTING_CUSTOMER'
				  AND mw.IsLatest = 1) AS SOURCE 
			  ( IndividualID 
			  , PreferenceID 
			  , ChannelID
			  , LastModifiedDate
			  , Value )  
			ON (TARGET.IndividualID = SOURCE.IndividualID 
			AND TARGET.PreferenceID = SOURCE.PreferenceID
			AND TARGET.ChannelID    = SOURCE.ChannelID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.LastModifiedDate THEN
				UPDATE SET [Value]            = SOURCE.Value,
						   [LastModifiedDate] = SOURCE.LastModifiedDate,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( IndividualID
					   , PreferenceID
					   , ChannelID
					   , Value
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.IndividualID
					   , SOURCE.PreferenceID
					   , SOURCE.ChannelID
					   , SOURCE.Value
					   , @DataImportDetailID
					   , SOURCE.LastModifiedDate
					   , @DataImportDetailID
					   , SOURCE.LastModifiedDate)
			OUTPUT INSERTED.IndividualID
			INTO @ProcessedValues (ID);

		/* Updating source temporary table flag individual as processed */
		UPDATE mw
		   SET ProcessedInd = 1
		  FROM #McLarenWiFiData2Process mw
		 INNER JOIN @ProcessedValues ii ON ii.ID = mw.IndividualID;
		 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert Individual Preferences from McLarenWiFi';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting or Updating Customer Preferences for Email channel
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		SET @StepName = 'Inserting Customer Preferences';

		MERGE Staging.STG_CustomerPreference AS TARGET  
		USING (SELECT mw.CustomerID                  AS CustomerID
					, @vMcLarenWiFiPrefernceID       AS PreferenceID
					, @vMcLarenWiFiChannelID         AS ChannelID
					, mw.TransactionDateTime         AS LastModifiedDate
					, mw.MarketingOptInflag          AS Value
				 FROM #McLarenWiFiData2Process mw
				WHERE mw.RowType = 'EXISTING_CUSTOMER'
				  AND mw.IsLatest = 1) AS SOURCE 
			  ( CustomerID 
			  , PreferenceID 
			  , ChannelID
			  , LastModifiedDate
			  , Value )  
			ON (TARGET.CustomerID = SOURCE.CustomerID 
			AND TARGET.PreferenceID = SOURCE.PreferenceID
			AND TARGET.ChannelID    = SOURCE.ChannelID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.LastModifiedDate THEN
				UPDATE SET [Value]            = SOURCE.Value,
						   [LastModifiedDate] = SOURCE.LastModifiedDate,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( CustomerID
					   , PreferenceID
					   , ChannelID
					   , Value
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.CustomerID
					   , SOURCE.PreferenceID
					   , SOURCE.ChannelID
					   , SOURCE.Value
					   , @DataImportDetailID
					   , SOURCE.LastModifiedDate
					   , @DataImportDetailID
					   , SOURCE.LastModifiedDate)
			OUTPUT INSERTED.CustomerID
			INTO @ProcessedValues (ID);

		/* Updating source temporary table to populate new individual ids */
		UPDATE mw
		   SET ProcessedInd = 1
		  FROM #McLarenWiFiData2Process mw
		 INNER JOIN @ProcessedValues ii ON ii.id = mw.CustomerID;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert Customer Preferences from McLarenWiFi';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/**************** Customers *********************************************/
	/* 26/09/2018: TBC - Updating  Customers data*/
	BEGIN TRY
		
		SET @StepName = 'Update Customers data from McLaren - Wifi';

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to update Customers data from McLarenWiFi';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* INSERT / UPDATE McLarenWifiHistory table */
	/* Update PreProcessing.McLaren_WiFi*/
	BEGIN TRY
		SET @StepName = 'Insert / update rows into McLarenWifiHistory table';

		INSERT INTO Staging.STG_MclarenWiFiHistory
		OUTPUT (INSERTED.McLaren_WiFiID)
		INTO @ProcessedValues (id)
		   SELECT mw.KeyMappingID
				, mw.McLaren_WiFi_ID 
				, mw.TransactionDateTime
				, mw.DeviceID
				, mw.CountryOfOrigin
				, mw.Language
				, mw.DateOfBirth
				, mw.AgeGroup
				, mw.SiteID
				, mw.Location
				, mw.SSID
				, mw.ProductName
				, CASE 
				      WHEN ISNULL(mw.PaymentAmount,0) >0 THEN
						1
					  ELSE
					    0
				  END AS HasUserPaidForService
				, mw.DeviceDetails
				, @DataImportDetailID
			FROM #McLarenWiFiData2Process mw;

 	   -- UPDATE Processed values
		UPDATE mw
		   SET ProcessedInd = 1
		  FROM PreProcessing.McLaren_WiFi mw
		 INNER JOIN @ProcessedValues tmp ON tmp.ID = mw.McLaren_WiFi_ID;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Insert / update rows into McLarenWifiHistory table';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH


	/* Update PreProcessing.McLaren_WiFi*/
	BEGIN TRY
		SET @StepName = 'Update PreProcessing.McLaren_WiFi';

		UPDATE mw
		   SET ProcessedInd = 1
		  FROM PreProcessing.McLaren_WiFi mw
		 INNER JOIN #McLarenWiFiData2Process tmp ON tmp.McLaren_WiFi_ID = mw.McLaren_WiFi_ID
		 WHERE tmp.ProcessedInd = 1;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to update PreProcessing.McLaren_WiFi table';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	SELECT @ErrorMsg = ERROR_MESSAGE();
	SET @ErrorNum = ERROR_NUMBER();
	EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;		
	THROW 51403, @ErrorMsg, 1; 
END CATCH  	


