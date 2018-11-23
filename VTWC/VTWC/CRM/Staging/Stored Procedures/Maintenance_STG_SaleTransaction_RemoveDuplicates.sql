CREATE PROCEDURE [Staging].[Maintenance_STG_SaleTransaction_RemoveDuplicates]
(
	@userid    INTEGER = 0,
	@debug     BIT
)
AS
BEGIN
    SET NOCOUNT ON;

	/**************************************************************************************
	**  Date: 14-12-2016                                                                 **
	**                                                                                   **
	**  This SP is used to remove duplicate MSD Sales Orders from the Sales Transaction  **
	**  table which been loaded in error. This happens when there are duplicated records **
	**  in PreProcessing.MSD_SalesOrders for the same DataImportDetailID                 **
	**                                                                                   **
	**  Where Sales Order has been load more than twice, this SP can be run multiple     **
	**  times until all duplicates have been removed                                     **
	**************************************************************************************/

    DECLARE @salestransactionid    INTEGER

	DECLARE @spname                     NVARCHAR(256)
	DECLARE @recordcount                INTEGER
	DECLARE @logtimingidnew             INTEGER
	DECLARE @logmessage                 NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    --Get all Sales Orders (ExtReference) with duplicate records

    CREATE TABLE #tmp_salestransactions
	    (salestransactionid    INTEGER       NOT NULL
		,extreference          NVARCHAR(256) NOT NULL
		,SourceCreatedDate     DATETIME
		,SourceModifiedDate    DATETIME
		,SalesDetailsInd       BIT
		,LoyaltyAllocationInd  BIT
		,IncidentInd           INTEGER
		,IncidentRelatedInd    INTEGER
		,CVITransactionInd     INTEGER)

    --Get duplicate Sales Order IDs and indicate whether they have associated SalesOrderDetail records

    INSERT INTO #tmp_salestransactions
	    (extreference
		,salestransactionid
		,SourceCreatedDate
		,SourceModifiedDate
		,SalesDetailsInd
		,LoyaltyAllocationInd
		,IncidentInd
		,IncidentRelatedInd
		,CVITransactionInd)
    SELECT a.ExtReference
	      ,a.SalestransactionID
	      ,a.SourceCreatedDate
          ,a.SourceModifiedDate
          ,CASE WHEN b.SalesTransactionID IS NOT NULL THEN 1 ELSE 0 END 
		  ,CASE WHEN d.SalesTransactionID IS NOT NULL THEN 1 ELSE 0 END
		  ,CASE WHEN e.SalesTransactionIDOriginal IS NOT NULL THEN 1 ELSE 0 END
		  ,CASE WHEN f.SalesTransactionIDNew IS NOT NULL THEN 1 ELSE 0 END
		  ,CASE WHEN g.SalesTransactionID IS NOT NULL THEN 1 ELSE 0 END 
    FROM Staging.STG_SalesTransaction a
	INNER JOIN (SELECT extreference,COUNT(1) AS NoOf
                FROM Staging.STG_SalesTransaction
                GROUP by extreference
                HAVING COUNT(1) > 1) c ON a.ExtReference = c.ExtReference
    LEFT JOIN Staging.STG_SalesDetail b ON a.SalesTransactionID = b.SalesTransactionID
	LEFT JOIN Staging.STG_LoyaltyAllocation d ON a.SalesTransactionID = d.SalesTransactionID
	LEFT JOIN Staging.STG_IncidentCase e ON a.SalesTransactionID = e.SalesTransactionIDOriginal
	LEFT JOIN Staging.STG_IncidentCase f ON a.SalesTransactionID = f.SalesTransactionIDNew
	LEFT JOIN Staging.STG_CVISalesTransaction g ON a.SalesTransactionID = g.SalesTransactionID
    GROUP BY  a.ExtReference
	         ,a.SalestransactionID
	         ,a.SourceCreatedDate
             ,a.SourceModifiedDate
		     ,CASE WHEN b.SalesTransactionID IS NOT NULL THEN 1 ELSE 0 END
			 ,CASE WHEN d.SalesTransactionID IS NOT NULL THEN 1 ELSE 0 END
		     ,CASE WHEN e.SalesTransactionIDOriginal IS NOT NULL THEN 1 ELSE 0 END
		     ,CASE WHEN f.SalesTransactionIDNew IS NOT NULL THEN 1 ELSE 0 END
		     ,CASE WHEN g.SalesTransactionID IS NOT NULL THEN 1 ELSE 0 END 


    IF @debug = 1
	BEGIN
	    SELECT extreference
		      ,salestransactionid
		      ,SourceCreatedDate
		      ,SourceModifiedDate
		      ,SalesDetailsInd
			  ,LoyaltyAllocationInd
			  ,IncidentInd
		      ,IncidentRelatedInd
		      ,CVITransactionInd
        FROM #tmp_salestransactions
		ORDER BY extreference
		        ,salestransactionid

        RETURN
    END

    
    DECLARE SalesTransactions CURSOR READ_ONLY
    FOR 
        WITH CTE AS (SELECT a.extreference
	                       ,a.salestransactionid
		 	               ,a.SourceCreatedDate
		 	               ,a.SourceModifiedDate
                           ,RANK() OVER(PARTITION BY a.extreference
			                            ORDER BY a.LoyaltyAllocationInd ASC
										        ,SalesDetailsInd ASC
							 		            ,a.SourceModifiedDate ASC
											    ,a.salestransactionid) AS Ranking
                     FROM #tmp_salestransactions a)
	   
	    SELECT SalesTransactionID
		FROM   CTE
		WHERE  Ranking = 1
		GROUP BY SalesTransactionID

		OPEN SalesTransactions

		FETCH NEXT FROM SalesTransactions
		    INTO @salestransactionid

		WHILE @@FETCH_STATUS = 0
        BEGIN

			DELETE c
			FROM Staging.STG_SalesDetail a
			INNER JOIN Staging.STG_Journey b ON a.SalesDetailID = b.SalesDetailID
			INNER JOIN Staging.STG_JourneyLeg c ON b.JourneyID = c.JourneyID
			WHERE a.SalesTransactionID = @salestransactionid

			DELETE b
			FROM Staging.STG_SalesDetail a
			INNER JOIN Staging.STG_Journey b ON a.SalesDetailID = b.SalesDetailID
			WHERE a.SalesTransactionID = @salestransactionid

            DELETE
			FROM Staging.STG_SalesDetail
			WHERE SalesTransactionID = @salestransactionid

            DELETE
			FROM Staging.STG_LoyaltyAllocation
			WHERE SalesTransactionID = @salestransactionid
			
			DELETE
			FROM Staging.STG_IncidentCase
			WHERE SalesTransactionIDOriginal = @salestransactionid
	
			DELETE
			FROM Staging.STG_IncidentCase
			WHERE SalesTransactionIDNew = @salestransactionid
			
			DELETE
			FROM Staging.STG_CVISalesTransaction
			WHERE SalesTransactionID = @salestransactionid

			DELETE
			FROM Staging.STG_SalesTransaction
			WHERE SalesTransactionID = @salestransactionid

            FETCH NEXT FROM SalesTransactions
		        INTO @salestransactionid
        END

	    CLOSE SalesTransactions
     
	DEALLOCATE SalesTransactions

    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

    RETURN
END