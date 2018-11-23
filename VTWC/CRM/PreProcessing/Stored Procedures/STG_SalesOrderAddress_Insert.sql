
CREATE PROCEDURE [PreProcessing].[STG_SalesOrderAddress_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid      INTEGER
    DECLARE @addresstypeidbilling     INTEGER
	DECLARE @addresstypeidshipping    INTEGER

	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Delta - MSD'

    SELECT @addresstypeidbilling = AddressTypeID
	FROM   Reference.AddressType
	WHERE  Name = 'Billing'

	SELECT @addresstypeidshipping = AddressTypeID
	FROM   Reference.AddressType
	WHERE  Name = 'Shipping'

	IF @informationsourceid IS NULL
	   OR @addresstypeidbilling IS NULL
	   OR @addresstypeidshipping IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL') +
		                  ', @addresstypeidbilling = ' + ISNULL(@addresstypeidbilling,'NULL') +
						  ', @addresstypeidshipping = ' + ISNULL(@addresstypeidshipping,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END

	--Has their primary address changed?

	;WITH BillingAddresses AS
	(
         SELECT  b.CustomerID
		        ,Staging.SetUKTime(a.CreatedOn) as CreatedOn
		        ,Staging.SetUKTime(a.out_orderplacedate) as out_orderplacedate
		        ,LTRIM(RTRIM(a.[BillTo_Line1]))           AS BillTo_Line1
		        ,LTRIM(RTRIM(a.[BillTo_Line2]))           AS BillTo_Line2
		        ,LTRIM(RTRIM(a.[BillTo_Line3]))           AS BillTo_Line3
		        ,LTRIM(RTRIM(a.[out_billto_line4]))       AS BillTo_Line4
		        ,LTRIM(RTRIM(a.[out_billto_line5]))       AS BillTo_Line5
		        ,LTRIM(RTRIM(a.[BillTo_City]))            AS BillTo_City
		        ,LTRIM(RTRIM(a.[BillTo_StateOrProvince])) AS BillTo_StateOrProvince
		        ,LTRIM(RTRIM(a.[BillTo_PostalCode]))      AS BillTo_PostalCode
		        ,d.CountryID
                ,ROW_NUMBER() OVER(Partition BY b.CustomerID
		                                       ,LTRIM(RTRIM(a.[BillTo_Line1]))
		                                       ,LTRIM(RTRIM(a.[BillTo_Line2]))
		                                       ,LTRIM(RTRIM(a.[BillTo_Line3]))
		                                       ,LTRIM(RTRIM(a.[out_billto_line4]))
		                                       ,LTRIM(RTRIM(a.[out_billto_line5]))
		                                       ,LTRIM(RTRIM(a.[BillTo_City]))
		                                       ,LTRIM(RTRIM(a.[BillTo_StateOrProvince]))
		                                       ,LTRIM(RTRIM(a.[BillTo_PostalCode]))
		                                       ,d.CountryID
                                   ORDER BY a.out_orderplacedate
								           ,a.CreatedOn) AS Ranking
	     FROM   [PreProcessing].[MSD_SalesOrder] a
	     INNER JOIN [Staging].[STG_KeyMapping] b ON a.ContactID = b.MSDID
	     INNER JOIN [Reference].[Country] d      ON d.Name = LTRIM(RTRIM(a.[BillTo_Country]))                               
	     LEFT JOIN [Staging].[STG_Address] c     ON b.CustomerID = c.CustomerID
	                                             AND ISNULL(LTRIM(RTRIM(a.[BillTo_Line1])),'')           = ISNULL(c.[AddressLine1],'')
									             AND ISNULL(LTRIM(RTRIM(a.[BillTo_Line2])),'')           = ISNULL(c.[AddressLine2],'')
									             AND ISNULL(LTRIM(RTRIM(a.[BillTo_Line3])),'')           = ISNULL(c.[AddressLine3],'')
										         AND ISNULL(LTRIM(RTRIM(a.[out_billto_line4])),'')       = ISNULL(c.[AddressLine4],'')
										         AND ISNULL(LTRIM(RTRIM(a.[out_billto_line5])),'')       = ISNULL(c.[AddressLine5],'')
									             AND ISNULL(LTRIM(RTRIM(a.[BillTo_City])),'')            = ISNULL(c.TownCity,'')
									             AND ISNULL(LTRIM(RTRIM(a.[BillTo_StateOrProvince])),'') = ISNULL(c.County,'')
									             AND LTRIM(RTRIM(a.[BillTo_PostalCode]))                 = ISNULL(c.PostalCode,'')
										         AND c.AddressTypeID = @addresstypeidbilling
												 AND c.PrimaryInd = 1
         WHERE c.CustomerID IS NULL
		 AND   a.ProcessedInd = 1
	     AND  (a.[BillTo_Line1] IS NOT NULL
	           OR a.[BillTo_Line2] IS NOT NULL
	           OR a.[BillTo_Line3] IS NOT NULL
	           OR a.[out_billto_line4] IS NOT NULL
	           OR a.[out_billto_line5] IS NOT NULL
	           OR a.[BillTo_City] IS NOT NULL
	           OR a.[BillTo_StateOrProvince] IS NOT NULL
	           OR a.[BillTo_PostalCode] IS NOT NULL)
	     AND   a.DataImportDetailID = @dataimportdetailid
    )

	SELECT CustomerID
		  ,CreatedOn
		  ,out_orderplacedate
		  ,BillTo_Line1
		  ,BillTo_Line2
		  ,BillTo_Line3
		  ,BillTo_Line4
		  ,BillTo_Line5
		  ,BillTo_City
		  ,BillTo_StateOrProvince
		  ,BillTo_PostalCode
		  ,CountryID
	INTO #tmp_billingaddress
	FROM BillingAddresses
	WHERE Ranking = 1

	INSERT INTO [Staging].[STG_Address]
           ([CustomerID]
		   ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[InformationSourceID]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[AddressLine1]
           ,[AddressLine2]
           ,[AddressLine3]
           ,[AddressLine4]
           ,[AddressLine5]
           ,[TownCity]
           ,[County]
           ,[PostalCode]
           ,[CountryID]
           ,[AddressTypeID])
    SELECT CustomerID
	      ,GETDATE()
	      ,@userid
		  ,GETDATE()
		  ,@userid
		  ,@informationsourceid
		  ,CreatedOn
		  ,out_orderplacedate
		  ,BillTo_Line1
		  ,BillTo_Line2
		  ,BillTo_Line3
		  ,BillTo_Line4
		  ,BillTo_Line5
		  ,BillTo_City
		  ,BillTo_StateOrProvince
		  ,BillTo_PostalCode
		  ,CountryID
		  ,@addresstypeidbilling
	FROM #tmp_billingaddress

	SELECT @recordcount = @@ROWCOUNT

	UPDATE a
    SET AddresseeInAddressInd = 1
    FROM Staging.STG_Address a,
         Staging.STG_Customer b,
		 #tmp_billingaddress c
    WHERE a.CustomerID = b.CustomerID
	AND   a.CustomerID = c.CustomerID
    AND   (CHARINDEX(b.LastName,a.AddressLine1) > 1
       OR AddressLine1 = '-')

	--Now to set the primary for each customer which is the last Billing address used for each customer

	UPDATE a
	SET PrimaryInd = 0
	FROM [Staging].[STG_Address] a,
	     #tmp_billingaddress b
    WHERE a.CustomerID = b.CustomerID
	AND   a.AddressTypeID = @addresstypeidbilling
	AND   a.PrimaryInd = 1

	UPDATE a
    SET PrimaryInd = 1
    FROM [Staging].[STG_Address] a
    INNER JOIN (SELECT a.CustomerID,
	                   a.AddressID,
                       ROW_NUMBER()  OVER (PARTITION BY a.CustomerID ORDER BY  a.SourceCreatedDate DESC,a.SourceModifiedDate DESC, AddressId DESC) AS LatestRow
                FROM   [Staging].[STG_Address] a
				INNER JOIN #tmp_billingaddress b ON a.CustomerID = b.CustomerID
			    WHERE  AddressTypeID = @addresstypeidbilling
			    ) b ON  a.CustomerID = b.CustomerID AND a.AddressID = b.AddressID AND b.LatestRow = 1
    WHERE AddressTypeID = @addresstypeidbilling

	;WITH ShippingAddresses AS
	(
         SELECT  b.CustomerID
		        ,Staging.SetUKTime(a.CreatedOn) as CreatedOn
		        ,Staging.SetUKTime(a.out_orderplacedate) as out_orderplacedate
		        ,LTRIM(RTRIM(a.[ShipTo_Line1]))           AS ShipTo_Line1
		        ,LTRIM(RTRIM(a.[ShipTo_Line2]))           AS ShipTo_Line2
		        ,LTRIM(RTRIM(a.[ShipTo_Line3]))           AS ShipTo_Line3
		        ,LTRIM(RTRIM(a.[out_Shipto_line4]))       AS ShipTo_Line4
		        ,LTRIM(RTRIM(a.[out_Shipto_line5]))       AS ShipTo_Line5
		        ,LTRIM(RTRIM(a.[ShipTo_City]))            AS ShipTo_City
		        ,LTRIM(RTRIM(a.[ShipTo_StateOrProvince])) AS ShipTo_StateOrProvince
		        ,LTRIM(RTRIM(a.[ShipTo_PostalCode]))      AS ShipTo_PostalCode
		        ,d.CountryID
                ,ROW_NUMBER() OVER(Partition BY b.CustomerID
		                                       ,LTRIM(RTRIM(a.[ShipTo_Line1]))
		                                       ,LTRIM(RTRIM(a.[ShipTo_Line2]))
		                                       ,LTRIM(RTRIM(a.[ShipTo_Line3]))
		                                       ,LTRIM(RTRIM(a.[out_Shipto_line4]))
		                                       ,LTRIM(RTRIM(a.[out_Shipto_line5]))
		                                       ,LTRIM(RTRIM(a.[ShipTo_City]))
		                                       ,LTRIM(RTRIM(a.[ShipTo_StateOrProvince]))
		                                       ,LTRIM(RTRIM(a.[ShipTo_PostalCode]))
		                                       ,d.CountryID
                                   ORDER BY a.out_orderplacedate
								           ,a.CreatedOn) AS Ranking
	     FROM [PreProcessing].[MSD_SalesOrder] a
	     INNER JOIN [Staging].[STG_KeyMapping] b ON a.ContactID = b.MSDID
	     LEFT  JOIN [Reference].[Country]      d ON d.Name = CASE LTRIM(RTRIM(a.[ShipTo_Country])) WHEN 'Great Britain' THEN 'United Kingdom'
		                                                     ELSE LTRIM(RTRIM(a.[ShipTo_Country])) END                               
	     LEFT JOIN  [Staging].[STG_Address] c    ON b.CustomerID = c.CustomerID
	                                             AND ISNULL(LTRIM(RTRIM(a.[ShipTo_Line1])),'')           = ISNULL(c.[AddressLine1],'')
									             AND ISNULL(LTRIM(RTRIM(a.[ShipTo_Line2])),'')           = ISNULL(c.[AddressLine2],'')
									             AND ISNULL(LTRIM(RTRIM(a.[ShipTo_Line3])),'')           = ISNULL(c.[AddressLine3],'')
										         AND ISNULL(LTRIM(RTRIM(a.[out_Shipto_line4])),'')       = ISNULL(c.[AddressLine4],'')
										         AND ISNULL(LTRIM(RTRIM(a.[out_Shipto_line5])),'')       = ISNULL(c.[AddressLine5],'')
									             AND ISNULL(LTRIM(RTRIM(a.[ShipTo_City])),'')            = ISNULL(c.TownCity,'')
									             AND ISNULL(LTRIM(RTRIM(a.[ShipTo_StateOrProvince])),'') = ISNULL(c.County,'')
									             AND LTRIM(RTRIM(a.[ShipTo_PostalCode]))                 = ISNULL(c.PostalCode,'')
										         AND c.AddressTypeID = @addresstypeidshipping
         WHERE c.CustomerID IS NULL
	     AND  (a.[ShipTo_Line1] IS NOT NULL
	           OR a.[ShipTo_Line2] IS NOT NULL
	           OR a.[ShipTo_Line3] IS NOT NULL
	           OR a.[out_Shipto_line4] IS NOT NULL
	           OR a.[out_Shipto_line5] IS NOT NULL
	           OR a.[ShipTo_City] IS NOT NULL
	           OR a.[ShipTo_StateOrProvince] IS NOT NULL
	           OR a.[ShipTo_PostalCode] IS NOT NULL)
	     AND   a.DataImportDetailID = @dataimportdetailid
		 AND   a.ProcessedInd = 1
    )
		
	INSERT INTO [Staging].[STG_Address]
           ([CustomerID]
		   ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[InformationSourceID]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[AddressLine1]
           ,[AddressLine2]
           ,[AddressLine3]
           ,[AddressLine4]
           ,[AddressLine5]
           ,[TownCity]
           ,[County]
           ,[PostalCode]
           ,[CountryID]
           ,[AddressTypeID]
	       ,[PrimaryInd])
    SELECT CustomerID
	      ,GETDATE()
	      ,@userid
		  ,GETDATE()
		  ,@userid
		  ,@informationsourceid
		  ,CreatedOn
		  ,out_orderplacedate
		  ,ShipTo_Line1
		  ,ShipTo_Line2
		  ,ShipTo_Line3
		  ,ShipTo_Line4
		  ,ShipTo_Line5
		  ,ShipTo_City
		  ,ShipTo_StateOrProvince
		  ,ShipTo_PostalCode
		  ,CountryID
		  ,@addresstypeidshipping
		  ,0
	FROM ShippingAddresses
    WHERE Ranking = 1

	SELECT @recordcount = @recordcount + @@ROWCOUNT
	
	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END