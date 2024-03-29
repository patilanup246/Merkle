USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[Zeta_Customer_MigrationInfo_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[Zeta_Customer_MigrationInfo_Insert]
(
    @userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	/**********************************************************************************
	**  Date: 15-08-2016                                                             **
	**                                                                               **
	**  This is support the migration of prospects from MSD not already migrated     **
	**                                                                               **
	**********************************************************************************/

	DECLARE @spname              NVARCHAR(256)	
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	INSERT INTO [Migration].[Zeta_Customer_MigrationInfo]
           ([ZetaCustomerID]
           ,[DateCreated]
           ,[CreatedPeriod]
           ,[Contactable]
           ,[ContactEmail]
           ,[MobileTelephoneNo]
           ,[ContactFirstName]
           ,[ContactLastName]
		   ,[MSDID]
		   ,[IsCorp]
		   ,[IsTMC]
		   ,[Corp_OptOut]
           ,[DefunctInd]
           ,[IsGUIDInd]
		   ,[LastPurchasedDate])
    SELECT [ZetaCustomerID]
           ,SUBSTRING([DateCreated],1,19) AS [DateCreated]
           ,CAST(DATEPART(Year,[DateCreated]) AS NVARCHAR(4)) + 'Q' + CAST(DATEPART(QUARTER,[DateCreated]) AS NVARCHAR(1)) AS [CreatedPeriod] 
           ,[Contactable]
           ,[ContactEmail]
           ,[MobileTelephoneNo]
           ,[ContactFirstName]
           ,[ContactLastName]
		   ,[MSDID]
		   ,[IsCorp]
		   ,[IsTMC]
		   ,[Corp_OptOut]
           ,CASE WHEN SUBSTRING([ContactEmail],1,23) = 'NowDefunctSiebelAccount' THEN 1 ELSE 0 END AS [DefunctInd]
		   ,[Staging].[IsUniqueIdentifier] (MSDID) AS IsGUIDInd
		   ,CASE WHEN LastPurchaseDate != '' THEN LastPurchaseDate
		         WHEN LastPurchaseDate = '' AND dDate_of_First_Purchase != '' AND dDate_of_First_Purchase > '2000-01-01' THEN dDate_of_First_Purchase
                 ELSE NULL	   
		   END
    FROM [Migration].[Zeta_Customer]

    UPDATE a
    SET  [HardBounceInd] = 1
    FROM [Migration].[Zeta_Customer_MigrationInfo] a,
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
    FROM [Migration].[Zeta_Customer_MigrationInfo] a,
         [Migration].[Zeta_KeyMappingCampaign] b,
	     [Migration].[Zeta_CampaignResponse] c
    WHERE a.ZetaCustomerID = b.ZetaCustomerID
    AND   b.CTIRecipientID = c.CTIRecipientID

	UPDATE a
	SET  [LastRespondDate] = c.[LatestDate]
	FROM [Migration].[Zeta_Customer_MigrationInfo] a
	INNER JOIN [Migration].[Zeta_KeyMappingCampaign] b ON a.ZetaCustomerID = b.ZetaCustomerID
    INNER JOIN (SELECT c.CTIRecipientID,
                       MAX(c.[ActionDate]) AS LatestDate
                FROM   [Migration].[Zeta_CampaignResponse] c
			    GROUP  BY c.CTIRecipientID) c ON  c.CTIRecipientID = b.CTIRecipientID

	UPDATE a
	SET  [InMSDInd] = 1
	FROM [Migration].[Zeta_Customer_MigrationInfo] a,
	     [Migration].[MSD_Contact] b
    WHERE a.MSDID = CAST(b.ContactID AS NVARCHAR(512))

	UPDATE a
	SET  [InMSDInd] = 1
	FROM [Migration].[Zeta_Customer_MigrationInfo] a,
	     [Migration].[MSD_Contact] b
    WHERE a.ContactEmail = b.EmailAddress1

	UPDATE a
	SET  [InCEMInd] = 1
	FROM [Migration].[Zeta_Customer_MigrationInfo] a,
	     [Staging].[STG_ElectronicAddress] b
    WHERE a.ContactEmail = b.Address
	AND   b.AddressTypeID = 3

	UPDATE a
	SET  [InCEMInd] = 1
	FROM [Migration].[Zeta_Customer_MigrationInfo] a,
	     [Staging].[STG_KeyMapping] b
    WHERE a.ZetaCustomerID = b.ZetaCustomerID

   --Flag those for migration - not already in CEM, responded and contactable

   --Prospects who've responded in timeframe

	UPDATE [Migration].[Zeta_Customer_MigrationInfo]
	SET   MigrateInd    = 1
	WHERE InCEMInd      = 0
	AND   DefunctInd    = 0
	AND   HardBounceInd = 0
	AND   Contactable   = 1
	AND   LastRespondDate IS NOT NULL
	AND   LastPurchasedDate IS NULL

	--Bookers

	--UPDATE [Migration].[Zeta_Customer_MigrationInfo]
	--SET   MigrateInd    = 1
	--WHERE InCEMInd      = 0
	--AND   DefunctInd    = 0
	--AND   HardBounceInd = 0
	--AND   InMSDInd      = 1
	--AND   Contactable   = 1
	--AND   LastPurchasedDate IS NOT NULL

 --   UPDATE a
	--SET MigrateInd = 1
	--FROM [Migration].[MSD_Contact] a,
	--     [Migration].[Zeta_Customer_MigrationInfo] b
 --   WHERE CAST(a.ContactId AS NVARCHAR(512)) = b.MSDID
	--AND   b.MigrateInd = 1
	--AND   b.Contactable = 1

	UPDATE a
	SET FinalMigrateInd = 1
	FROM  [Migration].[Zeta_Prospect] a,
	      [Migration].[Zeta_Customer_MigrationInfo] b
    WHERE a.ZetaCustomerID =  b.ZetaCustomerID
	AND   b.MigrateInd =  1


	--Log start time--
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT


    SELECT @recordcount = @@ROWCOUNT

	--Log end time--
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN
END














GO
