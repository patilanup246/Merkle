USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_Individual_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_Individual_Insert]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	/**********************************************************************************
	**  Date: 10-08-2016                                                             **
	**                                                                               **
	**  Amendment to support processing of additionl Zeta Prospects:                 **
	**  1. Prevent same ZetaCustomerID being process                                 **
	**  2. To reference field Migration.Zeta_Prospect.FinalMigrateInd rather than    **
	**     Migration.Zeta_Prospect.MigrateInd used to first migration                **
	**                                                                               **
	**********************************************************************************/
	
	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Legacy - Zeta'

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END

    INSERT INTO [Staging].[STG_Individual]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[ExtReference]
           ,[SourceCreatedDate]
		   ,[SourceModifiedDate]
           ,[Salutation]
           ,[FirstName]
           ,[LastName]
		   ,[InformationSourceID]
		   ,[DateFirstPurchase])
    SELECT GETDATE()
	       ,@userid
		   ,GETDATE()
		   ,@userid
		   ,0
		   ,CAST(ZetaCustomerID AS NVARCHAR(256))
		   ,a.[CreatedDate]
		   ,a.[CreatedDate]
		   ,NULL
		   ,a.FirstName
		   ,a.LastName
		   ,@informationsourceid
		   ,NULL
    FROM   Migration.Zeta_Prospect a
	LEFT JOIN [Staging].[STG_Individual] b ON CAST(a.ZetaCustomerID AS NVARCHAR(256)) = b.[ExtReference]
	WHERE  a.FinalMigrateInd = 1
	AND    b.[ExtReference] IS NULL

	SELECT @recordcount = @@ROWCOUNT
	
	UPDATE a
	SET  IndividualID = b.IndividualID 
	FROM Staging.STG_KeyMapping a,
	     Staging.STG_Individual b,
		 Migration.Zeta_Prospect c
	WHERE CAST(a.ZetaCustomerID AS NVARCHAR(256)) = b.ExtReference
	AND   a.ZetaCustomerID = c.ZetaCustomerID
	AND   c.FinalMigrateInd = 1
	AND   a.IndividualID IS NULL

	
	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END













GO
