CREATE PROCEDURE [PreProcessing].[CBE_EVoucherType_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid    INTEGER
	DECLARE @maxvalidityend         DATETIME

	DECLARE @now                    DATETIME
	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)
	DECLARE @successcountimport    INTEGER       = 0
	DECLARE @errorcountimport      INTEGER       = 0

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

	SELECT @maxvalidityend = CAST([Reference].[Configuration_GetSetting] ('Operations','Maximum Validity End Date') AS DATETIME)

	IF @informationsourceid IS NULL OR @maxvalidityend IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid or @maxvalidityend; ' +
		                  '@informationsourceid = ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') + 
						  '@maxvalidityend = '      + ISNULL(CAST(@maxvalidityend AS NVARCHAR(256)),'NULL') 
		
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

        RETURN
    END

    --It is possible for CBE to mutiple changes during a batch window. Only require the latest information

    --Start Processing - updates first

	;WITH CTE_Evoucher_Type AS (
	              SELECT TOP 999999999
						 a.[ID]
                        ,a.[Voucher_Type]
                        ,a.[Description]
                        ,a.[Max_Value]
                        ,a.[Max_Expiry_Period]
                        ,a.[Default_Expiry_Period]
                        ,a.[Denominations]
                        ,a.[Requestor]
                        ,a.[Requesting_Org]
                        ,a.[Receipient]
                        ,a.[Receipient_Org]
                        ,a.[Created_By]
                        ,a.[Date_Created]
                        ,a.[Date_Modified]
                        ,a.[Is_Active]
                        ,a.[Default_Ur_Id]
				        ,ROW_NUMBER() OVER (partition by [Voucher_Type] ORDER BY a.[Date_Modified] DESC
						                                                       , a.[CreatedDateETL] DESC) RANKING
                  FROM   [PreProcessing].[CBE_EvoucherTypeConfiguration] a WITH (NOLOCK)
				  WHERE  a.DataImportDetailID = @dataimportdetailid
	              AND    a.ProcessedInd = 0)

    SELECT *
	INTO #tmp_EvoucherType
	FROM CTE_Evoucher_Type
	WHERE RANKING = 1

	--eVoucher Types in [Reference].[EVoucherType] but not in #tmp_EvoucherType are to be treated as expired references

	UPDATE a
	SET  ValidityEndDate        = GETDATE()
	    ,ArchivedInd            = 1
		,LastModifiedDate       = GETDATE()
		,LastModifiedBy         = @userid
    FROM [Reference].[EVoucherType] a
	LEFT JOIN #tmp_EvoucherType     b ON a.ExtReference = b.[Voucher_Type]
	WHERE a.InformationSourceID = @informationsourceid
	AND a.ArchivedInd = 0
	AND b.[Voucher_Type] IS NULL

	--Updates

	UPDATE b
	SET    Description            = a.Description
	      ,MaxValue               = a.[Max_Value]
		  ,MaxExpiryPeriod        = a.[Max_Expiry_Period]
		  ,DefaultExpiryPeriod    = a.[Default_Expiry_Period]
		  ,Denomination           = a.[Denominations]
		  ,Requestor              = a.[Requestor]
		  ,RequestingOrganisation = a.[Requesting_Org]
		  ,Receipient             = a.[Receipient]
		  ,ReceipientOrganisation = a.[Receipient_Org]
		  ,SourceModifiedDate     = a.[Date_Modified]
		  ,ArchivedInd            = CASE WHEN a.[Is_Active] = 1 THEN 0 ELSE 1 END
		  ,LastModifiedDate       = GETDATE()
	FROM #tmp_EvoucherType a
	INNER JOIN [Reference].[EVoucherType] b ON b.ExtReference = a.[Voucher_Type]
	                                        AND b.InformationSourceID = @informationsourceid
											AND b.ArchivedInd = 0
	
	--Update process records

    UPDATE b
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
    FROM [Reference].[EVoucherType] a
	INNER JOIN  [PreProcessing].[CBE_EvoucherTypeConfiguration] b ON a.ExtReference = b.[Voucher_Type]
	                                                              AND a.InformationSourceID = @informationsourceid
    WHERE b.DataImportDetailID = @dataimportdetailid
	AND   b.ProcessedInd = 0
	
	SELECT @recordcount = @@ROWCOUNT

	--Now for new records

    INSERT INTO [Reference].[EVoucherType]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[InformationSourceID]
           ,[MaxValue]
           ,[MaxExpiryPeriod]
           ,[DefaultExpiryPeriod]
           ,[Denomination]
           ,[Requestor]
           ,[RequestingOrganisation]
           ,[Receipient]
           ,[ReceipientOrganisation]
           ,[ExtReference]
		   ,[ValidityStartDate]
		   ,[ValidityEndDate])
    SELECT  a.[Voucher_Type]
           ,a.[Description]
           ,GETDATE()
		   ,@userid
		   ,GETDATE()
		   ,@userid
		   ,CASE WHEN a.[Is_Active] = 1 THEN 0 ELSE 1 END
		   ,a.[Date_Created]
		   ,a.[Date_Modified]
		   ,@informationsourceid
		   ,a.[Max_Value]
           ,a.[Max_Expiry_Period]
           ,a.[Default_Expiry_Period]
           ,a.[Denominations]
           ,a.[Requestor]
           ,a.[Requesting_Org]
           ,a.[Receipient]
           ,a.[Receipient_Org]
           ,a.[Voucher_Type]
		   ,a.[Date_Created]
		   ,CASE WHEN a.Is_Active = 1 THEN GETDATE() ELSE @maxvalidityend END
    FROM #tmp_EvoucherType a  WITH (NOLOCK)
	LEFT JOIN [Reference].[EVoucherType] b WITH (NOLOCK) ON  a.[Voucher_Type] = b.[ExtReference]
	                                       AND b.InformationSourceID = @informationsourceid
 										   AND b.ArchivedInd = CASE WHEN a.Is_Active = 1 THEN 0 ELSE 1 END
	WHERE b.ExtReference IS NULL
	AND   a.Is_Active = 1
	
	--Update process records

	UPDATE b
	SET [ProcessedInd] = 1
	   ,[LastModifiedDateETL] = GETDATE()
    FROM [Reference].[EVoucherType] a
	INNER JOIN [PreProcessing].[CBE_EvoucherTypeConfiguration] b ON a.ExtReference = b.[Voucher_Type]
	                                                    AND a.InformationSourceID = @informationsourceid
	WHERE b.[DataImportDetailID] = @dataimportdetailid
	AND   b.[ProcessedInd] = 0

	--logging
	
    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[CBE_EvoucherTypeConfiguration] WITH (NOLOCK)
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   [PreProcessing].[CBE_EvoucherTypeConfiguration] WITH (NOLOCK)
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