/*===========================================================================================
Name:			Staging.STG_RailblazerEvolvi_Add
Purpose:		Flag customers provided by Railblazers (Evolvi) process as not contactable.
Parameters:		@userid - The key for the user executing the proc.
				@pDataImportDetailID - Unique ID for the data that we want to load
				@PkgExecKey The key for identifying package which ran the procedure
Notes:			 
			
Created:		2018-09-17	Juanjo Diaz (jdiaz@merkleinc.com)
Modified:		
Peer Review:	
Call script:	EXEC Staging.STG_RailblazerEvolvi_Add @userid, @PkgExecKey, @DataImportDetailID
=================================================================================================*/
CREATE PROCEDURE [Staging].[STG_RailblazerEvolvi_Add]
(
	@userid              INTEGER = 0,
	@PkgExecKey          INTEGER = -1,
	@DataImportDetailID  INTEGER

) 
AS
BEGIN TRY
	BEGIN TRAN
    SET NOCOUNT ON;

	/* Variables */
	DECLARE @InsertedIndividuals TABLE(IndividualID INT, Email VARCHAR(256));
	DECLARE @vEvolviInformationSourceID INT;
	DECLARE @vGeneralMarketingPreferenceID INT;
	DECLARE @vOptOutTrue BIT = 1;
	DECLARE @vTodayTimestamp DATETIME = GETDATE();
	DECLARE @vEmailAddressTypeID INT;

	DECLARE @ErrorMsg		NVARCHAR(MAX);
	DECLARE @ErrorNum		INTEGER;
	DECLARE @Procname       NVARCHAR(MAX);
	DECLARE @StepName       NVARCHAR(MAX);
	
	/* Gather basic data to run this process*/
	BEGIN TRY
		SET @StepName = 'Gather basic data to run this process';
		-- Setting stored procedure name for logging
		SET @ProcName = 'Staging.STG_RailblazerEvolvi_Add';

		-- Information Source ID for Evolvi
		SELECT @vEvolviInformationSourceID = iso.InformationSourceID 
		  FROM Reference.InformationSource iso WITH (NOLOCK)
		 WHERE iso.Name = 'Evolvi';
	
		-- Preference ID for General Marketing Opt-In
		SELECT @vGeneralMarketingPreferenceID = p.PreferenceID       
		  FROM Reference.Preference p WITH (NOLOCK)
		 WHERE p.Name = 'General marketing Opt-In';

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
	
	/* Detect when a Railblazer (Evolvi) user is a new customer or individual */
	BEGIN TRY
		
		SET @StepName = 'Detect when a Railblazer (Evolvi) user is a new customer or individual';

		DROP TABLE IF EXISTS #RailblazerEvolvi;

		SELECT CASE
				  WHEN ea.ElectronicAddressID IS NULL THEN
					'NEW_INDIVIDUAL'
				  WHEN ea.CustomerID IS NOT NULL THEN 
					'EXISTING_CUSTOMER'
				  WHEN ea.IndividualID IS NOT NULL THEN
					'EXISTING_INDIVIDUAL'
				  ELSE
					'UNKNOWN'
				END RowType,
				ea.IndividualID,
				ea.CustomerID,
				rd.Email,
				rd.Title,
				rd.FirstName,
				rd.Surname,
				rd.DateReceived,
				rd.ProcessedInd
		  INTO #RailblazerEvolvi 
		  FROM PreProcessing.Railblazers_Data rd
		  LEFT JOIN Staging.STG_ElectronicAddress ea ON rd.Email = ea.Address AND ea.AddressTypeID = @vEmailAddressTypeID
		 WHERE rd.DataImportDetailID = @DataImportDetailID
		   AND rd.ProcessedInd = 0; -- Not processed
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to read Railblazer (Evolvi) rows for processing.';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH


	/* Inserting new individuals */
	BEGIN TRY
		SET @StepName = 'Inserting new individuals into Staging.STG_Individual table';
		MERGE INTO [Staging].[STG_Individual] AS TARGET
		USING (SELECT -99 AS IndividualID 
					, @vTodayTimestamp            AS CreatedDate
					, @DataImportDetailID         AS CreatedBy
					, @vTodayTimestamp            AS LastModifiedDate
					, @DataImportDetailID         AS LastModifiedBy
					, tmp.DateReceived            AS SourceCreatedDate
					, tmp.DateReceived            AS SourceModifiedDate
					, @vEvolviInformationSourceID AS InformationSourceID
					, tmp.Title                   AS Salutation
					, tmp.FirstName               AS FirstName
					, tmp.Surname                 AS LastName
					, tmp.Email                   AS Email
				FROM #RailblazerEvolvi tmp 
				WHERE RowType = 'NEW_INDIVIDUAL') AS SOURCE
				( IndividualID
				, CreatedDate
				, CreatedBy
				, LastModifiedDate
				, LastModifiedBy
				, SourceCreatedDate
				, SourceModifiedDate
				, InformationSourceID
				, Salutation
				, FirstName
				, LastName
				, Email ) 
		   ON (TARGET.IndividualID = SOURCE.IndividualID) 
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
			, [LastName])
		  VALUES 
		   ( SOURCE.CreatedDate
		   , SOURCE.CreatedBy
		   , SOURCE.LastModifiedDate
		   , SOURCE.LastModifiedBy
		   , SOURCE.SourceCreatedDate
		   , SOURCE.SourceModifiedDate
		   , SOURCE.InformationSourceID
		   , SOURCE.Salutation
		   , SOURCE.FirstName
		   , SOURCE.LastName)
		OUTPUT INSERTED.IndividualID, SOURCE.Email
		INTO @InsertedIndividuals (IndividualID, Email);

		/* Updating source temporary table to populate new individual ids */
		UPDATE rb
		   SET IndividualID =  ii.IndividualID
		 FROM #RailblazerEvolvi rb 
		 INNER JOIN @InsertedIndividuals ii ON ii.Email = rb.Email;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals from Railblazer (Evolvi)';
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
			SELECT DISTINCT 'Evolvi'           AS Name
				 , 'Railblazer (Evolvi) exclusion' AS Description
				 , @vTodayTimestamp            AS CreatedDate
				 , @DataImportDetailID         AS CreatedBy
				 , @vTodayTimestamp            AS LastModifiedDate
				 , @DataImportDetailID         AS LastModifiedBy
				 , @vEvolviInformationSourceID AS InformationSourceID
				 , rb.DateReceived             AS SourceChangeDate
				 , rb.Email                    AS Address
				 , @vEmailAddressTypeID        AS AddressTypeID
				 , 1                           AS PrimaryInd
				 , 0                           AS UsedInCommunicationInd
				 , rb.IndividualID             AS IndividualID
				 , Staging.VT_HASH(rb.Email)   AS HashedAddress
				 , NEWID()                     AS EncryptedAddress
			  FROM #RailblazerEvolvi rb
			  WHERE rb.RowType = 'NEW_INDIVIDUAL';

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals Electronic Addresses from Railblazer (Evolvi)';
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
			SELECT 'Railblazer (Evolvi) exclusion' AS Description
				 , @vTodayTimestamp                AS CreatedDate
				 , @DataImportDetailID             AS CreatedBy
				 , @vTodayTimestamp                AS LastModifiedDate
				 , @DataImportDetailID             AS LastModifiedBy
				 , rb.IndividualID                 AS IndividualID
				 , @vEvolviInformationSourceID     AS InformationSourceID
				 , 0                               AS IsVerifiedInd
				 , 0                               AS IsParentInd
			  FROM #RailblazerEvolvi rb
			 WHERE rb.RowType = 'NEW_INDIVIDUAL';
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert new Individuals into Staging.STG_KeyMapping table from Railblazer (Evolvi)';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting or Updating Individual Preferences for all channels except 'None' channel.
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		SET @StepName = 'Inserting Individual Preferences';

		MERGE Staging.STG_IndividualPreference AS TARGET  
		USING (SELECT rb.IndividualID                AS IndividualID
					, @vGeneralMarketingPreferenceID AS PreferenceID
					, c.ChannelID                    AS ChannelID
				 FROM #RailblazerEvolvi rb
				CROSS JOIN Reference.Channel c
				WHERE c.Name <> 'None'
				  AND rb.CustomerID IS NULL) 
				AS SOURCE ( IndividualID , PreferenceID , ChannelID )  
			ON (TARGET.IndividualID = SOURCE.IndividualID 
			AND TARGET.PreferenceID = SOURCE.PreferenceID
			AND TARGET.ChannelID    = SOURCE.ChannelID) 
			WHEN MATCHED THEN
				UPDATE SET [Value]            = @vOptOutTrue,
						   [LastModifiedDate] = @vTodayTimestamp,
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
					   , @vOptOutTrue
					   , @DataImportDetailID
					   , @vTodayTimestamp
					   , @DataImportDetailID
					   , @vTodayTimestamp);
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @ErrorMsg = 'Unable to insert Individual Preferences from Railblazer (Evolvi)';
		SET @ErrorNum = ERROR_NUMBER();
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;			
		THROW 51403, @ErrorMsg, 1; 
	END CATCH

	/* Inserting or Updating Customer Preferences for all channels except 'None' channel.
	   Using MERGE to manage INSERTS & UPDATES */
	BEGIN TRY
		SET @StepName = 'Inserting Customer Preferences';
		MERGE Staging.STG_CustomerPreference AS TARGET  
		USING (SELECT rb.CustomerID                  AS CustomerID
					, @vGeneralMarketingPreferenceID AS PreferenceID
					, c.ChannelID                    AS ChannelID
				 FROM #RailblazerEvolvi rb
				CROSS JOIN Reference.Channel c
				WHERE c.Name <> 'None'
				  AND rb.CustomerID IS NOT NULL) 
				AS SOURCE ( CustomerID , PreferenceID , ChannelID )  
			ON (TARGET.CustomerID   = SOURCE.CustomerID 
			AND TARGET.PreferenceID = SOURCE.PreferenceID
			AND TARGET.ChannelID    = SOURCE.ChannelID) 
			WHEN MATCHED THEN
				UPDATE SET [Value]            = @vOptOutTrue,
						   [LastModifiedDate] = @vTodayTimestamp,
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
					   , @vOptOutTrue
					   , @DataImportDetailID
					   , @vTodayTimestamp
					   , @DataImportDetailID
					   , @vTodayTimestamp);
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN;
			SELECT @ErrorMsg = 'Unable to insert Customer Preferences from Railblazer (Evolvi)';
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
