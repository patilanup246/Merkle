

CREATE PROCEDURE [Production].[Customer_Insert] (@userid INTEGER = 0)
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @addresstypidemail INTEGER;
        DECLARE @addresstypidmobile INTEGER;
        DECLARE @countryiduk INTEGER;
        DECLARE @defaultoptinleisure INTEGER;
        DECLARE @defaultoptincorporate INTEGER;

        DECLARE @today DATE;

        DECLARE @spname NVARCHAR(256);
        DECLARE @recordcount INTEGER;
        DECLARE @logtimingidnew INTEGER;
        DECLARE @logmessage NVARCHAR(MAX);

        SELECT  @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.'
                + OBJECT_NAME(@@PROCID);

	--Log start time--

        EXEC [Operations].[LogTiming_Record] @userid = @userid,
            @logsource = @spname, @logtimingidnew = @logtimingidnew OUTPUT;

       IF EXISTS ( SELECT  1
                    FROM    [Production].[Customer] )
            BEGIN
                SET @logmessage = 'Table is not empty. Aborting.';
	    
                EXEC [Operations].[LogMessage_Record] @userid = @userid,
                    @logsource = @spname, @logmessage = @logmessage,
                    @logmessagelevel = 'ERROR';
                RETURN;
            END;

        SELECT  @today = CAST(GETDATE() AS DATE);


        SELECT  @countryiduk = [CountryID]
        FROM    [Reference].[Country]
        WHERE   [Name] = 'United Kingdom';

        SELECT  @addresstypidemail = [AddressTypeID]
        FROM    [Reference].[AddressType]
        WHERE   [Name] = 'Email';

        SELECT  @addresstypidmobile = [AddressTypeID]
        FROM    [Reference].[AddressType]
        WHERE   [Name] = 'Mobile';

        IF @addresstypidemail IS NULL
            OR @addresstypidmobile IS NULL
            OR @countryiduk IS NULL
            BEGIN
                SET @logmessage = 'No or invalid Country or Address Types;'
                    + ' @addresstypidemail = ' + ISNULL(@addresstypidemail,
                                                        'NULL')
                    + ', @addresstypidmobile = ' + ISNULL(@addresstypidemail,
                                                          'NULL')
                    + ', @countryiduk = ' + ISNULL(@countryiduk, 'NULL');
	    
                EXEC [Operations].[LogMessage_Record] @userid = @userid,
                    @logsource = @spname, @logmessage = @logmessage,
                    @logmessagelevel = 'ERROR',
                    @messagetypecd = 'Invalid Lookup';
    
                RETURN;
            END;

        SELECT  @defaultoptinleisure = [SubscriptionTypeID]
        FROM    [Reference].[SubscriptionType]
        WHERE   [Name] = [Reference].[Configuration_GetSetting]('Migration',
                                                              'Default Leisure Subscription Type');

        SELECT  @defaultoptincorporate = [SubscriptionTypeID]
        FROM    [Reference].[SubscriptionType]
        WHERE   [Name] = [Reference].[Configuration_GetSetting]('Migration',
                                                              'Default Corporate Subscription Type');

        IF (@defaultoptinleisure IS NULL)
            OR (@defaultoptincorporate IS NULL)
            BEGIN
                SET @logmessage = 'No or invalid reference data; '
                    + ' @defaultoptinleisure = ' + ISNULL(@defaultoptinleisure,
                                                          'NULL')
                    + ' @defaultoptincorporate = '
                    + ISNULL(@defaultoptincorporate, 'NULL'); 
	    
                EXEC [Operations].[LogMessage_Record] @userid = @userid,
                    @logsource = @spname, @logmessage = @logmessage,
                    @logmessagelevel = 'ERROR',
                    @messagetypecd = 'Invalid Lookup';

                RETURN;
            END;

 
--Iwan Jones -- Disable nonclustered indexes before loading customer data
        EXEC [Operations].[uspToggleIndexes] Production, Customer, 0;
	
