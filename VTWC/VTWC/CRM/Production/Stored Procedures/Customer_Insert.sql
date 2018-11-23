

CREATE PROCEDURE [Production].[Customer_Insert]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	--DECLARE @informationsourceid      INTEGER
	DECLARE @addresstypidemail        INTEGER
	DECLARE @addresstypidmobile       INTEGER
	DECLARE @countryiduk              INTEGER
	DECLARE @defaultoptinleisure      INTEGER
	DECLARE @defaultoptincorporate    INTEGER

	DECLARE @today                    DATE

	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT
/*
    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = [Reference].[Configuration_GetSetting] ('Migration','MSD Source')

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
        RETURN
    END
*/
	IF EXISTS (SELECT 1 FROM Production.Customer)
    BEGIN
        SET @logmessage = 'Table is not empty. Aborting.'
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR'
        RETURN
    END

	SELECT @today = CAST(GETDATE() AS DATE)


	SELECT @countryiduk = CountryID
	FROM   [Reference].[Country]
	WHERE  Name = 'United Kingdom'

	SELECT @addresstypidemail = AddressTypeID
    FROM [Reference].[AddressType]
    WHERE Name = 'Email'

	SELECT @addresstypidmobile = AddressTypeID
    FROM [Reference].[AddressType]
    WHERE Name = 'Mobile'

	IF @addresstypidemail IS NULL OR @addresstypidmobile IS NULL OR @countryiduk IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid Country or Address Types;' +
		                  ' @addresstypidemail = '   + ISNULL(@addresstypidemail,'NULL') + 
		                  ', @addresstypidmobile = ' + ISNULL(@addresstypidemail,'NULL') +
						  ', @countryiduk = '        + ISNULL(@countryiduk,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    
	    RETURN
	END

	SELECT @defaultoptinleisure = SubscriptionTypeID
	FROM   [Reference].[SubscriptionType]
	WHERE  Name = [Reference].[Configuration_GetSetting] ('Migration','Default Leisure Subscription Type')

	SELECT @defaultoptincorporate = SubscriptionTypeID
	FROM   [Reference].[SubscriptionType]
	WHERE  Name = [Reference].[Configuration_GetSetting] ('Migration','Default Corporate Subscription Type')

	IF (@defaultoptinleisure IS NULL) OR (@defaultoptincorporate IS NULL)
	BEGIN
	    SET @logmessage = 'No or invalid reference data; ' +
		                  ' @defaultoptinleisure = '   + ISNULL(@defaultoptinleisure,'NULL') + 
						  ' @defaultoptincorporate = ' + ISNULL(@defaultoptincorporate,'NULL') 
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

    INSERT INTO [Production].[Customer]
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
           ,[DateLastPurchaseAny])
    SELECT a.CustomerID
           ,NULL
           ,a.CreatedDate
           ,a.CreatedBy
           ,a.LastModifiedDate
           ,a.LastModifiedBy
           ,0
           ,NULL
           ,a.informationsourceid
           ,0                --ValidEmailInd, bit,>
           ,0                --<ValidMobileInd, bit,>
           ,0                --<OptInLeisureInd, bit,>
           ,0                --<OptInCorporateInd, bit,>
           ,CASE WHEN b.CountryID IS NULL THEN -99 ELSE b.CountryID END
           ,0
		   ,a.IsStaffInd
		   ,a.IsBlackListInd
		   ,a.IsCorporateInd
		   ,a.IsTMCInd
           ,a.Salutation
           ,a.FirstName
           ,a.MiddleName
           ,a.LastName
           ,c.ParsedAddress
           ,d.ParsedAddress

           ,CASE WHEN b.CountryID =  @countryiduk 
		         AND b.PostalCode IS NOT NULL 
				 AND (PATINDEX('[A-Z]%[0-9]%[0-9][A-Z][A-Z]',b.PostalCode)) = 1 THEN left(upper(left(replace(b.PostalCode,' ',''),(len(replace(b.PostalCode,' ',''))-3))),PATINDEX('%[0-9]%',b.PostalCode)-1)
		                     ELSE NULL END

           ,CASE WHEN b.CountryID =  @countryiduk 
		         AND b.PostalCode IS NOT NULL 
				 AND (PATINDEX('[A-Z]%[0-9]%[0-9][A-Z][A-Z]',b.PostalCode)) = 1 THEN upper(left(replace(b.PostalCode,' ',''),(len(replace(b.PostalCode,' ',''))-3)))
		                     ELSE NULL END

           ,a.SourceCreatedDate
           ,a.DateFirstPurchase
           ,a.DateLastPurchase

	FROM Staging.STG_Customer a
	LEFT OUTER JOIN Staging.STG_Address b ON a.CustomerID = b.CustomerID AND b.PrimaryInd = 1
	LEFT OUTER JOIN Staging.STG_ElectronicAddress c ON a.CustomerID = c.CustomerID AND c.AddressTypeID = @addresstypidemail AND c.PrimaryInd = 1 and c.[ArchivedInd]=0
	LEFT OUTER JOIN Staging.STG_ElectronicAddress d ON a.CustomerID = d.CustomerID AND d.AddressTypeID = @addresstypidmobile AND d.PrimaryInd = 1 and d.[ArchivedInd]=0
	WHERE a.IsPersonInd = 1

	SELECT @recordcount = @@ROWCOUNT

