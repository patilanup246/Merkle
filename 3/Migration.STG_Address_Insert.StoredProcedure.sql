USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_Address_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_Address_Insert]
(
    @userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @informationsourceid      INTEGER
	DECLARE @addresstypeidshipping    INTEGER
	DECLARE @addresstypeidbilling     INTEGER
	DECLARE @countryiduk              INTEGER

	DECLARE @spname                   NVARCHAR(256)
	DECLARE @recordcount              INTEGER
	DECLARE @logtimingidnew           INTEGER
	DECLARE @logmessage               NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    --Get Reference Information

	SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = [Reference].[Configuration_GetSetting] ('Migration','MSD Source')

	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END

	SELECT @countryiduk = CountryID
	FROM   [Reference].[Country]
	WHERE  Name = 'United Kingdom'

	SELECT @addresstypeidshipping = AddressTypeID
	FROM   [Reference].[AddressType]
	WHERE  Name = 'Shipping'

    SELECT @addresstypeidbilling = AddressTypeID
	FROM   [Reference].[AddressType]
	WHERE  Name = 'Billing'

	IF @addresstypeidbilling IS NULL OR @addresstypeidshipping IS NULL OR @countryiduk IS NULL
	BEGIN
		SET @logmessage = 'No or invalid country or address types;' + 
		                  ' @addresstypeidshipping = '              + ISNULL(@addresstypeidshipping,'NULL') +
		                  ', @addresstypeidbilling = '              + ISNULL(@addresstypeidbilling,'NULL') +
						  ', @countryiduk = '                       + ISNULL(@countryiduk,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
    END    

	--Process the data

	INSERT INTO [Staging].[STG_Address]
           ([CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
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
           ,[PrimaryInd]
           ,[AddressTypeID]
           ,[IndividualID]
           ,[CustomerID])
     SELECT GETDATE()
	       ,@userid
           ,GETDATE()
           ,@userid
           ,0
           ,@informationsourceid
		   ,a.OrderPlacedDate
		   ,a.OrderPlacedDate
           ,a.Address_Line1
           ,a.Address_Line2
           ,a.Address_Line3
           ,a.Address_Line4
           ,a.Address_Line5
           ,a.Address_City
           ,a.Address_StateOrProvince
           ,a.Address_PostalCode
           ,CASE Address_Country WHEN 'Great Britain' THEN @countryiduk
		                         ELSE  d.CountryID
								 END
           ,0
           ,CASE AddressType WHEN 'ShipTo' THEN @addresstypeidshipping
		                     WHEN 'BillTo' THEN @addresstypeidbilling
                             ELSE NULL END
           ,NULL
           ,c.CustomerID
    FROM   [Migration].[MSD_ContactAddress] a
	       JOIN [Staging].[STG_KeyMapping]       b ON a.ContactID = b.MSDID
		   JOIN [Staging].[STG_Customer]         c ON b.CustomerID = c.CustomerID
		   LEFT OUTER JOIN [Reference].[Country] d ON d.Name = a.Address_Country

	SELECT @recordcount = @@ROWCOUNT

	--Now to set the primary for each customer which is the last Billing address used for each customer

	UPDATE a
    SET PrimaryInd = 1
    FROM [Staging].[STG_Address] a
    INNER JOIN (SELECT CustomerID,
                       MAX(SourceCreatedDate) AS LatestDate
                FROM   [Staging].[STG_Address]
			    WHERE  AddressTypeID = @addresstypeidbilling
			    GROUP  BY CustomerID) b
            ON  a.CustomerID = b.CustomerID AND a.SourceCreatedDate = b.LatestDate
    WHERE AddressTypeID = @addresstypeidbilling

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT    
	RETURN
END











GO
