




CREATE PROCEDURE [Staging].[Maintenance_STG_SalesTransaction_Fulfilment]
(
    @userid         INTEGER = 0,
	@debug          BIT     = 1,
	@createddate    DATE,
	@createddate2   DATE = @createddate
)
AS
BEGIN
    
	/***************************************************************************************
	*** This procedure is to remove sales transactions and associated related data where ***
	*** the incorrect fulfilmemtmethod has been assigned for method SelfPrint for CBE.   ***
	***************************************************************************************/
	
	SET NOCOUNT ON;

	DECLARE @fulfilmentmethodid     INTEGER
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

    SELECT @fulfilmentmethodid = FulfilmentMethodID
	FROM   Reference.FulfilmentMethod
	WHERE  Name = 'SelfPrint_CBE'

	SELECT @informationsourceid = InformationSourceID
	FROM   Reference.InformationSource
	WHERE  Name = 'Delta - MSD'

	IF @fulfilmentmethodid IS NULL OR @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @fulfilmentmethodid or @informationsourceid; ' +
		                  '@fulfilmentmethodid = '    + ISNULL(@fulfilmentmethodid,'NULL') +
						  ', @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
        RETURN
    END

	;with cte 
	as
	(
		SELECT
				b.salestransactionid, a.SalesDetailID, dense_rank() over ( order by b.salestransactionId) as [Rank]
		FROM Staging.STG_SalesDetail a
		INNER JOIN Staging.STG_SalesTransaction b ON b.SalesTransactionID = a.SalesTransactionID
	    WHERE  (a.FulfilmentMethodID >= @fulfilmentmethodid or b.FulfilmentMethodID >= @fulfilmentmethodid)
		 AND   a.InformationSourceID = @informationsourceid
		 AND   CAST(b.CreatedDate AS DATE) between @createddate and @createddate2
		group by b.salestransactionid, a.SalesDetailID
	)
	select salestransactionid, SalesDetailID 
	into #Transactions
	from cte 
	where [rank] <= 1500
	ORDER BY 1,2

	IF @debug = 1
	BEGIN
	    SELECT a.* --COUNT(1) AS JourneyLeg
        FROM Staging.STG_JourneyLeg a
        INNER JOIN Staging.STG_Journey b ON a.JourneyID = b.JourneyID
		 INNER JOIN #Transactions t ON t.SalesDetailID = b.SalesDetailID

        SELECT a.*--COUNT(1) AS Journey
		FROM Staging.STG_Journey a
		 INNER JOIN #Transactions t ON t.SalesDetailID = a.SalesDetailID
        INNER JOIN Staging.STG_SalesDetail b ON a.SalesDetailID = b.SalesDetailID
        WHERE b.InformationSourceID = @informationsourceid


	    SELECT a.*--COUNT(1) AS LoyaltyAllocation_SalesDetail
	    FROM Staging.STG_LoyaltyAllocation a
    	 INNER JOIN #Transactions t ON t.SalesDetailID = a.SalesDetailID
	    INNER JOIN Staging.STG_SalesDetail b ON t.SalesDetailID = b.SalesDetailID
		WHERE b.InformationSourceID = @informationsourceid


        SELECT a.*--COUNT(1) AS SalesDetail
        FROM Staging.STG_SalesDetail a
		 INNER JOIN #Transactions t ON t.SalesDetailID = a.SalesDetailID
        WHERE a.InformationSourceID = @informationsourceid


	    SELECT a.*--COUNT(1) AS LoyaltyAllocation_SalesTransaction
	    FROM Staging.STG_LoyaltyAllocation a
		INNER JOIN #Transactions t ON t.SalesTransactionID = a.SalesTransactionID
		WHERE   a.InformationSourceID = @informationsourceid


	    SELECT a.*--COUNT(1) AS IncidentCase_Original
	    FROM Staging.STG_IncidentCase a
		INNER JOIN #Transactions t ON t.SalesTransactionID = a.SalesTransactionIDOriginal


        SELECT a.*--COUNT(1) AS IncidentCase_New
	    FROM Staging.STG_IncidentCase a
		INNER JOIN #Transactions t ON t.SalesTransactionID = a.SalesTransactionIDNew


	    SELECT a.*--COUNT(1) AS CVISalesTransaction
	    FROM Staging.STG_CVISalesTransaction a
		INNER JOIN #Transactions t ON t.SalesTransactionID = a.SalesTransactionID


        SELECT a.*--COUNT(1) AS SalesTransaction
        FROM Staging.STG_SalesTransaction a
		INNER JOIN #Transactions t ON t.SalesTransactionID = a.SalesTransactionID

    END
	ELSE
	BEGIN
		declare @count int
		select @count = count(1) from #Transactions
		print 'Records='+convert(char,@count)

