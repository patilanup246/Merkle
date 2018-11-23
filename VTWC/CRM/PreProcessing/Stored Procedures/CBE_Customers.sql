

CREATE PROCEDURE [PreProcessing].[CBE_Customers]
(
    @userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @cbe_customerid         INTEGER
	DECLARE @addresstypeidemail     INTEGER
	DECLARE @addresstypeidmobile    INTEGER

    DECLARE @now                    DATETIME
	DECLARE @spname                 NVARCHAR(256)	
	DECLARE @recordcount            INTEGER
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0
	
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT
	SELECT @now = GETDATE()

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	                                            @starttimepreprocessing      = NULL,
	                                            @endtimepreprocessing        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

	SELECT @addresstypeidemail = AddressTypeID
	FROM Reference.AddressType
	WHERE Name = 'Email'

	SELECT @addresstypeidmobile = AddressTypeID
	FROM Reference.AddressType
	WHERE Name = 'Mobile'

    IF @addresstypeidemail IS NULL OR @addresstypeidmobile IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @addresstypeidemail or @addresstypeidmobile; @dataimportdetailid = ' + ISNULL(CAST(@dataimportdetailid AS NVARCHAR(256)),'NULL')
		
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END


	--Identify existing customers with no changes and set to Processed as these can be skipped

	;WITH CTE_Matching_Customers AS (
                SELECT TOP 99999
					   TCScustomerID
                      ,Title
	                  ,forename
	                  ,surname
	                  ,ParsedAddressEmail
					  ,ParsedAddressMobile
                FROM  PreProcessing.TOCPLUS_Customer WITH (NOLOCK)
				WHERE DataImportDetailID = @dataimportdetailid
		        AND    ProcessedInd = 0
				INTERSECT
				SELECT TOP 99999
					   km.TCSCustomerID
                      ,cust.Salutation
	                  ,cust.FirstName
	                  --,cust.MiddleName
	                  ,cust.LastName
	                  ,ea.ParsedAddress
					  ,eam.ParsedAddress
                FROM Staging.STG_KeyMapping km WITH (NOLOCK)
                INNER JOIN Staging.STG_Customer			 cust WITH (NOLOCK) ON km.CustomerID = cust.CustomerID
                LEFT  JOIN Staging.STG_ElectronicAddress ea WITH (NOLOCK) ON ea.CustomerID = km.CustomerID
                                                                 AND ea.AddressTypeID = @addresstypeidemail
                                                                 AND ea.PrimaryInd = 1
                LEFT  JOIN Staging.STG_ElectronicAddress eam WITH (NOLOCK) ON eam.CustomerID = km.CustomerID
                                                                   AND eam.AddressTypeID = @addresstypeidmobile
                                                                   AND eam.PrimaryInd = 1
				WHERE km.TCSCustomerID IS NOT NULL
																 )

    UPDATE a
	SET   [ProcessedInd] = 1
	     ,[LastModifiedDateETL] = GETDATE()
    FROM  PreProcessing.TOCPLUS_Customer a
	INNER JOIN CTE_Matching_Customers b ON a.TCScustomerID = b.TCScustomerID
	WHERE DataImportDetailID = @dataimportdetailid
	AND    ProcessedInd = 0
				
	--Process any new or modified TVM's

	DECLARE TVM_Customers CURSOR READ_ONLY
	FOR
	    SELECT TCScustomerID
		FROM   PreProcessing.TOCPLUS_Customer WITH (NOLOCK)
		WHERE  DataImportDetailID = @dataimportdetailid
		AND    ProcessedInd = 0
		--AND    Account_Type = 'Virtual'
		--AND    Retail_Channel_Code = 'TVM'
		
		OPEN TVM_Customers
		
		FETCH NEXT FROM TVM_Customers
		    INTO @cbe_customerid

        WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC [PreProcessing].[CBE_Customer_Process] @userid             = @userid,
			                                            @cbe_customerid     = @cbe_customerid,
														@dataimportdetailid = @dataimportdetailid
		    FETCH NEXT FROM TVM_Customers
		        INTO @cbe_customerid

        END

		CLOSE TVM_Customers

    DEALLOCATE TVM_Customers

	--Process any new or updated customers
	
	DECLARE Customers CURSOR READ_ONLY
	FOR
	    SELECT TCScustomerID
		FROM   PreProcessing.TOCPLUS_Customer WITH (NOLOCK)
		WHERE  DataImportDetailID = @dataimportdetailid
		AND    ProcessedInd = 0
		--AND    Account_Type IN ('Full','Partial')
		
		OPEN Customers
		
		FETCH NEXT FROM Customers
		    INTO @cbe_customerid

        WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC [PreProcessing].[CBE_Customer_Process] @userid             = @userid,
			                                            @cbe_customerid     = @cbe_customerid,
														@dataimportdetailid = @dataimportdetailid
		    FETCH NEXT FROM Customers
		        INTO @cbe_customerid

        END

		CLOSE Customers

    DEALLOCATE Customers

    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.TOCPLUS_Customer
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Customer
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
	                                            @starttimepreprocessing      = NULL,
	                                            @endtimepreprocessing        = NULL,
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