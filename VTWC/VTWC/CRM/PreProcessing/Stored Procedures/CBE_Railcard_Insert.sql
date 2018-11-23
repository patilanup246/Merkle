CREATE PROCEDURE [PreProcessing].[CBE_Railcard_Insert]
    @userid             INTEGER = 0,
	@dataimportdetailid INTEGER 

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @informationsourceid    INTEGER
	DECLARE @now                    DATETIME

	DECLARE @spname                 NVARCHAR(256)
	DECLARE @logmessage             NVARCHAR(MAX)
	DECLARE @recordcount            INTEGER       = 0
	DECLARE @successcountimport     INTEGER       = 0
	DECLARE @errorcountimport       INTEGER       = 0
	DECLARE @logtimingidnew         INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    SELECT @now = GETDATE()

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

    EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Processing',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
	                                            @starttimeimport       = @now,
	                                            @endtimeimport         = NULL,
	                                            @totalcountimport      = NULL,
	                                            @successcountimport    = NULL,
	                                            @errorcountimport      = NULL

    --Get configuration settings

	SELECT @informationsourceid = InformationSourceID
    FROM [Reference].[InformationSource]
    WHERE Name = 'CBE'

	IF @informationsourceid IS NULL
    BEGIN
	    SET @logmessage = 'No or invalid information source: ' + ISNULL(CAST(@informationsourceid AS NVARCHAR(256)),'NULL') 
	    
	    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	                                          @logsource       = @spname,
			    							  @logmessage      = @logmessage,
				    						  @logmessagelevel = 'ERROR',
						    				  @messagetypecd   = 'Invalid Lookup'
        RETURN
    END

    --Updates to existing RailCardTypes

	UPDATE  Reference.RailCardType
    SET Name                      = b.Name
	   ,Description               = b.IDMS_Display_Name
       ,LastModifiedDate          = GETDATE()
       ,LastModifiedBy            = @userid
       ,ArchivedInd               = CASE WHEN b.Is_Active = 1 THEN 0 ELSE 1 END
	   ,Code                      = b.Code
       ,AdultStatusCode           = b.Adult_Status_Code
       ,ChildStatusCode           = b.Child_Status_Code
       ,AAAStatusCode             = b.AAA_Status_Code
       ,StartDate                 = b.Start_Date
       ,EndDate                   = b.End_Date
       ,IDMSDisplayName           = b.IDMS_Display_Name
       ,IDMSPrintingName          = b.IDMS_Printing_Name
       ,IDMSAttendedTIS           = b.IDMS_Attended_TIS
       ,IDMSUnattendedTIS         = b.IDMS_Unattended_TIS
       ,CAPRICode                 = b.CAPRI_Code
       ,QuoteDate                 = b.Quote_Date
       ,HolderType                = b.Holder_Type
       ,MinNoOfPassengers         = b.Min_No_Of_Passengers
       ,MaxNoOfPassengers         = b.Max_No_Of_Passengers
       ,MinNoOfRailcardHolders    = b.Min_No_Of_Railcard_Holders
       ,MaxNoOfRailcardHolders    = b.Max_No_Of_Railcard_Holders
       ,MinNoOfAccompanyingAdults = b.Min_No_Of_Accompanying_Adults
       ,MaxNoOfAccompanyingAdults = b.Max_No_Of_Accompanying_Adults
       ,MinNoOfAdults             = b.Min_No_Of_Adults
       ,MaxNoOfAdults             = b.Max_No_Of_Adults
       ,MinNoOfChildren           = b.Min_No_Of_Children
       ,MaxNoOfChildren           = b.Max_No_Of_Children
       ,PurchasePrice             = b.Purchase_Price
       ,DiscountPrice             = b.Discount_Price
       ,PeriodOfValidity          = b.Period_Of_Validity
       ,LastValidDate             = b.Last_Valid_Date
       ,IsPhysicalCard            = b.Is_Physical_Card
       ,SourceCreatedDate         = b.Date_Created
       ,SourceModifiedDate        = b.Date_Modified
       ,IsRestrictedByIssue       = b.Is_Restricted_By_Issue
       ,IsRestrictedByArea        = b.Is_Restricted_By_Area
       ,IsRestrictedByTrain       = b.Is_Restricted_By_Train
       ,IsRestrictedByDate        = b.Is_Restricted_By_Date
       ,MasterCode                = b.Master_Code
       ,InformationSourceID       = @InformationSourceID
    FROM  Reference.RailCardType a
	INNER JOIN PreProcessing.CBE_Railcard b ON a.ExtReference = b.Code
    WHERE b.ProcessedInd = 0
	AND   b.DataImportDetailID = @dataimportdetailid

	--Set ProcessedInd = 1 on CBE_Railcard for those updated

	UPDATE a
    SET  ProcessedInd = 1
	    ,[LastModifiedDateETL] = GETDATE()
	FROM  PreProcessing.CBE_Railcard a
	INNER JOIN Reference.RailCardType b ON a.Master_Code = b.ExtReference
	WHERE a.ProcessedInd = 0
	AND   a.DataImportDetailID = @dataimportdetailid

	--Add new RailCardTypes

	;WITH CTE_CBE_Railcard AS (
	        SELECT [CBE_RailcardID]
                  ,[ID]
                  ,[Name]
                  ,[Code]
                  ,[Adult_Status_Code]
                  ,[Child_Status_Code]
                  ,[AAA_Status_Code]
                  ,[Start_Date]
                  ,[End_Date]
                  ,[IDMS_Display_Name]
                  ,[IDMS_Printing_Name]
                  ,[IDMS_Attended_TIS]
                  ,[IDMS_Unattended_TIS]
                  ,[CAPRI_Code]
                  ,[Quote_Date]
                  ,[Holder_Type]
                  ,[Min_No_Of_Passengers]
                  ,[Max_No_Of_Passengers]
                  ,[Min_No_Of_Railcard_Holders]
                  ,[Max_No_Of_Railcard_Holders]
                  ,[Min_No_Of_Accompanying_Adults]
                  ,[Max_No_Of_Accompanying_Adults]
                  ,[Min_No_Of_Adults]
                  ,[Max_No_Of_Adults]
                  ,[Min_No_Of_Children]
                  ,[Max_No_Of_Children]
                  ,[Purchase_Price]
                  ,[Discount_Price]
                  ,[Period_Of_Validity]
                  ,[Last_Valid_Date]
                  ,[Is_Physical_Card]
                  ,[Date_Created]
                  ,[Date_Modified]
                  ,[Is_Active]
                  ,[Is_Restricted_By_Issue]
                  ,[Is_Restricted_By_Area]
                  ,[Is_Restricted_By_Train]
                  ,[Is_Restricted_By_Date]
                  ,[Master_Code]
                  ,[CreatedDateETL]
                  ,[LastModifiedDateETL]
                  ,[ProcessedInd]
                  ,[DataImportDetailID]
				  ,ROW_NUMBER() OVER (partition by [Master_Code]
                                      ORDER BY [Is_Active] DESC
									          ,Date_Modified DESC
									          ,[CBE_RailCardID] DESC) RANKING
          FROM [PreProcessing].[CBE_Railcard]
		  WHERE  DataImportDetailID = @dataimportdetailid
	      AND    ProcessedInd = 0)
  
    INSERT INTO Reference.RailCardType
           (Name
		   ,Description
           ,CreatedDate
           ,CreatedBy
           ,LastModifiedDate
           ,LastModifiedBy
           ,ArchivedInd
		   ,ExtReference                 
		   ,AdultStatusCode          
		   ,ChildStatusCode          
		   ,AAAStatusCode            
		   ,StartDate                
		   ,EndDate                  
		   ,IDMSDisplayName          
		   ,IDMSPrintingName         
		   ,IDMSAttendedTIS          
		   ,IDMSUnattendedTIS        
		   ,CAPRICode                
		   ,QuoteDate                
		   ,HolderType               
		   ,MinNoOfPassengers        
		   ,MaxNoOfPassengers        
		   ,MinNoOfRailcardHolders   
		   ,MaxNoOfRailcardHolders   
		   ,MinNoOfAccompanyingAdults
		   ,MaxNoOfAccompanyingAdults
		   ,MinNoOfAdults            
		   ,MaxNoOfAdults            
		   ,MinNoOfChildren          
		   ,MaxNoOfChildren          
		   ,PurchasePrice            
		   ,DiscountPrice            
		   ,PeriodOfValidity         
		   ,LastValidDate            
		   ,IsPhysicalCard           
		   ,SourceCreatedDate        
		   ,SourceModifiedDate       
		   ,IsRestrictedByIssue      
		   ,IsRestrictedByArea       
		   ,IsRestrictedByTrain      
		   ,IsRestrictedByDate       
		   ,MasterCode               
		   ,InformationSourceID      
           )
    SELECT b.Name
		  ,b.IDMS_Display_Name
		  ,GETDATE()
		  ,@userid
		  ,GETDATE()
		  ,@userid
		  ,CASE WHEN b.Is_Active = 1 THEN 0 ELSE 1 END
		  ,b.Code
		  ,b.Adult_Status_Code
		  ,b.Child_Status_Code
		  ,b.AAA_Status_Code
		  ,b.Start_Date
		  ,b.End_Date
		  ,b.IDMS_Display_Name
		  ,b.IDMS_Printing_Name
		  ,b.IDMS_Attended_TIS
		  ,b.IDMS_Unattended_TIS
		  ,b.CAPRI_Code
		  ,b.Quote_Date
		  ,b.Holder_Type
		  ,b.Min_No_Of_Passengers
		  ,b.Max_No_Of_Passengers
		  ,b.Min_No_Of_Railcard_Holders
		  ,b.Max_No_Of_Railcard_Holders
		  ,b.Min_No_Of_Accompanying_Adults
		  ,b.Max_No_Of_Accompanying_Adults
		  ,b.Min_No_Of_Adults
		  ,b.Max_No_Of_Adults
		  ,b.Min_No_Of_Children
		  ,b.Max_No_Of_Children
		  ,b.Purchase_Price
		  ,b.Discount_Price
		  ,b.Period_Of_Validity
		  ,b.Last_Valid_Date
		  ,b.Is_Physical_Card
		  ,b.Date_Created
		  ,b.Date_Modified
		  ,b.Is_Restricted_By_Issue
		  ,b.Is_Restricted_By_Area
		  ,b.Is_Restricted_By_Train
		  ,b.Is_Restricted_By_Date
		  ,b.Master_Code
		  ,@InformationSourceID
    FROM CTE_CBE_Railcard b
	LEFT JOIN Reference.RailCardType a ON a.ExtReference = b.Code
	WHERE a.RailCardTypeID IS NULL
	AND   b.RANKING = 1

	--Set ProcessedInd = 1 on CBE_Railcard for those added

	UPDATE a
    SET  ProcessedInd = 1
	    ,LastModifiedDateETL = GETDATE()
	FROM PreProcessing.CBE_Railcard a
	INNER JOIN Reference.RailcardType b ON a.Master_Code = b.ExtReference
	WHERE a.ProcessedInd = 0
	AND   a.DataImportDetailID = @dataimportdetailid

	--Log processing information

    SELECT @now = GETDATE()

	SELECT @successcountimport = COUNT(1)
    FROM   PreProcessing.CBE_Railcard
	WHERE  ProcessedInd = 1
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @errorcountimport = COUNT(1)
	FROM   PreProcessing.CBE_Railcard
	WHERE  ProcessedInd = 0
	AND    DataImportDetailID = @dataimportdetailid

	SELECT @recordcount = @successcountimport + @errorcountimport

	EXEC [Operations].[DataImportDetail_Update] @userid                = @userid,
	                                            @dataimportdetailid    = @dataimportdetailid,
	                                            @operationalstatusname = 'Completed',
	                                            @starttimeextract      = NULL,
	                                            @endtimeextract        = NULL,
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
	RETURN
END