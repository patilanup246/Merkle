declare	@userid                 INTEGER = 0,   
	@tcs_customerid         INTEGER = 5992749,
	@dataimportdetailid     INTEGER = 50


    SET NOCOUNT ON
	
	DECLARE @customerdetailid                     INTEGER
	DECLARE @sourcecreateddate					  DATETIME
	DECLARE @sourcemodifieddate				  DATETIME
    DECLARE @salutation                           NVARCHAR(100)
	DECLARE @firstname                            NVARCHAR(50)
	DECLARE @lastname                             NVARCHAR(50)	
	DECLARE @emailaddress                         NVARCHAR(256)
	DECLARE @mobilephone                          NVARCHAR(256)
	DECLARE @dayphonenumber                       NVARCHAR(256)
	DECLARE @eveningphonenumber                   NVARCHAR(256)
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

	DECLARE @customersubscriptionid               INTEGER
	DECLARE @subscriptioncreateddate              DATETIME
	DECLARE @subscriptionchanneltypeid            INTEGER
	DECLARE @optinind                             INTEGER
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
	DECLARE @spname                               NVARCHAR(256)
	DECLARE @recordcount                          INTEGER
	DECLARE @logtimingidnew                       INTEGER
	DECLARE @logmessage                           NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
    
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

    SELECT @defaultoptinleisure = SubscriptionTypeID
    FROM   [Reference].[SubscriptionType]
    WHERE  Name = [Reference].[Configuration_GetSetting] ('Migration','Default Leisure Subscription Type')

	SELECT @defaultoptincorporate = SubscriptionTypeID
	FROM   [Reference].[SubscriptionType]
	WHERE  Name = [Reference].[Configuration_GetSetting] ('Migration','Default Corporate Subscription Type')

	SELECT @subscriptionchanneltypeidleisure = SubscriptionChannelTypeID
	FROM   Reference.SubscriptionChannelType a,
	       Reference.SubscriptionType b,
	 	   Reference.ChannelType c
	WHERE  a.SubscriptionTypeID = b.SubscriptionTypeID
	AND    a.ChannelTypeID      = c.ChannelTypeID
	AND    b.SubscriptionTypeID = @defaultoptinleisure
	AND    c.Name = 'Email'

	SELECT @subscriptionchanneltypeidcorp = SubscriptionChannelTypeID
	FROM   Reference.SubscriptionChannelType a,
	       Reference.SubscriptionType b,
	 	   Reference.ChannelType c
	WHERE  a.SubscriptionTypeID = b.SubscriptionTypeID
	AND    a.ChannelTypeID = c.ChannelTypeID
	AND    b.SubscriptionTypeID = @defaultoptincorporate
	AND    c.Name = 'Email'

	IF @informationsourceid                 IS NULL
	   OR @addresstypeidemail               IS NULL
	   OR @addresstypeidmobile              IS NULL
	   OR @addresstypeidnamad				IS NULL
	   OR @defaultoptincorporate            IS NULL
	   OR @defaultoptinleisure              IS NULL
	   OR @subscriptionchanneltypeidleisure IS NULL
	   OR @subscriptionchanneltypeidcorp    IS NULL
	BEGIN
	    SET @logmessage = 'No or invalid reference information.' +
		                  ' @informationsourceid =  '                + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') +
						  ', @addresstypeidemail =  '                + ISNULL(CAST(@addresstypeidemail AS NVARCHAR(256)),'NULL') +
						  ', @addresstypeidmobile = '                + ISNULL(CAST(@addresstypeidmobile AS NVARCHAR(256)),'NULL') +
						  ', @addresstypeidnamad  = '                + ISNULL(CAST(@addresstypeidnamad AS NVARCHAR(256)),'NULL') +
						  ', @defaultoptincorporate = '              + ISNULL(CAST(@defaultoptincorporate AS NVARCHAR(256)),'NULL') +
						  ', @defaultoptinleisure   = '              + ISNULL(CAST(@defaultoptinleisure AS NVARCHAR(256)),'NULL') +
						  ', @subscriptionchanneltypeidleisure   = ' + ISNULL(CAST(@subscriptionchanneltypeidleisure AS NVARCHAR(256)),'NULL') +
						  ', @subscriptionchanneltypeidcorp   = '    + ISNULL(CAST(@subscriptionchanneltypeidcorp AS NVARCHAR(256)),'NULL')
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = 'Invalid Lookup'
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
		  ,@sourcemodifieddate= regcmddateupdated
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
    AND   ProcessedInd   = 0

	SELECT @namadrejectreason = [Staging].[rejectReason](@namad, @firstname,'',@lastname,@addressline1,@addressline2)

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

    IF @customerdetailid IS NULL
	BEGIN
	    SET @logmessage = 'No data supplied to process. ' +
		                  '@msd_customerid = ' + ISNULL(CAST(@tcs_customerid AS NVARCHAR(256)),'NULL') 
	    
		EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                      @logsource       = @spname,
											  @logmessage      = @logmessage,
											  @logmessagelevel = 'ERROR',
											  @messagetypecd   = NULL

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
						  SourceCreatedDate,
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
						  @sourcecreateddate,
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
		END 

		--IF Address has changed, update address
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

    IF @customernewind = 1
	BEGIN
	
	    PRINT 1
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
    END

	--SELECT @customerid

	--Now pull through subscription information held in PreProcessing

	--IF (@customernewind = 1 OR @migratingcustomerind = 1) AND @ispersonind = 1
	--BEGIN
	--	DECLARE Subscriptions CURSOR READ_ONLY
	--	FOR
	--	    SELECT CustomerSubscriptionID
	--		      ,CreatedDate
	--			  ,SubscriptionChannelTypeID
	--			  ,OptInInd
	--			  ,InformationSourceID
 --           FROM [PreProcessing].[API_CustomerSubscription] WITH (NOLOCK)
	--		WHERE TCSCustomerid = @customerdetailid
	--		AND   ProcessedInd = 0
	--		ORDER BY CustomerSubscriptionID

	--		OPEN Subscriptions

	--		FETCH NEXT FROM Subscriptions
	--		    INTO @customersubscriptionid
	--			    ,@subscriptioncreateddate
	--				,@subscriptionchanneltypeid
	--				,@optinind
	--				,@informationsourceidsubscription
		     	    
 --           WHILE @@FETCH_STATUS = 0
	--		BEGIN
	--		    EXEC [Staging].[STG_CustomerSubscriptionPreference_Update] @userid                    = @userid,   
	--                                                                       @informationsourceid       = @informationsourceidsubscription,
	--                                                                       @customerid                = @customerid,
	--                                                                       @sourcechangedate          = @subscriptioncreateddate,
	--                                                                       @archivedind               = 0,
	--                                                                       @subscriptionchanneltypeid = @subscriptionchanneltypeid,
	--                                                                       @optinind                  = @optinind,
	--                                                                       @starttime                 = NULL,
	--                                                                       @endtime                   = NULL,
	--                                                                       @daysofweek                = NULL,
	--                                                                       @recordcount               = @recordcountsubscription OUTPUT

 --              IF @recordcountsubscription > 0
	--		   BEGIN
	--		       UPDATE [PreProcessing].[API_CustomerSubscription]
	--			   SET    LastModifiedDate   = GETDATE()
	--			         ,ProcessedInd       = 1
	--					 ,DataImportDetailID = @dataimportdetailid
 --                  WHERE CustomerSubscriptionID = @customersubscriptionid
 --              END

 --              FETCH NEXT FROM Subscriptions
	--		    INTO @customersubscriptionid
	--			    ,@subscriptioncreateddate
	--				,@subscriptionchanneltypeid
	--				,@optinind
	--				,@informationsourceidsubscription

 --           END

	--		CLOSE Subscriptions

 --       DEALLOCATE Subscriptions

	--	--If there are no subscriptions then need to set the Customer Preferences

	--	IF NOT EXISTS (SELECT 1
	--	               FROM Staging.STG_CustomerSubscriptionPreference
	--				   WHERE CustomerID = @customerid
	--				   AND   ArchivedInd = 0)
 --       BEGIN
	--	    INSERT INTO [Staging].[STG_CustomerPreference]
 --                 ([CustomerID]
 --                 ,[OptionID]
 --                 ,[PreferenceValue]
 --                 ,[CreatedDate]
 --                 ,[CreatedBy]
 --                 ,[LastModifiedDate]
 --                 ,[LastModifiedBy]
 --                 ,[ArchivedInd])
 --           SELECT @customerid
	--		      ,a.OptionID
	--			  ,CASE WHEN OptionName = 'Opt out from all channels' THEN 1 ELSE 0 END
	--			  ,GETDATE()
	--			  ,@userid
	--			  ,GETDATE()
	--			  ,@userid
	--			  ,0
 --           FROM Staging.STG_PreferenceOptions a
	--		LEFT JOIN Staging.STG_CustomerPreference b ON a.OptionID = b.OptionID
	--		                                               AND b.CustomerID = @customerid
 --           WHERE a.ArchivedInd = 0
	--		AND   b.CustomerID IS NULL
	--	END

	--Now for CVI Responses

		--DECLARE CVIResponses CURSOR READ_ONLY
		--FOR
		--    SELECT CVIResponseCustomerID
		--	      ,InformationSourceID
		--	      ,CVIQuestionID
		--		  ,CVIQuestionGroupID
		--		  ,CVIQuestionAnswerID
		--		  ,Response
		--		  ,CreatedDate
  --          FROM [PreProcessing].[API_CVIResponseCustomer] WITH (NOLOCK)
		--	WHERE TCSCustomerid = @customerdetailid
		--	AND   ProcessedInd = 0
		--	ORDER BY CVIResponseCustomerID
			
		--	OPEN CVIResponses

		--	FETCH NEXT FROM CVIResponses
		--	    INTO @customerresponseid
		--		    ,@informationsourceidcvi
		--		    ,@cviquestionid
		--			,@cviquestiongroupid
		--			,@cviquestionanswerid
		--			,@response
		--			,@cviresponsecreateddate

  --          WHILE @@FETCH_STATUS = 0
		--	BEGIN
		--	    EXEC [Staging].[STG_CVIResponseCustomer_Update] @userid              = @userid,   
	 --                                                           @informationsourceid = @informationsourceidcvi,
	 --                                                           @customerid          = @customerid,
	 --                                                           @sourcechangedate    = @cviresponsecreateddate,
  --                                                              @cviquestionid       = @cviquestionid,
	 --                                                           @cviquestiongroupid  = @cviquestiongroupid ,
		--														@cviquestionanswerid = @cviquestionanswerid,
	 --                                                           @response            = @response,
	 --                                                           @recordcount         = @recordcountcvi OUTPUT

  --              IF @recordcountcvi > 0
		--	    BEGIN
		--	        UPDATE [PreProcessing].[API_CVIResponseCustomer]
		--		    SET    LastModifiedDate   = GETDATE()
		--		          ,ProcessedInd       = 1
		--	 			 ,DataImportDetailID = @dataimportdetailid
  --                  WHERE CVIResponseCustomerID = @customerresponseid
  --              END

		--		FETCH NEXT FROM CVIResponses
		--	    INTO @customerresponseid
		--		    ,@informationsourceidcvi
		--		    ,@cviquestionid
		--			,@cviquestiongroupid
		--			,@cviquestionanswerid
		--			,@response
		--			,@cviresponsecreateddate

		--    END

		--	CLOSE CVIResponses

  --      DEALLOCATE CVIResponses
    

    --END

	IF @customerupdateind = 1 AND @customernewind = 0
	BEGIN
        EXEC [Staging].[STG_Customer_Update] @userid              = @userid,   
	                                         @informationsourceid = @informationsourceid,
	                                         @customerid          = @customerid,
											 @sourcecreateddate   = @sourcecreateddate,
	                                         @sourcemodifieddate  = @sourcemodifieddate,
	                                         @archivedind         = 0,
	                                         @salutation          = @salutation,
	                                         @firstname           = @firstname,
	                                         @lastname            = @lastname,
	                                         @datefirstpurchase   = @datefirstpurchase,
											 @dateofbirth         = @dateofbirth,
											 @neareststation      = @neareststation,
											 @vtsegment           = @vtsegment,
											 @accountstatus       = @accountstatus,
											 @experianhouseholdincome   = @experianhouseholdincome,
											 @ExperianAgeBand     = @ExperianAgeBand,
	                                         @recordcount         = @recordcount OUTPUT 
    END

    IF @emailchangeind = 1 AND @emailaddress IS NOT NULL AND @parsedaddressemail IS NOT NULL
    BEGIN
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
    END

	IF @mobilechangeind = 1 AND @mobilephone IS NOT NULL AND @parsedaddressmobile IS NOT NULL
	BEGIN

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
    END

	
	IF  @dayphonenumber IS NOT NULL AND @parsedaddressmobile1 IS NOT NULL
	BEGIN

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
    END

	IF  @eveningphonenumber IS NOT NULL AND @parsedaddressmobile2 IS NOT NULL
	BEGIN

        EXEC [Staging].[STG_ElectronicAddress_Update] @userid              = @userid,   
	                                                  @informationsourceid = @informationsourceid,
	                                                  @customerid          = @customerid,
	                                                  @sourcemodifeddate   = @sourcemodifieddate,
	                                                  @address             = @dayphonenumber,
													  @parsedaddress       = @parsedaddressmobile2,  
													  @parsedind           = @parsedmobileind2,
													  @parsedscore         = @parsedmobilescore2,
                                                      @addresstypeid       = @addresstypeidmobile,
	                                                  @archivedind         = 1,
													  @primaryind          = 0,
	                                                  @recordcount         = @recordcount OUTPUT
    END

	IF @namadchangeind = 1 AND @namad IS NOT NULL 
	BEGIN
        EXEC [Staging].[STG_ElectronicAddress_Update] @userid              = @userid,   
	                                                  @informationsourceid = @informationsourceid,
	                                                  @customerid          = @customerid,
	                                                  @sourcemodifeddate   = @sourcemodifieddate,
	                                                  @address             = @namad,
                                                      @addresstypeid       = @addresstypeidnamad,
													  @archivedind         = 0,
													  @primaryind          = 1,
	                                                  @recordcount         = @recordcount OUTPUT
    END

	--Mark record as processed
 
	UPDATE [PreProcessing].TOCPLUS_Customer
	SET    ProcessedInd = 1
	      ,LastModifiedDateETL = GETDATE()
	WHERE  TCScustomerID = @tcs_customerid


	RETURN 