--Peter Malherbe -- Update Statistics to support customer loading
        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'Update Statistics to support Customer Load', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

			UPDATE STATISTICS [Staging].[STG_Customer]; 
			UPDATE STATISTICS [Staging].[STG_Address]; 
			UPDATE STATISTICS [Staging].[STG_ElectronicAddress]; 
			UPDATE STATISTICS [Reference].[Location];

        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'Update Statistics to support Customer Load', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

		EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'Insert Into Customer', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

        INSERT  INTO [Production].[Customer]
                ([CustomerID]
                ,[Description]
                ,[CreatedDate]
                ,[CreatedBy]
                ,[LastModifiedDate]
                ,[LastModifiedBy]
                ,[ArchivedInd]
                ,[IndividualID]
                ,[InformationSourceID]
                ,[ValidEmailInd]
                ,[ValidMobileInd]
                ,[OptInLeisureInd]
                ,[OptInCorporateInd]
                ,[CountryID]
                ,[IsOrganisationInd]
                ,[IsStaffInd]
                ,[IsBlackListInd]
                ,[IsCorporateInd]
                ,[IsTMCInd]
                ,[Salutation]
                ,[FirstName]
                ,[MiddleName]
                ,[LastName]
                ,[EmailAddress]
                ,[MobileNumber]
                ,[PostalArea]
                ,[PostalDistrict]
                ,[DateRegistered]
                ,[DateFirstPurchaseAny]
                ,[DateLastPurchaseAny]
                ,[VTSegment]
                ,[AccountStatus]
                ,[RegChannel]
                ,[RegOriginatingSystemType]
                ,[FirstCallTranDate]
                ,[FirstIntTranDate]
                ,[FirstMobAppTranDate]
                ,[FirstMobWebTranDate]
                ,[ExperianAgeBand]
                ,[ExperianHouseholdIncome]
                ,[DateOfBirth]
                ,[NearestStation]
                ,[LocationIDHomeActual]
		        )
        SELECT  [a].[CustomerID]
               ,NULL
               ,[a].[CreatedDate]
               ,[a].[CreatedBy]
               ,[a].[LastModifiedDate]
               ,[a].[LastModifiedBy]
               ,0
               ,NULL
               ,[a].[InformationSourceID]
               ,0                --ValidEmailInd, bit,>
               ,0                --<ValidMobileInd, bit,>
               ,0                --<OptInLeisureInd, bit,>
               ,0                --<OptInCorporateInd, bit,>
               ,ISNULL([b].[CountryID], -99)
               ,0
               ,[a].[IsStaffInd]
               ,[a].[IsBlackListInd]
               ,[a].[IsCorporateInd]
               ,[a].[IsTMCInd]
               ,[a].[Salutation]
               ,[a].[FirstName]
               ,[a].[MiddleName]
               ,[a].[LastName]
               ,[c].[ParsedAddress]
               ,[d].[ParsedAddress]
               ,CASE WHEN [b].[CountryID] = @countryiduk
                          AND [b].[PostalCode] IS NOT NULL
                          AND (PATINDEX('[A-Z]%[0-9]%[0-9][A-Z][A-Z]',
                                        [b].[PostalCode])) = 1
                     THEN LEFT(UPPER(LEFT(REPLACE([b].[PostalCode], ' ', ''),
                                          (LEN(REPLACE([b].[PostalCode], ' ', ''))
                                           - 3))),
                               PATINDEX('%[0-9]%', [b].[PostalCode]) - 1)
                     ELSE NULL
                END
               ,CASE WHEN [b].[CountryID] = @countryiduk
                          AND [b].[PostalCode] IS NOT NULL
                          AND (PATINDEX('[A-Z]%[0-9]%[0-9][A-Z][A-Z]',
                                        [b].[PostalCode])) = 1
                     THEN UPPER(LEFT(REPLACE([b].[PostalCode], ' ', ''),
                                     (LEN(REPLACE([b].[PostalCode], ' ', '')) - 3)))
                     ELSE NULL
                END
               ,[a].[SourceCreatedDate]
               ,[a].[DateFirstPurchase]
               ,[a].[DateLastPurchase]
               ,[a].[VTSegment]
               ,[a].[AccountStatus]
               ,[a].[RegChannel]
               ,[a].[RegOriginatingSystemType]
               ,CASE WHEN ISDATE([a].[FirstCallTranDate]) = 1
                          AND [a].[FirstCallTranDate] > CONVERT(DATE, '1899-12-30')
                     THEN [a].[FirstCallTranDate]
                     ELSE NULL
                END
               ,CASE WHEN ISDATE([a].[FirstIntTranDate]) = 1
                          AND [a].[FirstIntTranDate] > CONVERT(DATE, '1899-12-30')
                     THEN [a].[FirstIntTranDate]
                     ELSE NULL
                END
               ,CASE WHEN ISDATE([a].[FirstMobAppTranDate]) = 1
                          AND [a].[FirstMobAppTranDate] > CONVERT(DATE, '1899-12-30')
                     THEN [a].[FirstMobAppTranDate]
                     ELSE NULL
                END
               ,CASE WHEN ISDATE([a].[FirstMobWebTranDate]) = 1
                          AND [a].[FirstMobWebTranDate] > CONVERT(DATE, '1899-12-30')
                     THEN [a].[FirstMobWebTranDate]
                     ELSE NULL
                END
               ,[a].[ExperianAgeBand]
               ,[a].[ExperianHouseholdIncome]
               ,CASE WHEN ISDATE([a].[DateOfBirth]) = 1
                          AND [a].[DateOfBirth] > CONVERT(DATE, '1899-12-30')
                     THEN [a].[DateOfBirth]
                     ELSE NULL
                END
               ,[a].[NearestStation]
               ,[e].[LocationID]
        FROM    [Staging].[STG_Customer] [a]
        LEFT OUTER JOIN [Staging].[STG_Address] [b]
        ON      [a].[CustomerID] = [b].[CustomerID]
                AND [b].[PrimaryInd] = 1
        LEFT OUTER JOIN [Staging].[STG_ElectronicAddress] [c]
        ON      [a].[CustomerID] = [c].[CustomerID]
                AND [c].[AddressTypeID] = @addresstypidemail
                AND [c].[PrimaryInd] = 1
                AND [c].[ArchivedInd] = 0
        LEFT OUTER JOIN [Staging].[STG_ElectronicAddress] [d]
        ON      [a].[CustomerID] = [d].[CustomerID]
                AND [d].[AddressTypeID] = @addresstypidmobile
                AND [d].[PrimaryInd] = 1
                AND [d].[ArchivedInd] = 0
        LEFT OUTER JOIN [Reference].[Location_NLCCode_VW] [e] WITH (NOLOCK)
        ON      [e].[CRSCode] = [a].[NearestStation]
                AND [e].[CRSCode] <> ''
        WHERE   [a].[IsPersonInd] = 1;

		SELECT  @recordcount = @@ROWCOUNT;

        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'Insert Into Customer', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