--Validity flags for email and mobile numbers

    UPDATE a
	SET   ValidEmailInd = CASE ParsedScore WHEN 100 THEN 1 ELSE 0 END
	FROM  [Production].[Customer] a,
	      [Staging].[STG_ElectronicAddress] b
    WHERE  a.CustomerID = b.CustomerID
	AND    b.PrimaryInd = 1
	AND    b.AddressTypeID = @addresstypidemail

	UPDATE a
	SET   ValidMobileInd = CASE ParsedScore WHEN 100 THEN 1 ELSE 0 END
	FROM  [Production].[Customer] a,
	      [Staging].[STG_ElectronicAddress] b
    WHERE  a.CustomerID = b.CustomerID
	AND    b.PrimaryInd = 1
	AND    b.AddressTypeID = @addresstypidmobile

--Optin Flags - use email as the default channel

   --Leisure
   UPDATE a
	SET   OptInLeisureInd = b.OptInInd
	FROM  [Production].[Customer] a,
	      [Staging].[STG_CustomerSubscriptionPreference] b,
		  [Reference].[SubscriptionChannelType] c,
		  [Reference].[SubscriptionType] d,
		  [Reference].[ChannelType] e
    WHERE  a.CustomerID = b.CustomerID
	AND    c.SubscriptionChannelTypeID = b.SubscriptionChannelTypeID
	AND    d.SubscriptionTypeID = c.SubscriptionTypeID
	AND    e.ChannelTypeID = c.ChannelTypeID
	AND    c.SubscriptionTypeID = @defaultoptinleisure
	AND    e.Name = 'Email'
	AND    b.ArchivedInd = 0

   --Corporate
	UPDATE a
	SET   OptInCorporateInd = b.OptInInd
	FROM  [Production].[Customer] a,
	      [Staging].[STG_CustomerSubscriptionPreference] b,
		  [Reference].[SubscriptionChannelType] c,
		  [Reference].[SubscriptionType] d,
		  [Reference].[ChannelType] e
    WHERE  a.CustomerID = b.CustomerID
	AND    c.SubscriptionChannelTypeID = b.SubscriptionChannelTypeID
	AND    d.SubscriptionTypeID = c.SubscriptionTypeID
	AND    e.ChannelTypeID = c.ChannelTypeID
	AND    c.SubscriptionTypeID = @defaultoptincorporate
	AND    e.Name = 'Email'
	AND    b.ArchivedInd = 0

--Determine last order date
	
	UPDATE a
	SET  DateLastPurchaseAny = b.LatestDate
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       MAX(SalesTransactionDate) AS LatestDate
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

--Determine Ticket Information

