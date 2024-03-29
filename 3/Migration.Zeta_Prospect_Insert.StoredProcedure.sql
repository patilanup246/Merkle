USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[Zeta_Prospect_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[Zeta_Prospect_Insert]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT


	SELECT @recordcount = @recordcount + @@ROWCOUNT

	INSERT INTO [Migration].[Zeta_Prospect]
           ([ZetaCustomerID]
           ,[CreatedDate]
           ,[CreatedPeriod]
           ,[Contactable]
           ,[EmailAddress]
           ,[MobileNumber]
           ,[FirstName]
           ,[LastName]
           ,[DefunctInd]
           ,[HardBounceInd]
           ,[ValidEmailInd]
           ,[MigrateInd])
     SELECT [ZetaCustomerID]
           ,SUBSTRING([DateCreated],1,19)
           ,CAST(DATEPART(Year,[DateCreated]) AS NVARCHAR(4)) + 'Q' + CAST(DATEPART(QUARTER,[DateCreated]) AS NVARCHAR(1))
           ,[Contactable]
           ,[ContactEmail]
           ,[MobileTelephoneNo]
           ,[ContactFirstName]
           ,[ContactLastName]
           ,CASE WHEN SUBSTRING([ContactEmail],1,23) = 'NowDefunctSiebelAccount' THEN 1 ELSE 0 END
           ,0
           ,0
           ,0
    FROM [Migration].[Zeta_Customer]
	WHERE [Staging].[IsUniqueIdentifier] (MSDID) = 0

	SELECT @recordcount = @@ROWCOUNT
	
	UPDATE a
    SET  [HardBounceInd] = 1
    FROM [Migration].[Zeta_prospect] a,
         [Migration].[Zeta_KeyMappingCampaign] b,
	     [Migration].[Zeta_EmailBounces] c,
         [Reference].[ResponseCode] d,
         [Reference].[ResponseCodeType] e
    WHERE a.ZetaCustomerID = b.ZetaCustomerID
    AND   b.CTIRecipientID = c.CTIRecipientID
    AND   d.ResponseCodeTypeID = e.ResponseCodeTypeID
    AND   d.ExtReference = c.BounceBackLevelID
    AND   e.IsHardBounceInd = 1
	
	UPDATE a
    SET  [RespondedInd] = 1
    FROM [Migration].[Zeta_Prospect] a,
         [Migration].[Zeta_KeyMappingCampaign] b,
	     [Migration].[Zeta_CampaignResponse] c
    WHERE a.ZetaCustomerID = b.ZetaCustomerID
    AND   b.CTIRecipientID = c.CTIRecipientID

	UPDATE a
	SET  [LastRespondDate] = c.[LatestDate]
	FROM [Migration].[Zeta_Prospect] a
	INNER JOIN [Migration].[Zeta_KeyMappingCampaign] b ON a.ZetaCustomerID = b.ZetaCustomerID
    INNER JOIN (SELECT c.CTIRecipientID,
                       MAX(c.[ActionDate]) AS LatestDate
                FROM   [Migration].[Zeta_CampaignResponse] c
			    GROUP  BY c.CTIRecipientID) c ON  c.CTIRecipientID = b.CTIRecipientID

	UPDATE a
	SET  [InMSDInd] = 1
	FROM [Migration].[Zeta_Prospect] a,
	     [Migration].[MSD_Contact] b
    WHERE a.EmailAddress = b.EmailAddress1

	UPDATE a
	SET  [NonResponderInd] = 1
	FROM [Migration].[Zeta_Prospect] a,
	     [PreProcessing].[EmailCustomerWithCode] b
    WHERE a.ZetaCustomerID = b.CustomerID 
	AND   b.CellCode = 'NonResponse'

	UPDATE a
	SET  [OptOutInd] = 1
	FROM [Migration].[Zeta_Prospect] a,
	     [PreProcessing].[EmailCustomerWithCode] b
    WHERE a.ZetaCustomerID = b.CustomerID 
	AND   b.CellCode = 'ClickNO'

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END

GO