--Iwan Jones -- re-enable nonclustered indexes after loading customer data
        EXEC [Operations].[uspToggleIndexes] Production, Customer, 1;
	
--Validity flags for email and mobile numbers

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'Update ValidEmailInd', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

        UPDATE  [a]
        SET     [ValidEmailInd] = CASE [ParsedScore]
                                  WHEN 100 THEN 1
                                  ELSE 0
                                END
        FROM    [Production].[Customer] [a]
               ,[Staging].[STG_ElectronicAddress] [b]
        WHERE   [a].[CustomerID] = [b].[CustomerID]
                AND [b].[PrimaryInd] = 1
                AND [b].[AddressTypeID] = @addresstypidemail;
		
		SELECT  @recordcount = @@ROWCOUNT;

		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'Update ValidEmailInd', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'Update ValidMobileInd', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

        UPDATE  [a]
        SET     [ValidMobileInd] = CASE [ParsedScore]
                                   WHEN 100 THEN 1
                                   ELSE 0
                                 END
        FROM    [Production].[Customer] [a]
               ,[Staging].[STG_ElectronicAddress] [b]
        WHERE   [a].[CustomerID] = [b].[CustomerID]
                AND [b].[PrimaryInd] = 1
                AND [b].[AddressTypeID] = @addresstypidmobile;
		
		SELECT  @recordcount = @@ROWCOUNT;

		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'Update ValidMobileInd', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

