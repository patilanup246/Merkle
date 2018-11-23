/*===========================================================================================
Name:			STG_NewQualified_GranbyTraveller_Outbound
Purpose:		

Parameters:		

Outputs:		None
Notes:			    
			
Created:		USINARI
Modified:		

Peer Review:	
Call script:	e.g, EXEC Staging.STG_NewQualified_GranbyTraveller_Outbound 0
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_NewQualified_GranbyTraveller_Outbound]
(
	@userid                INTEGER = 0
)
AS
BEGIN
    
	SET NOCOUNT ON;
	   
	DECLARE @now                    DATETIME
	DECLARE @successCOUNTimport     INTEGER = 0
	DECLARE @errorCOUNTimport       INTEGER = 0

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordCOUNT            INTEGER   = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	DECLARE @importfilename			NVARCHAR(256)
		
	DECLARE @StepName               NVARCHAR(280)
	DECLARE @ProcName				NVARCHAR(256)
	DECLARE @DbName				    NVARCHAR(256) 
	DECLARE @AuditType			    NVARCHAR(256) 
	DECLARE @SpId							 INT 
	
	DECLARE @DebugPrint					INT = 0
		
	DECLARE @recordCOUNTIns            INTEGER       = 0
	
	DECLARE @recordCOUNTUpd            INTEGER       = 0
	DECLARE @rowCOUNTUpd					INTEGER       = 0
	DECLARE @rowCOUNTIns					INTEGER       = 0

	
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	SELECT @DbName = DB_NAME()
	SELECT @SpId = @@SPID
	SELECT @AuditType = 'PROCESS START'
	SELECT @StepName = 'Staging.STG_NewQualified_GranbyTraveller_Outbound ProcedureStart'

	
	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	---EXEC uspSSISProcStepStart @spname, @StepName

	BEGIN TRY

	IF OBJECT_ID('tempdb.dbo.#NewQualifiedCustomers2') IS NOT NULL
	BEGIN
		drop table #NewQualifiedCustomers2
	END
	IF OBJECT_ID('tempdb.dbo.#NewQualifiedCustomers') IS NOT NULL
	BEGIN
		drop table #NewQualifiedCustomers
	END
	IF OBJECT_ID('tempdb.dbo.#NewQualifiedCustomersJourneyPoints') IS NOT NULL
	BEGIN
		drop table #NewQualifiedCustomersJourneyPoints
	END
	IF OBJECT_ID('tempdb.dbo.#NewQualifiedCustomersSpend') IS NOT NULL
	BEGIN
		drop table #NewQualifiedCustomersSpend
	END
	IF OBJECT_ID('tempdb.dbo.#testJourneyPoints') IS NOT NULL
	BEGIN
		drop table #testJourneyPoints
	END
	IF OBJECT_ID('tempdb.dbo.#testJourneyPoints2') IS NOT NULL
	BEGIN
		drop table #testJourneyPoints2
	END
	IF OBJECT_ID('tempdb.dbo.#testJourneyPoints3') IS NOT NULL
	BEGIN
		drop table #testJourneyPoints3
	END


--Spend Level Qualification Criteria A customer ids

	SELECT Distinct 'Criteria A' as Criteria, l.tcscustomerid
	INTO #NewQualifiedCustomersSpend
	FROM PreProcessing.TOCPLUS_Journey a
	INNER JOIN (SELECT tcscustomerid, SUM(totalcost) as totalcost FROM PreProcessing.TOCPLUS_Journey j WHERE (j.outdatedep >= DATEADD(YEAR,-1, GETDATE())) GROUP BY tcscustomerid having SUM(totalcost) >=6000) l 
	on (a.tcscustomerid = l.tcscustomerid) 
	WHERE a.outdatedep < (SELECT max(DateEnd) FROM (SELECT top 13 * FROM reference.period WHERE datestart < GETDATE() order by PeriodID desc) k1)
	AND a.outdatedep > (SELECT min(DateStart) FROM (SELECT top 13 * FROM reference.period WHERE datestart < GETDATE() order by PeriodID desc) k2)
	AND a.origstation in ('WARRINGTON BANK QUAY','WIGAN NORTH WESTERN','WILMSLOW','BANGOR (GWYNEDD)','BIRMINGHAM INTERNATIONAL','EDINBURGH WAVERLEY', 'GLASGOW CENTRAL','FLINT','HAYMARKET (EDINBURGH)','HOLYHEAD',
	'LIVERPOOL LIME STREET','LANCASTER','LLANDUDNO JUNCTION','LOCKERBIE','MANCHESTER PICCADILLY','NORTHAMPTON','NUNEATON','PENRITH','PRESTATYN','SANDWELL & DUDLEY','STOKE-ON-TRENT','WOLVERHAMPTON','LONDON EUSTON',
	'OXENHOLME LAKE DISTRICT','RUGBY','RUNCORN','WATFORD JUNCTION','WREXHAM GENERAL','MOTHERWELL','PRESTON','TAMWORTH','COLWYN BAY','MACCLESFIELD','RHYL','COVENTRY','STOCKPORT','CREWE','STAFFORD','MILTON KEYNES CENTRAL',
	'BIRMINGHAM NEW STREET','CARLISLE', 'CHESTER','LICHFIELD TRENT VALLEY','BLACKPOOL NORTH','POULTON-LE-FYLDE','KIRKHAM & WESHAM','SHREWSBURY','WELLINGTON (SHROPSHIRE)','TELFORD CENTRAL')
	AND a.deststation in ('WARRINGTON BANK QUAY','WIGAN NORTH WESTERN','WILMSLOW','BANGOR (GWYNEDD)','BIRMINGHAM INTERNATIONAL','EDINBURGH WAVERLEY', 'GLASGOW CENTRAL','FLINT','HAYMARKET (EDINBURGH)','HOLYHEAD',
	'LIVERPOOL LIME STREET','LANCASTER','LLANDUDNO JUNCTION','LOCKERBIE', 'MANCHESTER PICCADILLY','NORTHAMPTON','NUNEATON','PENRITH','PRESTATYN','SANDWELL & DUDLEY','STOKE-ON-TRENT','WOLVERHAMPTON', 'LONDON EUSTON',
	'OXENHOLME LAKE DISTRICT','RUGBY','RUNCORN','WATFORD JUNCTION','WREXHAM GENERAL','MOTHERWELL','PRESTON','TAMWORTH','COLWYN BAY','MACCLESFIELD','RHYL','COVENTRY','STOCKPORT','CREWE','STAFFORD','MILTON KEYNES CENTRAL',
	'BIRMINGHAM NEW STREET','CARLISLE','CHESTER','LICHFIELD TRENT VALLEY','BLACKPOOL NORTH','POULTON-LE-FYLDE','KIRKHAM & WESHAM','SHREWSBURY','WELLINGTON (SHROPSHIRE)','TELFORD CENTRAL')
	OR faresettingtoc = 'IWC'
	

--Journey Points based Qualification Criteria A customer ids

	SELECT a.*
	INTO #testJourneyPoints
	FROM PreProcessing.TOCPLUS_Journey a
	WHERE a.outdatedep < (SELECT max(DateEnd) FROM (SELECT top 13 * FROM reference.period WHERE datestart < GETDATE() order by PeriodID desc) k1)
	AND a.outdatedep > (SELECT min(DateStart) FROM (SELECT top 13 * FROM reference.period WHERE datestart < GETDATE() order by PeriodID desc) k2)
	AND a.origstation in ('WARRINGTON BANK QUAY','WIGAN NORTH WESTERN','WILMSLOW','BANGOR (GWYNEDD)','BIRMINGHAM INTERNATIONAL','EDINBURGH WAVERLEY', 'GLASGOW CENTRAL','FLINT','HAYMARKET (EDINBURGH)','HOLYHEAD',
	'LIVERPOOL LIME STREET','LANCASTER','LLANDUDNO JUNCTION','LOCKERBIE','MANCHESTER PICCADILLY','NORTHAMPTON','NUNEATON','PENRITH','PRESTATYN','SANDWELL & DUDLEY','STOKE-ON-TRENT','WOLVERHAMPTON','LONDON EUSTON',
	'OXENHOLME LAKE DISTRICT','RUGBY','RUNCORN','WATFORD JUNCTION','WREXHAM GENERAL','MOTHERWELL','PRESTON','TAMWORTH','COLWYN BAY','MACCLESFIELD','RHYL','COVENTRY','STOCKPORT','CREWE','STAFFORD','MILTON KEYNES CENTRAL',
	'BIRMINGHAM NEW STREET','CARLISLE', 'CHESTER','LICHFIELD TRENT VALLEY','BLACKPOOL NORTH','POULTON-LE-FYLDE','KIRKHAM & WESHAM','SHREWSBURY','WELLINGTON (SHROPSHIRE)','TELFORD CENTRAL')
	AND a.deststation in ('WARRINGTON BANK QUAY','WIGAN NORTH WESTERN','WILMSLOW','BANGOR (GWYNEDD)','BIRMINGHAM INTERNATIONAL','EDINBURGH WAVERLEY', 'GLASGOW CENTRAL','FLINT','HAYMARKET (EDINBURGH)','HOLYHEAD',
	'LIVERPOOL LIME STREET','LANCASTER','LLANDUDNO JUNCTION','LOCKERBIE', 'MANCHESTER PICCADILLY','NORTHAMPTON','NUNEATON','PENRITH','PRESTATYN','SANDWELL & DUDLEY','STOKE-ON-TRENT','WOLVERHAMPTON', 'LONDON EUSTON',
	'OXENHOLME LAKE DISTRICT','RUGBY','RUNCORN','WATFORD JUNCTION','WREXHAM GENERAL','MOTHERWELL','PRESTON','TAMWORTH','COLWYN BAY','MACCLESFIELD','RHYL','COVENTRY','STOCKPORT','CREWE','STAFFORD','MILTON KEYNES CENTRAL',
	'BIRMINGHAM NEW STREET','CARLISLE','CHESTER','LICHFIELD TRENT VALLEY','BLACKPOOL NORTH','POULTON-LE-FYLDE','KIRKHAM & WESHAM','SHREWSBURY','WELLINGTON (SHROPSHIRE)','TELFORD CENTRAL')
	or faresettingtoc = 'IWC'


	SELECT outdatedep, tcscustomerid, TOC_JourneyID, 1 as JourneyPoints
	INTO #testJourneyPoints2
	FROM #testJourneyPoints a
	WHERE a.tickettypecode in ('TTN', 'TTS') AND ((a.FullAdultFare >= 614) or (a.DiscAdultFare1>=614) or (a.DiscAdultFare2>=614) or (a.DiscAdultFare3>=614))
	union
	SELECT outdatedep, tcscustomerid,  TOC_JourneyID, 2 as JourneyPoints
	FROM #testJourneyPoints a
	WHERE a.tickettypecode = 'VBR' AND ((a.FullAdultFare >=165) or (a.DiscAdultFare1>=165) or (a.DiscAdultFare2>=165) or (a.DiscAdultFare3>=165))
	union
	SELECT outdatedep, tcscustomerid,  TOC_JourneyID, 2 as JourneyPoints
	FROM #testJourneyPoints a
	WHERE a.tickettypecode = 'FOR' AND ((a.FullAdultFare >=100) or (a.DiscAdultFare1>=100) or (a.DiscAdultFare2>=100) or (a.DiscAdultFare3>=100))
	union
	SELECT outdatedep, tcscustomerid,  TOC_JourneyID, 1 as JourneyPoints
	FROM #testJourneyPoints a
	WHERE a.tickettypecode in ('BFO','BGO','BHO','FAS','FBS','FCS','FIS','LFB','FSS') AND ((a.FullAdultFare >= 70) or (a.DiscAdultFare1>=70) or (a.DiscAdultFare2>=70) or (a.DiscAdultFare3>=70))
	union
	SELECT outdatedep, tcscustomerid,  TOC_JourneyID, 1 as JourneyPoints
	FROM #testJourneyPoints a
	WHERE a.tickettypecode in ('FDS', 'FOS') AND ((a.FullAdultFare >= 50) or (a.DiscAdultFare1>=50) or (a.DiscAdultFare2>=50) or (a.DiscAdultFare3>=50))


	SELECT tcscustomerid, outdatedep, journeypoints, SUM(journeypoints) over (partition by tcscustomerid order by tcscustomerid, outdatedep) as JourneyPointsRunningTotal
	INTO #testJourneyPoints3
	FROM #testJourneyPoints2
	--WHERE tcscustomerid = 2192701
	ORDER BY 1,2;


	
	SELECT Distinct 'Criteria B' as Criteria, a.tcscustomerid 
	INTO #NewQualifiedCustomersJourneyPoints 
	FROM #testJourneyPoints3 a
	INNER JOIN #testJourneyPoints3 b on (b.tcscustomerid = a.tcscustomerid) AND (abs(datediff(day, a.outdatedep, b.outdatedep)) <=96) AND (abs(a.JourneyPointsRunningTotal - b.JourneyPointsRunningTotal) >= 16)


	SELECT distinct criteria + '   ' as Criteria, tcscustomerid 
	INTO #NewQualifiedCustomers
	FROM(
	SELECT  criteria, tcscustomerid  FROM #NewQualifiedCustomersJourneyPoints 
	union 
	SELECT  criteria, tcscustomerid  FROM #NewQualifiedCustomersSpend
	) a

	update a
	set criteria = 'Criteria A&B'
	FROM #NewQualifiedCustomers a
	WHERE a.tcscustomerid in (SELECT b.tcscustomerid FROM #NewQualifiedCustomers b GROUP BY b.tcscustomerid having COUNT(*) = 2)


	SELECT distinct * INTO #NewQualifiedCustomers2 FROM #NewQualifiedCustomers

	SELECT distinct a.criteria as Criteria, a.tcscustomerid as Customer_Id, b.title as Title, b.forename as First_Name, b.surname as Surname, b.emailaddress as Email_Address, b.addressline1 as Address_Line1,
			b.addressline2 as Address_Line2,b.addressline3 as Address_Line3,b.addressline4 as Address_Line4,b.addressline5 as Address_Line5,b.COUNTry as COUNTry, b.postcode as Postcode, b.dayphoneno as Day_Phone_Number,
			b.MobileTelephoneNo as Mobile_Phone_Number, c.Revenue12 as Revenue_FROM_Last_12_Months, c.Transactions12 as Transactions_FROM_Last_12_Months 
	FROM #NewQualifiedCustomers2 a
	INNER JOIN PreProcessing.TOCPLUS_Customer b on a.tcscustomerid = b.tcscustomerid
	left outer join (
						SELECT		a1.tcscustomerid , SUM(a1.totalcostofallpurchases)as Revenue12 , COUNT(*) as Transactions12
						FROM PreProcessing.TOCPLUS_Transaction a1
						WHERE (a1.transactiondate >= DATEADD(YEAR,-1, GETDATE()))   
						GROUP BY a1.tcscustomerid
						) c on a.tcscustomerid = c.tcscustomerid

	---EXEC dbo.uspSSISProcStepSuccess @spname, @StepName		
	
	END TRY
	BEGIN CATCH  
	 DECLARE   
	  @ErrorMessage VARCHAR(4000),  
	  @ErrorNumber INT,  
	  @ErrorSeverity INT,  
	  @ErrorState INT,  
	  @ErrorLine INT,  
	  @ErrorProcedure VARCHAR(126);  
  
  
	 SELECT   
	  @ErrorNumber = ERROR_NUMBER(),  
	  @ErrorSeverity = ERROR_SEVERITY(),  
	  @ErrorState = ERROR_STATE(),  
	  @ErrorLine = ERROR_LINE(),  
	  @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), 'N/A');  
  
	 --Build the error message string  
	 SELECT @ErrorMessage = 'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +  
				'Message: ' + ERROR_MESSAGE()        
	 
	 SELECT @StepName = 'STG_NewQualified_GranbyTraveller_Outbound'
    --EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMessage, -1
	 
	 RAISERROR                                      
	 (  
	  @ErrorMessage,  
	  @ErrorSeverity,  
	  1,  
	  @ErrorNumber,  
	  @ErrorSeverity,  
	  @ErrorState,  
	  @ErrorProcedure,  
	  @ErrorLine  
	 );      
	END CATCH
	
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	SELECT @DbName = DB_NAME()
	SELECT @SpId = @@SPID
	SELECT @AuditType = 'PROCESS END'
	SELECT @StepName = 'Staging.STG_NewQualified_GranbyTraveller_Outbound Procedure Try'

	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	---EXEC dbo.uspSSISProcStepSuccess @spname, @StepName


	RETURN 
END