
  CREATE PROCEDURE [Staging].[STG_Address_Insert] 
     @customerid     int,         
	 @SourceCreatedDate datetime   = NULL,
	 @SourceModifiedDate datetime  = NULL,
	 @companyname    nvarchar(100) = NULL,
     @address1       nvarchar(512) = NULL,
     @address2       nvarchar(512) = NULL,
     @address3       nvarchar(512) = NULL,
     @address4       nvarchar(512) = NULL,
     @address5       nvarchar(512) = NULL,
     @postcode       nvarchar(512) = NULL,
     @country        nvarchar(512) = NULL
  ----------------------------------------
  AS 
  BEGIN

   SET NOCOUNT ON;

   DECLARE @userid                 INTEGER = 0

   DECLARE @CreatedDate datetime        = GETDATE()
   DECLARE @LastModifiedDate datetime   = GETDATE()

   DECLARE @ArchivedInd int             = 0
   DECLARE @PrimaryInd int              = 1
   DECLARE @AddressTypeID int           

   DECLARE @countryID int;
   DECLARE @InformationSourceID int 

   DECLARE @ErrMsg varchar(512)
   DECLARE @RowCount int = 0;

   -- TrainLine is the InformationSource 
   SELECT @InformationSourceID = InformationSourceID
   FROM Reference.InformationSource
   WHERE Name = 'TrainLine'
   AND ArchivedInd = 0

   IF @@ROWCOUNT = 0
     BEGIN
      SET @ErrMsg = 'Unable to find the specified Informaion Source (TrainLine)';
      THROW 51403, @ErrMsg,1
     END   

	-- Contact Address
	SELECT @AddressTypeID = AddressTypeID
	FROM Reference.AddressType
	WHERE [Name] = 'Contact'

	IF @@ROWCOUNT = 0
     BEGIN
      SET @ErrMsg = 'Unable to find the specified Address Type (Contact)';
      THROW 51403, @ErrMsg,1
     END   

   -- Getting Country ID from Country Name
   SELECT @countryID = CountryID
   FROM Reference.Country C
   WHERE C.Name = @country;

   IF @@ROWCOUNT = 0
     BEGIN
      SET @ErrMsg = 'Unable to find the specified country ('+@country+')';
      THROW 51403, @ErrMsg,1
     END      
   
   -- Inserting new Customer Contact Address Information
   INSERT INTO Staging.STG_Address
     ( CreatedDate,
       CreatedBy,
       LastModifiedDate,
       LastModifiedBy,
       ArchivedInd,
       InformationSourceID,
       SourceCreatedDate,
       SourceModifiedDate,
	   CompanyName,
       AddressLine1,
       AddressLine2,
       AddressLine3,
       AddressLine4,
       AddressLine5,
       PostalCode,
       CountryID,
       PrimaryInd,
       AddressTypeID,
       CustomerID )
    VALUES
     ( @CreatedDate,
       @userid,
       @LastModifiedDate,
       @userid,
       @ArchivedInd,
       @InformationSourceID,
       @SourceCreateDDate,
       @SourceModifiedDate,
	   @companyname,
       @address1,
       @address2,
       @address3,
       @address4,
       @address5,
       @postcode,
       @CountryID,
       @PrimaryInd,
       @AddressTypeID,
       @CustomerID )
    
   SET @RowCount = @@ROWCOUNT
   


   IF @RowCount = 0
     BEGIN
      SET @ErrMsg = 'Unable to add Address';
      THROW 90508, @ErrMsg,1
      END  
    return @RowCount;
 END