--Optin Flags - use email as the default channel
   --General Marketing Flag (Email)
        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'General Marketing Flag (Email)', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

        UPDATE  [a]
        SET     [OptInLeisureInd] = [b].[Value]
        FROM    [Production].[Customer] [a]
        INNER JOIN [Staging].[STG_CustomerPreference] [b]
        ON      [a].[CustomerID] = [b].[CustomerID]
        INNER JOIN [Reference].[Preference] [c]
        ON      [b].[PreferenceID] = [c].[PreferenceID]
                AND [c].[Name] = 'General Marketing Opt-In'
        INNER JOIN [Reference].[Channel] [d]
        ON      [d].[ChannelID] = [b].[ChannelID]
                AND [d].[Name] = 'Email';
		
		SELECT  @recordcount = @@ROWCOUNT;
		
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'General Marketing Flag (Email)', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 
   
   --DfT Optin
        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'DfT Optin', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

        UPDATE  [a]
        SET     [OptInCorporateInd] = [b].[Value]
        FROM    [Production].[Customer] [a]
        INNER JOIN [Staging].[STG_CustomerPreference] [b]
        ON      [a].[CustomerID] = [b].[CustomerID]
        INNER JOIN [Reference].[Preference] [c]
        ON      [b].[PreferenceID] = [c].[PreferenceID]
                AND [c].[Name] = 'DFT Opt-In'
        INNER JOIN [Reference].[Channel] [d]
        ON      [d].[ChannelID] = [b].[ChannelID]
                AND [d].[Name] = 'None';
		
		SELECT  @recordcount = @@ROWCOUNT;
		
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'DfT Optin', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

	--Determine last order date
		EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'Determine last order date', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 
	
        UPDATE  [a]
        SET     [DateLastPurchaseAny] = [b].[LatestDate]
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [c].[CustomerID]
                           ,MAX([SalesTransactionDate]) AS [LatestDate]
                    FROM    [Staging].[STG_Customer] [c]
                           ,[Staging].[STG_SalesTransaction] [d]
                    WHERE   [c].[CustomerID] = [d].[CustomerID]
                    GROUP BY [c].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;

		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'Determine last order date', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

