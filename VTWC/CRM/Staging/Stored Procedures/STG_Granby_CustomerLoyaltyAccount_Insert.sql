USE [CRM]
GO
/****** Object:  StoredProcedure [Staging].[STG_Granby_CustomerLoyaltyAccount_Insert]    Script Date: 29/08/2018 12:16:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*===========================================================================================
Name:			STG_Granby_CustomerLoyaltyAccount_Insert
Purpose:		

Parameters:		

Outputs:		None
Notes:			    
			
Created:		USINARI
Modified:		

Peer Review:	
Call script:	e.g, EXEC Staging.STG_Granby_CustomerLoyaltyAccount_Insert 0, XXX
=================================================================================================*/

CREATE PROCEDURE [Staging].[STG_Granby_CustomerLoyaltyAccount_Insert]
(
	@userid                INTEGER = 0,
	@dataimportdetailid    INTEGER
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @now                    DATETIME
	DECLARE @successcountimport     INTEGER = 0
	DECLARE @errorcountimport       INTEGER = 0

	DECLARE @informationsourceid    INTEGER

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER
	DECLARE @logmessage             NVARCHAR(MAX)

	DECLARE @importfilename				NVARCHAR(256)
	
	DECLARE @dataimportdetailid_Journey INTEGER 

	
	DECLARE @StepName                 NVARCHAR(280)
	DECLARE @ProcName						 NVARCHAR(256)
	DECLARE @DbName				       NVARCHAR(256) 
	DECLARE @AuditType				       NVARCHAR(256) 
	DECLARE @SpId							 INT 
		
	DECLARE @DebugPrint					INT = 0

	DECLARE @CUID bigint 
	DECLARE @TITLE nvarchar(255)
	DECLARE @FORENAME nvarchar(255)
	DECLARE @SURNAME nvarchar(255)
	DECLARE @GENDER nchar(1)
	DECLARE @DAY_TELEPHONE nvarchar(255)
	DECLARE @EVENING_TELEPHONE nvarchar(255)
	DECLARE @FAX_NUM nvarchar(255)
	DECLARE @EMAIL_ADDRESS nvarchar(255)
	DECLARE @HOME_ADDRESS_LINE1 nvarchar(255)
	DECLARE @HOME_ADDRESS_LINE2 nvarchar(255)
	DECLARE @HOME_ADDRESS_LINE3 nvarchar(255)
	DECLARE @HOME_ADDRESS_LINE4 nvarchar(255)
	DECLARE @HOME_ADDRESS_LINE5 nvarchar(255)
	DECLARE @HOME_POSTCODE nvarchar(255)
	DECLARE @HOME_MAIL_PREF_FLAG nchar(1)
	DECLARE @HOME_COMPANY_NAME nvarchar(255)
	DECLARE @WORK_ADDRESS_LINE1 nvarchar(255)
	DECLARE @WORK_ADDRESS_LINE2 nvarchar(255)
	DECLARE @WORK_ADDRESS_LINE3 nvarchar(255)
	DECLARE @WORK_ADDRESS_LINE4 nvarchar(255)
	DECLARE @WORK_ADDRESS_LINE5 nvarchar(255)
	DECLARE @WORK_POSTCODE nvarchar(255)
	DECLARE @WORK_MAIL_PREF_FLAG nchar(1)
	DECLARE @WORK_COMPANY_NAME nvarchar(255)
	DECLARE @DO_NOT_MAIL_VT nchar(1)
	DECLARE @LOYALTY_MEMBERSHIP_NUM nvarchar(255)
	DECLARE @PASSWORD nvarchar(255)
	DECLARE @EFF_TO_DATE datetime 
	DECLARE @TICKET_VALUE decimal(18, 0)
	DECLARE @SOURCE_CODE nvarchar(255)
	DECLARE @CreatedDateETL datetime 
	DECLARE @LastModifiedDateETL datetime 

	DECLARE @customerid int
	
	DECLARE @LoyaltyProgrammeTypeID int

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	SELECT @DbName = DB_NAME()
	SELECT @SpId = @@SPID
	SELECT @AuditType = 'PROCESS START'
	SELECT @StepName = 'Staging.STG_Granby_CustomerLoyaltyAccount_Insert ProcedureStart'

	
	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	---EXEC uspSSISProcStepStart @spname, @StepName

	
	BEGIN TRY
	BEGIN TRANSACTION

	--Log start time--
	
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT
										 
    SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'Trainline'

	
	IF @informationsourceid IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid @informationsourceid; @informationsourceid = ' + ISNULL(@informationsourceid,'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'

											  COMMIT TRANSACTION
											  RETURN
    END

    SELECT @now = GETDATE()
	
	SELECT @importfilename = importfilename FROM [Operations].[DataImportDetail] WHERE dataimportdetailid = @dataimportdetailid


	SELECT @StepName = 'DataImportDetail_Update'

	--EXEC dbo.uspSSISProcStepStart @spname, @StepName

	EXEC [Operations].[DataImportDetail_Update] @userid            = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	  														  @importfilename = @importfilename,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

	--EXEC dbo.uspSSISProcStepSuccess @spname, @StepName
	
	--Insert Loyalty Accounts that do not exist
	IF CURSOR_STATUS('global','GranbyLoyaltyAccountNotExists')>=-1
	BEGIN
	CLOSE GranbyLoyaltyAccountNotExists
	DEALLOCATE GranbyLoyaltyAccountNotExists  
	END  

	
	SET @StepName = 'Staging.STG_LoyaltyAccount Insert'
	--EXEC uspSSISProcStepStart @ProcName, @StepName

	SELECT @LoyaltyProgrammeTypeID = LoyaltyProgrammeTypeID FROM [Reference].[LoyaltyProgrammeType] WHERE name = 'Granby'

	DECLARE GranbyLoyaltyAccountNotExists CURSOR READ_ONLY
    FOR 
			SELECT 
			   [LOYALTY_MEMBERSHIP_NUM]
			  ,[EFF_TO_DATE]
			  ,[CreatedDateETL]
			  ,[LastModifiedDateETL]
		  FROM [PreProcessing].[Granby_Traveller] a
		  WHERE a.DataImportDetailID = @dataimportdetailid
		  AND   a.ProcessedInd = 0
		  AND NOT EXISTS (SELECT 1 FROM [Staging].[STG_LoyaltyAccount] b WHERE b.[LoyaltyReference] =a.[LOYALTY_MEMBERSHIP_NUM])

	    OPEN GranbyLoyaltyAccountNotExists

	   FETCH NEXT FROM GranbyLoyaltyAccountNotExists  
		INTO  
			   @LOYALTY_MEMBERSHIP_NUM
			  ,@EFF_TO_DATE
			  ,@CreatedDateETL
			  ,@LastModifiedDateETL


	    WHILE @@FETCH_STATUS = 0
        BEGIN
		  
				INSERT INTO [Staging].[STG_LoyaltyAccount]
							  ([Name]
							  ,[Description]
							  ,[CreatedDate]
							  ,[CreatedBy]
							  ,[LastModifiedDate]
							  ,[LastModifiedBy]
							  ,[ArchivedInd]
							  ,[LoyaltyProgrammeTypeID]
							  ,[LoyaltyReference]
							  ,[InformationSourceID]
							  ,[SourceCreatedDate]
							  ,[SourceModifiedDate])
					  VALUES
							  (NULL
							  ,NULL
							  ,getdate()
							  ,0
							  ,@LastModifiedDateETL
							  ,0
							  ,0
							  ,@LoyaltyProgrammeTypeID
							  ,@LOYALTY_MEMBERSHIP_NUM
							  ,1
							  ,getdate()
							  ,getdate())

						   FETCH NEXT FROM GranbyLoyaltyAccountNotExists  
							INTO  
									 @LOYALTY_MEMBERSHIP_NUM
									,@EFF_TO_DATE
									,@CreatedDateETL
									,@LastModifiedDateETL

	     END

		CLOSE GranbyLoyaltyAccountNotExists
     
      DEALLOCATE GranbyLoyaltyAccountNotExists
			 
 
	IF CURSOR_STATUS('global','GranbyCustomerNotExists')>=-1
	BEGIN
	CLOSE GranbyCustomerNotExists
	DEALLOCATE GranbyCustomerNotExists  
	END  

	DECLARE GranbyCustomerNotExists CURSOR READ_ONLY
    FOR 
			SELECT 
			--[GranbyTravellerID]
			--,[EXTERNAL_REFERENCE]
			   [CUID]
			  ,[TITLE]
			  ,[FORENAME]
			  ,[SURNAME]
			  ,[GENDER]
			  ,[DAY_TELEPHONE]
			  ,[EVENING_TELEPHONE]
			  ,[FAX_NUM]
			  ,[EMAIL_ADDRESS]
			  ,[HOME_ADDRESS_LINE1]
			  ,[HOME_ADDRESS_LINE2]
			  ,[HOME_ADDRESS_LINE3]
			  ,[HOME_ADDRESS_LINE4]
			  ,[HOME_ADDRESS_LINE5]
			  ,[HOME_POSTCODE]
			  ,[HOME_MAIL_PREF_FLAG]
			  ,[HOME_COMPANY_NAME]
			  ,[WORK_ADDRESS_LINE1]
			  ,[WORK_ADDRESS_LINE2]
			  ,[WORK_ADDRESS_LINE3]
			  ,[WORK_ADDRESS_LINE4]
			  ,[WORK_ADDRESS_LINE5]
			  ,[WORK_POSTCODE]
			  ,[WORK_MAIL_PREF_FLAG]
			  ,[WORK_COMPANY_NAME]
			  ,[DO_NOT_MAIL_VT]
			  ,[LOYALTY_MEMBERSHIP_NUM]
			  ,[PASSWORD]
			  ,[EFF_TO_DATE]
			  ,[TICKET_VALUE]
			  ,[SOURCE_CODE]
			  ,[CreatedDateETL]
			  ,[LastModifiedDateETL]
			  --,[ProcessedInd]
			  --,[DataImportDetailID]
		  FROM [PreProcessing].[Granby_Traveller] a
		  WHERE a.DataImportDetailID = @dataimportdetailid
		  AND   a.ProcessedInd = 0
		  AND NOT EXISTS (SELECT 1 FROM staging.STG_KeyMapping b WHERE b.TCSCustomerID =a.CUID)

	   OPEN GranbyCustomerNotExists

      FETCH NEXT FROM GranbyCustomerNotExists  
		INTO   @CUID
			  ,@TITLE
			  ,@FORENAME
			  ,@SURNAME
			  ,@GENDER
			  ,@DAY_TELEPHONE
			  ,@EVENING_TELEPHONE
			  ,@FAX_NUM
			  ,@EMAIL_ADDRESS
			  ,@HOME_ADDRESS_LINE1
			  ,@HOME_ADDRESS_LINE2
			  ,@HOME_ADDRESS_LINE3
			  ,@HOME_ADDRESS_LINE4
			  ,@HOME_ADDRESS_LINE5
			  ,@HOME_POSTCODE
			  ,@HOME_MAIL_PREF_FLAG
			  ,@HOME_COMPANY_NAME
			  ,@WORK_ADDRESS_LINE1
			  ,@WORK_ADDRESS_LINE2
			  ,@WORK_ADDRESS_LINE3
			  ,@WORK_ADDRESS_LINE4
			  ,@WORK_ADDRESS_LINE5
			  ,@WORK_POSTCODE
			  ,@WORK_MAIL_PREF_FLAG
			  ,@WORK_COMPANY_NAME
			  ,@DO_NOT_MAIL_VT
			  ,@LOYALTY_MEMBERSHIP_NUM
			  ,@PASSWORD
			  ,@EFF_TO_DATE
			  ,@TICKET_VALUE
			  ,@SOURCE_CODE
			  ,@CreatedDateETL
			  ,@LastModifiedDateETL

		SET @StepName = 'Staging.STG_Customer_Add'
	
		--EXEC uspSSISProcStepStart @ProcName, @StepName

	    WHILE @@FETCH_STATUS = 0
        BEGIN
		
				EXEC [Staging].[STG_Customer_Add] @userid                         = @userid,   
															  @informationsourceid            = @informationsourceid,
															  @sourcecreateddate              = @CreatedDateETL,
															  @sourcemodifieddate             = @LastModifiedDateETL,
															  @archivedind                    = 0,
															  @salutation                     = @TITLE,
															  @firstname                      = @FORENAME,
															  @lastname                       = @SURNAME,
															  @datefirstpurchase              = NULL, --@datefirstpurchase,
															  @datelastpurchase               = NULL, --@datelastpurchase,
															  @TCSCustomerid                  = @CUID,
															  @ispersonind                    = 1, --@ispersonind,
															  @dateofbirth                    = NULL, --@dateofbirth,
															  @companyname	                   = @WORK_COMPANY_NAME,
															  @addressline1	                = @WORK_ADDRESS_LINE1,
															  @addressline2	                = @WORK_ADDRESS_LINE2,
															  @addressline3	                = @WORK_ADDRESS_LINE3,
															  @addressline4	                = @WORK_ADDRESS_LINE4,
															  @addressline5	                = @WORK_ADDRESS_LINE5,
															  @postcode	                      = @WORK_POSTCODE,
															  @country	                      = 'Unknown', --@country,
															  @neareststation                 = NULL, --@neareststation,  
															  @vtsegment                      = NULL, --@vtsegment,
															  @accountstatus                  = NULL, --@accountstatus,
															  @regchannel                     = NULL, --@regchannel,
															  @regoriginatingsystemtype       = NULL, --@regoriginatingsystemtype,
															  @firstcalltrandate              = NULL, --@firstcalltrandate,
															  @firstinttrandate               = NULL, --@firstinttrandate,
															  @firstmobapptrandate            = NULL, --@firstmobapptrandate,
															  @firstmobwebtrandate            = NULL, --@FirstMobWebTranDate,
															  @experianhouseholdincome        = NULL, --@experianhouseholdincome,
															  @experianageband                = NULL, --@ExperianAgeBand,
															  @customerid                     = @customerid OUTPUT

		FETCH NEXT FROM GranbyCustomerNotExists  
		INTO   @CUID
			  ,@TITLE
			  ,@FORENAME
			  ,@SURNAME
			  ,@GENDER
			  ,@DAY_TELEPHONE
			  ,@EVENING_TELEPHONE
			  ,@FAX_NUM
			  ,@EMAIL_ADDRESS
			  ,@HOME_ADDRESS_LINE1
			  ,@HOME_ADDRESS_LINE2
			  ,@HOME_ADDRESS_LINE3
			  ,@HOME_ADDRESS_LINE4
			  ,@HOME_ADDRESS_LINE5
			  ,@HOME_POSTCODE
			  ,@HOME_MAIL_PREF_FLAG
			  ,@HOME_COMPANY_NAME
			  ,@WORK_ADDRESS_LINE1
			  ,@WORK_ADDRESS_LINE2
			  ,@WORK_ADDRESS_LINE3
			  ,@WORK_ADDRESS_LINE4
			  ,@WORK_ADDRESS_LINE5
			  ,@WORK_POSTCODE
			  ,@WORK_MAIL_PREF_FLAG
			  ,@WORK_COMPANY_NAME
			  ,@DO_NOT_MAIL_VT
			  ,@LOYALTY_MEMBERSHIP_NUM
			  ,@PASSWORD
			  ,@EFF_TO_DATE
			  ,@TICKET_VALUE
			  ,@SOURCE_CODE
			  ,@CreatedDateETL
			  ,@LastModifiedDateETL
        END

	CLOSE GranbyCustomerNotExists
     
   DEALLOCATE GranbyCustomerNotExists
			 
	   --EXEC uspSSISProcStepSuccess @ProcName, @StepName
	
--Now add new loyalty account to customer relationships

	INSERT INTO [Staging].[STG_CustomerLoyaltyAllocation]
           ([Name]
           ,[Description]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[LastModifiedDate]
           ,[LastModifiedBy]
           ,[ArchivedInd]
           ,[CustomerID]
           ,[SourceCreatedDate]
           ,[SourceModifiedDate]
           ,[LoyaltyAccountID]
           ,[InformationSourceID]
           ,[ExtReference]
           ,[StartDate]
           ,[EndDate]
           ,[Status])
     SELECT NULL
           ,NULL
           ,GETDATE()
           ,@userid
           ,GETDATE()
           ,@userid
           ,0
		   ,c.CustomerID
		   ,a.CreatedDateETL
		   ,a.LastModifiedDateETL
           ,b.LoyaltyAccountID
		   ,@informationsourceid
		   ,a.LOYALTY_MEMBERSHIP_NUM
		   ,DATEADD(y,-1, a.eff_to_date) 
		   ,a.EFF_TO_DATE
		   ,'A'
												   --,Staging.SetUKTime(a.out_loyaltystartdate) as out_loyaltystartdate
												   --,Staging.SetUKTime(a.out_loyaltyenddate) as out_loyaltyenddate
												   --,@informationsourceid
												   --,CAST(a.out_loyaltymembershipId AS NVARCHAR(256))
   FROM [Preprocessing].[Granby_Traveller] a		--[PreProcessing].[MSD_LoyaltyProgrammeMembership] a
	INNER JOIN [Staging].[STG_LoyaltyAccount] b     ON a.LOYALTY_MEMBERSHIP_NUM = b.LoyaltyReference
	INNER JOIN [Staging].[STG_keyMapping] c         ON a.CUID = c.TCSCustomerID
	INNER JOIN [Reference].[LoyaltyProgrammeType] d ON b.LoyaltyProgrammeTypeID = d.LoyaltyProgrammeTypeID
	LEFT JOIN [Staging].[STG_CustomerLoyaltyAccount] e ON e.CustomerID = c.CustomerID and e.LoyaltyAccountID = b.LoyaltyAccountID 
	WHERE e.CustomerLoyaltyAccountID IS NULL
	AND   a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0


--Update any matching records - only field of value that will change is the EndDate, i.e. loyalty account is no longer being used by that customer

 --   UPDATE a
	--SET EndDate  = Staging.SetUKTime(e.out_loyaltyenddate),
	--    InformationSourceID = @informationsourceid,
	--    LastModifiedDate    = GETDATE(),
	--	LastModifiedBy      = @userid
	--FROM [Staging].[STG_CustomerLoyaltyAccount] a,
	--     [Staging].[STG_LoyaltyAccount] b,
	--	 [Reference].[LoyaltyProgrammeType] c,
	--	 [Staging].[STG_keyMapping] d,
	--	 [PreProcessing].[MSD_LoyaltyProgrammeMembership] e
	--WHERE a.LoyaltyAccountID = b.LoyaltyAccountID
	--AND   b.LoyaltyProgrammeTypeID = c.LoyaltyProgrammeTypeID
	--AND   a.CustomerID = d.CustomerID
	--AND   d.MSDID = e.out_customerId
	--AND   CAST(e.out_loyaltymembershipId AS NVARCHAR(256)) = a.ExtReference
	--AND   c.ExtReference = e.out_loyaltytype
	--AND   e.DataImportDetailID = @dataimportdetailid
	--AND   e.ProcessedInd = 0

	
	UPDATE a
	SET  ProcessedInd = 1, LastModifiedDateETL =GETDATE()
	FROM PreProcessing.Granby_Traveller a
	WHERE   a.DataImportDetailID = @dataimportdetailid
	AND   a.ProcessedInd = 0

	--SELECT @recordcount = @@ROWCOUNT

				
	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.Granby_Traveller
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid


	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.Granby_Traveller
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

	SELECT @StepName = 'Data Import Detail Update'

	--EXEC uspSSISProcStepStart @spname, @StepName

	
	EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
	     													  @importfilename = @importfilename,
	                                            @starttimeimport       = NULL,
	                                            @endtimeimport         = @now,
	                                            @totalcountimport      = @recordcount,
	                                            @successcountimport    = @successcountimport,
	                                            @errorcountimport      = @errorcountimport

    --Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT

	COMMIT TRANSACTION
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
  
  
	  --ROLLBACK TRANSACTION;
	 SELECT   
	  @ErrorNumber = ERROR_NUMBER(),  
	  @ErrorSeverity = ERROR_SEVERITY(),  
	  @ErrorState = ERROR_STATE(),  
	  @ErrorLine = ERROR_LINE(),  
	  @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), 'N/A');  
  
	 --Build the error message string  
	 SELECT @ErrorMessage = 'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +  
				'Message: ' + ERROR_MESSAGE()        
	 
	 SELECT @StepName = 'STG_Granby_CustomerLoyaltyAccount_Insert'
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
	SELECT @StepName = 'Staging.STG_Granby_CustomerLoyaltyAccount_Insert Procedure Try'

	--EXEC dbo.uspAuditAddAudit 	@AuditType=@AuditType, @Process=@spname,  @ProcessStep=@StepName, @DatabaseName=@Dbname, @SPID =@SpId, @PrintToScreen=0
	---EXEC dbo.uspSSISProcStepSuccess @spname, @StepName

	 
	RETURN 
END

