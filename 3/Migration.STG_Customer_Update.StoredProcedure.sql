USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_Customer_Update]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_Customer_Update]
(
    @userid         INTEGER = 0
)
AS
BEGIN

    SET NOCOUNT ON;

	DECLARE @informationsourceid      INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	UPDATE a
	SET   IsStaffInd     = ISNULL(b.IsStaff,0),
          IsCorporateInd = ISNULL(b.IsCorp,0),
		  IsTMCInd       = ISNULL(b.IsTMC,0)
	FROM  Staging.STG_Customer a,
	      Migration.Zeta_Customer b,
		  Staging.STG_KeyMapping c
	WHERE a.CustomerID = c.CustomerID
	AND   c.ZetaCustomerID = b.ZetaCustomerID

	SELECT @recordcount = @@ROWCOUNT

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT    
	RETURN
END









GO