--Determine Ticket Information
--Purchased First Class Tickets
		EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'Purchased First Class Tickets - MIN', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

        UPDATE  [a]
        SET     [DateFirstPurchaseFirst] = [f].[ReqDate]
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [b].[CustomerID]
                           ,MIN([b].[SalesTransactionDate]) AS [ReqDate]
                    FROM    [Staging].[STG_SalesTransaction] [b]
                           ,[Staging].[STG_SalesDetail] [c]
                           ,[Reference].[Product] [d]
                           ,[Reference].[TicketClass] [e]
                    WHERE   [b].[SalesTransactionID] = [c].[SalesTransactionID]
                            AND [c].[ProductID] = [d].[ProductID]
                            AND [d].[TicketClassID] = [e].[TicketClassID]
                            AND [c].[IsTrainTicketInd] = 1
                            AND [e].[Name] = 'First'
                    GROUP BY [b].[CustomerID]
                   ) [f]
        ON      [a].[CustomerID] = [f].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;

		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'Purchased First Class Tickets - MIN', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

		EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'Purchased First Class Tickets - MAX', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

        UPDATE  [a]
        SET     [DateLastPurchaseFirst] = [f].[ReqDate]
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [b].[CustomerID]
                           ,MAX([b].[SalesTransactionDate]) AS [ReqDate]
                    FROM    [Staging].[STG_SalesTransaction] [b]
                           ,[Staging].[STG_SalesDetail] [c]
                           ,[Reference].[Product] [d]
                           ,[Reference].[TicketClass] [e]
                    WHERE   [b].[SalesTransactionID] = [c].[SalesTransactionID]
                            AND [c].[ProductID] = [d].[ProductID]
                            AND [d].[TicketClassID] = [e].[TicketClassID]
                            AND [c].[IsTrainTicketInd] = 1
                            AND [e].[Name] = 'First'
                    GROUP BY [b].[CustomerID]
                   ) [f]
        ON      [a].[CustomerID] = [f].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;

		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'Purchased First Class Tickets - MAX', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

--Travel Dates
--Any

		EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'ANY Travel Dates - MIN', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

        UPDATE  [a]
        SET     [DateFirstTravelAny] = [f].[ReqDate]
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [j].[CustomerID]
                           ,MIN([j].[OutDepartureDateTime]) AS [ReqDate]
                    FROM    [Staging].[STG_Journey] [j]
                    WHERE   CAST([j].[OutDepartureDateTime] AS DATE) < @today
                    GROUP BY [j].[CustomerID]
                   ) [f]
        ON      [a].[CustomerID] = [f].[CustomerID]; 
		
		SELECT  @recordcount = @@ROWCOUNT;

		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'ANY Travel Dates - MIN', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

		EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'ANY Travel Dates - NULL', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 
		
        UPDATE  [a]
        SET     [DateLastTravelAny] = CASE WHEN [z].[ReqDate] IS NULL
                                              OR [z].[ReqDate] < [f].[ReqDate]
                                         THEN [f].[ReqDate]
                                         ELSE [z].[ReqDate]
                                    END
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [j].[CustomerID]
                           ,MAX([j].[OutDepartureDateTime]) AS [ReqDate]
                    FROM    [Staging].[STG_Journey] [j]
                    WHERE   CAST([j].[OutDepartureDateTime] AS DATE) < @today
                    GROUP BY [j].[CustomerID]
                   ) [f]
        ON      [a].[CustomerID] = [f].[CustomerID]
        LEFT JOIN (
                   SELECT   [j].[CustomerID]
                           ,MAX([j].[RetDepartureDateTime]) AS [ReqDate]
                   FROM     [Staging].[STG_Journey] [j]
                   WHERE    CAST([j].[RetDepartureDateTime] AS DATE) < @today
                            AND [j].[RetDepartureDateTime] IS NOT NULL
                   GROUP BY [j].[CustomerID]
                  ) [z]
        ON      [a].[CustomerID] = [z].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;

		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'ANY Travel Dates - NULL', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

