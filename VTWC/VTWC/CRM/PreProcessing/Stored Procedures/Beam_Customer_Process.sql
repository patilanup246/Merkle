CREATE PROCEDURE [PreProcessing].[Beam_Customer_Process]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @now                                 DATETIME
	DECLARE @successcountimport                  INTEGER = 0
	DECLARE @errorcountimport                    INTEGER = 0

	DECLARE @dataimporttypeid                    INTEGER
	DECLARE @dataimportlogid                     INTEGER
	DECLARE @operationalstatusid                 INTEGER

	DECLARE @defaultoptinleisure                 INTEGER
	DECLARE @defaultoptincorporate               INTEGER
	DECLARE @subscriptionchanneltypeidleisure    INTEGER
	DECLARE @subscriptionchanneltypeidcorp       INTEGER
	DECLARE @addresstypeidemail                  INTEGER
	DECLARE @addresstypeidmobile                 INTEGER
	DECLARE @addresstypeidbeamvisitor            INTEGER
	DECLARE @marketingoptin                      BIT     = 0
	DECLARE @sourcecreateddate                   DATETIME

	DECLARE @informationsourceid                 INTEGER
	DECLARE @promotionsegmentdefinitionid        INTEGER

	DECLARE @beamcustomerid                      INTEGER
	DECLARE @beamvisitorid                       NVARCHAR(256)

    DECLARE @emailaddress                        NVARCHAR(100)
    DECLARE @customerid                          INTEGER
	DECLARE @individualid                        INTEGER
	DECLARE @firstname                           NVARCHAR(256)
	DECLARE @lastname                            NVARCHAR(256)


	DECLARE @parsedaddressemail                  NVARCHAR(256) = NULL
	DECLARE @parsedindemail                      BIT           = 0
	DECLARE @parsedscoreemail                    INTEGER       = 0

	DECLARE @electronicaddressid                 INTEGER
	DECLARE @recordcount                         INTEGER

	DECLARE @spname                              NVARCHAR(256)
	DECLARE @logtimingidnew                      INTEGER
	DECLARE @logmessage                          NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    --Initiate import logging details
    IF @dataimportdetailid IS NULL
	BEGIN
	    SELECT @operationalstatusid = OperationalStatusID
	    FROM   Reference.OperationalStatus
	    WHERE  Name = 'Processing'

	    SELECT @dataimporttypeid = DataImportTypeID
	    FROM   [Reference].[DataImportType]
	    WHERE  Name = 'Beam'
    
	    EXEC @dataimportlogid = [Operations].[DataImportLog_Add] @userid           = 0,
	                                                             @dataimporttypeid = @dataimporttypeid

        UPDATE Operations.DataImportLog
	    SET   OperationalStatusID = @operationalstatusid
	    WHERE DataImportLogID   = @dataimportlogid
	    AND   DataImportTypeID  = @dataimporttypeid

        SELECT @dataimportdetailid = DataImportDetailID
        FROM   Operations.DataImportDetail
        WHERE  DataImportLogID = @dataimportlogid
    
    	IF @dataimportdetailid IS NULL OR @dataimportdetailid !> 0
    	BEGIN
	        SET @logmessage = 'No or invalid data import log reference.' + ISNULL(CAST(@dataimportdetailid AS NVARCHAR(256)),'NULL') 
	    
		    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                          @logsource       = @spname,
				    							  @logmessage      = @logmessage,
					    						  @logmessagelevel = 'ERROR',
						    					  @messagetypecd   = NULL
            RETURN
        END	

        UPDATE PreProcessing.Beam_Customer
	    SET    DataImportDetailID = @dataimportdetailid
	    WHERE  DataImportDetailID IS NULL
		AND    ParsedEmailInd = 1
    END

	--Get reference information

	SELECT @promotionsegmentdefinitionid = PromotionSegmentDefinitionID
	FROM   [Reference].[PromotionSegmentDefinition]
	WHERE  Name = 'Beam Customer Visits'
	
	SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Beam'

    SELECT @addresstypeidemail = AddressTypeID
	FROM   [Reference].[AddressType]
	WHERE  Name = 'Email'

	SELECT @addresstypeidmobile = AddressTypeID
	FROM   [Reference].[AddressType]
	WHERE  Name = 'Mobile'

	SELECT @addresstypeidbeamvisitor = AddressTypeID
	FROM   [Reference].[AddressType]
	WHERE  Name = 'Beam Visitor ID'

    SELECT @defaultoptinleisure = SubscriptionTypeID
    FROM   [Reference].[SubscriptionType]
    WHERE  Name = [Reference].[Configuration_GetSetting] ('Migration','Default Leisure Subscription Type')

	SELECT @defaultoptincorporate = SubscriptionTypeID
	FROM   [Reference].[SubscriptionType]
	WHERE  Name = [Reference].[Configuration_GetSetting] ('Migration','Default Corporate Subscription Type')

	SELECT @subscriptionchanneltypeidleisure = SubscriptionChannelTypeID
	FROM   Reference.SubscriptionChannelType a,
	       Reference.SubscriptionType b,
	 	   Reference.ChannelType c
	WHERE  a.SubscriptionTypeID = b.SubscriptionTypeID
	AND    a.ChannelTypeID      = c.ChannelTypeID
	AND    b.SubscriptionTypeID = @defaultoptinleisure
	AND    c.Name = 'Email'

	SELECT @subscriptionchanneltypeidcorp = SubscriptionChannelTypeID
	FROM   Reference.SubscriptionChannelType a,
	       Reference.SubscriptionType b,
	 	   Reference.ChannelType c
	WHERE  a.SubscriptionTypeID = b.SubscriptionTypeID
	AND    a.ChannelTypeID = c.ChannelTypeID
	AND    b.SubscriptionTypeID = @defaultoptincorporate
	AND    c.Name = 'Email'

	IF @informationsourceid                 IS NULL
	   OR @addresstypeidemail               IS NULL
	   OR @addresstypeidbeamvisitor         IS NULL
	   OR @defaultoptincorporate            IS NULL
	   OR @defaultoptinleisure              IS NULL
	   OR @subscriptionchanneltypeidleisure IS NULL
	   OR @subscriptionchanneltypeidcorp    IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid reference information.' +
		                  ' @informationsourceid =  '                + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') +
						  ', @addresstypeidemail =  '                + ISNULL(CAST(@addresstypeidemail AS NVARCHAR(256)),'NULL') +
						  ', @addresstypeidbeamvisitor = '           + ISNULL(CAST(@addresstypeidbeamvisitor AS NVARCHAR(256)),'NULL') +
						  ', @defaultoptincorporate = '              + ISNULL(CAST(@defaultoptincorporate AS NVARCHAR(256)),'NULL') +
						  ', @defaultoptinleisure   = '              + ISNULL(CAST(@defaultoptinleisure AS NVARCHAR(256)),'NULL') +
						  ', @subscriptionchanneltypeidleisure   = ' + ISNULL(CAST(@subscriptionchanneltypeidleisure AS NVARCHAR(256)),'NULL') +
						  ', @subscriptionchanneltypeidcorp   = '    + ISNULL(CAST(@subscriptionchanneltypeidcorp AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

	SELECT @now = GETDATE()

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

    --First see if existing customer

    EXEC [PreProcessing].[Check_For_Customer] @userid = 0,
	                                          @tablename = 'Beam_Customer',
	                                          @dataimportdetailid = @dataimportdetailid

    --Update their opt-in status

	DECLARE Customers CURSOR READ_ONLY
	FOR
	    SELECT Beam_CustomerID
		      ,VisitorID
		      ,CustomerID
		      ,OptIn
			  ,CreatedDate
		FROM   PreProcessing.Beam_Customer
		WHERE  DataImportDetailID = @dataimportdetailid
		AND    ProcessedInd       = 0
		AND    MatchedInd         = 1
		AND    CustomerID IS NOT NULL
		AND    CreatedDate IS NOT NULL
		ORDER BY CreatedDate

		OPEN Customers

		FETCH NEXT FROM Customers
		    INTO @beamcustomerid
			    ,@beamvisitorid
			    ,@customerid
				,@marketingoptin
				,@sourcecreateddate

		WHILE @@FETCH_STATUS = 0
        BEGIN
			
		    --EXEC [Staging].[STG_CustomerSubscriptionPreference_Update] @userid                    = @userid,   
	     --                                                              @informationsourceid       = @informationsourceid,
	     --                                                              @customerid                = @customerid,
	     --                                                              @sourcechangedate          = @sourcecreateddate,
	     --                                                              @archivedind               = 0,
	     --                                                              @subscriptionchanneltypeid = @subscriptionchanneltypeidleisure,
	     --                                                              @optinind                  = @marketingoptin,
      --                                                                 @recordcount               = @recordcount OUTPUT

            --Ensure the Visitor ID is recorded if not primary

            IF NOT EXISTS (SELECT 1
			               FROM  [Staging].[STG_ElectronicAddress]
				           WHERE AddressTypeID = @addresstypeidbeamvisitor
				           AND   CustomerID    = @customerid
				           AND   PrimaryInd    = 1
						   AND   Address       = @beamvisitorid)
			BEGIN
			    EXEC [Staging].[STG_ElectronicAddress_Update] @userid              = 0,   
	                                                          @informationsourceid = @informationsourceid,
	                                                          @customerid          = @customerid,
	                                                          @sourcemodifeddate   = @sourcecreateddate,
	                                                          @address             = @beamvisitorid,
	                                                          @parsedaddress       = NULL,
	                                                          @parsedind           = 0,
	                                                          @parsedscore         = 0,
	                                                          @addresstypeid       = @addresstypeidbeamvisitor,
	                                                          @archivedind         = 0,
	                                                          @recordcount         = @recordcount OUTPUT
            END

            FETCH NEXT FROM Customers
		        INTO @beamcustomerid
			        ,@beamvisitorid
			        ,@customerid
				    ,@marketingoptin
				    ,@sourcecreateddate
        END

		CLOSE Customers

    DEALLOCATE Customers

    --Next are they existing individual

    EXEC [PreProcessing].[Check_For_Individual] @userid = 0,
	                                            @tablename = 'Beam_Customer',
	                                            @dataimportdetailid = @dataimportdetailid

    --Update their opt-in status

	DECLARE Individuals CURSOR READ_ONLY
	FOR
	    SELECT Beam_CustomerID
		      ,VisitorID
			  ,IndividualID
		      ,OptIn
			  ,CreatedDate
		FROM   PreProcessing.Beam_Customer
		WHERE  DataImportDetailID = @dataimportdetailid
		AND    ProcessedInd       = 0
		AND    MatchedInd         = 1
		AND    IndividualID IS NOT NULL
		AND    CreatedDate IS NOT NULL
		ORDER BY CreatedDate

		OPEN Individuals

		FETCH NEXT FROM Individuals
		    INTO @beamcustomerid
			    ,@beamvisitorid
			    ,@individualid
				,@marketingoptin
				,@sourcecreateddate

		WHILE @@FETCH_STATUS = 0
        BEGIN
		    EXEC [Staging].[STG_IndividualSubscriptionPreference_Update] @userid                    = @userid,   
	                                                                     @informationsourceid       = @informationsourceid,
	                                                                     @individualid              = @individualid,
	                                                                     @sourcechangedate          = @sourcecreateddate,
	                                                                     @archivedind               = 0,
	                                                                     @subscriptionchanneltypeid = @subscriptionchanneltypeidleisure,
	                                                                     @optinind                  = @marketingoptin,
                                                                         @recordcount               = @recordcount OUTPUT

            --Ensure the Visitor ID is recorded

            IF NOT EXISTS (SELECT 1
			               FROM  [Staging].[STG_ElectronicAddress]
				           WHERE AddressTypeID = @addresstypeidbeamvisitor
				           AND   IndividualID  = @individualid
				           AND   PrimaryInd    = 1
						   AND   Address       = @beamvisitorid)
			BEGIN
			    EXEC [Staging].[STG_ElectronicAddress_Update] @userid              = 0,   
	                                                          @informationsourceid = @informationsourceid,
	                                                          @individualid        = @individualid,
	                                                          @sourcemodifeddate   = @sourcecreateddate,
	                                                          @address             = @beamvisitorid,
	                                                          @parsedaddress       = NULL,
	                                                          @parsedind           = 0,
	                                                          @parsedscore         = 0,
	                                                          @addresstypeid       = @addresstypeidbeamvisitor,
	                                                          @archivedind         = 0,
	                                                          @recordcount         = @recordcount OUTPUT
            END

            FETCH NEXT FROM Individuals
		        INTO @beamcustomerid
				    ,@beamvisitorid
			        ,@individualid
				    ,@marketingoptin
				    ,@sourcecreateddate
        END

		CLOSE Individuals

    DEALLOCATE Individuals

    --For those not matched, add as Prospects

    DECLARE Prospects CURSOR READ_ONLY
	FOR 
	    SELECT Beam_CustomerID,
		       VisitorID,
			   EMailAddress,
			   OptIn,
			   FirstName,
			   LastName,
			   CreatedDate,
			   ParsedAddressEmail,
			   ParsedEmailInd,
			   ParsedEmailScore
		FROM   PreProcessing.Beam_Customer
		WHERE  DataImportDetailID = @dataimportdetailid
		AND    ProcessedInd       = 0
		AND    MatchedInd         = 0
		AND    ParsedEmailScore   > 0
		AND    ProfanityInd       = 0
		AND    CreatedDate IS NOT NULL
		ORDER BY CreatedDate

		OPEN Prospects

		FETCH NEXT FROM Prospects
		    INTO @beamcustomerid,
			     @beamvisitorid,
			     @emailaddress,
				 @marketingoptin,
				 @firstname,
				 @lastname,
				 @sourcecreateddate,
				 @parsedaddressemail,
				 @parsedindemail,
				 @parsedscoreemail
				 
		WHILE @@FETCH_STATUS = 0
        BEGIN

		    --Additional check to cater for multiple records with the same email address in batch process

			IF NOT EXISTS (SELECT 1
			               FROM Staging.STG_ElectronicAddress
						   WHERE PrimaryInd = 1
						   AND   ParsedAddress = @parsedaddressemail)
            BEGIN

		        EXEC [Staging].[STG_Individual_Add] @userid              = @userid,   
		                                            @informationsourceid = @informationsourceid,
		                                            @sourcecreateddate   = @now,
		                                            @sourcemodifieddate  = @now,
		                                            @archivedind         = 0,
		                                            @salutation          = NULL,
		                                            @firstname           = @firstname,
		                                            @middlename          = NULL,
		                                            @lastname            = @lastname,
		                                            @datefirstpurchase   = NULL,
		                                            @individualid        = @individualid OUTPUT

                IF @individualid IS NOT NULL AND @individualid > 0
			    BEGIN
			    --Email first
			    
				    IF @emailaddress IS NOT NULL
				    BEGIN

				        EXEC [Staging].[STG_IndividualElectronicAddress_Add] @userid              = @userid,   
	                                                                         @informationsourceid = @informationsourceid,
	                                                                         @individualid        = @individualid,
	                                                                         @sourcemodifeddate   = @sourcecreateddate,
	                                                                         @address             = @emailaddress,
	                                                                         @parsedaddress       = @parsedaddressemail,
	                                                                         @parsedind           = @parsedindemail,
	                                                                         @parsedscore         = @parsedscoreemail,
	                                                                         @addresstypeid       = @addresstypeidemail,
	                                                                         @archivedind         = 0,
	                                                                         @electronicaddressid =  @electronicaddressid OUTPUT
                        END

                END
            END
			
			EXEC [Staging].[STG_IndividualSubscriptionPreference_Update] @userid                    = 0,   
	                                                                     @informationsourceid       = @informationsourceid,
	                                                                     @individualid              = @individualid,
	                                                                     @sourcechangedate          = @sourcecreateddate,
	                                                                     @archivedind               = 0,
	                                                                     @subscriptionchanneltypeid = @subscriptionchanneltypeidleisure,
	                                                                     @optinind                  = @marketingoptin,
	                                                                     @starttime                 = @now,
	                                                                     @endtime                   = NULL,
	                                                                     @daysofweek                = NULL,
	                                                                     @recordcount               = @recordcount OUTPUT	

            --Beam Visitor ID
				
			IF @beamvisitorid IS NOT NULL
			BEGIN
				EXEC [Staging].[STG_IndividualElectronicAddress_Add] @userid              = @userid,   
	                                                                 @informationsourceid = @informationsourceid,
	                                                                 @individualid        = @individualid,
	                                                                 @sourcemodifeddate   = @sourcecreateddate,
	                                                                 @address             = @beamvisitorid,
	                                                                 @parsedaddress       = NULL,
	                                                                 @parsedind           = 0,
	                                                                 @parsedscore         = 0,
	                                                                 @addresstypeid       = @addresstypeidbeamvisitor,
	                                                                 @archivedind         = 0,
	                                                                 @electronicaddressid =  @electronicaddressid OUTPUT
            END

            UPDATE PreProcessing.Beam_Customer
			SET    IndividualID = @individualid
			WHERE  Beam_CustomerID = @beamcustomerid


		    FETCH NEXT FROM Prospects
		        INTO @beamcustomerid,
			         @beamvisitorid,
			         @emailaddress,
				     @marketingoptin,
					 @firstname,
				     @lastname,
				     @sourcecreateddate,
				     @parsedaddressemail,
				     @parsedindemail,
				     @parsedscoreemail
        END

	    CLOSE Prospects
     
	DEALLOCATE Prospects

	--Populate Production.PromotionSegmentationCustomer

    INSERT INTO [Production].[PromotionSegmentCustomer]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[PromotionSegmentDefinitionID]
           ,[CustomerID]
           ,[InformationSourceID]
           ,[ExtReference]
           ,[SourceCreatedDate])
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
           ,@promotionsegmentdefinitionid
           ,a.CustomerID
           ,@informationsourceid
           ,a.VisitorID
           ,a.CreatedDate
    FROM PreProcessing.Beam_Customer a
	LEFT JOIN [Production].[PromotionSegmentCustomer] b ON  a.CustomerID  = b.CustomerID
	                                                    AND a.VisitorID   = b.ExtReference
														AND a.CreatedDate = b.SourceCreatedDate
	WHERE b.PromotionSegmentDefinitionID IS NULL
	AND   a.CustomerID IS NOT NULL
	AND   a.MatchedInd = 1
	AND   a.ProcessedInd = 0	
	AND   a.DataImportDetailID = @dataimportdetailid
	GROUP BY a.CustomerID
	        ,a.VisitorID
			,a.CreatedDate

	--Mark those records as processed 

	UPDATE a
	SET   ProcessedInd = 1
	FROM  PreProcessing.Beam_Customer a
	INNER JOIN [Production].[PromotionSegmentCustomer] b  ON a.CustomerID  = b.CustomerID
	                                                     AND a.VisitorID   = b.ExtReference
														 AND a.CreatedDate = b.SourceCreatedDate
    WHERE a.ProcessedInd = 0
	AND   a.DataImportDetailID = @dataimportdetailid

	--Populate Production.PromotionSegmentationIndividual

	INSERT INTO [Production].[PromotionSegmentIndividual]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[PromotionSegmentDefinitionID]
           ,[IndividualID]
           ,[InformationSourceID]
           ,[ExtReference]
           ,[SourceCreatedDate])
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
           ,@promotionsegmentdefinitionid
           ,a.IndividualID
           ,@informationsourceid
           ,a.VisitorID
           ,a.CreatedDate
    FROM PreProcessing.Beam_Customer a
	LEFT JOIN [Production].[PromotionSegmentIndividual] b ON  a.IndividualID = b.IndividualID
	                                                      AND a.VisitorID    = b.ExtReference
														  AND a.CreatedDate  = b.SourceCreatedDate
	WHERE b.PromotionSegmentDefinitionID IS NULL
	AND   a.IndividualID IS NOT NULL
	AND   a.ProcessedInd = 0	
	AND   a.DataImportDetailID = @dataimportdetailid

	--Mark those records as processed 

	UPDATE a
	SET   ProcessedInd = 1
	FROM  PreProcessing.Beam_Customer a
	INNER JOIN [Production].[PromotionSegmentIndividual] b ON  a.IndividualID = b.IndividualID
	                                                       AND a.VisitorID    = b.ExtReference
														   AND a.CreatedDate  = b.SourceCreatedDate
    WHERE a.ProcessedInd = 0
	AND   a.DataImportDetailID = @dataimportdetailid

	--Update logs

    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.Beam_Customer
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.Beam_Customer
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = NULL,
	                                            @endtimeimport         = @now,
	                                            @totalcountimport      = @recordcount,
	                                            @successcountimport    = @successcountimport,
	                                            @errorcountimport      = @errorcountimport

    SELECT @operationalstatusid = OperationalStatusID
	FROM   Reference.OperationalStatus
	WHERE  Name = 'Completed'

	UPDATE Operations.DataImportLog
	SET   OperationalStatusID = @operationalstatusid
	WHERE DataImportLogID   = @dataimportlogid
	AND   DataImportTypeID  = @dataimporttypeid


    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END