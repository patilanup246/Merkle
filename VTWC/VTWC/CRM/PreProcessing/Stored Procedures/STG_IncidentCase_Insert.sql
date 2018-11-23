
CREATE PROCEDURE [PreProcessing].[STG_IncidentCase_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @now                    DATETIME
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT


    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Delta - MSD'

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
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

	-- Update existing non-processed records --

	UPDATE a
	SET
				[Name]						= b.ticketnumber
			   ,[Description]				= b.[title]
			   ,[LastModifiedDate]			= GETDATE()
			   ,[LastModifiedBy]			= @userid
			   ,[InformationSourceID]		= @informationsourceid
			   ,[SourceCreatedDate]			= Staging.SetUKTime(CONVERT(datetime, left(b.createdon, -1+CHARINDEX(' ', b.createdon)), 101)+' '+substring(b.createdon, 1+CHARINDEX(' ', b.createdon), CHARINDEX('M', b.createdon)-CHARINDEX(' ', b.createdon)))
			   ,[SourceModifiedDate]		= Staging.SetUKTime(CONVERT(datetime, left(b.modifiedon, -1+CHARINDEX(' ', b.modifiedon)), 101)+' '+substring(b.modifiedon, 1+CHARINDEX(' ', b.modifiedon), CHARINDEX('M', b.modifiedon)-CHARINDEX(' ', b.modifiedon)))
			   ,[CustomerID]				= m.customerid
			   ,[IncidentCaseTypeID]		= r2.IncidentCaseTypeID
			   ,[IncidentCaseStatusID]		= r4.IncidentCaseStatusID
			   ,[IncidentCaseReasonID]		= r.IncidentCaseReasonID
			   ,[SalesTransactionIDOriginal]= t.SalesTransactionID
			   ,[SalesTransactionIDNew]		= t2.SalesTransactionID
			   ,[IncidentCaseRefundTypeID]	= r3.IncidentCaseRefundTypeID
			   ,[CaseNumber]				= b.[ticketnumber]
			   ,[ExtReference]				= b.[incidentid]
			   ,[ComplaintInd]				= case when [out_complaint] = 'true' then 1 else 0 end
			   ,[DateRefunded]				= Staging.SetUKTime(convert(datetime, b.out_daterefunded, 101))
			   ,[RefundAmount]				= convert(decimal(14,2),coalesce(out_refundamount,'0'))
	FROM  	[Staging].[STG_IncidentCase] a
			inner join [PreProcessing].[MSD_Incident] b on a.ExtReference = CAST(b.incidentid AS NVARCHAR(256))
			inner join Staging.STG_KeyMapping m on b.customerid=m.msdid
			inner join Staging.STG_SalesTransaction t on t.ExtReference=b.out_originalbookingid
			left  join Staging.STG_SalesTransaction t2 on t2.ExtReference=b.out_newbookingid
			left join Reference.IncidentCaseReason r on r.[ExtReference] = b.out_amendmentreason
			left join Reference.IncidentCaseType r2 on r2.[ExtReference] = b.caseorigincode
			left join Reference.IncidentCaseRefundType r3 on r3.[ExtReference] = b.out_refundcode
			left join Reference.IncidentCaseStatus r4 on r4.[ExtReference] = b.statecode
			--left join Staging.STG_IncidentCase g on g.ExtReference = CAST(b.incidentid AS NVARCHAR(256))
			WHERE	b.ProcessedInd = 0
				AND b.DataImportDetailID = @dataimportdetailid


	-- insert new non-processed records --

	INSERT INTO [Staging].[STG_IncidentCase]
			   ([Name]
			   ,[Description]
			   ,[CreatedDate]
			   ,[CreatedBy]
			   ,[LastModifiedDate]
			   ,[LastModifiedBy]
			   ,[InformationSourceID]
			   ,[SourceCreatedDate]
			   ,[SourceModifiedDate]
			   ,[CustomerID]
			   ,[IncidentCaseTypeID]
			   ,[IncidentCaseStatusID]
			   ,[IncidentCaseReasonID]
			   ,[SalesTransactionIDOriginal]
			   ,[SalesTransactionIDNew]
			   ,[IncidentCaseRefundTypeID]
			   ,[CaseNumber]
			   ,[ExtReference]
			   ,[ComplaintInd]
			   ,[DateRefunded]
			   ,[RefundAmount])
	SELECT
			ticketnumber					[Name]
			,[title]						[Description]
			,GETDATE()						[CreatedDate]
			,@userid						[CreatedBy]
			,GETDATE()						[LastModifiedDate]
			,@userid						[LastModifiedBy]
			,@informationsourceid			[InformationSourceID]
			,Staging.SetUKTime(CONVERT(datetime, left(createdon, -1+CHARINDEX(' ', createdon)), 101)+' '+substring(createdon, 1+CHARINDEX(' ', createdon), CHARINDEX('M', createdon)-CHARINDEX(' ', createdon))) as [SourceCreatedDate] --M/d/yyyy h:mm:ss AM
			,Staging.SetUKTime(CONVERT(datetime, left(modifiedon, -1+CHARINDEX(' ', modifiedon)), 101)+' '+substring(modifiedon, 1+CHARINDEX(' ', modifiedon), CHARINDEX('M', modifiedon)-CHARINDEX(' ', modifiedon))) as [SourceModifiedDate] --M/d/yyyy h:mm:ss AM
			,m.customerid
			,r2.IncidentCaseTypeID			[IncidentCaseTypeID]
			,r4.IncidentCaseStatusID
			,r.IncidentCaseReasonID
			,t.SalesTransactionID			[SalesTransactionIDOriginal]
			,t2.SalesTransactionID			[SalesTransactionIDNew]
			,r3.IncidentCaseRefundTypeID	[IncidentCaseRefundTypeID]
			,[ticketnumber]					[CaseNumber]
			,a.[incidentid]					[ExtReference]
			,case when [out_complaint] = 'true' then 1 else 0 end [ComplaintInd]
			,Staging.SetUKTime(convert(datetime, a.out_daterefunded, 101))
			,convert(decimal(14,2),coalesce(out_refundamount,'0')) as RefundAmount
			FROM [PreProcessing].[MSD_Incident] a
			inner join Staging.STG_KeyMapping m on a.customerid=m.msdid
			inner join Staging.STG_SalesTransaction t on t.ExtReference=a.out_originalbookingid
			left  join Staging.STG_SalesTransaction t2 on t2.ExtReference=a.out_newbookingid
			left join Reference.IncidentCaseReason r on r.[ExtReference] = a.out_amendmentreason
			left join Reference.IncidentCaseType r2 on r2.[ExtReference] = a.caseorigincode
			left join Reference.IncidentCaseRefundType r3 on r3.[ExtReference] = a.out_refundcode
			left join Reference.IncidentCaseStatus r4 on r4.[ExtReference] = a.statecode
			left join Staging.STG_IncidentCase g on g.ExtReference = CAST(a.incidentid AS NVARCHAR(256))
			WHERE	g.ExtReference IS NULL
				and a.ProcessedInd = 0
				AND a.DataImportDetailID = @dataimportdetailid

	UPDATE a
	SET  ProcessedInd = 1
	FROM [PreProcessing].[MSD_Incident] a 
	INNER JOIN  Staging.STG_IncidentCase b ON b.ExtReference = CAST(a.incidentid AS NVARCHAR(256))
	AND   a.DataImportDetailID = @dataimportdetailid
		
	SELECT @successcountimport = COUNT(1)
    FROM   [PreProcessing].[MSD_Incident]
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   [PreProcessing].[MSD_Incident]
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