CREATE PROCEDURE [Staging].[STG_Collection_Insert]
(
    @userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @segmentid              INTEGER

    DECLARE @spname                 NVARCHAR(256)
    DECLARE @recordcount            INTEGER
    DECLARE @logtimingidnew         INTEGER
    DECLARE @logmessage             NVARCHAR(MAX)

    SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    --Log start time--

    EXEC [Operations].[LogTiming_Record] @userid         = @userid,
                                         @logsource      = @spname,
                                         @logtimingidnew = @logtimingidnew OUTPUT

	EXEC	[Operations].[TableBackup]
			@table_name = N'Staging.STG_Collection'
			
	TRUNCATE TABLE [Staging].[STG_Collection]

	INSERT INTO [Staging].[STG_Collection]
           ([CollectionNumber])
     SELECT CollectionNumber
	 FROM   [Staging].[STG_IndividualCustomerAudit]
	 WHERE  CollectionNumber > 0
	 GROUP BY CollectionNumber

     --Identifiy last customer to make a purchase and use as the primary for subscriptions

	 ;WITH DateLastPurchased AS
	 (
          SELECT a.CustomerID,
		         b.CollectionNumber,
				 a.DateLastPurchase,
                 ROW_NUMBER() OVER (Partition BY b.CollectionNumber ORDER BY a.DateLastPurchase DESC) AS Ranking
          FROM  Staging.STG_Customer a,
                Staging.STG_IndividualCustomerAudit b,
				Staging.STG_Collection c
          WHERE a.CustomerID = b.CustomerID
		  AND   b.CollectionNumber = c.CollectionNumber
     )

	 UPDATE a
	 SET CustomerIDPrimary = b.CustomerID
	 FROM  Staging.STG_Collection a,
	       DateLastPurchased b
	 WHERE a.CollectionNumber = b.CollectionNumber
     AND   b.Ranking = 1;

	 UPDATE a
	 SET [OptInLeisureInd] = b.[OptInLeisureInd]
	 FROM Staging.STG_Collection a,
	      Production.Customer b
     WHERE a.CustomerIDPrimary = b.CustomerID
	 
	 
	 EXEC	[Operations].[CheckTableAndRestoreOnFailure]
			@table_name = N'Staging.STG_Collection'

    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

	 RETURN
END