--Purchased First Class Tickets
    UPDATE a
    SET DateFirstPurchaseFirst = f.ReqDate
    FROM  Production.Customer a
    INNER JOIN (SELECT b.CustomerID,MIN(b.SalesTransactionDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c,
	                 Reference.Product d,
                     Reference.TicketClass e
                WHERE b.SalesTransactionID = c.SalesTransactionID
                AND   c.ProductID = d.ProductID
                AND   d.TicketClassID = e.TicketClassID
				AND   c.IsTrainTicketInd = 1
				AND   e.Name = 'First'
                GROUP BY b.CustomerID) f
    ON a.CustomerID = f.CustomerID

    UPDATE a
    SET DateLastPurchaseFirst = f.ReqDate
    FROM  Production.Customer a
    INNER JOIN (SELECT b.CustomerID,MAX(b.SalesTransactionDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c,
	                 Reference.Product d,
                     Reference.TicketClass e
                WHERE b.SalesTransactionID = c.SalesTransactionID
                AND   c.ProductID = d.ProductID
                AND   d.TicketClassID = e.TicketClassID
			    AND   c.IsTrainTicketInd = 1
				AND   e.Name = 'First'
                GROUP BY b.CustomerID) f
    ON a.CustomerID = f.CustomerID


--Travel Dates
--Any
    UPDATE a
    SET DateFirstTravelAny = f.ReqDate
    FROM  Production.Customer a
    INNER JOIN (SELECT b.CustomerID,MIN(c.OutTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c
                WHERE b.SalesTransactionID = c.SalesTransactionID
	            AND   c.IsTrainTicketInd = 1
				AND   c.OutTravelDate < @today
                GROUP BY b.CustomerID) f
    ON a.CustomerID = f.CustomerID 

    UPDATE a
    SET DateLastTravelAny = CASE WHEN z.ReqDate IS NULL OR z.ReqDate < f.ReqDate THEN f.ReqDate ELSE z.ReqDate END
    FROM  Production.Customer a
    INNER JOIN (SELECT b.CustomerID,MAX(c.OutTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c
                WHERE b.SalesTransactionID = c.SalesTransactionID
	            AND   c.IsTrainTicketInd = 1
				AND   c.OutTravelDate < @today
                GROUP BY b.CustomerID) f     ON a.CustomerID = f.CustomerID
	LEFT JOIN (SELECT b.CustomerID,MAX(c.ReturnTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c
                WHERE b.SalesTransactionID = c.SalesTransactionID
	            AND   c.IsTrainTicketInd = 1
				AND   c.ReturnTravelDate < @today
				AND	  c.ReturnTravelDate IS NOT NULL
                GROUP BY b.CustomerID) z	ON a.CustomerID = z.CustomerID


----First
    UPDATE a
    SET DateFirstTravelFirst = f.ReqDate
    FROM  Production.Customer a
    INNER JOIN (SELECT b.CustomerID,MIN(c.OutTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c,
	                 Reference.Product d,
                     Reference.TicketClass e
                WHERE b.SalesTransactionID = c.SalesTransactionID
                AND   c.ProductID = d.ProductID
                AND   d.TicketClassID = e.TicketClassID
				AND   c.IsTrainTicketInd = 1
				AND   e.Name = 'First'
				AND   c.OutTravelDate < @today
                GROUP BY b.CustomerID) f
    ON a.CustomerID = f.CustomerID

    UPDATE a
    SET DateLastTravelFirst = CASE WHEN z.ReqDate IS NULL OR z.ReqDate < f.ReqDate THEN f.ReqDate ELSE z.ReqDate END
    FROM  Production.Customer a
    INNER JOIN (SELECT b.CustomerID,MAX(c.OutTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c,
	                 Reference.Product d,
                     Reference.TicketClass e
                WHERE b.SalesTransactionID = c.SalesTransactionID
                AND   c.ProductID = d.ProductID
                AND   d.TicketClassID = e.TicketClassID
				AND   c.IsTrainTicketInd = 1
				AND   e.Name = 'First'
				AND   c.OutTravelDate < @today
                GROUP BY b.CustomerID) f
    ON a.CustomerID = f.CustomerID
	LEFT JOIN (SELECT b.CustomerID,MAX(c.ReturnTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c,
	                 Reference.Product d,
                     Reference.TicketClass e
                WHERE b.SalesTransactionID = c.SalesTransactionID
                AND   c.ProductID = d.ProductID
                AND   d.TicketClassID = e.TicketClassID
				AND   c.IsTrainTicketInd = 1
				AND   e.Name = 'First'
				AND   c.ReturnTravelDate < @today
				AND   c.ReturnTravelDate IS NOT NULL
                GROUP BY b.CustomerID) z
    ON a.CustomerID = z.CustomerID

--Next Travel Date
----Any
    UPDATE a
    SET DateNextTravelAny = CASE WHEN z.ReqDate IS NULL OR z.ReqDate > f.ReqDate THEN f.ReqDate ELSE z.ReqDate END
    FROM  Production.Customer a
    INNER JOIN (SELECT b.CustomerID,MIN(c.OutTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c
                WHERE b.SalesTransactionID = c.SalesTransactionID
	            AND   c.IsTrainTicketInd = 1
				AND   c.OutTravelDate >= @today
                GROUP BY b.CustomerID) f     ON a.CustomerID = f.CustomerID
	LEFT JOIN (SELECT b.CustomerID,MIN(c.ReturnTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c
                WHERE b.SalesTransactionID = c.SalesTransactionID
	            AND   c.IsTrainTicketInd = 1
				AND   c.ReturnTravelDate >= @today
				AND	  c.ReturnTravelDate IS NOT NULL
                GROUP BY b.CustomerID) z	ON a.CustomerID = z.CustomerID

--First
    UPDATE a
    SET DateNextTravelFirst = CASE WHEN z.ReqDate IS NULL OR z.ReqDate > f.ReqDate THEN f.ReqDate ELSE z.ReqDate END
    FROM  Production.Customer a
    INNER JOIN (SELECT b.CustomerID,MIN(c.OutTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c,
	                 Reference.Product d,
                     Reference.TicketClass e
                WHERE b.SalesTransactionID = c.SalesTransactionID
                AND   c.ProductID = d.ProductID
                AND   d.TicketClassID = e.TicketClassID
				AND   c.IsTrainTicketInd = 1
				AND   e.Name = 'First'
				AND   c.OutTravelDate >= @today
                GROUP BY b.CustomerID) f
    ON a.CustomerID = f.CustomerID
	LEFT JOIN (SELECT b.CustomerID,MIN(c.ReturnTravelDate) As ReqDate
                FROM Staging.STG_SalesTransaction b,
	                 Staging.STG_SalesDetail c,
	                 Reference.Product d,
                     Reference.TicketClass e
                WHERE b.SalesTransactionID = c.SalesTransactionID
                AND   c.ProductID = d.ProductID
                AND   d.TicketClassID = e.TicketClassID
				AND   c.IsTrainTicketInd = 1
				AND   e.Name = 'First'
				AND   c.ReturnTravelDate >= @today
				AND	  c.ReturnTravelDate IS NOT NULL
                GROUP BY b.CustomerID) z
    ON a.CustomerID = z.CustomerID

--Determine Sales Amounts
----Total Sales

	UPDATE a
	SET  SalesAmountTotal = b.TotalSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountTotal) AS TotalSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

	UPDATE a
	SET  SalesAmount3Mnth = b.TotalSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountTotal) AS TotalSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
				AND    d.SalesTransactionDate >= DATEADD(M,-3,@today)
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

	UPDATE a
	SET  SalesAmount6Mnth = b.TotalSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountTotal) AS TotalSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
				AND    d.SalesTransactionDate >= DATEADD(M,-6,@today)
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

	UPDATE a
	SET  SalesAmount12Mnth = b.TotalSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountTotal) AS TotalSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
				AND    d.SalesTransactionDate >= DATEADD(M,-12,@today)
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

----Rail Sales

	UPDATE a
	SET  SalesAmountRailTotal = b.RailSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountRail) AS RailSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

	UPDATE a
	SET  SalesAmountRail3Mnth = b.RailSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountRail) AS RailSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
				AND    d.SalesTransactionDate >= DATEADD(M,-3,@today)
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

	UPDATE a
	SET  SalesAmountRail6Mnth = b.RailSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountRail) AS RailSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
				AND    d.SalesTransactionDate >= DATEADD(M,-6,@today)
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

	UPDATE a
	SET  SalesAmountRail12Mnth = b.RailSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountRail) AS RailSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
				AND    d.SalesTransactionDate >= DATEADD(M,-12,@today)
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

----Non Rail Sales

	UPDATE a
	SET  SalesAmountNotRailTotal = b.NotRailSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountNotRail) AS NotRailSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

	UPDATE a
	SET  SalesAmountNotRail3Mnth = b.NotRailSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountNotRail) AS NotRailSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
				AND    d.SalesTransactionDate >= DATEADD(M,-3,@today)
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

	UPDATE a
	SET  SalesAmountNotRail6Mnth = b.NotRailSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountNotRail) AS NotRailSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
				AND    d.SalesTransactionDate >= DATEADD(M,-6,@today)
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID

	UPDATE a
	SET  SalesAmountNotRail12Mnth = b.NotRailSales
	FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       SUM(d.SalesAmountNotRail) AS NotRailSales
                FROM   [Staging].[STG_Customer] c,
				       [Staging].[STG_SalesTransaction] d
			    WHERE  c.CustomerID = d.CustomerID
				AND    d.SalesTransactionDate >= DATEADD(M,-12,@today)
			    GROUP  BY c.CustomerID) b
            ON  a.CustomerID = b.CustomerID


