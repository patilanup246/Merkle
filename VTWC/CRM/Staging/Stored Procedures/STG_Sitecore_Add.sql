/*===========================================================================================
Name:			Staging.STG_Sitecore_Add
Purpose:		Reads Sitecore Newsletter subscripton data from Silverpop tables and acomodates 
				data on CRM tables for future usage.
Parameters:		@userid - The key for the user executing the proc.
				@pDataImportDetailID - Unique ID for the data that we want to load
				@PkgExecKey The key for identifying package which ran the procedure
Notes:			 
			
Created:		2018-09-20	Juanjo Diaz (jdiaz@merkleinc.com)
Modified:		
Peer Review:	
Call script:	EXEC Staging.STG_Sitecore_Add @userid, @PkgExecKey, @DataImportDetailID
=================================================================================================*/
CREATE PROCEDURE [Staging].[STG_Sitecore_Add]
(
	@userid              INTEGER = 0,
	@PkgExecKey          INTEGER = -1,
	@DataImportDetailID  INTEGER

) AS
BEGIN TRY
	BEGIN TRAN
    SET NOCOUNT ON;

	/* Variables */
	DECLARE @ProcessedValues               TABLE( id INT , Email VARCHAR(256));
	DECLARE @vTodayTimestamp               DATETIME = GETDATE();
	DECLARE @vSiteCoreInformationSourceID  INT;
	DECLARE @vEmailAddressTypeID           INT;
	DECLARE @vSiteCorePrefernceID          INT;
	DECLARE @vSiteCoreChannelID            INT;
	DECLARE @vOptInTrue                    BIT = 1;
	DECLARE @CVIQuestionID                 INT;

	/* Error handleing variables */
	DECLARE @ErrorMsg NVARCHAR(MAX);
	DECLARE @ErrorNum INTEGER;
	DECLARE @Procname NVARCHAR(MAX);
	DECLARE @StepName NVARCHAR(MAX);

	/* Gather basic data to run this process*/
	BEGIN TRY
		SET @StepName = 'Gather basic data to run this process';
		-- Setting stored procedure name for logging
		SET @ProcName = 'Staging.STG_Sitecore_Add';

		-- Information Source ID for Sitecore
		SELECT @vSiteCoreInformationSourceID = iso.InformationSourceID 
		  FROM Reference.InformationSource iso WITH (NOLOCK)
		 WHERE iso.Name = 'Sitecore';
	
		-- Preference ID for General Marketing Opt-In
		SELECT @vSiteCorePrefernceID = p.PreferenceID       
		  FROM Reference.Preference p WITH (NOLOCK)
		 WHERE p.Name = 'General Marketing Opt-In';

		-- Channel ID for EMAIL 
		SELECT @vSiteCoreChannelID = c.ChannelID
		  FROM Reference.Channel c WITH (NOLOCK)
		 WHERE c.Name = 'Email'

		-- Email Address Type ID
		SELECT @vEmailAddressTypeID = adrt.AddressTypeID             
		  FROM Reference.AddressType adrt WITH (NOLOCK)      
		 WHERE adrt.Name = 'EMAIL';
	END TRY
	BEGIN CATCH
		SELECT @ErrorMsg = 'Unable to gather basic data to run this process.';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Read Sitecore not processed rows */
	BEGIN TRY
	
		SET @StepName = 'Read Sitecore not processed rows';	
	
		DROP TABLE IF EXISTS #SiteCoreData2Process;
		
		SELECT RANK() OVER (PARTITION BY sc.Email ORDER BY Opt_In_Date DESC) IsLatest
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
			 , RecordID
			 , Email
			 , CONVERT(DATETIME, [Opt_In_Date], 111) AS Opt_In_Date
			 , CVI_Country
			 , CVI_Title
			 , CVI_Forename
			 , CVI_Surname
			 , CVI_Frequency
			 , CVI_Postcode
			 , CVI_PurchType
			 , CVI_Railcard
			 , CVI_Station
			 , CVI_TravelReason
			 , CVI_YoB
			 , IsProcessedInd
		  INTO #SiteCoreData2Process
		  FROM ibm_system.dbo.SP_Sitecore_OptIns sc
		  LEFT JOIN Staging.STG_ElectronicAddress ea ON ea.Address = sc.Email AND ea.AddressTypeID = 3 -- Only EMAIL
		 WHERE sc.IsProcessedInd = 0;
		 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to read Sitecore rows for ibm_system.dbo.SP_Sitecore_OptIns table.';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting / Updating individuals */
	BEGIN TRY
		SET @StepName = 'Inserting new individuals into Staging.STG_Individual table';
		MERGE INTO [Staging].[STG_Individual] AS TARGET
		USING (SELECT IsLatest
						, COALESCE(IndividualID,-99)    AS IndividualID
						, @vTodayTimestamp              AS CreatedDate
						, @DataImportDetailID           AS CreatedBy
						, @vTodayTimestamp              AS LastModifiedDate
						, @DataImportDetailID           AS LastModifiedBy
						, Opt_In_Date                   AS SourceCreatedDate
						, Opt_In_Date                   AS SourceModifiedDate
						, @vSiteCoreInformationSourceID AS InformationSourceID
						, RecordID                      AS RecordID
						, Email                         AS Email
						, CVI_Title                     AS Title
						, CVI_Forename                  AS Forename
						, CVI_Surname                   AS Surname
						, CVI_YoB                       AS YearOfBirth
				FROM #SiteCoreData2Process tmp 
				WHERE tmp.RowType <> 'EXISTING_CUSTOMER'
					AND tmp.IsLatest = 1) AS SOURCE
				( IsLatest
				, IndividualID
				, CreatedDate
				, CreatedBy
				, LastModifiedDate
				, LastModifiedBy
				, SourceCreatedDate
				, SourceModifiedDate
				, InformationSourceID
				, RecordID
				, Email
				, Title
				, Forename
				, Surname
				, YearOfBirth) 
			ON (TARGET.IndividualID = SOURCE.IndividualID) 
		  WHEN MATCHED THEN
		      UPDATE SET [Salutation]  = SOURCE.Title,
			             [FirstName]   = SOURCE.Forename,
						 [LastName]    = SOURCE.Surname,
						 [YearOfBirth] = SOURCE.YearOfBirth,
						 [LastModifiedBy] = SOURCE.LastModifiedBy,
						 [LastModifiedDate] = SOURCE.LastModifiedDate,
						 [SourceModifiedDate] = SOURCE.SourceModifiedDate
		  WHEN NOT MATCHED THEN
			  INSERT 
				( [CreatedDate]
				, [CreatedBy]
				, [LastModifiedDate]
				, [LastModifiedBy]
				, [SourceCreatedDate]
				, [SourceModifiedDate]
				, [InformationSourceID]
				, [Salutation]
				, [FirstName]
				, [LastName]
				, [YearOfBirth])
			  VALUES 
			   ( SOURCE.CreatedDate
			   , SOURCE.CreatedBy
			   , SOURCE.LastModifiedDate
			   , SOURCE.LastModifiedBy
			   , SOURCE.SourceCreatedDate
			   , SOURCE.SourceModifiedDate
			   , SOURCE.InformationSourceID
			   , SOURCE.Title
			   , SOURCE.Forename
			   , SOURCE.Surname
			   , SOURCE.YearOfBirth)
			OUTPUT INSERTED.IndividualID, SOURCE.Email
			INTO @ProcessedValues (ID, Email);

		/* Updating source temporary table to populate new individual ids */
		SET @StepName = 'Updating source temporary table to populate new individual ids';
		UPDATE sc
		   SET IndividualID =  ii.ID
		     , IsProcessedInd = 1
		  FROM #SiteCoreData2Process sc
		 INNER JOIN @ProcessedValues ii ON ii.Email = sc.Email;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals from Sitecore';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting Electronic Address for those that are new Individuals */
	BEGIN TRY
		SET @StepName = 'Inserting Electronic Address for those that are new Individuals';

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
			SELECT DISTINCT 'Sitecore'         AS Name
				 , 'WCA - Sitecore Newsletter' AS Description
				 , @vTodayTimestamp            AS CreatedDate
				 , @DataImportDetailID         AS CreatedBy
				 , @vTodayTimestamp            AS LastModifiedDate
				 , @DataImportDetailID         AS LastModifiedBy
				 , @vSitecoreInformationSourceID AS InformationSourceID
				 , sc.Opt_In_Date              AS SourceChangeDate
				 , sc.Email                    AS Address
				 , @vEmailAddressTypeID        AS AddressTypeID
				 , 1                           AS PrimaryInd
				 , 1                           AS UsedInCommunicationInd
				 , sc.IndividualID             AS IndividualID
				 , Staging.VT_HASH(sc.Email)   AS HashedAddress
				 , NEWID()                     AS EncryptedAddress
			  FROM #SiteCoreData2Process sc
			  WHERE sc.RowType = 'NEW_INDIVIDUAL';

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals Electronic Addresses from Sitecore';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* If Country or POSTCODE has been populated we'll insert a new row in Address 
	   for those that are new Individuals or update existing */
	BEGIN TRY
		SET @StepName = 'Inserting or Updating Address for Individuals';

		MERGE Staging.STG_Address AS TARGET  
		USING (SELECT sc.IndividualID                AS IndividualID
					, c.CountryID                    AS CountryID
					, sc.CVI_PostCode                AS PostCode
					, sc.Opt_In_Date                 AS Opt_In_Date
				 FROM #SiteCoreData2Process sc
				 LEFT JOIN Reference.Country c WITH (NOLOCK) ON c.Name = sc.CVI_Country

				 WHERE sc.RowType <> 'EXISTING_CUSTOMER') 
				AS SOURCE ( IndividualID , CountryID , PostCode, Opt_In_Date )  
			ON (TARGET.IndividualID = SOURCE.IndividualID 
			AND TARGET.AddressTypeID =  @vEmailAddressTypeID) 
			WHEN MATCHED AND TARGET.SourceCreatedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CountryID          = COALESCE(SOURCE.CountryID, TARGET.CountryID),
				           PostalCode         = COALESCE(SOURCE.PostCode, TARGET.PostalCode),
						   SourceModifiedDate = SOURCE.Opt_In_Date,
						   LastModifiedDate   = @vTodayTimestamp,
						   LastModifiedBy     = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( IndividualID
					   , CountryID
					   , PostalCode
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate
					   , SourceCreatedDate
					   , SourceModifiedDate
					   , InformationSourceID
					   , AddressTypeID)
				VALUES ( SOURCE.IndividualID
					   , SOURCE.CountryID
					   , SOURCE.PostCode
					   , @DataImportDetailID
					   , @vTodayTimestamp
					   , @DataImportDetailID
					   , @vTodayTimestamp
					   , SOURCE.Opt_In_Date
					   , SOURCE.Opt_In_Date
					   , @vSitecoreInformationSourceID
					   , @vEmailAddressTypeID)
			OUTPUT INSERTED.IndividualID
			INTO @ProcessedValues (ID);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals Addresses from Sitecore';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting new Individuals into KeyMapping table */
	BEGIN TRY
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
			SELECT 'Sitecore - WCA Newsletter'    AS Description
				 , @vTodayTimestamp               AS CreatedDate
				 , @DataImportDetailID            AS CreatedBy
				 , @vTodayTimestamp               AS LastModifiedDate
				 , @DataImportDetailID            AS LastModifiedBy
				 , sc.IndividualID                AS IndividualID
				 , @vSiteCoreInformationSourceID  AS InformationSourceID
				 , 0                              AS IsVerifiedInd
				 , 0                              AS IsParentInd
			  FROM #SiteCoreData2Process sc
			 WHERE sc.RowType = 'NEW_INDIVIDUAL';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals into Staging.STG_KeyMapping table from Sitecore';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

    /* Inserting or Updating Individual Newsletter Preference for Email channel
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		DELETE FROM @ProcessedValues;
		
		SET @StepName = 'Inserting Individual Preferences';

		MERGE Staging.STG_IndividualPreference AS TARGET  
		USING (SELECT sc.IndividualID                AS IndividualID
					, @vSiteCorePrefernceID          AS PreferenceID
					, @vSiteCoreChannelID            AS ChannelID
					, sc.Opt_In_Date                 AS Opt_In_Date
				 FROM #SiteCoreData2Process sc
				WHERE sc.RowType <> 'EXISTING_CUSTOMER') 
				AS SOURCE ( IndividualID , PreferenceID , ChannelID, Opt_In_Date )  
			ON (TARGET.IndividualID = SOURCE.IndividualID 
			AND TARGET.PreferenceID = SOURCE.PreferenceID
			AND TARGET.ChannelID    = SOURCE.ChannelID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET [Value]            = @vOptInTrue,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
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
					   , @vOptInTrue
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date)
			OUTPUT INSERTED.IndividualID
			INTO @ProcessedValues (ID);

		/* Updating source temporary table to populate new individual ids */
		UPDATE sc
		   SET IsProcessedInd = 1
		  FROM #SiteCoreData2Process sc
		 INNER JOIN @ProcessedValues ii ON ii.ID = sc.IndividualID;
		 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert Individual Preferences from Sitecore';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting or Updating Customer Preferences for Email channel
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		SET @StepName = 'Inserting Customer Preferences';

		MERGE Staging.STG_CustomerPreference AS TARGET  
		USING (SELECT sc.CustomerID                  AS CustomerID
					, @vSiteCorePrefernceID          AS PreferenceID
					, @vSiteCoreChannelID            AS ChannelID
					, sc.Opt_In_Date                 AS Opt_In_Date
				 FROM #SiteCoreData2Process sc
				WHERE sc.RowType = 'EXISTING_CUSTOMER') 
				AS SOURCE ( CustomerID , PreferenceID , ChannelID, Opt_In_Date )  
			ON (TARGET.CustomerID   = SOURCE.CustomerID 
			AND TARGET.PreferenceID = SOURCE.PreferenceID
			AND TARGET.ChannelID    = SOURCE.ChannelID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET [Value]            = @vOptInTrue,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
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
					   , @vOptInTrue
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date)
			OUTPUT INSERTED.CustomerID
			INTO @ProcessedValues (id);

		/* Updating source temporary table to populate new individual ids */
		UPDATE sc
		   SET IsProcessedInd = 1
		  FROM #SiteCoreData2Process sc
		 INNER JOIN @ProcessedValues ii ON ii.id = sc.CustomerID;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert Customer Preferences from Sitecore';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/**************** CVI *****************************************************/
	/**************** Individuals *********************************************/
	/* Inserting or Updating CVI Frequency Question and Answers for Individuals
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		SET @StepName = 'Getting CVI Individuals Sitecore Frequency Question & Answer';

		SELECT TOP 1 @CVIQuestionID = CVIQuestionID 
		  FROM Reference.CVIQuestion WITH (NOLOCK) 
		 WHERE Name = 'NWL_FREQUENCY';

		MERGE Staging.STG_CVIIndividual AS TARGET  
		USING (SELECT sc.IndividualID     AS IndividualID
					, @CVIQuestionID      AS CVIQuestionID
					, sa.CVIAnswerID      AS CVIAnswerID
					, sc.Opt_In_Date      AS Opt_In_Date
				FROM #SiteCoreData2Process sc
				INNER JOIN Reference.CVIStandardAnswer sa WITH (NOLOCK) ON sc.CVI_Frequency = sa.Description
				WHERE sc.RowType <> 'EXISTING_CUSTOMER') 
				AS SOURCE ( IndividualID 
				          , CVIQuestionID 
						  , CVIAnswerID
						  , Opt_In_Date)  
			ON (TARGET.IndividualID     = SOURCE.IndividualID 
			AND TARGET.CVIQuestionID    = SOURCE.CVIQuestionID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CVIAnswerID        = SOURCE.CVIAnswerID,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( IndividualID
					   , CVIQuestionID
					   , CVIAnswerID
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.IndividualID
					   , SOURCE.CVIQuestionID
					   , SOURCE.CVIAnswerID
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert / update CVI Individuals Sitecore Frequency Question & Answer';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting or Updating CVI Purchase Type Question and Answers for Individuals
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		SET @StepName = 'Getting CVI Individuals Sitecore Purchase Type Question & Answer';

		SELECT TOP 1 @CVIQuestionID = CVIQuestionID 
		  FROM Reference.CVIQuestion WITH (NOLOCK) 
		 WHERE Name = 'NWL_PURCHASE_TYPE';

		MERGE Staging.STG_CVIIndividual AS TARGET  
		USING (SELECT sc.IndividualID     AS IndividualID
					, @CVIQuestionID      AS CVIQuestionID
					, sa.CVIAnswerID      AS CVIAnswerID
					, sc.Opt_In_Date      AS Opt_In_Date
				FROM #SiteCoreData2Process sc
				INNER JOIN Reference.CVIStandardAnswer sa WITH (NOLOCK) ON sc.CVI_PurchType = sa.Description
				WHERE sc.RowType <> 'EXISTING_CUSTOMER') 
				AS SOURCE ( IndividualID 
				          , CVIQuestionID 
						  , CVIAnswerID
						  , Opt_In_Date)  
			ON (TARGET.IndividualID   = SOURCE.IndividualID 
			AND TARGET.CVIQuestionID = SOURCE.CVIQuestionID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CVIAnswerID        = SOURCE.CVIAnswerID,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( IndividualID
					   , CVIQuestionID
					   , CVIAnswerID
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.IndividualID
					   , SOURCE.CVIQuestionID
					   , SOURCE.CVIAnswerID
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to Insert / Update CVI Individuals Purchase Type Question & Answer';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting or Updating CVI Railcard Type Question and Answers for Individuals
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		SET @StepName = 'Getting CVI Sitecore Individuals Railcard Type Question & Answer';

		SELECT TOP 1 @CVIQuestionID = CVIQuestionID 
		  FROM Reference.CVIQuestion WITH (NOLOCK) 
		 WHERE Name = 'NWL_RAILCARD_TYPE';

		MERGE Staging.STG_CVIIndividual AS TARGET  
		USING (SELECT sc.IndividualID     AS IndividualID
					, @CVIQuestionID      AS CVIQuestionID
					, sa.CVIAnswerID      AS CVIAnswerID
					, sc.Opt_In_Date      AS Opt_In_Date
				FROM #SiteCoreData2Process sc
				INNER JOIN Reference.CVIStandardAnswer sa WITH (NOLOCK) ON sc.CVI_Railcard = sa.Description
				WHERE sc.RowType <> 'EXISTING_CUSTOMER') 
				AS SOURCE ( IndividualID 
				          , CVIQuestionID 
						  , CVIAnswerID
						  , Opt_In_Date)  
			ON (TARGET.IndividualID   = SOURCE.IndividualID 
			AND TARGET.CVIQuestionID = SOURCE.CVIQuestionID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CVIAnswerID        = SOURCE.CVIAnswerID,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( IndividualID
					   , CVIQuestionID
					   , CVIAnswerID
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.IndividualID
					   , SOURCE.CVIQuestionID
					   , SOURCE.CVIAnswerID
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to Insert / Update CVI Individuals Railcard Type Question & Answer';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH
	
	/* Inserting or Updating CVI Preferred Departure Station Type Question and Answers for Individuals
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		SET @StepName = 'Getting CVI Sitecore Individuals Preferred Departure Station Type Question & Answer';

		SELECT TOP 1 @CVIQuestionID = CVIQuestionID 
		  FROM Reference.CVIQuestion WITH (NOLOCK) 
		 WHERE Name = 'NWL_PREFERRED_VT_DEPARTURE_STATION';

		MERGE Staging.STG_CVIIndividual AS TARGET  
		USING (SELECT sc.IndividualID     AS IndividualID
					, @CVIQuestionID      AS CVIQuestionID
					, sa.CVIAnswerID      AS CVIAnswerID
					, sc.Opt_In_Date      AS Opt_In_Date
				FROM #SiteCoreData2Process sc
				INNER JOIN Reference.CVIStandardAnswer sa WITH (NOLOCK) ON sc.CVI_Station = sa.Description
				WHERE sc.RowType <> 'EXISTING_CUSTOMER') 
				AS SOURCE ( IndividualID 
				          , CVIQuestionID 
						  , CVIAnswerID
						  , Opt_In_Date)  
			ON (TARGET.IndividualID   = SOURCE.IndividualID 
			AND TARGET.CVIQuestionID = SOURCE.CVIQuestionID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CVIAnswerID        = SOURCE.CVIAnswerID,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( IndividualID
					   , CVIQuestionID
					   , CVIAnswerID
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.IndividualID
					   , SOURCE.CVIQuestionID
					   , SOURCE.CVIAnswerID
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to Insert / Update CVI Individuals  Preferred Departure Station Type Question & Answer';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH
	
	/* Inserting or Updating CVI General Reason for Travel Type Question and Answers for Individuals
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		SET @StepName = 'Getting CVI Sitecore Individuals General Reason for Travel Type Question & Answer';

		SELECT TOP 1 @CVIQuestionID = CVIQuestionID 
		  FROM Reference.CVIQuestion WITH (NOLOCK) 
		 WHERE Name = 'NWL_GENERAL_REASON_FOR_TRAVEL';

		MERGE Staging.STG_CVIIndividual AS TARGET  
		USING (SELECT sc.IndividualID     AS IndividualID
					, @CVIQuestionID      AS CVIQuestionID
					, sa.CVIAnswerID      AS CVIAnswerID
					, sc.Opt_In_Date      AS Opt_In_Date
				FROM #SiteCoreData2Process sc
				INNER JOIN Reference.CVIStandardAnswer sa WITH (NOLOCK) ON sc.CVI_TravelReason = sa.Description
				WHERE sc.RowType <> 'EXISTING_CUSTOMER') 
				AS SOURCE ( IndividualID 
				          , CVIQuestionID 
						  , CVIAnswerID
						  , Opt_In_Date)  
			ON (TARGET.IndividualID   = SOURCE.IndividualID 
			AND TARGET.CVIQuestionID = SOURCE.CVIQuestionID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CVIAnswerID        = SOURCE.CVIAnswerID,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( IndividualID
					   , CVIQuestionID
					   , CVIAnswerID
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.IndividualID
					   , SOURCE.CVIQuestionID
					   , SOURCE.CVIAnswerID
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to Insert / Update CVI Individuals General Reason for Travel Type Question & Answer';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH
	/**************** Customers *********************************************/
	/* Inserting or Updating CVI Frequency Question and Answers for Customers
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		SET @StepName = 'Getting CVI Customers Sitecore Frequency Question & Answer';

		SELECT TOP 1 @CVIQuestionID = CVIQuestionID 
		  FROM Reference.CVIQuestion WITH (NOLOCK) 
		 WHERE Name = 'NWL_FREQUENCY';
		 
		MERGE Staging.STG_CVICustomer AS TARGET  
		USING (SELECT sc.CustomerID       AS CustomerID
					, @CVIQuestionID      AS CVIQuestionID
					, sa.CVIAnswerID      AS CVIAnswerID
					, sc.Opt_In_Date      AS Opt_In_Date
				FROM #SiteCoreData2Process sc
			   INNER JOIN Reference.CVIStandardAnswer sa WITH (NOLOCK) ON sc.CVI_Frequency = sa.Description
				WHERE sc.RowType = 'EXISTING_CUSTOMER') 
				AS SOURCE ( CustomerID 
				          , CVIQuestionID 
						  , CVIAnswerID
						  , Opt_In_Date)  
			ON (TARGET.CustomerID       = SOURCE.CustomerID 
			AND TARGET.CVIQuestionID    = SOURCE.CVIQuestionID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CVIAnswerID        = SOURCE.CVIAnswerID,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( CustomerID
					   , CVIQuestionID
					   , CVIAnswerID
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.CustomerID
					   , SOURCE.CVIQuestionID
					   , SOURCE.CVIAnswerID
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert / update CVI Customers Sitecore Frequency Question & Answer';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting or Updating CVI Purchase Type Question and Answers for Customers
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		SET @StepName = 'Getting CVI Sitecore Customers Purchase Type Question & Answer';

		SELECT TOP 1 @CVIQuestionID = CVIQuestionID 
		  FROM Reference.CVIQuestion WITH (NOLOCK) 
		 WHERE Name = 'NWL_PURCHASE_TYPE';

		MERGE Staging.STG_CVICustomer AS TARGET  
		USING (SELECT sc.CustomerID       AS CustomerID
					, @CVIQuestionID      AS CVIQuestionID
					, sa.CVIAnswerID      AS CVIAnswerID
					, sc.Opt_In_Date      AS Opt_In_Date
				FROM #SiteCoreData2Process sc
				INNER JOIN Reference.CVIStandardAnswer sa WITH (NOLOCK) ON sc.CVI_PurchType = sa.Description
				WHERE sc.RowType = 'EXISTING_CUSTOMER') 
				AS SOURCE ( CustomerID 
				          , CVIQuestionID 
						  , CVIAnswerID
						  , Opt_In_Date)  
			ON (TARGET.CustomerID      = SOURCE.CustomerID
			AND TARGET.CVIQuestionID   = SOURCE.CVIQuestionID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CVIAnswerID        = SOURCE.CVIAnswerID,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( CustomerID
					   , CVIQuestionID
					   , CVIAnswerID
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.CustomerID
					   , SOURCE.CVIQuestionID
					   , SOURCE.CVIAnswerID
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to Insert / Update CVI Customer Purchase Type Question & Answer';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting or Updating CVI Railcard Type Question and Answers for Customers
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		SET @StepName = 'Getting CVI Sitecore Customer Railcard Type Question & Answer';

		SELECT TOP 1 @CVIQuestionID = CVIQuestionID 
		  FROM Reference.CVIQuestion WITH (NOLOCK) 
		 WHERE Name = 'NWL_RAILCARD_TYPE';

		MERGE Staging.STG_CVICustomer AS TARGET  
		USING (SELECT sc.CustomerID       AS CustomerID
					, @CVIQuestionID      AS CVIQuestionID
					, sa.CVIAnswerID      AS CVIAnswerID
					, sc.Opt_In_Date      AS Opt_In_Date
				FROM #SiteCoreData2Process sc
				INNER JOIN Reference.CVIStandardAnswer sa WITH (NOLOCK) ON sc.CVI_Railcard = sa.Description
				WHERE sc.RowType = 'EXISTING_CUSTOMER') 
				AS SOURCE ( CustomerID 
				          , CVIQuestionID 
						  , CVIAnswerID
						  , Opt_In_Date)  
			ON (TARGET.CustomerID       = SOURCE.CustomerID
			AND TARGET.CVIQuestionID    = SOURCE.CVIQuestionID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CVIAnswerID        = SOURCE.CVIAnswerID,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( CustomerID
					   , CVIQuestionID
					   , CVIAnswerID
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.CustomerID
					   , SOURCE.CVIQuestionID
					   , SOURCE.CVIAnswerID
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to Insert / Update CVI Customer Railcard Type Question & Answer';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH
	
	/* Inserting or Updating CVI Preferred Departure Station Type Question and Answers for Customers
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		SET @StepName = 'Getting CVI Sitecore Customer Preferred Departure Station Type Question & Answer';

		SELECT TOP 1 @CVIQuestionID = CVIQuestionID 
		  FROM Reference.CVIQuestion WITH (NOLOCK) 
		 WHERE Name = 'NWL_PREFERRED_VT_DEPARTURE_STATION';

		MERGE Staging.STG_CVICustomer AS TARGET  
		USING (SELECT sc.CustomerID       AS CustomerID
					, @CVIQuestionID      AS CVIQuestionID
					, sa.CVIAnswerID      AS CVIAnswerID
					, sc.Opt_In_Date      AS Opt_In_Date
				FROM #SiteCoreData2Process sc
				INNER JOIN Reference.CVIStandardAnswer sa WITH (NOLOCK) ON sc.CVI_Station = sa.Description
				WHERE sc.RowType = 'EXISTING_CUSTOMER') 
				AS SOURCE ( CustomerID 
				          , CVIQuestionID 
						  , CVIAnswerID
						  , Opt_In_Date)  
			ON (TARGET.CustomerID       = SOURCE.CustomerID
			AND TARGET.CVIQuestionID    = SOURCE.CVIQuestionID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CVIAnswerID        = SOURCE.CVIAnswerID,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( CustomerID
					   , CVIQuestionID
					   , CVIAnswerID
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.CustomerID
					   , SOURCE.CVIQuestionID
					   , SOURCE.CVIAnswerID
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to Insert / Update CVI Customer Preferred Departure Station Type Question & Answer';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH
	
	/* Inserting or Updating CVI General Reason for Travel Type Question and Answers for Customers
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		
		SET @StepName = 'Getting CVI Sitecore Customer General Reason for Travel Type Question & Answer';

		SELECT TOP 1 @CVIQuestionID = CVIQuestionID 
		  FROM Reference.CVIQuestion WITH (NOLOCK) 
		 WHERE Name = 'NWL_GENERAL_REASON_FOR_TRAVEL';

		MERGE Staging.STG_CVICustomer AS TARGET  
		USING (SELECT sc.CustomerID       AS CustomerID
					, @CVIQuestionID      AS CVIQuestionID
					, sa.CVIAnswerID      AS CVIAnswerID
					, sc.Opt_In_Date      AS Opt_In_Date
				FROM #SiteCoreData2Process sc
				INNER JOIN Reference.CVIStandardAnswer sa WITH (NOLOCK) ON sc.CVI_TravelReason = sa.Description
				WHERE RowType = 'EXISTING_CUSTOMER') 
				AS SOURCE ( CustomerID 
				          , CVIQuestionID 
						  , CVIAnswerID
						  , Opt_In_Date)  
			ON (TARGET.CustomerID       = SOURCE.CustomerID
			AND TARGET.CVIQuestionID    = SOURCE.CVIQuestionID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.Opt_In_Date THEN
				UPDATE SET CVIAnswerID        = SOURCE.CVIAnswerID,
						   [LastModifiedDate] = SOURCE.Opt_In_Date,
						   [LastModifiedBy]   = @DataImportDetailID
			WHEN NOT MATCHED THEN  
				INSERT ( CustomerID
					   , CVIQuestionID
					   , CVIAnswerID
					   , CreatedBy
					   , CreatedDate
					   , LastModifiedBy
					   , LastModifiedDate)
				VALUES ( SOURCE.CustomerID
					   , SOURCE.CVIQuestionID
					   , SOURCE.CVIAnswerID
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date
					   , @DataImportDetailID
					   , SOURCE.Opt_In_Date);

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to Insert / Update CVI Customer General Reason for Travel Type Question & Answer';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Update ibm_system.dbo.Sitecore_OptIns*/
	BEGIN TRY
		SET @StepName = 'Update ibm_sys.dbo.Sitecore_OptIns';

		UPDATE sc
		   SET IsProcessedInd = 1
		  FROM ibm_system.dbo.SP_Sitecore_OptIns sc
		 INNER JOIN #SiteCoreData2Process tmp ON tmp.RecordID = sc.RecordID
		 WHERE tmp.IsProcessedInd = 1;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to update ibm_system.dbo.SP_Sitecore_Optins table';
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