----First

		EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'First Travel Dates - MIN', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0; 

        UPDATE  [a]
        SET     [DateFirstTravelFirst] = [f].[ReqDate]
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [j].[CustomerID]
                           ,MIN([j].[OutDepartureDateTime]) AS [ReqDate]
                    FROM    [Staging].[STG_Journey] [j]
                           ,[Staging].[STG_SalesDetail] [c]
                           ,[Reference].[Product] [d]
                           ,[Reference].[TicketClass] [e]
                    WHERE   [j].[SalesDetailID] = [c].[SalesDetailID]
                            AND [c].[ProductID] = [d].[ProductID]
                            AND [d].[TicketClassID] = [e].[TicketClassID]
                            AND [c].[IsTrainTicketInd] = 1
                            AND [e].[Name] = 'First'
                            AND CAST([j].[OutDepartureDateTime] AS DATE) < @today
                    GROUP BY [j].[CustomerID]
                   ) [f]
        ON      [a].[CustomerID] = [f].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;

		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'First Travel Dates - MIN', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname, @ProcessStep = 'First Travel Dates - NULL', @DatabaseName = 'CRM', @FileName = '', @Rows = NULL, @PrintToScreen = 0;

        UPDATE  [a]
        SET     [DateLastTravelFirst] = CASE WHEN [z].[ReqDate] IS NULL
                                                  OR [z].[ReqDate] < [f].[ReqDate]
                                             THEN [f].[ReqDate]
                                             ELSE [z].[ReqDate]
                                        END
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [j].[CustomerID]
                           ,MAX([j].[OutDepartureDateTime]) AS [ReqDate]
                    FROM    [Staging].[STG_Journey] [j]
                           ,[Staging].[STG_SalesDetail] [c]
                           ,[Reference].[Product] [d]
                           ,[Reference].[TicketClass] [e]
                    WHERE   [j].[SalesDetailID] = [c].[SalesDetailID]
                            AND [c].[ProductID] = [d].[ProductID]
                            AND [d].[TicketClassID] = [e].[TicketClassID]
                            AND [c].[IsTrainTicketInd] = 1
                            AND [e].[Name] = 'First'
                            AND CAST([j].[OutDepartureDateTime] AS DATE) < @today
                    GROUP BY [j].[CustomerID]
                   ) [f]
        ON      [a].[CustomerID] = [f].[CustomerID]
        LEFT JOIN (
                   SELECT   [j].[CustomerID]
                           ,MAX([j].[RetDepartureDateTime]) AS [ReqDate]
                   FROM     [Staging].[STG_Journey] [j]
                           ,[Staging].[STG_SalesDetail] [c]
                           ,[Reference].[Product] [d]
                           ,[Reference].[TicketClass] [e]
                   WHERE    [j].[SalesDetailID] = [c].[SalesDetailID]
                            AND [c].[ProductID] = [d].[ProductID]
                            AND [d].[TicketClassID] = [e].[TicketClassID]
                            AND [c].[IsTrainTicketInd] = 1
                            AND [e].[Name] = 'First'
                            AND CAST([j].[RetDepartureDateTime] AS DATE) < @today
                            AND [j].[RetDepartureDateTime] IS NOT NULL
                   GROUP BY [j].[CustomerID]
                  ) [z]
        ON      [a].[CustomerID] = [z].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,             @ProcessStep = 'First Travel Dates - NULL', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

--Next Travel Date
----Any
        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Next Travel Date - ANY', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [DateNextTravelAny] = CASE WHEN [z].[ReqDate] IS NULL
                                                OR [z].[ReqDate] > [f].[ReqDate]
                                           THEN [f].[ReqDate]
                                           ELSE [z].[ReqDate]
                                      END
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [j].[CustomerID]
                           ,MIN([j].[OutDepartureDateTime]) AS [ReqDate]
                    FROM    [Staging].[STG_Journey] [j]
                    WHERE   CAST([j].[OutDepartureDateTime] AS DATE) >= @today
                    GROUP BY [j].[CustomerID]
                   ) [f]
        ON      [a].[CustomerID] = [f].[CustomerID]
        LEFT JOIN (
                   SELECT   [j].[CustomerID]
                           ,MIN([j].[RetDepartureDateTime]) AS [ReqDate]
                   FROM     [Staging].[STG_Journey] [j]
                   WHERE    CAST([j].[RetDepartureDateTime] AS DATE) >= @today
                            AND [j].[RetDepartureDateTime] IS NOT NULL
                   GROUP BY [j].[CustomerID]
                  ) [z]
        ON      [a].[CustomerID] = [z].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Next Travel Date - ANY', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 
