CREATE PROCEDURE [Staging].[STG_AddressUnique_Insert]
(
	@userid                INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    UPDATE  [Staging].[STG_AddressParsed]
	SET AddressUniqueID = NULL
	
    INSERT INTO [Staging].[STG_AddressUnique]
 	      ([AddressLine1]
          ,[City]
          ,[PostalCode]
          ,[Country]
		  ,[HouseNumber]
          ,[StreetName]
          ,[County]
          ,[ApartmentLabel]
          ,[ApartmentNumber]
		  ,[FirmName]
		  ,[AddressBlock1]
		  ,[AverageConfidence])
	SELECT [AddressLine1]
          ,[City]
          ,[PostalCode]
          ,[Country]
		  ,[HouseNumber]
          ,[StreetName]
          ,[County]
          ,[ApartmentLabel]
          ,[ApartmentNumber]
          ,[Firmname]
		  ,[AddressBlock1]
		  ,AVG(CAST(Confidence AS DECIMAL(5,2)))
    FROM [Staging].[STG_AddressParsed]
    GROUP BY [AddressLine1]
          ,[City]
          ,[PostalCode]
          ,[Country]
		  ,[HouseNumber]
          ,[StreetName]
          ,[County]
          ,[ApartmentLabel]
          ,[ApartmentNumber]
		  ,[FirmName]
		  ,[AddressBlock1]

    SELECT @recordcount = @@ROWCOUNT

    UPDATE a
	SET AddressUniqueID  = b.AddressUniqueID,
	    CreatedBy        = @userid,
		CreatedDate      = GETDATE(),
	    LastModifiedBy   = @userid,
		LastModifiedDate = GETDATE()
	FROM [Staging].[STG_AddressParsed] a,
	     [Staging].[STG_AddressUnique] b
    WHERE a.[AddressLine1]    = b.[AddressLine1]
    AND   a.[City]            = b.[City]
    AND   a.[PostalCode]      = b.[PostalCode]
    AND   a.[Country]         = b.[Country]
    AND   a.[HouseNumber]     = b.[HouseNumber]
    AND   a.[StreetName]      = b.[StreetName]
    AND   a.[County]          = b.[County]
	AND   a.[ApartmentLabel]  = b.[ApartmentLabel]
	AND   a.[ApartmentNumber] = b.[ApartmentNumber]
	AND   a.[FirmName]        = b.[FirmName]
	AND   a.[AddressBlock1]   = b.[AddressBlock1]

	UPDATE a
	SET  NumberofCustomers = b.CustomerCount
	FROM [Staging].[STG_AddressUnique] a
	INNER JOIN (SELECT bb.AddressUniqueID
	                  ,COUNT(Distinct(cc.CustomerID)) AS CustomerCount
	            FROM Staging.STG_AddressParsed bb,
				     Staging.STG_Address cc
			    WHERE cc.AddressID = bb.AddressID
				GROUP BY  bb.AddressUniqueID) b ON b.AddressUniqueID = a.AddressUniqueID
	    
    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END