----Sales Transactions

    UPDATE a 
    SET SalesTransactionTotal = b.SalesTransactionTotal
    FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       COUNT(DISTINCT([SalesTransactionID])) AS SalesTransactionTotal
                FROM [Staging].[STG_Customer] c,
                       [Staging].[STG_SalesTransaction] d
                WHERE c.CustomerID = d.CustomerID
                GROUP BY c.CustomerID) b
            ON a.CustomerID = b.CustomerID

    UPDATE a
    SET SalesTransaction1Mnth = b.SalesTransaction1Mnth
    FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       COUNT(DISTINCT([SalesTransactionID])) AS SalesTransaction1Mnth
                FROM [Staging].[STG_Customer] c,
                       [Staging].[STG_SalesTransaction] d
                WHERE c.CustomerID = d.CustomerID
                AND d.SalesTransactionDate >= DATEADD(M,-1,@today)
                GROUP BY c.CustomerID) b
            ON a.CustomerID = b.CustomerID

    UPDATE a
    SET SalesTransaction3Mnth = b.SalesTransaction3Mnth
    FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       COUNT(DISTINCT([SalesTransactionID])) AS SalesTransaction3Mnth
                FROM [Staging].[STG_Customer] c,
                       [Staging].[STG_SalesTransaction] d
                WHERE c.CustomerID = d.CustomerID
                AND d.SalesTransactionDate >= DATEADD(M,-3,@today)
                GROUP BY c.CustomerID) b
            ON a.CustomerID = b.CustomerID

    UPDATE a
    SET SalesTransaction6Mnth = b.SalesTransaction6Mnth
    FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       COUNT(DISTINCT([SalesTransactionID])) AS SalesTransaction6Mnth
                FROM [Staging].[STG_Customer] c,
                       [Staging].[STG_SalesTransaction] d
                WHERE c.CustomerID = d.CustomerID
                AND d.SalesTransactionDate >= DATEADD(M,-6,@today)
                GROUP BY c.CustomerID) b
            ON a.CustomerID = b.CustomerID

    UPDATE a
    SET SalesTransaction12Mnth = b.SalesTransaction12Mnth
    FROM [Production].[Customer] a
    INNER JOIN (SELECT c.CustomerID,
                       COUNT(DISTINCT([SalesTransactionID])) AS SalesTransaction12Mnth
                FROM [Staging].[STG_Customer] c,
                       [Staging].[STG_SalesTransaction] d
                WHERE c.CustomerID = d.CustomerID
                AND d.SalesTransactionDate >= DATEADD(M,-12,@today)
                GROUP BY c.CustomerID) b
            ON a.CustomerID = b.CustomerID 

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END