--		print 'Deleting STG_JourneyLeg'
	    DELETE a 
        FROM Staging.STG_JourneyLeg a
        INNER JOIN Staging.STG_Journey b ON a.JourneyID = b.JourneyID
		 INNER JOIN #Transactions t ON t.SalesDetailID = b.SalesDetailID
		select @recordcount += @@rowcount

--		print 'Deleting STG_Journey'
        DELETE a 
		FROM Staging.STG_Journey a
		 INNER JOIN #Transactions t ON t.SalesDetailID = a.SalesDetailID
		select @recordcount += @@rowcount


--		print 'Deleting STG_LoyaltyAllocation'
	    DELETE a 
	    FROM Staging.STG_LoyaltyAllocation a
		INNER JOIN #Transactions t ON t.SalesDetailID = a.SalesDetailID
		WHERE   a.InformationSourceID = @informationsourceid
		select @recordcount += @@rowcount

--		print 'Deleting STG_SalesDetail'
        DELETE a 
        FROM Staging.STG_SalesDetail a
		 INNER JOIN #Transactions t ON t.SalesDetailID = a.SalesDetailID
        WHERE a.InformationSourceID = @informationsourceid
		select @recordcount += @@rowcount

--		print 'Deleting STG_LoyaltyAllocation'
	    DELETE a 
	    FROM Staging.STG_LoyaltyAllocation a
		INNER JOIN #Transactions t ON t.SalesTransactionID = a.SalesTransactionID
		select @recordcount += @@rowcount

--		print 'Deleting STG_IncidentCase'
	    DELETE a 
	    FROM Staging.STG_IncidentCase a
		INNER JOIN #Transactions t ON t.SalesTransactionID = a.SalesTransactionIDOriginal
		select @recordcount += @@rowcount


--		print 'Deleting STG_IncidentCase'
        DELETE a 
	    FROM Staging.STG_IncidentCase a
		INNER JOIN #Transactions t ON t.SalesTransactionID = a.SalesTransactionIDNew
		select @recordcount += @@rowcount


--		print 'Deleting STG_CVISalesTransaction'
	    DELETE a 
	    FROM Staging.STG_CVISalesTransaction a
		INNER JOIN #Transactions t ON t.SalesTransactionID = a.SalesTransactionID
		select @recordcount += @@rowcount

		-- remove Transactions with correct fulfillment
		DELETE a
		from #Transactions a
		INNER JOIN Staging.STG_SalesTransaction b ON b.SalesTransactionID = a.SalesTransactionID
	    INNER JOIN Staging.STG_SalesDetail c ON b.SalesTransactionID = c.SalesTransactionID
		WHERE b.InformationSourceID = @informationsourceid
		and b.FulfilmentMethodID < @fulfilmentmethodid
		and c.FulfilmentMethodID < @fulfilmentmethodid

--		select top 10 'After', * from #Transactions

		print 'Deleting STG_SalesTransaction'
        DELETE a 
        FROM Staging.STG_SalesTransaction a
		INNER JOIN #Transactions t ON t.SalesTransactionID = a.SalesTransactionID
		select @recordcount += @@rowcount
		print 'Deletions='+convert(char,@recordcount)

    END

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

	RETURN
END