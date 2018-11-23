/*===========================================================================================
Name:			Staging.STG_Beam_Add
Purpose:		Reads Beam data from PreProcessing table and loads that
				data on CRM tables for future usage. Mainly used to capture prospects.
Parameters:		@userid - The key for the user executing the proc.
				@pDataImportDetailID - Unique ID for the data that we want to load
				@PkgExecKey The key for identifying package which ran the procedure
Notes:			 
			
Created:		2018-09-25	Juanjo Diaz (jdiaz@merkleinc.com)
Modified:		
Peer Review:	
Call script:	EXEC Staging.STG_Beam_Add @userid, @PkgExecKey, @DataImportDetailID
=================================================================================================*/
CREATE PROCEDURE [Staging].[STG_Beam_Add]
(
	@userid              INTEGER = 0,
	@PkgExecKey          INTEGER = -1,
	@DataImportDetailID  INTEGER

) AS
BEGIN TRY
	BEGIN TRAN
    SET NOCOUNT ON;

	/* Variables */
	DECLARE @ProcessedValues          TABLE( id INT , Email VARCHAR(256));
	DECLARE @vTodayTimestamp          DATETIME = GETDATE();
	DECLARE @vBeamInformationSourceID INT;
	DECLARE @vEmailAddressTypeID      INT;
	DECLARE @vBeamPrefernceID         INT;
	DECLARE @vBeamChannelID           INT;

	/* Error handleing variables */
	DECLARE @ErrorMsg NVARCHAR(MAX);
	DECLARE @ErrorNum INTEGER;
	DECLARE @Procname NVARCHAR(MAX);
	DECLARE @StepName NVARCHAR(MAX);

	/* Gather basic data to run this process*/
	BEGIN TRY
		SET @StepName = 'Gather basic data to run this process';
		-- Setting stored procedure name for logging
		SET @ProcName = 'Staging.STG_Beam_Add';

		-- Information Source ID for Beam
		SELECT @vBeamInformationSourceID = iso.InformationSourceID 
		  FROM Reference.InformationSource iso WITH (NOLOCK)
		 WHERE iso.Name = 'Beam';
	
		-- Preference ID for General Marketing Opt-In
		SELECT @vBeamPrefernceID = p.PreferenceID       
		  FROM Reference.Preference p WITH (NOLOCK)
		 WHERE p.Name = 'General Marketing Opt-In';

		-- Channel ID for EMAIL 
		SELECT @vBeamChannelID = c.ChannelID
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

	/* Read Beam not processed rows */
	BEGIN TRY
	
		SET @StepName = 'Read Beam not processed rows';	
	
		DROP TABLE IF EXISTS #BeamData2Process;
		
		SELECT RANK() OVER (PARTITION BY bc.EmailAddress ORDER BY bc.LastModifiedDate DESC) IsLatest
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
			 , bc.Beam_CustomerID
			 , bc.FirstName
			 , bc.LastName
			 , bc.EmailAddress
			 , bc.OptIn
			 , bc.CreatedDate
			 , bc.CreatedBy
			 , bc.LastModifiedDate
			 , bc.LastModifiedBy
			 , bc.ProcessedInd
			 , bc.DataImportDetailID
		  INTO #BeamData2Process
		  FROM PreProcessing.Beam_Customer bc
		  LEFT JOIN Staging.STG_ElectronicAddress ea ON ISNULL(ea.ParsedAddress,ea.Address) = bc.EmailAddress AND ea.AddressTypeID = 3 -- Only EMAIL
		 WHERE bc.ProcessedInd = 0;
		 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to read Beam rows for PreProcessing.Beam_Customer table.';
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
					, CreatedDate                   AS SourceCreatedDate
					, LastModifiedDate              AS SourceModifiedDate
					, @vBeamInformationSourceID     AS InformationSourceID
					, EmailAddress                  AS EmailAddress
					, FirstName                     AS FirstName
					, LastName                      AS LastName
				FROM #BeamData2Process tmp 
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
				, EmailAddress
				, FirstName
				, LastName) 
			ON (TARGET.IndividualID = SOURCE.IndividualID) 
		  WHEN MATCHED 
		    AND TARGET.LastModifiedDate < SOURCE.LastModifiedDate
			AND (TARGET.FirstName != SOURCE.FirstName OR 
			     TARGET.LastName  != SOURCE.LastName)  THEN
		      UPDATE SET [FirstName]           = ISNULL(SOURCE.FirstName, TARGET.FirstName),
						 [LastName]            = ISNULL(SOURCE.LastName , TARGET.Lastname),
						 [LastModifiedBy]      = SOURCE.LastModifiedBy,
						 [LastModifiedDate]    = SOURCE.LastModifiedDate,
						 [SourceModifiedDate]  = SOURCE.SourceModifiedDate,
						 [InformationSourceID] = SOURCE.InformationSourceID
		  WHEN NOT MATCHED THEN
			  INSERT 
				( [CreatedDate]
				, [CreatedBy]
				, [LastModifiedDate]
				, [LastModifiedBy]
				, [SourceCreatedDate]
				, [SourceModifiedDate]
				, [InformationSourceID]
				, [FirstName]
				, [LastName])
			  VALUES 
			   ( SOURCE.CreatedDate
			   , SOURCE.CreatedBy
			   , SOURCE.LastModifiedDate
			   , SOURCE.LastModifiedBy
			   , SOURCE.SourceCreatedDate
			   , SOURCE.SourceModifiedDate
			   , SOURCE.InformationSourceID
			   , SOURCE.FirstName
			   , SOURCE.LastName)
			OUTPUT INSERTED.IndividualID, SOURCE.EmailAddress
			INTO @ProcessedValues (ID, Email);

		/* Updating source temporary table to populate new individual ids */
		SET @StepName = 'Updating source temporary table to populate new individual ids';
		UPDATE bd
		   SET IndividualID =  ii.ID
		     , ProcessedInd = 1
		  FROM #BeamData2Process bd
		 INNER JOIN @ProcessedValues ii ON ii.Email = bd.EmailAddress;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals from Beam';
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
			SELECT DISTINCT 'Beam'                  AS Name
				 , 'Beam - Multimedia'              AS Description
				 , @vTodayTimestamp                 AS CreatedDate
				 , @DataImportDetailID              AS CreatedBy
				 , @vTodayTimestamp                 AS LastModifiedDate
				 , @DataImportDetailID              AS LastModifiedBy
				 , @vBeamInformationSourceID        AS InformationSourceID
				 , bd.LastModifiedDate              AS SourceChangeDate
				 , bd.EmailAddress                  AS EmailAddress
				 , @vEmailAddressTypeID             AS AddressTypeID
				 , 1                                AS PrimaryInd
				 , 1                                AS UsedInCommunicationInd
				 , bd.IndividualID                  AS IndividualID
				 , Staging.VT_HASH(bd.EmailAddress) AS HashedAddress
				 , NEWID()                          AS EncryptedAddress
			  FROM #BeamData2Process bd
			  WHERE bd.RowType = 'NEW_INDIVIDUAL'
			    AND bd.IsLatest = 1;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals Electronic Addresses from Beam';
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
			SELECT 'Beam - Multimedia'        AS Description
				 , @vTodayTimestamp           AS CreatedDate
				 , @DataImportDetailID        AS CreatedBy
				 , @vTodayTimestamp           AS LastModifiedDate
				 , @DataImportDetailID        AS LastModifiedBy
				 , bd.IndividualID            AS IndividualID
				 , @vBeamInformationSourceID  AS InformationSourceID
				 , 0                          AS IsVerifiedInd
				 , 0                          AS IsParentInd
			  FROM #BeamData2Process bd
			 WHERE bd.RowType = 'NEW_INDIVIDUAL'
			   AND bd.IsLatest = 1;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals into Staging.STG_KeyMapping table from Beam';
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
		USING (SELECT bd.IndividualID     AS IndividualID
					, @vBeamPrefernceID   AS PreferenceID
					, @vBeamChannelID     AS ChannelID
					, bd.LastModifiedDate AS LastModifiedDate
					, bd.OptIn            AS OptInValue
				 FROM #BeamData2Process bd
				WHERE bd.RowType <> 'EXISTING_CUSTOMER'
			     AND bd.IsLatest = 1 ) 
				AS SOURCE ( IndividualID , PreferenceID , ChannelID, LastModifiedDate, OptInValue )  
			ON (TARGET.IndividualID = SOURCE.IndividualID 
			AND TARGET.PreferenceID = SOURCE.PreferenceID
			AND TARGET.ChannelID    = SOURCE.ChannelID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.LastModifiedDate THEN
				UPDATE SET [Value]            = SOURCE.OptInValue,
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
					   , SOURCE.OptInValue
					   , @DataImportDetailID
					   , SOURCE.LastModifiedDate
					   , @DataImportDetailID
					   , SOURCE.LastModifiedDate)
			OUTPUT INSERTED.IndividualID
			INTO @ProcessedValues (ID);

		/* Updating source temporary table to populate new individual ids */
		UPDATE sc
		   SET ProcessedInd = 1
		  FROM #BeamData2Process sc
		 INNER JOIN @ProcessedValues ii ON ii.ID = sc.IndividualID;
		 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		--SELECT @ErrorMsg = 'Unable to insert Individual Preferences from Beam';
		SET @ErrorMsg = ERROR_MESSAGE();
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting or Updating Customer Preferences for Email channel
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		SET @StepName = 'Inserting Customer Preferences';

		MERGE Staging.STG_CustomerPreference AS TARGET  
		USING (SELECT bd.CustomerID       AS CustomerID
					, @vBeamPrefernceID   AS PreferenceID
					, @vBeamChannelID     AS ChannelID
					, bd.LastModifiedDate AS LastModifiedDate
					, bd.OptIn            AS OptInValue
				 FROM #BeamData2Process bd
				WHERE bd.RowType = 'EXISTING_CUSTOMER'
  			      AND bd.IsLatest = 1) 
				AS SOURCE ( CustomerID , PreferenceID , ChannelID, LastModifiedDate, OptInValue )  
			ON (TARGET.CustomerID   = SOURCE.CustomerID 
			AND TARGET.PreferenceID = SOURCE.PreferenceID
			AND TARGET.ChannelID    = SOURCE.ChannelID) 
			WHEN MATCHED AND TARGET.LastModifiedDate < SOURCE.LastModifiedDate THEN
				UPDATE SET [Value]            = SOURCE.OptInValue,
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
					   , SOURCE.OptInValue
					   , @DataImportDetailID
					   , SOURCE.LastModifiedDate
					   , @DataImportDetailID
					   , SOURCE.LastModifiedDate)
			OUTPUT INSERTED.CustomerID
			INTO @ProcessedValues (id);

		/* Updating source temporary table to populate new individual ids */
		UPDATE sc
		   SET ProcessedInd = 1
		  FROM #BeamData2Process sc
		 INNER JOIN @ProcessedValues ii ON ii.id = sc.CustomerID;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert Customer Preferences from Beam';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Update PreProcessing.*/
	BEGIN TRY
		SET @StepName = 'Update PreProcessing.Beam_Customer';

		UPDATE bc
		   SET ProcessedInd = 1
		  FROM PreProcessing.Beam_Customer bc
		 INNER JOIN #BeamData2Process tmp ON tmp.Beam_CustomerID = bc.Beam_CustomerID
		 WHERE tmp.ProcessedInd = 1;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to update PreProcessing.Beam_Customer table';
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