--First
        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Next Travel Date - FIRST', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [DateNextTravelFirst] = CASE WHEN [z].[ReqDate] IS NULL
                                                  OR [z].[ReqDate] > [f].[ReqDate]
                                             THEN [f].[ReqDate]
                                             ELSE [z].[ReqDate]
                                        END
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [j].[CustomerID]
                           ,MIN([j].[OutDepartureDateTime]) AS [ReqDate]
                    FROM    [Staging].[STG_Journey] [j]
                           ,[Staging].[STG_SalesDetail] [c]
                           ,[Reference].[Product] [d]
                           ,[Reference].[TicketClass] [e]
                    WHERE   [j].[SalesDetailID] = [c].[SalesDetailID]
                            AND [c].[ProductID] = [d].[ProductID]
                            AND [d].[TicketClassID] = [e].[TicketClassID]
                            AND [c].[IsTrainTicketInd] = 1
                            AND [e].[Name] = 'First'
                            AND CAST([j].[OutDepartureDateTime] AS DATE) >= @today
                    GROUP BY [j].[CustomerID]
                   ) [f]
        ON      [a].[CustomerID] = [f].[CustomerID]
        LEFT JOIN (
                   SELECT   [j].[CustomerID]
                           ,MIN([j].[RetDepartureDateTime]) AS [ReqDate]
                   FROM     [Staging].[STG_Journey] [j]
                           ,[Staging].[STG_SalesDetail] [c]
                           ,[Reference].[Product] [d]
                           ,[Reference].[TicketClass] [e]
                   WHERE    [j].[SalesDetailID] = [c].[SalesDetailID]
                            AND [c].[ProductID] = [d].[ProductID]
                            AND [d].[TicketClassID] = [e].[TicketClassID]
                            AND [c].[IsTrainTicketInd] = 1
                            AND [e].[Name] = 'First'
                            AND CAST([j].[RetDepartureDateTime] AS DATE) >= @today
                            AND [j].[RetDepartureDateTime] IS NOT NULL
                   GROUP BY [j].[CustomerID]
                  ) [z]
        ON      [a].[CustomerID] = [z].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Next Travel Date - FIRST', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

