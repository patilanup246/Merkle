/*===========================================================================================
Name:			STG_NotQualifiedRenew_GranbyTraveller_Outbound
Purpose:		

Parameters:		

Outputs:		None
Notes:			    
			
Created:		USINARI
Modified:		

Peer Review:	
Call script:	e.g, EXEC Staging.STG_NotQualifiedRenew_GranbyTraveller_Outbound 0
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_NotQualifiedRenew_GranbyTraveller_Outbound]
(
	@userid                INTEGER = 0
)
AS
BEGIN
    
	SET NOCOUNT ON;
	   
	DECLARE @now                    DATETIME
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER   = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	DECLARE @importfilename			NVARCHAR(256)
		
	DECLARE @StepName               NVARCHAR(280)
	DECLARE @ProcName				NVARCHAR(256)
	DECLARE @DbName				    NVARCHAR(256) 
	DECLARE @AuditType			    NVARCHAR(256) 
	DECLARE @SpId							 INT 
	
	DECLARE @DebugPrint					INT = 0
		
	DECLARE @recordcountIns            INTEGER       = 0
	
	DECLARE @recordcountUpd            INTEGER       = 0
	DECLARE @rowcountUpd					INTEGER       = 0
	DECLARE @rowcountIns					INTEGER       = 0

	
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	SELECT @DbName = DB_NAME()
	SELECT @SpId = @@SPID
	SELECT @AuditType = 'PROCESS START'
	SELECT @StepName = 'Staging.STG_NotQualifiedRenew_GranbyTraveller_Outbound ProcedureStart'

	
	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	---EXEC uspSSISProcStepStart @spname, @StepName

	BEGIN TRY

	IF OBJECT_ID('tempdb.dbo.#JourneyReQualifiedCustomers') IS NOT NULL
	BEGIN
		drop table #JourneyReQualifiedCustomers
	END
	IF OBJECT_ID('tempdb.dbo.#ReQualifiedCustomers2') IS NOT NULL
	BEGIN
		drop table #ReQualifiedCustomers2
	END
	IF OBJECT_ID('tempdb.dbo.#ReQualifiedCustomers') IS NOT NULL
	BEGIN
		drop table #ReQualifiedCustomers
	END
	IF OBJECT_ID('tempdb.dbo.#ReQualifiedCustomersJourneyPoints') IS NOT NULL
	BEGIN
		drop table #ReQualifiedCustomersJourneyPoints
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
	IF OBJECT_ID('tempdb.dbo.#ReQualifiedCustomersSpend') IS NOT NULL
	BEGIN
		drop table #ReQualifiedCustomersSpend
	END

	SELECT K.*
	INTO #JourneyReQualifiedCustomers
	FROM (
	SELECT a.* 
	FROM PreProcessing.TOCPLUS_Journey a
	WHERE a.tcscustomerid in (SELECT CUID FROM PreProcessing.Granby_Traveller WHERE (EFF_TO_DATE > GETDATE()) and (EFF_TO_DATE <= DATEADD(month,3, GETDATE())))
	) k
	INNER JOIN PreProcessing.Granby_Traveller m on (k.tcscustomerid = m.CUID) and (k.outdatedep >= DATEADD(month,-12, m.EFF_TO_DATE))
	

--Spend Level Qualification Criteria A customer ids

	SELECT DISTINCT 'Criteria A' as Criteria, l.tcscustomerid
	INTO #ReQualifiedCustomersSpend
	FROM #JourneyReQualifiedCustomers a
	INNER JOIN (SELECT tcscustomerid, SUM(totalcost) as totalcost FROM #JourneyReQualifiedCustomers j WHERE (j.outdatedep >= DATEADD(YEAR,-1, GETDATE()))  GROUP BY tcscustomerid having SUM(totalcost) >=5000) l 
	on (a.tcscustomerid = l.tcscustomerid)
	WHERE a.origstation in ('WARRINGTON BANK QUAY','WIGAN NORTH WESTERN','WILMSLOW','BANGOR (GWYNEDD)','BIRMINGHAM INTERNATIONAL','EDINBURGH WAVERLEY', 'GLASGOW CENTRAL','FLINT','HAYMARKET (EDINBURGH)','HOLYHEAD',
	'LIVERPOOL LIME STREET','LANCASTER','LLANDUDNO JUNCTION','LOCKERBIE','MANCHESTER PICCADILLY','NORTHAMPTON','NUNEATON','PENRITH','PRESTATYN','SANDWELL & DUDLEY','STOKE-ON-TRENT','WOLVERHAMPTON','LONDON EUSTON',
	'OXENHOLME LAKE DISTRICT','RUGBY','RUNCORN','WATFORD JUNCTION','WREXHAM GENERAL','MOTHERWELL','PRESTON','TAMWORTH','COLWYN BAY','MACCLESFIELD','RHYL','COVENTRY','STOCKPORT','CREWE','STAFFORD','MILTON KEYNES CENTRAL',
	'BIRMINGHAM NEW STREET','CARLISLE', 'CHESTER','LICHFIELD TRENT VALLEY','BLACKPOOL NORTH','POULTON-LE-FYLDE','KIRKHAM & WESHAM','SHREWSBURY','WELLINGTON (SHROPSHIRE)','TELFORD CENTRAL')
	and a.deststation in ('WARRINGTON BANK QUAY','WIGAN NORTH WESTERN','WILMSLOW','BANGOR (GWYNEDD)','BIRMINGHAM INTERNATIONAL','EDINBURGH WAVERLEY', 'GLASGOW CENTRAL','FLINT','HAYMARKET (EDINBURGH)','HOLYHEAD',
	'LIVERPOOL LIME STREET','LANCASTER','LLANDUDNO JUNCTION','LOCKERBIE', 'MANCHESTER PICCADILLY','NORTHAMPTON','NUNEATON','PENRITH','PRESTATYN','SANDWELL & DUDLEY','STOKE-ON-TRENT','WOLVERHAMPTON', 'LONDON EUSTON',
	'OXENHOLME LAKE DISTRICT','RUGBY','RUNCORN','WATFORD JUNCTION','WREXHAM GENERAL','MOTHERWELL','PRESTON','TAMWORTH','COLWYN BAY','MACCLESFIELD','RHYL','COVENTRY','STOCKPORT','CREWE','STAFFORD','MILTON KEYNES CENTRAL',
	'BIRMINGHAM NEW STREET','CARLISLE','CHESTER','LICHFIELD TRENT VALLEY','BLACKPOOL NORTH','POULTON-LE-FYLDE','KIRKHAM & WESHAM','SHREWSBURY','WELLINGTON (SHROPSHIRE)','TELFORD CENTRAL')
	or faresettingtoc = 'IWC'

	
--Journey Points based Qualification Criteria A customer ids

	SELECT a.*
	INTO #testJourneyPoints
	FROM #JourneyReQualifiedCustomers a
	WHERE a.origstation in ('WARRINGTON BANK QUAY','WIGAN NORTH WESTERN','WILMSLOW','BANGOR (GWYNEDD)','BIRMINGHAM INTERNATIONAL','EDINBURGH WAVERLEY', 'GLASGOW CENTRAL','FLINT','HAYMARKET (EDINBURGH)','HOLYHEAD',
	'LIVERPOOL LIME STREET','LANCASTER','LLANDUDNO JUNCTION','LOCKERBIE','MANCHESTER PICCADILLY','NORTHAMPTON','NUNEATON','PENRITH','PRESTATYN','SANDWELL & DUDLEY','STOKE-ON-TRENT','WOLVERHAMPTON','LONDON EUSTON',
	'OXENHOLME LAKE DISTRICT','RUGBY','RUNCORN','WATFORD JUNCTION','WREXHAM GENERAL','MOTHERWELL','PRESTON','TAMWORTH','COLWYN BAY','MACCLESFIELD','RHYL','COVENTRY','STOCKPORT','CREWE','STAFFORD','MILTON KEYNES CENTRAL',
	'BIRMINGHAM NEW STREET','CARLISLE', 'CHESTER','LICHFIELD TRENT VALLEY','BLACKPOOL NORTH','POULTON-LE-FYLDE','KIRKHAM & WESHAM','SHREWSBURY','WELLINGTON (SHROPSHIRE)','TELFORD CENTRAL')
	and a.deststation in ('WARRINGTON BANK QUAY','WIGAN NORTH WESTERN','WILMSLOW','BANGOR (GWYNEDD)','BIRMINGHAM INTERNATIONAL','EDINBURGH WAVERLEY', 'GLASGOW CENTRAL','FLINT','HAYMARKET (EDINBURGH)','HOLYHEAD',
	'LIVERPOOL LIME STREET','LANCASTER','LLANDUDNO JUNCTION','LOCKERBIE', 'MANCHESTER PICCADILLY','NORTHAMPTON','NUNEATON','PENRITH','PRESTATYN','SANDWELL & DUDLEY','STOKE-ON-TRENT','WOLVERHAMPTON', 'LONDON EUSTON',
	'OXENHOLME LAKE DISTRICT','RUGBY','RUNCORN','WATFORD JUNCTION','WREXHAM GENERAL','MOTHERWELL','PRESTON','TAMWORTH','COLWYN BAY','MACCLESFIELD','RHYL','COVENTRY','STOCKPORT','CREWE','STAFFORD','MILTON KEYNES CENTRAL',
	'BIRMINGHAM NEW STREET','CARLISLE','CHESTER','LICHFIELD TRENT VALLEY','BLACKPOOL NORTH','POULTON-LE-FYLDE','KIRKHAM & WESHAM','SHREWSBURY','WELLINGTON (SHROPSHIRE)','TELFORD CENTRAL')
	or faresettingtoc = 'IWC'


	SELECT outdatedep, tcscustomerid, TOC_JourneyID, 1 as JourneyPoints
	INTO #testJourneyPoints2
	FROM #testJourneyPoints a
	WHERE a.tickettypecode in ('TTN', 'TTS') and ((a.FullAdultFare >= 614) or (a.DiscAdultFare1>=614) or (a.DiscAdultFare2>=614) or (a.DiscAdultFare3>=614))
	union
	SELECT outdatedep, tcscustomerid,  TOC_JourneyID, 2 as JourneyPoints
	FROM #testJourneyPoints a
	WHERE a.tickettypecode = 'VBR' and ((a.FullAdultFare >=165) or (a.DiscAdultFare1>=165) or (a.DiscAdultFare2>=165) or (a.DiscAdultFare3>=165))
	union
	SELECT outdatedep, tcscustomerid,  TOC_JourneyID, 2 as JourneyPoints
	FROM #testJourneyPoints a
	WHERE a.tickettypecode = 'FOR' and ((a.FullAdultFare >=100) or (a.DiscAdultFare1>=100) or (a.DiscAdultFare2>=100) or (a.DiscAdultFare3>=100))
	union
	SELECT outdatedep, tcscustomerid,  TOC_JourneyID, 1 as JourneyPoints
	FROM #testJourneyPoints a
	WHERE a.tickettypecode in ('BFO','BGO','BHO','FAS','FBS','FCS','FIS','LFB','FSS') and ((a.FullAdultFare >= 70) or (a.DiscAdultFare1>=70) or (a.DiscAdultFare2>=70) or (a.DiscAdultFare3>=70))
	union
	SELECT outdatedep, tcscustomerid,  TOC_JourneyID, 1 as JourneyPoints
	FROM #testJourneyPoints a
	WHERE a.tickettypecode in ('FDS', 'FOS') and ((a.FullAdultFare >= 50) or (a.DiscAdultFare1>=50) or (a.DiscAdultFare2>=50) or (a.DiscAdultFare3>=50))


	SELECT tcscustomerid, outdatedep, journeypoints, SUM(journeypoints) over (partition by tcscustomerid ORDER BY tcscustomerid, outdatedep) as JourneyPointsRunningTotal
	INTO #testJourneyPoints3
	FROM #testJourneyPoints2
	ORDER BY 1,2;


	--SELECT DISTINCT 'Criteria B' as Criteria, a.tcscustomerid 
	--INTO #ReQualifiedCustomersJourneyPoints 
	--FROM #testJourneyPoints3 a
	--WHERE a.JourneyPointsRunningTotal >= 16
	--and exists (SELECT 1 FROM #testJourneyPoints2 b WHERE (b.tcscustomerid = a.tcscustomerid) and (abs(datediff(day, a.outdatedep, b.outdatedep)) <=96)) 

	SELECT DISTINCT 'Criteria B' as Criteria, a.tcscustomerid 
	INTO #ReQualifiedCustomersJourneyPoints 
	FROM #testJourneyPoints3 a
	INNER JOIN #testJourneyPoints3 b on (b.tcscustomerid = a.tcscustomerid) and (abs(datediff(day, a.outdatedep, b.outdatedep)) <=96) and (abs(a.JourneyPointsRunningTotal - b.JourneyPointsRunningTotal) >= 16)

	
	SELECT DISTINCT criteria + '   ' as Criteria, tcscustomerid 
	INTO #ReQualifiedCustomers
	FROM(
	SELECT  criteria, tcscustomerid  FROM #ReQualifiedCustomersJourneyPoints 
	union 
	SELECT  criteria, tcscustomerid  FROM #ReQualifiedCustomersSpend
	) a

	update a
	set criteria = 'Criteria A&B'
	FROM #ReQualifiedCustomers a
	WHERE a.tcscustomerid in (SELECT b.tcscustomerid FROM #ReQualifiedCustomers b GROUP BY b.tcscustomerid having count(*) = 2)

	SELECT DISTINCT * INTO #ReQualifiedCustomers2 
	FROM #ReQualifiedCustomers


	SELECT DISTINCT b.LOYALTY_MEMBERSHIP_NUM, b.EFF_TO_DATE as Expiry_Date, GETDATE() as Start_Analysis_Window, DATEADD(month,-2,GETDATE()) as Start_2Month_Window, l.totalcost as Spend,
			 m.JourneyPointsLast2Months as Points_Last2Months, (16 - m.JourneyPointsLast2Months) as Points_Last2Months, DATEADD(month,1,GETDATE()) as Points_Needed_By_Date, d.title as Title, 
			 d.forename as First_Name, d.surname as Surname, d.emailaddress as Email_Address
	FROM #JourneyReQualifiedCustomers a 
	INNER JOIN PreProcessing.Granby_Traveller b on a.tcscustomerid = b.CUID
	INNER JOIN PreProcessing.TOCPLUS_Customer d on a.tcscustomerid = d.tcscustomerid
	INNER JOIN (SELECT tcscustomerid, SUM(totalcost) as totalcost FROM #JourneyReQualifiedCustomers j WHERE (j.outdatedep >= DATEADD(YEAR,-1, GETDATE()))  GROUP BY tcscustomerid) l
	on (a.tcscustomerid = l.tcscustomerid)
	INNER JOIN (SELECT tcscustomerid, SUM(isnull(journeypoints,0)) as JourneyPointsLast2Months FROM #testJourneyPoints2 WHERE outdatedep >= DATEADD(month, -2, GETDATE()) GROUP BY tcscustomerid) m
	on (a.tcscustomerid = m.tcscustomerid)
	WHERE a.tcscustomerid not in (SELECT tcscustomerid FROM #ReQualifiedCustomers2)
	and a.origstation in ('WARRINGTON BANK QUAY','WIGAN NORTH WESTERN','WILMSLOW','BANGOR (GWYNEDD)','BIRMINGHAM INTERNATIONAL','EDINBURGH WAVERLEY', 'GLASGOW CENTRAL','FLINT','HAYMARKET (EDINBURGH)','HOLYHEAD',
	'LIVERPOOL LIME STREET','LANCASTER','LLANDUDNO JUNCTION','LOCKERBIE','MANCHESTER PICCADILLY','NORTHAMPTON','NUNEATON','PENRITH','PRESTATYN','SANDWELL & DUDLEY','STOKE-ON-TRENT','WOLVERHAMPTON','LONDON EUSTON',
	'OXENHOLME LAKE DISTRICT','RUGBY','RUNCORN','WATFORD JUNCTION','WREXHAM GENERAL','MOTHERWELL','PRESTON','TAMWORTH','COLWYN BAY','MACCLESFIELD','RHYL','COVENTRY','STOCKPORT','CREWE','STAFFORD','MILTON KEYNES CENTRAL',
	'BIRMINGHAM NEW STREET','CARLISLE', 'CHESTER','LICHFIELD TRENT VALLEY','BLACKPOOL NORTH','POULTON-LE-FYLDE','KIRKHAM & WESHAM','SHREWSBURY','WELLINGTON (SHROPSHIRE)','TELFORD CENTRAL')
	and a.deststation in ('WARRINGTON BANK QUAY','WIGAN NORTH WESTERN','WILMSLOW','BANGOR (GWYNEDD)','BIRMINGHAM INTERNATIONAL','EDINBURGH WAVERLEY', 'GLASGOW CENTRAL','FLINT','HAYMARKET (EDINBURGH)','HOLYHEAD',
	'LIVERPOOL LIME STREET','LANCASTER','LLANDUDNO JUNCTION','LOCKERBIE', 'MANCHESTER PICCADILLY','NORTHAMPTON','NUNEATON','PENRITH','PRESTATYN','SANDWELL & DUDLEY','STOKE-ON-TRENT','WOLVERHAMPTON', 'LONDON EUSTON',
	'OXENHOLME LAKE DISTRICT','RUGBY','RUNCORN','WATFORD JUNCTION','WREXHAM GENERAL','MOTHERWELL','PRESTON','TAMWORTH','COLWYN BAY','MACCLESFIELD','RHYL','COVENTRY','STOCKPORT','CREWE','STAFFORD','MILTON KEYNES CENTRAL',
	'BIRMINGHAM NEW STREET','CARLISLE','CHESTER','LICHFIELD TRENT VALLEY','BLACKPOOL NORTH','POULTON-LE-FYLDE','KIRKHAM & WESHAM','SHREWSBURY','WELLINGTON (SHROPSHIRE)','TELFORD CENTRAL')
	or faresettingtoc = 'IWC'


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
	 
	 SELECT @StepName = 'STG_NotQualifiedRenew_GranbyTraveller_Outbound'
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
	SELECT @StepName = 'Staging.STG_NotQualifiedRenew_GranbyTraveller_Outbound Procedure Try'

	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	---EXEC dbo.uspSSISProcStepSuccess @spname, @StepName


	RETURN 
END