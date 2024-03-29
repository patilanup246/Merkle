USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[STG_Journey_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[STG_Journey_Insert]
(
	@userid         INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

--OutBound

    INSERT INTO [Staging].[STG_Journey]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SalesDetailID]
           ,[LocationIDOrigin]
           ,[LocationIDDestination]
           ,[ECJourneyScore]
           ,[DepartureDateTime]
           ,[InferredDepartureInd]
           ,[ArrivalDateTime]
           ,[InferredArrivalInd]
		   ,[IsOutboundInd])
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
           ,a.SalesDetailID
           ,d.LocationID
           ,e.LocationID
           ,0
           ,a.OutTravelDate
           ,0
           ,NULL
           ,0
		   ,1
    FROM [Staging].[STG_SalesDetail] a
	INNER JOIN [Staging].[STG_SalesTransaction]   b ON a.SalesTransactionID = b.SalesTransactionID
	INNER JOIN [Migration].[MSD_SalesOrder]       c ON CAST(c.SalesOrderId AS NVARCHAR(256)) = b.[ExtReference]
	LEFT JOIN  [Reference].[LocationAlias]        d ON d.Name = c.out_journeyorigin
	LEFT JOIN  [Reference].[LocationAlias]        e ON e.Name = c.out_journeydestination
	WHERE a.IsTrainTicketInd = 1
	AND   c.out_journeyorigin IS NOT NULL
	AND   a.OutTravelDate IS NOT NULL
	AND   a.IsReturnInferredInd = 0
      
--Returns

    INSERT INTO [Staging].[STG_Journey]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[SalesDetailID]
           ,[LocationIDOrigin]
           ,[LocationIDDestination]
           ,[ECJourneyScore]
           ,[DepartureDateTime]
           ,[InferredDepartureInd]
           ,[ArrivalDateTime]
           ,[InferredArrivalInd]
		   ,[IsReturnInd])
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
           ,a.SalesDetailID
           ,d.LocationID
           ,e.LocationID
           ,0
           ,CASE WHEN a.IsReturnInferredInd = 1 THEN a.OutTravelDate
		                                        ELSE a.ReturnTravelDate
            END
           ,0
           ,NULL
           ,0
		   ,1
    FROM [Staging].[STG_SalesDetail] a
	INNER JOIN [Staging].[STG_SalesTransaction]   b ON a.SalesTransactionID = b.SalesTransactionID
	INNER JOIN [Migration].[MSD_SalesOrder]       c ON CAST(c.SalesOrderId AS NVARCHAR(256)) = b.[ExtReference]
	LEFT JOIN  [Reference].[LocationAlias]        d ON d.Name = c.out_journeydestination
	LEFT JOIN  [Reference].[LocationAlias]        e ON e.Name = c.out_journeyorigin
	WHERE a.IsTrainTicketInd = 1
	AND   ((c.out_retserviceoperators IS NOT NULL AND   a.ReturnTravelDate IS NOT NULL)
	       OR IsReturnInferredInd = 1)
   


    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN 
END

GO