--Determine Sales Amounts
----Total Sales

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - Total Sales', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [SalesAmountTotal] = ISNULL([b].[TotalSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountTotal]) AS [TotalSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - Total Sales', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - 3mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [SalesAmount3Mnth] = ISNULL([b].[TotalSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountTotal]) AS [TotalSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -3,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - 3mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - 6mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [SalesAmount6Mnth] = ISNULL([b].[TotalSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountTotal]) AS [TotalSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -6,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - 6mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - 12mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [SalesAmount12Mnth] = ISNULL([b].[TotalSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountTotal]) AS [TotalSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -12,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - 12mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 
		        
		EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - 24mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [SalesAmount24Mnth] = ISNULL([b].[TotalSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountTotal]) AS [TotalSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -24,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - 24mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - 36mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [SalesAmount36Mnth] = ISNULL([b].[TotalSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountTotal]) AS [TotalSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -36,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Determine Sales Amounts - 36mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 
----Rail Sales

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Rail Sales - Total', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [SalesAmountRailTotal] = ISNULL([b].[RailSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountRail]) AS [RailSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Rail Sales - Total', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Rail Sales - 3mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [SalesAmountRail3Mnth] = ISNULL([b].[RailSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountRail]) AS [RailSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -3,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname, @ProcessStep = 'Rail Sales - 3mnth', @DatabaseName = 'CRM', @FileName = '', @Rows = @recordcount, @PrintToScreen = 0; 
																
        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesAmountRail6Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesAmountRail6Mnth] = ISNULL([b].[RailSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountRail]) AS [RailSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -6,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesAmountRail6Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesAmountRail12Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
		UPDATE  [a]
        SET     [SalesAmountRail12Mnth] = ISNULL([b].[RailSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountRail]) AS [RailSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -12,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesAmountRail12Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

----Non Rail Sales

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesAmountNotRailTotal', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesAmountNotRailTotal] = ISNULL([b].[NotRailSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountNotRail]) AS [NotRailSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesAmountNotRailTotal', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesAmountNotRail3Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesAmountNotRail3Mnth] = ISNULL([b].[NotRailSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountNotRail]) AS [NotRailSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -3,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesAmountNotRail3Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesAmountNotRail6Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesAmountNotRail6Mnth] = ISNULL([b].[NotRailSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountNotRail]) AS [NotRailSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -6,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesAmountNotRail6Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesAmountNotRail12Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesAmountNotRail12Mnth] = ISNULL([b].[NotRailSales], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,SUM([d].[SalesAmountNotRail]) AS [NotRailSales]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -12,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesAmountNotRail12Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 


----Sales Transactions

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesTransactionTotal', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesTransactionTotal] = ISNULL([b].[SalesTransactionTotal], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,COUNT(DISTINCT ([SalesTransactionID])) AS [SalesTransactionTotal]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesTransactionTotal', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesTransaction1Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesTransaction1Mnth] = ISNULL([b].[SalesTransaction1Mnth], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,COUNT(DISTINCT ([SalesTransactionID])) AS [SalesTransaction1Mnth]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -1,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesTransaction1Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesTransaction3Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesTransaction3Mnth] = ISNULL([b].[SalesTransaction3Mnth], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,COUNT(DISTINCT ([SalesTransactionID])) AS [SalesTransaction3Mnth]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -3,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesTransaction3Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesTransaction6Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
		SET     [SalesTransaction6Mnth] = ISNULL([b].[SalesTransaction6Mnth], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,COUNT(DISTINCT ([SalesTransactionID])) AS [SalesTransaction6Mnth]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -6,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesTransaction6Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0; 

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesTransaction12Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesTransaction12Mnth] = ISNULL([b].[SalesTransaction12Mnth], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,COUNT(DISTINCT ([SalesTransactionID])) AS [SalesTransaction12Mnth]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -12,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesTransaction12Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0;  

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesTransaction24Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesTransaction24Mnth] = ISNULL([b].[SalesTransaction24Mnth], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,COUNT(DISTINCT ([SalesTransactionID])) AS [SalesTransaction24Mnth]
                    FROM    [Staging].[STG_Customer] [c]
                           ,[Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -24,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
        EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesTransaction24Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0;  

        EXEC [synUspAudit] @AuditType = 'TRACE START', @Process = @spname,            @ProcessStep = 'Update SalesTransaction36Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = NULL, @PrintToScreen = 0;
        
        UPDATE  [a]
        SET     [SalesTransaction36Mnth] = ISNULL([b].[SalesTransaction36Mnth], 0)
        FROM    [Production].[Customer] [a]
        INNER JOIN (
                    SELECT  [d].[CustomerID]
                           ,COUNT(DISTINCT ([SalesTransactionID])) AS [SalesTransaction36Mnth]
                    FROM    [Staging].[STG_SalesTransaction] [d]
                    WHERE   [d].[SalesTransactionDate] >= DATEADD(M, -36,
                                                              @today)
                    GROUP BY [d].[CustomerID]
                   ) [b]
        ON      [a].[CustomerID] = [b].[CustomerID];
		
		SELECT  @recordcount = @@ROWCOUNT;
        
		EXEC [synUspAudit] @AuditType = 'TRACE END', @Process = @spname,            @ProcessStep = 'Update SalesTransaction36Mnth', @DatabaseName = 'CRM', @FileName = '',            @Rows = @recordcount, @PrintToScreen = 0;  

--Log end time

        EXEC [Operations].[LogTiming_Record] @userid = @userid,
            @logsource = @spname, @logtimingid = @logtimingidnew,
            @recordcount = @recordcount,
            @logtimingidnew = @logtimingidnew OUTPUT;
        RETURN; 
    END;