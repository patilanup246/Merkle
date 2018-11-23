DECLARE  @customerid     int,         
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

   DECLARE @CustomerAddress TABLE
   (CreatedDate DATETIME, CreatedBy INT , LastModifiedDate DATETIME, LastModifiedBy INT
   ,ArchivedInd BIT, InformationSourceID INT,SourceCreatedDate DATETIME, SourceModifiedDate DATETIME
   ,CompanyName NVARCHAR(100), Address1 NVARCHAR(512), Address2 NVARCHAR(512), Address3 NVARCHAR(512)
   ,address4 NVARCHAR(512), address5 NVARCHAR(512), postcode NVARCHAR(512), CountryID NVARCHAR(512)
   ,PrimaryInd NVARCHAR(512), AddressTypeID NVARCHAR(512), CustomerID INT)

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


INSERT INTO @CustomerAddress
(createddate,CreatedBy, lastmodifieddate, archivedind, informationsourceid,sourcecreateddate
,sourcemodifieddate, companyname, address1, address2, address3, address4, address5
,postcode, countryid, primaryind, addresstypeid,customerid)     
SELECT createddate,userid, lastmodifieddate, archivedind, informationsourceid,sourcecreatedate
		,sourcemodifieddate, companyname, address1, address2, address3, address4, address5
		,postcode, countryid, primaryind, addresstype
		,customerid
FROM (
MERGE Staging.STG_Address AS TRGT
USING (SELECT @CreatedDate as createddate, @userid as userid, @LastModifiedDate as lastmodifieddate
		,@ArchivedInd as archivedind, @InformationSourceID as informationsourceid,@SourceCreateDDate as sourcecreatedate
		,@SourceModifiedDate as sourcemodifieddate, @companyname as companyname, @address1 as address1
		,@address2 as address2, @address3 as address3, @address4 as address4, @address5 as address5
		,@postcode as postcode, @CountryID as countryid, @PrimaryInd as primaryind, @AddressTypeID as addresstype
		,@CustomerID as customerid) AS SRC
ON TRGT.CustomerID = SRC.customerid
AND TRGT.[PrimaryInd] = 1
WHEN NOT MATCHED THEN
-- Inserting new Customer Contact Address Information
INSERT (CreatedDate, CreatedBy, LastModifiedDate, LastModifiedBy, ArchivedInd
		,InformationSourceID, SourceCreatedDate, SourceModifiedDate, CompanyName
		,AddressLine1, AddressLine2, AddressLine3, AddressLine4, AddressLine5
		,PostalCode, CountryID, PrimaryInd, AddressTypeID, CustomerID)
VALUES
		(@CreatedDate, @userid, @LastModifiedDate, @userid, @ArchivedInd, @InformationSourceID
		,@SourceCreateDDate, @SourceModifiedDate, companyname, address1, address2, address3
		,address4, address5, postcode, @CountryID, @PrimaryInd, @AddressTypeID,CustomerID)
WHEN MATCHED 
	AND (TRGT.companyname <> SRC.companyname
			OR TRGT.addressline1  <> SRC.address2
			OR TRGT.addressline2  <> SRC.address2
			OR TRGT.addressline3  <> SRC.address3
			OR TRGT.addressline4  <> SRC.address4
			OR TRGT.addressline5  <> SRC.address5
			OR TRGT.postalcode  <> SRC.postcode
			OR TRGT.countryid   <> SRC.countryid) 
	THEN
		UPDATE 
		SET [PrimaryInd] = 0
	OUTPUT $ACTION AS [Action]
		,SRC.createddate,SRC.userid, SRC.lastmodifieddate
		,SRC.archivedind, SRC.informationsourceid,SRC.sourcecreatedate
		,SRC.sourcemodifieddate, SRC.companyname, SRC.address1
		,SRC.address2, SRC.address3, SRC.address4, SRC.address5
		,SRC.postcode, SRC.countryid, SRC.primaryind, SRC.addresstype
		,SRC.customerid) MERGE_OUT
		WHERE MERGE_OUT.[Action] = 'UPDATE';



