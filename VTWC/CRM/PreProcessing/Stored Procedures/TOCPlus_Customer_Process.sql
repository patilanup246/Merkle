/*===========================================================================================
Name:			PreProcessing.TOCPlus_Customer_Process
Purpose:		For each preprocessed customer record,  manipulate matching and merge to load
				the record into staging tables
Parameters:		@userid - The key for the user executing the proc.
				@tcs_customerid - The source key for the customer being processed.
                @dataimportdetailid - The key for the feed being processed.
				@DebugPrint - flag to print audit data to screen
				@PkgExecKey - The key for identifying package which ran the procedure
				@DebugRecordset - When implmented, used to control displaying debug recordset information
				
Notes:			 
			
Created:		2018-08-01	Dhana Mani
Modified:		
Peer Review:	
Call script:	EXEC PreProcessing.TOCPlus_Customer_Process 0, 57005,50
=================================================================================================*/


CREATE PROCEDURE [PreProcessing].[TOCPlus_Customer_Process]
(
	@userid                 INTEGER = 0,   
	@tcs_customerid         INTEGER,
	@dataimportdetailid     INTEGER,
	@DebugPrint				INTEGER = 0,
	@PkgExecKey			   INTEGER = -1,
	@DebugRecordset		   INTEGER = 0
)
AS
BEGIN
    SET NOCOUNT ON
	
	DECLARE @customerdetailid                     INTEGER
	DECLARE @sourcecreateddate					  DATETIME
	DECLARE @sourcemodifieddate				      DATETIME
    DECLARE @salutation                           NVARCHAR(100)
	DECLARE @firstname                            NVARCHAR(50)
	DECLARE @lastname                             NVARCHAR(50)	
	DECLARE @emailaddress                         NVARCHAR(256)
	DECLARE @mobilephone                          NVARCHAR(256)
	DECLARE @dayphonenumber                       NVARCHAR(256)
	DECLARE @eveningphonenumber                   NVARCHAR(256) = NULL
	DECLARE @otherphonenumber                     NVARCHAR(256)
	DECLARE @dateofbirth                          DATETIME
	DECLARE @neareststation                       NVARCHAR(256)
	DECLARE @datecreated                          DATETIME
	DECLARE @datemodified                         DATETIME
	DECLARE @datefirstpurchase                    DATETIME
	DECLARE @datelastpurchase                     DATETIME
	DECLARE @vtsegment							  INT
	DECLARE @accountstatus                        NVARCHAR(25)
	DECLARE @regchannel                           NVARCHAR(20)
	DECLARE @regoriginatingsystemtype             NVARCHAR(20)
	DECLARE @firstcalltrandate                    DATETIME
	DECLARE @firstinttrandate                     DATETIME
	DECLARE @firstmobapptrandate                  DATETIME
	DECLARE @FirstMobWebTranDate                  DATETIME
	DECLARE @experianhouseholdincome              NVARCHAR(20)
	DECLARE @ExperianAgeBand                      NVARCHAR(20)
	DECLARE @ispersonind                          BIT = 1

	DECLARE @companyname                          NVARCHAR(100)
	DECLARE @addressline1                         NVARCHAR(512)
	DECLARE @addressline2                         NVARCHAR(512)
	DECLARE @addressline3                         NVARCHAR(512)
	DECLARE @addressline4                         NVARCHAR(512)
	DECLARE @addressline5                         NVARCHAR(100)
	DECLARE @postcode                             NVARCHAR(10)
	DECLARE @country                              NVARCHAR(50) 

	DECLARE @namad								  NVARCHAR(255)
	DECLARE @namadind							  BIT = 1
	DECLARE @namadscore							  INTEGER = 100
	DECLARE @namadrejectreason					  NVARCHAR(255)
	DECLARE @parsedaddressemail                   NVARCHAR(256)
	DECLARE @parsedemailind                       BIT
	DECLARE @parsedemailscore                     INTEGER
	DECLARE @parsedaddressmobile                  NVARCHAR(50)
	DECLARE @parsedmobileind                      BIT
	DECLARE @parsedmobilescore                    INTEGER
	DECLARE @parsedaddressmobile1                 NVARCHAR(50)
	DECLARE @parsedmobileind1                     BIT
	DECLARE @parsedmobilescore1                   INTEGER
	DECLARE @parsedaddressmobile2                 NVARCHAR(50)
	DECLARE @parsedmobileind2                     BIT
	DECLARE @parsedmobilescore2                   INTEGER
	DECLARE @parsedaddressmobile3                 NVARCHAR(50) = NULL
	DECLARE @parsedmobileind3                     BIT = NULL
	DECLARE @parsedmobilescore3                   INTEGER = NULL 

	DECLARE @keymappingid                         INTEGER
	DECLARE @customerid                           INTEGER

    DECLARE @informationsourceid                  INTEGER
	DECLARE @addresstypeidemail                   INTEGER
	DECLARE @addresstypeidmobile                  INTEGER
	DECLARE @addresstypeidnamad                   INTEGER

	DECLARE @defaultoptincorporate                INTEGER
	DECLARE @subscriptionchanneltypeidleisure     INTEGER              
	DECLARE @defaultoptinleisure                  INTEGER
	DECLARE @subscriptionchanneltypeidcorp        INTEGER

	DECLARE @customernewind                       BIT = 1
	DECLARE @customerupdateind                    BIT = 1
    DECLARE @emailchangeind                       BIT = 1
	DECLARE @mobilechangeind                      BIT = 1
	DECLARE @namadchangeind                       BIT = 1
	DECLARE @optinchangeind                       BIT = 1

	DECLARE @preferenceid                         INTEGER
	DECLARE @channelid                            INTEGER	
	DECLARE @value                                BIT
	DECLARE @subscriptioncreateddate              DATETIME
	DECLARE @subscriptionchanneltypeid            INTEGER
	DECLARE @informationsourceidsubscription      INTEGER
	DECLARE @recordcountsubscription              INTEGER

	DECLARE @customerresponseid                   INTEGER
	DECLARE @cviquestionid                        INTEGER
	DECLARE @cviquestiongroupid                   INTEGER
	DECLARE @cviquestionanswerid                  INTEGER
	DECLARE @response                             VARCHAR(4000)
    DECLARE @cviresponsecreateddate               DATETIME
    DECLARE @informationsourceidcvi               INTEGER
	DECLARE @recordcountcvi                       INTEGER

	DECLARE @now                                  DATETIME
	DECLARE @spid								  INTEGER	= @@SPID
	DECLARE @spname								  SYSNAME 
	DECLARE @dbname								  SYSNAME	= DB_NAME()
	DECLARE @recordcount                          INTEGER
	DECLARE @logtimingidnew                       INTEGER
	DECLARE @logmessage                           NVARCHAR(MAX)

	--subscription variables
	DECLARE @GeneralMarketingOptinId INT
	DECLARE @RetailerMarketingOptinId INT
	DECLARE @DftOptInFlagId INT
	DECLARE @ThirdPartyMarketingOptinId INT
	DECLARE @ThirdPartyOptoutId INT
	DECLARE @NoneChannelId INT
	DECLARE @EmailChannelId INT
	DECLARE @SMSChannelId INT
	DECLARE @MailChannelId INT

	DECLARE @Rows					INTEGER = 0
	DECLARE @ProcName				NVARCHAR(50)
	DECLARE @StepName				NVARCHAR(50)

	DECLARE  @ErrorMsg              NVARCHAR(MAX)
	DECLARE  @ErrorNum              INTEGER
	
	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--EXEC dbo.uspAuditAddAudit
	--	 @AuditType='PROCESS START'
	--	,@Process=@spname, @DatabaseName=@dbname,@SPID =@SPID, @PrintToScreen=@DebugPrint
    
	--Get reference information

	SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'TrainLine'

    SELECT @addresstypeidemail = AddressTypeID
	FROM   [Reference].[AddressType]
	WHERE  Name = 'Email'

	SELECT @addresstypeidmobile = AddressTypeID
	FROM   [Reference].[AddressType]
	WHERE  Name = 'Mobile'

	SELECT @addresstypeidnamad = AddressTypeID
	FROM   [Reference].[AddressType]
	WHERE  Name = 'Namad'

	--Preference Channel type ids

	SELECT @GeneralMarketingOptinId = PreferenceID FROM Reference.Preference WHERE [Name] = 'General Marketing Opt-In'

	SELECT @RetailerMarketingOptinId = PreferenceID FROM Reference.Preference WHERE [Name] = 'Retailer Marketing Opt-In'

	SELECT @DftOptInFlagId = PreferenceID FROM Reference.Preference WHERE [Name] = 'DFT Opt-In'

	SELECT @ThirdPartyMarketingOptinId = PreferenceID FROM Reference.Preference WHERE [Name] = 'Third party marketing Opt-In'

	SELECT @ThirdPartyOptoutId = PreferenceID FROM Reference.Preference WHERE [Name] = 'Third party Opt-Out'

	SELECT @NoneChannelId = ChannelID FROM Reference.Channel WHERE [Name] = 'None'

	SELECT @EmailChannelId = ChannelID FROM Reference.Channel WHERE [Name] = 'Email'

	SELECT @SMSChannelId = ChannelID FROM Reference.Channel WHERE [Name] = 'SMS'

	SELECT @MailChannelId = ChannelID FROM Reference.Channel WHERE [Name] = 'Mail'

	SET @ProcName = 'PreProcessing.TOC_Customer_Process'

	SET @StepName = 'Check if reference values are populated'

	IF @informationsourceid                 IS NULL
	   OR @addresstypeidemail               IS NULL
	   OR @addresstypeidmobile              IS NULL
	   OR @addresstypeidnamad				IS NULL
	   OR @GeneralMarketingOptinId          IS NULL
	   OR @RetailerMarketingOptinId         IS NULL
	   OR @DftOptInFlagId					IS NULL
	   OR @ThirdPartyMarketingOptinId		IS NULL
	   OR @NoneChannelId					IS NULL
	   OR @EmailChannelId					IS NULL
	   OR @SMSChannelId						IS NULL
	   OR @MailChannelId					IS NULL
	BEGIN
	    SET @ErrorMsg = 'No or invalid reference information.' +
		                  ' @informationsourceid =  '                + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') +
						  ', @addresstypeidemail =  '                + ISNULL(CAST(@addresstypeidemail AS NVARCHAR(256)),'NULL') +
						  ', @addresstypeidmobile = '                + ISNULL(CAST(@addresstypeidmobile AS NVARCHAR(256)),'NULL') +
						  ', @addresstypeidnamad  = '                + ISNULL(CAST(@addresstypeidnamad AS NVARCHAR(256)),'NULL') +
						  ', @GeneralMarketingOptinId = '            + ISNULL(CAST(@GeneralMarketingOptinId AS NVARCHAR(256)),'NULL') +
						  ', @RetailerMarketingOptinId   = '         + ISNULL(CAST(@RetailerMarketingOptinId AS NVARCHAR(256)),'NULL') +
						  ', @DftOptInFlagId   = '					 + ISNULL(CAST(@DftOptInFlagId AS NVARCHAR(256)),'NULL') +
						  ', @ThirdPartyMarketingOptinId   = '		 + ISNULL(CAST(@ThirdPartyMarketingOptinId AS NVARCHAR(256)),'NULL') +
						  ', @NoneChannelId   = '					 + ISNULL(CAST(@NoneChannelId AS NVARCHAR(256)),'NULL') +
						  ', @EmailChannelId   = '					 + ISNULL(CAST(@EmailChannelId AS NVARCHAR(256)),'NULL') +
						  ', @SMSChannelId   = '					 + ISNULL(CAST(@SMSChannelId AS NVARCHAR(256)),'NULL') +
						  ', @MailChannelId   = '					 + ISNULL(CAST(@MailChannelId AS NVARCHAR(256)),'NULL')
	    
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey

        RETURN
    END

	--Get the customer details

	SELECT @customerdetailid    = TCScustomerID
          ,@datecreated         = CreatedDateETL
          ,@datemodified        = LastModifiedDateETL
		  ,@sourcecreateddate	= firstregdate
          ,@emailaddress        = emailaddress
		  ,@dateofbirth		    = CAST(dateofbirth AS DATE)
		  ,@companyname	        = companyname
		  ,@addressline1	    = addressline1
		  ,@addressline2	    = addressline2
		  ,@addressline3	    = addressline3
		  ,@addressline4	    = addressline4
		  ,@addressline5	    = addressline5
		  ,@postcode	        = postcode
		  ,@country	            = country 
          ,@dayphonenumber      = dayphoneno
		  ,@eveningphonenumber  = eveningphoneno		  
          ,@salutation          = title
          ,@firstname           = forename
          ,@lastname            = [Surname]
		  ,@neareststation      = homestation
		  ,@sourcemodifieddate  = regcmddateupdated
		  ,@datefirstpurchase   = firsttransdate
		  ,@datelastpurchase    = lasttransdate
		  ,@vtsegment			= vtsegment
		  ,@accountstatus	    = accountstatus
		  ,@regchannel          = RegChannel
		  ,@regoriginatingsystemtype = RegOriginatingSystemType
          ,@mobilephone         = MobileTelephoneNo
		  ,@firstcalltrandate   = FirstCallTranDate
		  ,@firstinttrandate    = FirstIntTranDate
		  ,@firstmobapptrandate = FirstMobAppTranDate
		  ,@FirstMobWebTranDate = FirstMobWebTranDate
		  ,@experianhouseholdincome = ExperianHouseholdIncome
		  ,@ExperianAgeBand	    = ExperianAgeBand
		  ,@namad				= Staging.genUniqueKey(forename,'',surname,postcode,addressline1,addressline2)
          ,@parsedaddressemail  = [ParsedAddressEmail]
          ,@parsedemailind      = CASE WHEN [ParsedEmailInd] IS NULL THEN 0 ELSE [ParsedEmailInd] END
          ,@parsedemailscore    = CASE WHEN [ParsedEmailScore] IS NULL THEN 0 ELSE [ParsedEmailScore] END
          ,@parsedaddressmobile = [ParsedAddressMobile]
          ,@parsedmobileind     = CASE WHEN [ParsedMobileInd] IS NULL THEN 0 ELSE [ParsedMobileInd] END
          ,@parsedmobilescore   = CASE WHEN [ParsedMobileScore] IS NULL THEN 0 ELSE [ParsedMobileScore] END
		  ,@parsedaddressmobile1 = [ParsedAddressMobile1]
          ,@parsedmobileind1     = CASE WHEN [ParsedMobileInd1] IS NULL THEN 0 ELSE [ParsedMobileInd] END
          ,@parsedmobilescore1   = CASE WHEN [ParsedMobileScore1] IS NULL THEN 0 ELSE [ParsedMobileScore] END
		  ,@parsedaddressmobile2 = [ParsedAddressMobile2]
          ,@parsedmobileind2     = CASE WHEN [ParsedMobileInd2] IS NULL THEN 0 ELSE [ParsedMobileInd] END
          ,@parsedmobilescore2   = CASE WHEN [ParsedMobileScore2] IS NULL THEN 0 ELSE [ParsedMobileScore] END
    FROM  [PreProcessing].TOCPLUS_Customer WITH (NOLOCK)
	WHERE TCScustomerID = @tcs_customerid
	AND DataImportDetailID = @dataimportdetailid
    AND   ProcessedInd   = 0

	SELECT @namadrejectreason = [Staging].[rejectReason](@namad, @firstname,'',@lastname,@addressline1,@addressline2)

	
	-- set empty values to null for ease of shifting
	SELECT @parsedaddressmobile = CASE WHEN LTRIM(RTRIM(@parsedaddressmobile)) = '' THEN NULL ELSE @parsedaddressmobile END
	       ,@parsedmobileind = CASE WHEN LTRIM(RTRIM(@parsedmobileind)) = '' THEN NULL ELSE @parsedmobileind END
		   ,@parsedmobilescore = CASE WHEN LTRIM(RTRIM(@parsedmobilescore)) = '' THEN NULL ELSE @parsedmobilescore END
		   ,@parsedaddressmobile1 = CASE WHEN LTRIM(RTRIM(@parsedaddressmobile1)) = '' THEN NULL ELSE @parsedaddressmobile1 END
	       ,@parsedmobileind1 = CASE WHEN LTRIM(RTRIM(@parsedmobileind1)) = '' THEN NULL ELSE @parsedmobileind1 END
		   ,@parsedmobilescore1 = CASE WHEN LTRIM(RTRIM(@parsedmobilescore1)) = '' THEN NULL ELSE @parsedmobilescore1 END
		   ,@parsedaddressmobile2 = CASE WHEN LTRIM(RTRIM(@parsedaddressmobile2)) = '' THEN NULL ELSE @parsedaddressmobile2 END
	       ,@parsedmobileind2 = CASE WHEN LTRIM(RTRIM(@parsedmobileind2)) = '' THEN NULL ELSE @parsedmobileind2 END
		   ,@parsedmobilescore2 = CASE WHEN LTRIM(RTRIM(@parsedmobilescore2)) = '' THEN NULL ELSE @parsedmobilescore2 END

    /*
	 we need to store original mobile number along with parsed number, becuase we are shifting parsed mobile numbers to left
	 we would also need to shift original numbers to the left	
	 if parsedmobile number are null/empty set the original number formats to null otherwise leave original value for shifting purpose
	*/

	SELECT @mobilephone = CASE WHEN @parsedaddressmobile IS NULL THEN NULL ELSE @mobilephone END 
	       ,@dayphonenumber = CASE WHEN @parsedaddressmobile1 IS NULL THEN NULL ELSE @dayphonenumber END
		   ,@eveningphonenumber = CASE WHEN @parsedaddressmobile2 IS NULL THEN NULL ELSE @eveningphonenumber END
		   

	-- if there are empty addresses in the left, shift address to left from right
	;with 
	 cte1 as (SELECT @parsedaddressmobile AS parsedaddressmobile,@parsedaddressmobile1 AS parsedaddressmobile1
				,ISNULL(@parsedaddressmobile2,@parsedaddressmobile3) as parsedaddressmobile2
				, CASE WHEN @parsedaddressmobile2 IS NULL THEN NULL ELSE @parsedaddressmobile3 END as parsedaddressmobile3 )
	,cte2 as (SELECT parsedaddressmobile, ISNULL(parsedaddressmobile1,parsedaddressmobile2) as parsedaddressmobile1
			 , CASE WHEN parsedaddressmobile1 IS NULL THEN parsedaddressmobile3 ELSE parsedaddressmobile2 end as parsedaddressmobile2
			 , CASE WHEN parsedaddressmobile1 IS NULL THEN NULL ELSE parsedaddressmobile3 END as parsedaddressmobile3 from cte1)
	,cte3 as (SELECT ISNULL(parsedaddressmobile,parsedaddressmobile1) as parsedaddressmobile
			 , CASE WHEN parsedaddressmobile IS NULL then parsedaddressmobile2 ELSE parsedaddressmobile1  end as parsedaddressmobile1
			 , CASE WHEN parsedaddressmobile IS NULL THEN parsedaddressmobile3 ELSE parsedaddressmobile2 end as parsedaddressmobile2
			 , CASE WHEN parsedaddressmobile IS NULL THEN NULL ELSE parsedaddressmobile3 END as parsedaddressmobile3 from cte2)
	SELECT @parsedaddressmobile = parsedaddressmobile
		   , @parsedaddressmobile1 = parsedaddressmobile1
		   , @parsedaddressmobile2 = parsedaddressmobile2
	from cte3

	;with 
	 cte1 as (SELECT @parsedmobileind AS parsedmobileind,@parsedmobileind1 AS parsedmobileind1
				,ISNULL(@parsedmobileind2,@parsedmobileind3) as parsedmobileind2
				, CASE WHEN @parsedmobileind2 IS NULL THEN NULL ELSE @parsedmobileind3 END as parsedmobileind3 )
	,cte2 as (SELECT parsedmobileind, ISNULL(parsedmobileind1,parsedmobileind2) as parsedmobileind1
			 , CASE WHEN parsedmobileind1 IS NULL THEN parsedmobileind3 ELSE parsedmobileind2 end as parsedmobileind2
			 , CASE WHEN parsedmobileind1 IS NULL THEN NULL ELSE parsedmobileind3 END as parsedmobileind3 from cte1)
	,cte3 as (SELECT ISNULL(parsedmobileind,parsedmobileind1) as parsedmobileind
			 , CASE WHEN parsedmobileind IS NULL then parsedmobileind2 ELSE parsedmobileind1  end as parsedmobileind1
			 , CASE WHEN parsedmobileind IS NULL THEN parsedmobileind3 ELSE parsedmobileind2 end as parsedmobileind2
			 , CASE WHEN parsedmobileind IS NULL THEN NULL ELSE parsedmobileind3 END as parsedmobileind3 from cte2)
	SELECT @parsedmobileind = parsedmobileind
		   , @parsedmobileind1 = parsedmobileind1
		   , @parsedmobileind2 = parsedmobileind2
	from cte3

	;with 
	 cte1 as (SELECT @parsedmobilescore AS parsedmobilescore,@parsedmobilescore1 AS parsedmobilescore1
				,ISNULL(@parsedmobilescore2,@parsedmobilescore3) as parsedmobilescore2
				, CASE WHEN @parsedmobilescore2 IS NULL THEN NULL ELSE @parsedmobilescore3 END as parsedmobilescore3 )
	,cte2 as (SELECT parsedmobilescore, ISNULL(parsedmobilescore1,parsedmobilescore2) as parsedmobilescore1
			 , CASE WHEN parsedmobilescore1 IS NULL THEN parsedmobilescore3 ELSE parsedmobilescore2 end as parsedmobilescore2
			 , CASE WHEN parsedmobilescore1 IS NULL THEN NULL ELSE parsedmobilescore3 END as parsedmobilescore3 from cte1)
	,cte3 as (SELECT ISNULL(parsedmobilescore,parsedmobilescore1) as parsedmobilescore
			 , CASE WHEN parsedmobilescore IS NULL then parsedmobilescore2 ELSE parsedmobilescore1  end as parsedmobilescore1
			 , CASE WHEN parsedmobilescore IS NULL THEN parsedmobilescore3 ELSE parsedmobilescore2 end as parsedmobilescore2
			 , CASE WHEN parsedmobilescore IS NULL THEN NULL ELSE parsedmobilescore3 END as parsedmobilescore3 from cte2)
	SELECT @parsedmobilescore = parsedmobilescore
		   , @parsedmobilescore1 = parsedmobilescore1
		   , @parsedmobilescore2 = parsedmobilescore2
	from cte3

	;with 
	 cte1 as (SELECT @mobilephone AS number, @dayphonenumber AS number1
				,ISNULL(@eveningphonenumber,@otherphonenumber) as number2
				, CASE WHEN @eveningphonenumber IS NULL THEN NULL ELSE @otherphonenumber END as number3 )
	,cte2 as (SELECT number, ISNULL(number1,number2) as number1
			 , CASE WHEN number1 IS NULL THEN number3 ELSE number2 end as number2
			 , CASE WHEN number1 IS NULL THEN NULL ELSE number3 END as number3 from cte1)
	,cte3 as (SELECT ISNULL(number,number1) as number
			 , CASE WHEN number IS NULL then number2 ELSE number1  end as number1
			 , CASE WHEN number IS NULL THEN number3 ELSE number2 end as number2
			 , CASE WHEN number IS NULL THEN NULL ELSE number3 END as number3 from cte2)
	SELECT @mobilephone = number
		   , @dayphonenumber = number1
		   , @eveningphonenumber = number2
	from cte3

	SET @StepName = 'Check if customer source key exists in preprocessing'
    IF @customerdetailid IS NULL
	BEGIN
	    SET @ErrorMsg = 'No data supplied to process. ' +
		                  '@msd_customerid = ' + ISNULL(CAST(@tcs_customerid AS NVARCHAR(256)),'NULL') 
	    
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, 51403, @ErrorMsg, @PkgExecKey

        RETURN
    END

	--Is this a known customer?

    SELECT @keymappingid = KeyMappingID
	      ,@customerid   = CustomerID
	FROM   [Staging].[STG_KeyMapping] WITH (NOLOCK)
	WHERE  TCSCustomerid = @customerdetailid
	
	--Is this a known customer from TOC - match on all stored email address

	IF @keymappingid IS NULL AND @parsedaddressemail IS NOT NULL 
	BEGIN
        SELECT @keymappingid = KeyMappingID
		      ,@customerid   = a.CustomerID
		FROM   [Staging].[STG_KeyMapping] a WITH (NOLOCK)
		INNER JOIN [Staging].[STG_ElectronicAddress] b WITH (NOLOCK) ON a.CustomerID = b.CustomerID
		WHERE a.IsParentInd = 1
		AND   b.AddressTypeID = @addresstypeidemail
		AND   b.ParsedScore = 100
		AND   b.ParsedAddress = @parsedaddressemail
    END

    --Is this a known customer from TOC  - match on primary mobile phone with parsedaddressmobile

	IF @keymappingid IS NULL AND @parsedaddressmobile IS NOT NULL
	BEGIN
        SELECT @keymappingid = KeyMappingID
		      ,@customerid   = a.CustomerID
		FROM   [Staging].[STG_KeyMapping] a WITH (NOLOCK)
		INNER JOIN [Staging].[STG_ElectronicAddress] b WITH (NOLOCK) ON a.CustomerID = b.CustomerID
		WHERE a.IsParentInd = 1
		AND   b.AddressTypeID = @addresstypeidmobile
		AND   b.PrimaryInd = 1
		AND   b.ParsedScore = 100
		AND   b.ParsedAddress = @parsedaddressmobile
    END

	--Is this a known customer from TOC  - match on primary mobile phone with parsedaddressmobile1

	IF @keymappingid IS NULL AND @parsedaddressmobile1 IS NOT NULL
	BEGIN
        SELECT @keymappingid = KeyMappingID
		      ,@customerid   = a.CustomerID
		FROM   [Staging].[STG_KeyMapping] a WITH (NOLOCK)
		INNER JOIN [Staging].[STG_ElectronicAddress] b WITH (NOLOCK) ON a.CustomerID = b.CustomerID
		WHERE a.IsParentInd = 1
		AND   b.AddressTypeID = @addresstypeidmobile
		AND   b.PrimaryInd = 1
		AND   b.ParsedScore = 100
		AND   b.ParsedAddress = @parsedaddressmobile1
    END

	--Is this a known customer from TOC  - match on primary mobile phone with parsedaddressmobile2

	IF @keymappingid IS NULL AND @parsedaddressmobile2 IS NOT NULL
	BEGIN
        SELECT @keymappingid = KeyMappingID
		      ,@customerid   = a.CustomerID
		FROM   [Staging].[STG_KeyMapping] a WITH (NOLOCK)
		INNER JOIN [Staging].[STG_ElectronicAddress] b WITH (NOLOCK) ON a.CustomerID = b.CustomerID
		WHERE a.IsParentInd = 1
		AND   b.AddressTypeID = @addresstypeidmobile
		AND   b.PrimaryInd = 1
		AND   b.ParsedScore = 100
		AND   b.ParsedAddress = @parsedaddressmobile2
    END

	--Is this a known customer from TOC - match on name and address, if the namad reject reason is null 

	IF @keymappingid IS NULL AND @namadrejectreason IS NULL
	BEGIN
        SELECT @keymappingid = KeyMappingID
		      ,@customerid   = a.CustomerID
		FROM   [Staging].[STG_KeyMapping] a WITH (NOLOCK)
		INNER JOIN [Staging].[STG_ElectronicAddress] b WITH (NOLOCK) ON a.CustomerID = b.CustomerID
		WHERE a.IsParentInd = 1
		AND   b.AddressTypeID = @addresstypeidnamad
		AND   b.PrimaryInd = 1
		AND   b.ParsedAddress = @namad
    END

	--Is this a new customer from TOC but was a Prospect - match on all stored email address

	IF @keymappingid IS NULL AND @parsedaddressemail IS NOT NULL
	BEGIN
        SELECT @keymappingid = KeyMappingID
		      ,@customerid   = a.CustomerID
		FROM   [Staging].[STG_KeyMapping] a WITH (NOLOCK)
		INNER JOIN [Staging].[STG_ElectronicAddress] b WITH (NOLOCK) ON a.IndividualID = b.IndividualID
		WHERE a.IsParentInd = 1
		AND   b.AddressTypeID = @addresstypeidemail
		AND   b.ParsedScore = 100
		AND   b.ParsedAddress = @parsedaddressemail
    END

	--Is this a new customer from TOC but was a Prospect - match on primary mobile phone

	IF @keymappingid IS NULL AND @parsedaddressmobile IS NOT NULL
	BEGIN
        SELECT @keymappingid = KeyMappingID
		      ,@customerid   = a.CustomerID
		FROM   [Staging].[STG_KeyMapping] a WITH (NOLOCK)
		INNER JOIN [Staging].[STG_ElectronicAddress] b WITH (NOLOCK) ON a.IndividualID = b.IndividualID
		WHERE a.IsParentInd = 1
		AND   b.AddressTypeID = @addresstypeidmobile
		AND   b.PrimaryInd = 1
		AND   b.ParsedScore = 100
		AND   b.ParsedAddress = @parsedaddressmobile
    END

	--Is this a new customer from TOC but was a Prospect - match on primary mobile phone1

	IF @keymappingid IS NULL and @parsedaddressmobile1 IS NOT NULL
	BEGIN
        SELECT @keymappingid = KeyMappingID
		      ,@customerid   = a.CustomerID
		FROM   [Staging].[STG_KeyMapping] a WITH (NOLOCK)
		INNER JOIN [Staging].[STG_ElectronicAddress] b WITH (NOLOCK) ON a.IndividualID = b.IndividualID
		WHERE a.IsParentInd = 1
		AND   b.AddressTypeID = @addresstypeidmobile
		AND   b.PrimaryInd = 1
		AND   b.ParsedScore = 100
		AND   b.ParsedAddress = @parsedaddressmobile1
    END

	--Is this a new customer from TOC but was a Prospect - match on primary mobile phone2

	IF @keymappingid IS NULL AND @parsedaddressmobile2 IS NOT NULL
	BEGIN
        SELECT @keymappingid = KeyMappingID
		      ,@customerid   = a.CustomerID
		FROM   [Staging].[STG_KeyMapping] a WITH (NOLOCK)
		INNER JOIN [Staging].[STG_ElectronicAddress] b WITH (NOLOCK) ON a.IndividualID = b.IndividualID
		WHERE a.IsParentInd = 1
		AND   b.AddressTypeID = @addresstypeidmobile
		AND   b.PrimaryInd = 1
		AND   b.ParsedScore = 100
		AND   b.ParsedAddress = @parsedaddressmobile2
    END

	--Is this a new customer from TOC but was a Prospect - match on name and address


	IF @keymappingid IS NULL AND @namadrejectreason IS NULL
	BEGIN
        SELECT @keymappingid = KeyMappingID
		      ,@customerid   = a.CustomerID
		FROM   [Staging].[STG_KeyMapping] a WITH (NOLOCK)
		INNER JOIN [Staging].[STG_ElectronicAddress] b WITH (NOLOCK) ON a.IndividualID = b.IndividualID
		WHERE a.IsParentInd = 1
		AND   b.AddressTypeID = @addresstypeidnamad
		AND   b.PrimaryInd = 1
		AND   b.ParsedAddress = @namad
    END


	IF @keymappingid IS NOT NULL  -- existing
    BEGIN
	    SET @customernewind = 0

		--Changes to the base customer information?

        IF EXISTS (SELECT Salutation,
				          FirstName,
				          LastName,
						  --SourceCreatedDate,
						  DateOfBirth,
						  NearestStation,
						  SourceModifiedDate,
						  DateLastPurchase,
						  VTSegment,
						  AccountStatus,
						  ExperianHouseholdIncome,
						  ExperianAgeBand
		           FROM [Staging].[STG_Customer] WITH (NOLOCK)
				   WHERE CustomerID = @customerid
				   INTERSECT
				   SELECT @salutation,
				          @firstname,
						  @lastname,
						  --@sourcecreateddate,
						  @dateofbirth,
						  @neareststation,
						  @sourcemodifieddate,
						  @datelastpurchase,
						  @vtsegment,
						  @accountstatus,
						  @experianhouseholdincome,
						  @ExperianAgeBand
				          )
		BEGIN		   
		    SET @customerupdateind = 0
	    END

		--check if the source customer key already exists in key mapping table, if not create a record and mark the parent flag to 0
		IF NOT EXISTS(SELECT *
		          FROM [Staging].[STG_KeyMapping]
				  WHERE TCSCustomerID = @customerdetailid
				  AND CustomerID = @customerid)
		BEGIN
			--EXEC uspAuditAddAudit @AuditType='TRACE START', @ProcessStep='Perform Insert to Staging.STG_KeyMapping'
   --                     ,@Process=@spname, @DatabaseName=@dbname, @Rows=null, @PrintToScreen=@DebugPrint

			INSERT INTO [Staging].[STG_KeyMapping]
			   ([CreatedDate]
			   ,[CreatedBy]
			   ,[LastModifiedDate]
			   ,[LastModifiedBy]
			   ,[CustomerID]
			   ,[TCSCustomerID]
			   ,[InformationSourceID]
			   ,[IsParentInd])
		 VALUES
			   (GETDATE()
			   ,@userid
			   ,GETDATE()
			   ,@userid
			   ,@customerid
			   ,@customerdetailid
			   ,@informationsourceid
			   ,0)

		    SET @rows = @@rowcount

			--EXEC uspAuditAddAudit @AuditType='TRACE END', @ProcessStep='Prepare Customer Mapping Keys'
   --                     ,@Process=@spname, @DatabaseName=@dbname, @Rows=@Rows, @PrintToScreen=@DebugPrint
		END 

		--IF Address has changed, update address
		SET @StepName = 'Staging.STG_Address_Upsert'
		BEGIN TRY		

		--EXEC uspSSISProcStepStart @ProcName, @StepName

		EXEC [Staging].[STG_Address_Upsert]	  @customerid           = @customerid,   
											  @sourcecreateddate    = @sourcecreateddate,
											  @sourcemodifieddate   = @sourcemodifieddate, 
											  @companyname          = @companyname,
											  @address1             = @addressline1,
											  @address2             = @addressline2,
											  @address3             = @addressline3,
											  @address4             = @addressline4,
											  @address5             = @addressline5,
											  @postcode             = @postcode,
											  @country              = @country

		--EXEC uspSSISProcStepSuccess @ProcName, @StepName

		END TRY
		BEGIN CATCH
			SELECT @ErrorMsg = 'Unable to update address for customer, tcscutomerid - '   + CAST(@tcs_customerid AS NVARCHAR(50))

			SET @ErrorNum = ERROR_NUMBER()

			EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey

			RETURN;

		END CATCH
		--Email address changed?

		IF EXISTS (SELECT ParsedAddress
		           FROM  [Staging].[STG_ElectronicAddress] WITH (NOLOCK)
				   WHERE AddressTypeID = @addresstypeidemail
				   AND   CustomerID    = @customerid
				   AND   PrimaryInd    = 1
				   INTERSECT
				   SELECT @parsedaddressemail)
        BEGIN
	        SET @emailchangeind = 0
        END

		--Mobile phone changed?

		IF EXISTS (SELECT ParsedAddress
		           FROM  [Staging].[STG_ElectronicAddress] WITH (NOLOCK)
				   WHERE AddressTypeID = @addresstypeidmobile
				   AND   CustomerID    = @customerid
				   AND   PrimaryInd    = 1
				   INTERSECT
				   SELECT @parsedaddressmobile)

		BEGIN
		    SET @mobilechangeind = 0
        END

		--Namad changed?

		IF EXISTS (SELECT ParsedAddress
		           FROM  [Staging].[STG_ElectronicAddress] WITH (NOLOCK)
				   WHERE AddressTypeID = @addresstypeidnamad
				   AND   CustomerID    = @customerid
				   AND   PrimaryInd    = 1
				   INTERSECT
				   SELECT @namad)

		BEGIN
		    SET @namadchangeind = 0
        END

		--Add in phone check
	END

	SELECT @now = GETDATE()

	--check if its new customer and insert customer record
    IF @customernewind = 1
	BEGIN
	
		SET @StepName = 'Staging.STG_Customer_Add'
		BEGIN TRY		

		--EXEC uspSSISProcStepStart @ProcName, @StepName

	    EXEC [Staging].[STG_Customer_Add] @userid                         = @userid,   
	                                      @informationsourceid            = @informationsourceid,
	                                      @sourcecreateddate              = @sourcecreateddate,
	                                      @sourcemodifieddate             = @sourcemodifieddate,
	                                      @archivedind                    = 0,
	                                      @salutation                     = @salutation,
	                                      @firstname                      = @firstname,
	                                      @lastname                       = @lastname,
	                                      @datefirstpurchase              = @datefirstpurchase,
										  @datelastpurchase               = @datelastpurchase,
										  @TCSCustomerid                  = @customerdetailid,
										  @ispersonind                    = @ispersonind,
										  @dateofbirth                    = @dateofbirth,
										  @companyname	                  = @companyname,
										  @addressline1	                  = @addressline1,
										  @addressline2	                  = @addressline2,
										  @addressline3	                  = @addressline3,
										  @addressline4	                  = @addressline4,
										  @addressline5	                  = @addressline5,
										  @postcode	                      = @postcode,
										  @country	                      = @country,
										  @neareststation                 = @neareststation,  
										  @vtsegment                      = @vtsegment,
										  @accountstatus                  = @accountstatus,
										  @regchannel                     = @regchannel,
										  @regoriginatingsystemtype       = @regoriginatingsystemtype,
										  @firstcalltrandate              = @firstcalltrandate,
										  @firstinttrandate               = @firstinttrandate,
										  @firstmobapptrandate            = @firstmobapptrandate,
										  @firstmobwebtrandate            = @FirstMobWebTranDate,
										  @experianhouseholdincome        = @experianhouseholdincome,
										  @experianageband                = @ExperianAgeBand,
	                                      @customerid                     = @customerid OUTPUT

		 --EXEC uspSSISProcStepSuccess @ProcName, @StepName
		END TRY
		BEGIN CATCH
			SELECT @ErrorMsg = 'Unable to add customer, tcscutomerid - '   + CAST(@tcs_customerid AS NVARCHAR(50))

			SET @ErrorNum = ERROR_NUMBER()

			EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey

			RETURN;
		END CATCH
    END

	--check if customer exists and customer details have changed then update customer details
	IF @customerupdateind = 1 AND @customernewind = 0
	BEGIN
	    SET @StepName = 'Staging.STG_Customer_Update'
		BEGIN TRY		

		--EXEC uspSSISProcStepStart @ProcName, @StepName

        EXEC [Staging].[STG_Customer_Update] @userid              = @userid,   
	                                         @informationsourceid = @informationsourceid,
	                                         @customerid          = @customerid,
											 --@sourcecreateddate   = @sourcecreateddate,
	                                         @sourcemodifieddate  = @sourcemodifieddate,
	                                         @archivedind         = 0,
	                                         @salutation          = @salutation,
	                                         @firstname           = @firstname,
	                                         @lastname            = @lastname,
	                                         @datefirstpurchase   = @datefirstpurchase,
											 @datelastpurchase   = @datelastpurchase,
											 @dateofbirth         = @dateofbirth,
											 @neareststation      = @neareststation,
											 @vtsegment           = @vtsegment,
											 @accountstatus       = @accountstatus,
											 @experianhouseholdincome   = @experianhouseholdincome,
											 @ExperianAgeBand     = @ExperianAgeBand,
	                                         @recordcount         = @recordcount OUTPUT 
		--EXEC uspSSISProcStepSuccess @ProcName, @StepName
		END TRY
		BEGIN CATCH

			SET @ErrorNum = ERROR_NUMBER()
			SET @ErrorMsg = ERROR_MESSAGE()
			EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
			RETURN;
		END CATCH ;
    END

	--Now pull through subscription information held in PreProcessing

	IF (@customernewind = 1 OR @customerupdateind = 1) AND @ispersonind = 1 AND @customerid>0
	BEGIN
		DECLARE Subscriptions CURSOR READ_ONLY
		FOR
			SELECT customerid
				   ,CASE WHEN ScbscriptionType = 'donotemail'				THEN @GeneralMarketingOptinId
						 WHEN ScbscriptionType = 'donotmail'				THEN @GeneralMarketingOptinId
						 WHEN ScbscriptionType = 'donotsms'					THEN @GeneralMarketingOptinId
						 WHEN ScbscriptionType = 'thirdpartyoptout'			THEN @ThirdPartyOptoutId
						 WHEN ScbscriptionType = 'retailermarketingoptin'   THEN @RetailerMarketingOptinId
						 WHEN ScbscriptionType = 'thirdpartymarketingoptin' THEN @ThirdPartyMarketingOptinId
						 WHEN ScbscriptionType = 'DftOptInFlag'				THEN @DftOptInFlagId
					END AS PrefereneID
				   ,CASE WHEN ScbscriptionType = 'donotemail'				THEN @EmailChannelId
						 WHEN ScbscriptionType = 'donotmail'				THEN @MailChannelId
						 WHEN ScbscriptionType = 'donotsms'					THEN @SMSChannelId
						 WHEN ScbscriptionType = 'thirdpartyoptout'			THEN @NoneChannelId
						 WHEN ScbscriptionType = 'retailermarketingoptin'   THEN @NoneChannelId
						 WHEN ScbscriptionType = 'thirdpartymarketingoptin' THEN @NoneChannelId
						 WHEN ScbscriptionType = 'DftOptInFlag'				THEN @NoneChannelId
					END AS ChannelID
					,CASE WHEN Subscription = 'Y' THEN 1 WHEN Subscription = 'N' THEN 0 ELSE 0 END AS [value]
					,@sourcecreateddate as sourcecreateddate
					,@sourcemodifieddate as sourcemodifieddate
			FROM (
			SELECT unpvt.customerid, Subscription, ScbscriptionType
			FROM (
			--for donot preferences flip the values to keep value script consistent 
			SELECT @customerid AS customerid
				   ,CAST(CASE WHEN donotemail = 'Y' THEN 'N' WHEN donotemail = 'N' THEN 'Y' ELSE NULL END AS nchar(1)) AS donotemail
				   ,CAST(CASE WHEN donotmail  = 'Y' THEN 'N' WHEN donotmail  = 'N' THEN 'Y' ELSE NULL END AS nchar(1)) AS donotmail
				   ,CAST(CASE WHEN donotsms   = 'Y' THEN 'N' WHEN donotsms   = 'N' THEN 'Y' ELSE NULL END AS nchar(1)) AS donotsms
				   ,thirdpartyoptout
				   ,CAST(retailermarketingoptin AS nchar(1)) AS retailermarketingoptin
				   ,CAST(thirdpartymarketingoptin AS nchar(1)) AS thirdpartymarketingoptin
				   ,CAST(DftOptInFlag AS nchar(1)) AS DftOptInFlag
			FROM PreProcessing.TOCPLUS_Customer
			WHERE TCScustomerID = @tcs_customerid
			AND   ProcessedInd   = 0
			AND DataImportDetailID = @dataimportdetailid) AS S
			UNPIVOT
			(Subscription
			 FOR ScbscriptionType IN (donotemail, donotmail, donotsms, thirdpartyoptout
									,retailermarketingoptin, thirdpartymarketingoptin, dftoptinflag)
			) as unpvt) AS SQ

			OPEN Subscriptions

			FETCH NEXT FROM Subscriptions
			    INTO @customerid
				    ,@preferenceid
					,@channelid
					,@value
					,@sourcecreateddate
					,@sourcemodifieddate
		     	    
            WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @StepName = 'Staging.STG_CustomerPreference_Update'
				BEGIN TRY
					--EXEC uspSSISProcStepStart @ProcName, @StepName

					EXEC [Staging].[STG_CustomerPreference_Update]  @userid                 = @userid,   
																	@customerid             = @customerid,
																	@preferenceid           = @preferenceid,
																	@channelid              = @channelid,
																	@value                  = @value,
																	@sourcecreateddate      = @sourcecreateddate,
																	@sourcemodifieddate     = @sourcemodifieddate

					--EXEC uspSSISProcStepSuccess @ProcName, @StepName
				END TRY
				BEGIN CATCH

					SET @ErrorNum = ERROR_NUMBER()
					SET @ErrorMsg = ERROR_MESSAGE()
					EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey

				END CATCH ;

               FETCH NEXT FROM Subscriptions
			    INTO @customerid
				    ,@preferenceid
					,@channelid
					,@value
					,@sourcecreateddate
					,@sourcemodifieddate

            END

			CLOSE Subscriptions

        DEALLOCATE Subscriptions
    END

    IF @emailchangeind = 1 AND @emailaddress IS NOT NULL AND @parsedaddressemail IS NOT NULL
    BEGIN
		SET @StepName = 'Staging.STG_ElectronicAddress_Update - record Email address change'
	BEGIN TRY

		--EXEC uspSSISProcStepStart @ProcName, @StepName

		EXEC [Staging].[STG_ElectronicAddress_Update] @userid              = @userid,   
	                                                  @informationsourceid = @informationsourceid,
	                                                  @customerid          = @customerid,
	                                                  @sourcemodifeddate   = @sourcemodifieddate,
	                                                  @address             = @emailaddress,
													  @parsedaddress       = @parsedaddressemail,
													  @parsedind           = @parsedemailind,
													  @parsedscore         = @parsedemailscore,
                                                      @addresstypeid       = @addresstypeidemail,
	                                                  @archivedind         = 0,
													  @primaryind          = 1,
	                                                  @recordcount         = @recordcount OUTPUT

		--EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
		RETURN;
	END CATCH ;
    END

	IF @mobilechangeind = 1 AND @mobilephone IS NOT NULL AND @parsedaddressmobile IS NOT NULL
	BEGIN
		SET @StepName = 'Staging.STG_ElectronicAddress_Update - record mobile phone change'
	BEGIN TRY

		--EXEC uspSSISProcStepStart @ProcName, @StepName

        EXEC [Staging].[STG_ElectronicAddress_Update] @userid              = @userid,   
	                                                  @informationsourceid = @informationsourceid,
	                                                  @customerid          = @customerid,
	                                                  @sourcemodifeddate   = @sourcemodifieddate,
	                                                  @address             = @mobilephone,
													  @parsedaddress       = @parsedaddressmobile,  
													  @parsedind           = @parsedmobileind,
													  @parsedscore         = @parsedmobilescore,
                                                      @addresstypeid       = @addresstypeidmobile,
	                                                  @archivedind         = 0,
													  @primaryind          = 1,
	                                                  @recordcount         = @recordcount OUTPUT

		--EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
		RETURN;
	END CATCH ;
    END
	
	IF  @dayphonenumber IS NOT NULL AND @parsedaddressmobile1 IS NOT NULL AND @parsedaddressmobile <> @parsedaddressmobile1
	BEGIN
		SET @StepName = 'Staging.STG_ElectronicAddress_Update - record day phone change'
	BEGIN TRY

		--EXEC uspSSISProcStepStart @ProcName, @StepName

        EXEC [Staging].[STG_ElectronicAddress_Update] @userid              = @userid,   
	                                                  @informationsourceid = @informationsourceid,
	                                                  @customerid          = @customerid,
	                                                  @sourcemodifeddate   = @sourcemodifieddate,
	                                                  @address             = @dayphonenumber,
													  @parsedaddress       = @parsedaddressmobile1,  
													  @parsedind           = @parsedmobileind1,
													  @parsedscore         = @parsedmobilescore1,
                                                      @addresstypeid       = @addresstypeidmobile,
	                                                  @archivedind         = 1,
													  @primaryind          = 0,
	                                                  @recordcount         = @recordcount OUTPUT

		--EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
		RETURN;
	END CATCH ;
    END

	IF  @eveningphonenumber IS NOT NULL AND @parsedaddressmobile2 IS NOT NULL AND @parsedaddressmobile <> @parsedaddressmobile2
	BEGIN
		SET @StepName = 'Staging.STG_ElectronicAddress_Update - record evening phone change'
	BEGIN TRY

		--EXEC uspSSISProcStepStart @ProcName, @StepName

        EXEC [Staging].[STG_ElectronicAddress_Update] @userid              = @userid,   
	                                                  @informationsourceid = @informationsourceid,
	                                                  @customerid          = @customerid,
	                                                  @sourcemodifeddate   = @sourcemodifieddate,
	                                                  @address             = @eveningphonenumber,
													  @parsedaddress       = @parsedaddressmobile2,  
													  @parsedind           = @parsedmobileind2,
													  @parsedscore         = @parsedmobilescore2,
                                                      @addresstypeid       = @addresstypeidmobile,
	                                                  @archivedind         = 1,
													  @primaryind          = 0,
	                                                  @recordcount         = @recordcount OUTPUT

		--EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
		RETURN;
	END CATCH ;
    END

	IF @namadchangeind = 1 AND @namad IS NOT NULL AND @namadrejectreason IS NULL
	BEGIN
		SET @StepName = 'Staging.STG_ElectronicAddress_Update - record namad change'
	BEGIN TRY

		--EXEC uspSSISProcStepStart @ProcName, @StepName

        EXEC [Staging].[STG_ElectronicAddress_Update] @userid              = @userid,   
	                                                  @informationsourceid = @informationsourceid,
	                                                  @customerid          = @customerid,
	                                                  @sourcemodifeddate   = @sourcemodifieddate,
	                                                  @address             = @namad,
													  @parsedaddress       = @namad,
													  @parsedind           = @namadind,
													  @parsedscore         = @namadscore,
                                                      @addresstypeid       = @addresstypeidnamad,
													  @archivedind         = 0,
													  @primaryind          = 1,
	                                                  @recordcount         = @recordcount OUTPUT
		--EXEC uspSSISProcStepSuccess @ProcName, @StepName
	END TRY
	BEGIN CATCH
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = ERROR_MESSAGE()
		EXEC dbo.uspSSISProcStepFailed @ProcName, @StepName, @ErrorNum, @ErrorMsg, @PkgExecKey
		RETURN;
	END CATCH ;
    END

	--Mark record as processed
 
	UPDATE [PreProcessing].TOCPLUS_Customer
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
	WHERE  TCScustomerID = @tcs_customerid
	AND DataImportDetailID = @dataimportdetailid 

	-- End auditting
	--EXEC dbo.uspAuditAddAudit
	--	 @AuditType='PROCESS END'
	--	,@Process=@spname, @DatabaseName=@dbname,@SPID =@spid,@Rows = @recordcount, @PrintToScreen=@DebugPrint


	RETURN 
END
GO


