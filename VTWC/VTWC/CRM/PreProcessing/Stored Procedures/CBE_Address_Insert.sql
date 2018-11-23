CREATE PROCEDURE [PreProcessing].[CBE_Address_Insert]
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
	DECLARE @addresstypeidcontact     INTEGER

	DECLARE @now                      DATETIME
	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)
	DECLARE @successcountimport       INTEGER = 0
	DECLARE @errorcountimport         INTEGER = 0

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

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

    --Get configuration settings

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'CBE'

    SELECT @addresstypeidbilling = AddressTypeID
	FROM   Reference.AddressType
	WHERE  Name = 'Billing'

	SELECT @addresstypeidshipping = AddressTypeID
	FROM   Reference.AddressType
	WHERE  Name = 'Shipping'

	SELECT @addresstypeidcontact = AddressTypeID
	FROM   Reference.AddressType
	WHERE  Name = 'Contact'

	IF @informationsourceid IS NULL
	   OR @addresstypeidbilling IS NULL
	   OR @addresstypeidshipping IS NULL
	   OR @addresstypeidcontact IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') +
		                  ', @addresstypeidbilling = ' + ISNULL(CAST(@addresstypeidbilling AS NVARCHAR(256)),'NULL') +
						  ', @addresstypeidshipping = ' + ISNULL(CAST(@addresstypeidshipping AS NVARCHAR(256)),'NULL') + 
						  ', @addresstypeidcontact = '  + ISNULL(CAST(@addresstypeidcontact AS NVARCHAR(256)),'NULL')
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

	--Has their primary billing address changed?

	;WITH BillingAddresses AS
	(
         SELECT TOP 99999999 
				b.CustomerID
		        ,a.Date_Created
		        ,LTRIM(RTRIM(a.[Address_Line_1])) AS Address_Line_1
		        ,LTRIM(RTRIM(a.[Address_Line_2])) AS Address_Line_2
		        ,LTRIM(RTRIM(a.[Address_Line_3])) AS Address_Line_3
		        ,LTRIM(RTRIM(a.[Address_Line_4])) AS Address_Line_4
		        ,LTRIM(RTRIM(a.[Address_Line_5])) AS Address_Line_5
		        ,LTRIM(RTRIM(a.[Postcode]))       AS Postcode
		        ,d.CountryID
                ,ROW_NUMBER() OVER(Partition BY b.CustomerID
		                                       ,LTRIM(RTRIM(a.[Address_Line_1]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_2]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_3]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_4]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_5]))
		                                       ,LTRIM(RTRIM(a.[Postcode]))
		                                       ,d.CountryID
                                   ORDER BY a.Date_Created) AS Ranking
	     FROM   [PreProcessing].[CBE_Address]	a WITH (NOLOCK)
		 INNER JOIN [Staging].[STG_KeyMapping]  b WITH (NOLOCK) ON a.CD_ID = b.CBECustomerID
	     INNER JOIN [Reference].[Country]		d WITH (NOLOCK) ON d.Code = LTRIM(RTRIM(a.[Country]))
		                                        AND a.Date_Created BETWEEN d.ValidityStartDate AND d.ValidityEndDate
		 LEFT JOIN [Staging].[STG_Address]		c WITH (NOLOCK) ON b.CustomerID = c.CustomerID
	                                            AND ISNULL(LTRIM(RTRIM(a.[Address_Line_1])),'') = ISNULL(c.[AddressLine1],'')
									            AND ISNULL(LTRIM(RTRIM(a.[Address_Line_2])),'') = ISNULL(c.[AddressLine2],'')
									            AND ISNULL(LTRIM(RTRIM(a.[Address_Line_3])),'') = ISNULL(c.[AddressLine3],'')
										        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_4])),'') = ISNULL(c.[AddressLine4],'')
										        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_5])),'') = ISNULL(c.[AddressLine5],'')
									            AND ISNULL(LTRIM(RTRIM(a.[Postcode])),'')       = ISNULL(c.PostalCode,'')
										        AND c.AddressTypeID = @addresstypeidbilling
												AND c.PrimaryInd = 1
         WHERE c.CustomerID IS NULL
		 AND   a.Is_Billing_Address = 1
		 AND   (a.[Address_Line_1]   IS NOT NULL
	           OR a.[Address_Line_2] IS NOT NULL
	           OR a.[Address_Line_3] IS NOT NULL
	           OR a.[Address_Line_4] IS NOT NULL
	           OR a.[Address_Line_5] IS NOT NULL
	           OR a.[Postcode]       IS NOT NULL)
	     AND   a.DataImportDetailID = @dataimportdetailid
    )

	SELECT CustomerID
		  ,Date_Created
		  ,Address_Line_1
		  ,Address_Line_2
		  ,Address_Line_3
		  ,Address_Line_4
		  ,Address_Line_5
		  ,Postcode
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
           ,[PostalCode]
           ,[CountryID]
           ,[AddressTypeID])
    SELECT CustomerID
	      ,GETDATE()
	      ,@userid
		  ,GETDATE()
		  ,@userid
		  ,@informationsourceid
		  ,Date_Created
		  ,Date_Created
		  ,Address_Line_1
		  ,Address_Line_2
		  ,Address_Line_3
		  ,Address_Line_4
		  ,Address_Line_5
		  ,Postcode
		  ,CountryID
		  ,@addresstypeidbilling
	FROM #tmp_billingaddress

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

	--Has their shipping address changed?

	;WITH ShippingAddresses AS
	(
         SELECT TOP 99999999 
				b.CustomerID
		        ,a.Date_Created
		        ,LTRIM(RTRIM(a.[Address_Line_1])) AS Address_Line_1
		        ,LTRIM(RTRIM(a.[Address_Line_2])) AS Address_Line_2
		        ,LTRIM(RTRIM(a.[Address_Line_3])) AS Address_Line_3
		        ,LTRIM(RTRIM(a.[Address_Line_4])) AS Address_Line_4
		        ,LTRIM(RTRIM(a.[Address_Line_5])) AS Address_Line_5
		        ,LTRIM(RTRIM(a.[Postcode]))       AS Postcode
		        ,d.CountryID
                ,ROW_NUMBER() OVER(Partition BY b.CustomerID
		                                       ,LTRIM(RTRIM(a.[Address_Line_1]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_2]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_3]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_4]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_5]))
		                                       ,LTRIM(RTRIM(a.[Postcode]))
		                                       ,d.CountryID
                                   ORDER BY a.Date_Created) AS Ranking
	     FROM   [PreProcessing].[CBE_Address]  a WITH (NOLOCK)
	     INNER JOIN [Staging].[STG_KeyMapping] b WITH (NOLOCK) ON a.CD_ID = b.CBECustomerID
	     INNER JOIN [Reference].[Country]	   d WITH (NOLOCK) ON d.Code = LTRIM(RTRIM(a.[Country]))
		                                         AND a.Date_Created BETWEEN d.ValidityStartDate AND d.ValidityEndDate                               
	     LEFT JOIN [Staging].[STG_Address]	   c WITH (NOLOCK) ON b.CustomerID = c.CustomerID
	                                             AND ISNULL(LTRIM(RTRIM(a.[Address_Line_1])),'') = ISNULL(c.[AddressLine1],'')
									             AND ISNULL(LTRIM(RTRIM(a.[Address_Line_2])),'') = ISNULL(c.[AddressLine2],'')
									             AND ISNULL(LTRIM(RTRIM(a.[Address_Line_3])),'') = ISNULL(c.[AddressLine3],'')
										         AND ISNULL(LTRIM(RTRIM(a.[Address_Line_4])),'') = ISNULL(c.[AddressLine4],'')
										         AND ISNULL(LTRIM(RTRIM(a.[Address_Line_5])),'') = ISNULL(c.[AddressLine5],'')
									             AND ISNULL(LTRIM(RTRIM(a.[Postcode])),'')       = ISNULL(c.PostalCode,'')
										         AND c.AddressTypeID = @addresstypeidshipping
         WHERE c.CustomerID IS NULL
		 AND   a.Is_Delivery_Address = 1
		 AND   (a.[Address_Line_1]   IS NOT NULL
	           OR a.[Address_Line_2] IS NOT NULL
	           OR a.[Address_Line_3] IS NOT NULL
	           OR a.[Address_Line_4] IS NOT NULL
	           OR a.[Address_Line_5] IS NOT NULL
	           OR a.[Postcode]       IS NOT NULL)
	     AND   a.DataImportDetailID = @dataimportdetailid
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
		  ,Date_Created
		  ,Date_Created
		  ,Address_Line_1
		  ,Address_Line_2
		  ,Address_Line_3
		  ,Address_Line_4
		  ,Address_Line_5
		  ,Postcode
		  ,CountryID
		  ,@addresstypeidshipping
		  ,0
	FROM ShippingAddresses
    WHERE Ranking = 1

	--Has their contact address changed?

	;WITH ContactAddresses AS
	(
         SELECT TOP 99999999 
				b.CustomerID
		        ,a.Date_Created
		        ,LTRIM(RTRIM(a.[Address_Line_1])) AS Address_Line_1
		        ,LTRIM(RTRIM(a.[Address_Line_2])) AS Address_Line_2
		        ,LTRIM(RTRIM(a.[Address_Line_3])) AS Address_Line_3
		        ,LTRIM(RTRIM(a.[Address_Line_4])) AS Address_Line_4
		        ,LTRIM(RTRIM(a.[Address_Line_5])) AS Address_Line_5
		        ,LTRIM(RTRIM(a.[Postcode]))       AS Postcode
		        ,d.CountryID
                ,ROW_NUMBER() OVER(Partition BY b.CustomerID
		                                       ,LTRIM(RTRIM(a.[Address_Line_1]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_2]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_3]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_4]))
		                                       ,LTRIM(RTRIM(a.[Address_Line_5]))
		                                       ,LTRIM(RTRIM(a.[Postcode]))
		                                       ,d.CountryID
                                   ORDER BY a.Date_Created) AS Ranking
	     FROM   [PreProcessing].[CBE_Address]  a WITH (NOLOCK)
	     INNER JOIN [Staging].[STG_KeyMapping] b WITH (NOLOCK) ON a.CD_ID = b.CBECustomerID
	     INNER JOIN [Reference].[Country]	   d WITH (NOLOCK) ON d.Code = LTRIM(RTRIM(a.[Country]))            
		                                         AND a.Date_Created BETWEEN d.ValidityStartDate AND d.ValidityEndDate                   
	     LEFT JOIN [Staging].[STG_Address]	   c WITH (NOLOCK) ON b.CustomerID = c.CustomerID
	                                             AND ISNULL(LTRIM(RTRIM(a.[Address_Line_1])),'') = ISNULL(c.[AddressLine1],'')
									             AND ISNULL(LTRIM(RTRIM(a.[Address_Line_2])),'') = ISNULL(c.[AddressLine2],'')
									             AND ISNULL(LTRIM(RTRIM(a.[Address_Line_3])),'') = ISNULL(c.[AddressLine3],'')
										         AND ISNULL(LTRIM(RTRIM(a.[Address_Line_4])),'') = ISNULL(c.[AddressLine4],'')
										         AND ISNULL(LTRIM(RTRIM(a.[Address_Line_5])),'') = ISNULL(c.[AddressLine5],'')
									             AND ISNULL(LTRIM(RTRIM(a.[Postcode])),'')       = ISNULL(c.PostalCode,'')
										         AND c.AddressTypeID = @addresstypeidcontact
         WHERE c.CustomerID IS NULL
		 AND   a.Is_Contact_Address = 1
		 AND   (a.[Address_Line_1]   IS NOT NULL
	           OR a.[Address_Line_2] IS NOT NULL
	           OR a.[Address_Line_3] IS NOT NULL
	           OR a.[Address_Line_4] IS NOT NULL
	           OR a.[Address_Line_5] IS NOT NULL
	           OR a.[Postcode]       IS NOT NULL)
	     AND   a.DataImportDetailID = @dataimportdetailid
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
		  ,Date_Created
		  ,Date_Created
		  ,Address_Line_1
		  ,Address_Line_2
		  ,Address_Line_3
		  ,Address_Line_4
		  ,Address_Line_5
		  ,Postcode
		  ,CountryID
		  ,@addresstypeidcontact
		  ,0
	FROM ContactAddresses
    WHERE Ranking = 1

	SELECT @recordcount = @recordcount + @@ROWCOUNT

	UPDATE a
	SET [LastModifiedDateETL] = GETDATE()
	   ,ProcessedInd          = 1
    FROM [PreProcessing].[CBE_Address] a
	INNER JOIN [Staging].[STG_KeyMapping] b ON a.CD_ID = b.CBECustomerID
	INNER JOIN [Reference].[Country]      d ON d.Code = LTRIM(RTRIM(a.[Country]))
	INNER JOIN [Staging].[STG_Address]    c ON b.CustomerID = c.CustomerID
	                                        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_1])),'') = ISNULL(c.[AddressLine1],'')
									        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_2])),'') = ISNULL(c.[AddressLine2],'')
									        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_3])),'') = ISNULL(c.[AddressLine3],'')
										    AND ISNULL(LTRIM(RTRIM(a.[Address_Line_4])),'') = ISNULL(c.[AddressLine4],'')
										    AND ISNULL(LTRIM(RTRIM(a.[Address_Line_5])),'') = ISNULL(c.[AddressLine5],'')
									        AND ISNULL(LTRIM(RTRIM(a.[Postcode])),'')       = ISNULL(c.PostalCode,'')
										    AND c.AddressTypeID = @addresstypeidbilling
											AND d.CountryID = d.CountryID
    WHERE a.Is_Billing_Address = 1
	AND   a.ProcessedInd       = 0
	AND   a.DataImportDetailID = @dataimportdetailid

	UPDATE a
	SET [LastModifiedDateETL] = GETDATE()
	   ,ProcessedInd          = 1
    FROM [PreProcessing].[CBE_Address] a
	INNER JOIN [Staging].[STG_KeyMapping] b ON a.CD_ID = b.CBECustomerID
	INNER JOIN [Reference].[Country]      d ON d.Code = LTRIM(RTRIM(a.[Country]))
	INNER JOIN [Staging].[STG_Address]    c ON b.CustomerID = c.CustomerID
	                                        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_1])),'') = ISNULL(c.[AddressLine1],'')
									        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_2])),'') = ISNULL(c.[AddressLine2],'')
									        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_3])),'') = ISNULL(c.[AddressLine3],'')
										    AND ISNULL(LTRIM(RTRIM(a.[Address_Line_4])),'') = ISNULL(c.[AddressLine4],'')
										    AND ISNULL(LTRIM(RTRIM(a.[Address_Line_5])),'') = ISNULL(c.[AddressLine5],'')
									        AND ISNULL(LTRIM(RTRIM(a.[Postcode])),'')       = ISNULL(c.PostalCode,'')
										    AND c.AddressTypeID = @addresstypeidshipping
											AND d.CountryID = d.CountryID
    WHERE a.Is_Delivery_Address = 1
	AND   a.ProcessedInd       = 0
	AND   a.DataImportDetailID = @dataimportdetailid

	UPDATE a
	SET [LastModifiedDateETL] = GETDATE()
	   ,ProcessedInd          = 1
    FROM [PreProcessing].[CBE_Address] a
	INNER JOIN [Staging].[STG_KeyMapping] b ON a.CD_ID = b.CBECustomerID
	INNER JOIN [Reference].[Country]      d ON d.Code = LTRIM(RTRIM(a.[Country]))
	INNER JOIN [Staging].[STG_Address]    c ON b.CustomerID = c.CustomerID
	                                        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_1])),'') = ISNULL(c.[AddressLine1],'')
									        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_2])),'') = ISNULL(c.[AddressLine2],'')
									        AND ISNULL(LTRIM(RTRIM(a.[Address_Line_3])),'') = ISNULL(c.[AddressLine3],'')
										    AND ISNULL(LTRIM(RTRIM(a.[Address_Line_4])),'') = ISNULL(c.[AddressLine4],'')
										    AND ISNULL(LTRIM(RTRIM(a.[Address_Line_5])),'') = ISNULL(c.[AddressLine5],'')
									        AND ISNULL(LTRIM(RTRIM(a.[Postcode])),'')       = ISNULL(c.PostalCode,'')
										    AND c.AddressTypeID = @addresstypeidcontact
											AND d.CountryID = d.CountryID
    WHERE a.Is_Contact_Address = 1
	AND   a.ProcessedInd       = 0
	AND   a.DataImportDetailID = @dataimportdetailid

    --logging
	
	SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_Address WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_Address WITH (NOLOCK)
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
 
	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END