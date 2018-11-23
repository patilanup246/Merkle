/*===========================================================================================
Name:			[Staging].[STG_Journey_Upsert] 
Purpose:		Insert/Update Journey information into table Staging.STG_Journey.
Parameters:		@userid - The key for the user executing the proc.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-10	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC [Staging].[STG_Journey_Upsert] 
=================================================================================================*/

  CREATE PROCEDURE [Staging].[STG_Journey_Upsert] 
    @userid                INTEGER = 0,
	@dataimportdetailid    INTEGER, 
	@DebugPrint			   INTEGER = 0,
	@PkgExecKey			   INTEGER = -1,
	@DebugRecordset		   INTEGER = 0
  ----------------------------------------
  AS 
  BEGIN

  
   SET NOCOUNT ON;

	DECLARE @now                    DATETIME = GETDATE()
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @importfilename			NVARCHAR(256)


   DECLARE @spid	INTEGER	= @@SPID
   DECLARE @spname  SYSNAME = COALESCE(OBJECT_NAME(@@PROCID), 'UNKNWON')
   DECLARE @dbname  SYSNAME = DB_NAME()
   DECLARE @Rows	INTEGER = 0
   DECLARE @ProcName NVARCHAR(50)
   DECLARE @StepName NVARCHAR(50)

   DECLARE @informationsourceid INT 

   DECLARE  @ErrorMsg		NVARCHAR(MAX)
   DECLARE  @ErrorNum		INTEGER
   DECLARE  @ErrorSeverity	 NVARCHAR(255)
   DECLARE  @ErrorState NVARCHAR(255)

	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS START'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint

	SET @ProcName = 'PreProcessing.TOCPlus_Journey_Insert'
   
    SELECT @importfilename = importfilename FROM [Operations].[DataImportDetail] WHERE dataimportdetailid = @dataimportdetailid

	SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'TrainLine'

	SET @StepName = 'Check if information source reference values are populated'

	IF @informationsourceid                 IS NULL
	BEGIN
	    SET @ErrorMsg = 'No or invalid reference information.' +
		                  ' @informationsourceid =  '                + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') 
	    
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey

        RETURN
    END

	IF OBJECT_ID(N'tempdb..#TOC') IS NOT NULL
	DROP TABLE #TOC
	SELECT faresettingtoc AS ShortCode, FareSettingTOCDesc AS [Name], @InformationSourceID AS InformationSourceID
	INTO #TOC
	FROM PreProcessing.TOCPLUS_Journey
	WHERE DataImportDetailID = @DataImportDetailID
	GROUP BY faresettingtoc, FareSettingTOCDesc

	EXEC [Reference].[TOC_Upsert]

	IF OBJECT_ID(N'tempdb..#RailCardType') IS NOT NULL
	DROP TABLE #RailCardType
	SELECT Code, Name, InformationSourceID
	INTO #RailCardType
	FROM (
	SELECT railcard1 AS Code, railcarddesc AS [Name], @InformationSourceID AS InformationSourceID
	FROM PreProcessing.TOCPLUS_Journey
	WHERE DataImportDetailID = @DataImportDetailID 
	GROUP BY railcard1, railcarddesc
	UNION ALL 
	SELECT Railcard2, railcard2desc , @InformationSourceID
	FROM PreProcessing.TOCPLUS_Journey
	WHERE DataImportDetailID = @DataImportDetailID 
	GROUP BY Railcard2, railcard2desc 
	UNION ALL 
	SELECT Railcard3, railcard3desc , @InformationSourceID 
	FROM PreProcessing.TOCPLUS_Journey
	WHERE DataImportDetailID = @DataImportDetailID 
	GROUP BY Railcard3, railcard3desc) AS SQ
	GROUP BY Code, Name, InformationSourceID

	EXEC [Reference].[RailCardType_Upsert]

	IF OBJECT_ID(N'tempdb..#Product') IS NOT NULL
	DROP TABLE #Product
	SELECT tickettypecode AS TicketTypeCode, tickettypedesc AS [Name], @InformationSourceID AS InformationSourceID
	INTO #Product
	FROM PreProcessing.TOCPLUS_Journey
	WHERE DataImportDetailID = @DataImportDetailID
	GROUP BY tickettypecode, tickettypedesc

	EXEC [Reference].[Product_Upsert]

	IF OBJECT_ID(N'tempdb..#FulfilmentMethod') IS NOT NULL
	DROP TABLE #FulfilmentMethod
	SELECT deliverymethodcode AS ShortCode, deliverymethoddescription AS [Name], @InformationSourceID AS InformationSourceID
	INTO #FulfilmentMethod
	FROM PreProcessing.TOCPLUS_Journey
	WHERE DataImportDetailID = @DataImportDetailID
	GROUP BY deliverymethodcode, deliverymethoddescription

	EXEC [Reference].[FulfilmentMethod_Upsert]

	IF OBJECT_ID(N'tempdb..#AvailabilityCode') IS NOT NULL
	DROP TABLE #AvailabilityCode
	SELECT availabilitycode AS ShortCode, AvailabilityCodeDesc AS [Name], @InformationSourceID AS InformationSourceID
	INTO #AvailabilityCode
	FROM PreProcessing.TOCPLUS_Journey
	GROUP BY availabilitycode, AvailabilityCodeDesc

	EXEC [Reference].[AvailabilityCode_Upsert]

    SET @StepName = 'Operations.DataImportDetail_Update'
	BEGIN TRY		

		EXEC uspSSISProcStepStart @ProcName, @StepName

		EXEC [Operations].[DataImportDetail_Update] @userid                 = @userid,
													@dataimportdetailid     = @dataimportdetailid,
													@operationalstatusname  = 'Processing',
													@importfilename         = @importfilename,
													@starttimepreprocessing = NULL,
													@endtimepreprocessing   = NULL,
													@starttimeimport        = @now,
													@endtimeimport          = NULL,
													@totalcountimport       = NULL,
													@successcountimport     = NULL,
													@errorcountimport       = NULL
		EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
	END CATCH ;

	

	SET @StepName = 'Insert journey information';
	BEGIN TRY   		
		EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Insert journey information start'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

		--Create temporary table with location information to aid performance
		IF OBJECT_ID(N'tempdb..#Station') IS NOT NULL
		DROP TABLE #Station
		SELECT [StationID]
			  ,[Name]
			  ,[ShortCode] AS StationCode
			  ,County
			  ,PostCode
			  ,GroupStation
		INTO #Station
		FROM [Reference].[Station]

		IF OBJECT_ID(N'tempdb..#Journey') IS NOT NULL
		DROP TABLE #Journey
		SELECT  J.journeyid AS ExtReference, J.purchaseid , SD.SalesDetailID, SD.SalesTransactionID, SD.CustomerID, J.tcstransactionid, J.tcsbookingid, TOC.TOCID, Origin.StationID AS OrigStationID
			   ,Dest.Stationid AS DestStationID, J.outdatedep, J.outdatearr, J.retdatedep, J.retdatearr, CASE WHEN J.journeytype = 'R' THEN 1 ELSE 0 END AS IsReturnIndicator
			   ,J.cmddateupdated AS SourceModifiedDate,COALESCE(RCT.RailcardTypeID,-1) AS RailCard, J.noofrailcards, J.totaladults, J.totalchildren, J.totalreturningadults
			   ,J.totalreturningchildren, J.costoftickets, J.totalcost, J.savingsmade, J.procode
			   ,P.ProductID, FFM.FulfilmentMethodID, CASE WHEN J.journeydirection='O' THEN 1 ELSE 0 END IsOutboundInd, J.journeyreference
			   ,J.outboundmileage, AC.AvailabilityCodeID, CASE WHEN J.DisabledInd = 'N' THEN 0 WHEN J.DisabledInd = 'Y' THEN 1 ELSE NULL END AS DisabledInd, J.NoFullFareAdults, J.NoDiscFareAdults
			   ,J.NoFullFareChildren, J.NoDiscFareChildren, J.NoRailcard1, J.DateCreated, J.DateUpdated
			   ,J.FareId, J.PromoCode, J.FullAdultFare, J.DiscAdultFare1, J.DiscAdultFare2, J.DiscAdultFare3
			   ,J.FullChildFare, J.DiscChildFare1, J.DiscChildFare2, J.DiscChildFare3, J.NoAdultsFullFare
			   ,J.NoAdultsDiscFare1, J.NoAdultsDiscFare2, J.NoAdultsDiscFare3, J.NoChildFullFare, J.NoChildDiscFare1
			   ,J.NoChildDiscFare2, J.NoChildDiscFare3, COALESCE(RCT1.RailcardTypeID,-1) AS RailCard2, J.NoRailcard2, COALESCE(RCT2.RailcardTypeID,-1) AS RailCard3
			   ,J.NoRailcard3, J.NoGroupTicketsFullFare, J.NoGroupTicketsDiscFare, J.FullGroupFare, J.DiscGroupFare
		INTO #Journey
		FROM Staging.STG_SalesDetail AS SD
		INNER JOIN (
				SELECT   ROW_NUMBER() OVER (PARTITION BY purchaseid, journeyid ORDER BY cmddateupdated DESC, TOC_JourneyID DESC) AS RANKING 
						,*
				FROM PreProcessing.TOCPLUS_Journey 
				WHERE  DataImportDetailID = @dataimportdetailid
				AND    ProcessedInd = 0) AS J
			ON  SD.ExtReference = J.purchaseid
		LEFT JOIN Reference.TOC AS TOC
			ON J.faresettingtoc = TOC.ShortCode 
		LEFT JOIN Reference.RailcardType AS RCT
			ON J.railcard1 = RCT.Code
		LEFT JOIN Reference.Product AS P
			ON J.tickettypecode = P.TicketTypeCode
		LEFT JOIN Reference.FulfilmentMethod AS FFM
			ON J.deliverymethodcode = FFM.ShortCode 
		LEFT JOIN Reference.AvailabilityCode AS AC
			ON J.availabilitycode = AC.ShortCode
		LEFT JOIN #Station AS Origin WITH (NOLOCK)
			ON Origin.StationCode = J.origstationcode
		LEFT JOIN #Station AS Dest WITH (NOLOCK)
			ON Dest.StationCode = J.deststationcode
		LEFT JOIN Reference.RailcardType AS RCT1
			ON J.railcard2 = RCT1.Code
		LEFT JOIN Reference.RailcardType AS RCT2
			ON J.railcard3 = RCT2.Code
		WHERE J.RANKING = 1
		--AND TRY_CAST(SD.ExtReference AS INT) IS NOT NULL

		MERGE Staging.STG_Journey AS TRGT
		USING #Journey AS SRC
		ON TRGT.ExtReference = SRC.ExtReference
		WHEN NOT MATCHED THEN
		-- Inserting new journey information 
		INSERT (SalesDetailID, CustomerID, SalesTransactionID, ExtReference, TCSBookingID, TOCIDPrimary, LocationIDOrigin, LocationIDDestination
			,[OutDepartureDateTime], [OutArrivalDateTime], [RetDepartureDateTime], [RetArrivalDateTime], IsReturnInd,InformationSourceID
			,SourceModifiedDate,NoOfRailCards, TotalAdults, TotalChildren, TotalReturningAdults , totalreturningchildren, costoftickets
			,totalcost, savingsmade, procode, JourneyReference,IsOutboundInd, outboundmileage, AvailabilityCodeID
			,DisabledInd, NoFullFareAdults, NoDiscFareAdults, NoFullFareChildren, NoDiscFareChildren, NoRailcard1, DateCreated
			,DateUpdated, FareId, PromoCode, FullAdultFare, DiscAdultFare1, DiscAdultFare2, DiscAdultFare3, FullChildFare
			,DiscChildFare1, DiscChildFare2, DiscChildFare3, NoAdultsFullFare, NoAdultsDiscFare1, NoAdultsDiscFare2, NoAdultsDiscFare3
			,NoChildFullFare, NoChildDiscFare1, NoChildDiscFare2, NoChildDiscFare3, RailCard2, NoRailcard2, RailCard3, NoRailcard3
			,NoGroupTicketsFullFare, NoGroupTicketsDiscFare, FullGroupFare, DiscGroupFare, CreatedDate, CreatedBy, CreatedExtractNumber, LastModifiedDate
			,LastModifiedBy, LastModifiedExtractNumber)
		VALUES
				(SalesDetailID, CustomerID, SalesTransactionID, ExtReference, TCSBookingID, TOCID, OrigStationID, DestStationID
				,outdatedep, outdatearr, retdatedep, retdatearr, IsReturnIndicator, @InformationSourceID
				,SourceModifiedDate, NoOfRailCards, TotalAdults, TotalChildren, TotalReturningAdults , totalreturningchildren, costoftickets
				,totalcost, savingsmade, procode, JourneyReference,IsOutboundInd, outboundmileage, AvailabilityCodeID
				,DisabledInd, NoFullFareAdults, NoDiscFareAdults, NoFullFareChildren, NoDiscFareChildren, NoRailcard1, DateCreated
				,DateUpdated, FareId, PromoCode, FullAdultFare, DiscAdultFare1, DiscAdultFare2, DiscAdultFare3, FullChildFare
				,DiscChildFare1, DiscChildFare2, DiscChildFare3, NoAdultsFullFare, NoAdultsDiscFare1, NoAdultsDiscFare2, NoAdultsDiscFare3
				,NoChildFullFare, NoChildDiscFare1, NoChildDiscFare2, NoChildDiscFare3, RailCard2, NoRailcard2, RailCard3, NoRailcard3
				,NoGroupTicketsFullFare, NoGroupTicketsDiscFare, FullGroupFare, DiscGroupFare, @Now, 0, @dataimportdetailid, @Now
				,0, @dataimportdetailid)
		WHEN MATCHED 
			AND SRC.SourceModifiedDate > TRGT.SourceModifiedDate
			THEN 
				-- Update existing journey information
				UPDATE 
				SET TRGT.SourceModifiedDate = SRC.SourceModifiedDate
					,TRGT.LastModifiedExtractNumber = @dataimportdetailid
				    ,TRGT.LastModifiedDate = @now
					,TRGT.CustomerID = SRC.CustomerID
					,TRGT.SalesTransactionID  =  SRC.SalesTransactionID
					,TRGT.TCSBookingID = SRC.TCSBookingID
					,TRGT.TOCIDPrimary = SRC.TOCID
					,TRGT.LocationIDOrigin = SRC.OrigStationID
					,TRGT.LocationIDDestination = SRC.DestStationID
					,TRGT.[OutDepartureDateTime] = SRC.outdatedep
					,TRGT.[OutArrivalDateTime] = SRC.outdatearr
					,TRGT.[RetDepartureDateTime] = SRC.retdatedep
					,TRGT.[RetArrivalDateTime] = SRC.retdatearr
					,TRGT.IsReturnInd = SRC.IsReturnIndicator
					,TRGT.NoOfRailCards = SRC.NoOfRailCards
					,TRGT.TotalAdults = SRC.TotalAdults
					,TRGT.TotalChildren = SRC.TotalChildren
					,TRGT.TotalReturningAdults = SRC.TotalReturningAdults 
					,TRGT.totalreturningchildren = SRC.totalreturningchildren
					,TRGT.costoftickets = SRC.costoftickets
					,TRGT.totalcost = SRC.totalcost
					,TRGT.savingsmade = SRC.savingsmade
					,TRGT.procode = SRC.procode
					,TRGT.JourneyReference = SRC.JourneyReference
					,TRGT.IsOutboundInd = SRC.IsOutboundInd
					,TRGT.outboundmileage = SRC.outboundmileage
					,TRGT.AvailabilityCodeID = SRC.AvailabilityCodeID
					,TRGT.DisabledInd = SRC.DisabledInd
					,TRGT.NoFullFareAdults = SRC.NoFullFareAdults
					,TRGT.NoDiscFareAdults = SRC.NoDiscFareAdults
					,TRGT.NoFullFareChildren = SRC.NoFullFareChildren
					,TRGT.NoDiscFareChildren = SRC.NoDiscFareChildren
					,TRGT.NoRailcard1 = SRC.NoRailcard1
					,TRGT.FareId = SRC.FareId
					,TRGT.PromoCode = SRC.PromoCode
					,TRGT.FullAdultFare = SRC.FullAdultFare
					,TRGT.DiscAdultFare1 = SRC.DiscAdultFare1
					,TRGT.DiscAdultFare2 = SRC.DiscAdultFare2
					,TRGT.DiscAdultFare3 = SRC.DiscAdultFare3
					,TRGT.FullChildFare = SRC.FullChildFare
					,TRGT.DiscChildFare1 = SRC.DiscChildFare1
					,TRGT.DiscChildFare2 = SRC.DiscChildFare2
					,TRGT.DiscChildFare3 = SRC.DiscChildFare3
					,TRGT.NoAdultsFullFare = SRC.NoAdultsFullFare
					,TRGT.NoAdultsDiscFare1 = SRC.NoAdultsDiscFare1
					,TRGT.NoAdultsDiscFare2 = SRC.NoAdultsDiscFare2
					,TRGT.NoAdultsDiscFare3 = SRC.NoAdultsDiscFare3
					,TRGT.NoChildFullFare = SRC.NoChildFullFare
					,TRGT.NoChildDiscFare1 = SRC.NoChildDiscFare1
					,TRGT.NoChildDiscFare2 = SRC.NoChildDiscFare2
					,TRGT.NoChildDiscFare3 = SRC.NoChildDiscFare3
					,TRGT.RailCard2 = SRC.RailCard2
					,TRGT.NoRailcard2 = SRC.NoRailcard2
					,TRGT.RailCard3 = SRC.RailCard3
					,TRGT.NoRailcard3 = SRC.NoRailcard3
					,TRGT.NoGroupTicketsFullFare = SRC.NoGroupTicketsFullFare
					,TRGT.NoGroupTicketsDiscFare = SRC.NoGroupTicketsDiscFare
					,TRGT.FullGroupFare = SRC.FullGroupFare
					,TRGT.DiscGroupFare = SRC.DiscGroupFare;
		UPDATE SD
		SET SD.ProductID = J.ProductID
			,SD.FulfilmentMethodID = J.FulfilmentMethodID
			,RailcardTypeID = J.RailCard 
		FROM Staging.STG_SalesDetail AS SD
		INNER JOIN #Journey AS J
		ON  SD.SalesDetailID = J.SalesDetailID


		EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Insert journey information finish'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
	END TRY
	BEGIN CATCH		
	    SELECT @ErrorNum = ERROR_NUMBER();
		SELECT @ErrorMsg = ERROR_MESSAGE();
	    EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey;
		THROW 51403, @ErrorMsg, 1;		
	END CATCH

	EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Update processed ind in preprocessing journey table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

	UPDATE B
	SET  B.ProcessedInd = 1
	FROM [PreProcessing].TOCPLUS_Journey AS B 
	INNER JOIN  Staging.STG_Journey AS BL ON B.journeyid = BL.ExtReference
	AND   B.DataImportDetailID = @dataimportdetailid
	WHERE TRY_CAST(BL.ExtReference AS int) IS NOT NULL

	EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Update processed ind in preprocessing journey table'
                        ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint


	SELECT @successcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Journey
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.TOCPLUS_Journey
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

	SET @StepName = 'Operations.DataImportDetail_Update'
	BEGIN TRY
		EXEC uspSSISProcStepStart @ProcName, @StepName
		EXEC [Operations].[DataImportDetail_Update] @userid						= @userid,
													@dataimportdetailid			= @dataimportdetailid,
													@operationalstatusname		= 'Completed',
													@importfilename             = @importfilename,
													@starttimepreprocessing     = NULL,
													@endtimepreprocessing		= NULL,
													@starttimeimport			= NULL,
													@endtimeimport				= @now,
													@totalcountimport			= @recordcount,
													@successcountimport			= @successcountimport,
													@errorcountimport			= @errorcountimport
		EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
	END CATCH ;

	-- End auditting
	EXEC dbo.uspAuditAddAudit
		 @AuditType='PROCESS END'
		,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid, @PrintToScreen=@DebugPrint
 END
GO

