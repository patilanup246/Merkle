USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_KeyMapping_Update]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_KeyMapping_Update]
(
    @userid         INTEGER = 0
)
AS
BEGIN

    /*****************************************************************************
	****  This will update table STG_KeyMapping with ZetaID and CTIRecipientID ***
	*****************************************************************************/

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

	--Process the data for MSDID (i.e Customers)

	UPDATE a
	SET    ZetaCustomerID = b.ZetaCustomerID
	FROM  Staging.STG_KeyMapping a,
	      Migration.Zeta_Customer b
	WHERE CAST(a.MSDID AS NVARCHAR(64)) = b.MSDID 
	AND   [Staging].[IsUniqueIdentifier] (b.MSDID) > 0

	SELECT @recordcount = @@ROWCOUNT

	UPDATE a
	SET    CTIRecipientID = b.CTIRecipientID
	FROM  Staging.STG_KeyMapping a,
	      Migration.Zeta_KeyMappingCampaign b
	WHERE a.ZetaCustomerID = b.ZetaCustomerID 

	SELECT @recordcount = @recordcount + @@ROWCOUNT

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT    
	RETURN
END









GO
