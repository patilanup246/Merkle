
CREATE PROCEDURE [api_customer].[createRandomCustomer]
  @NewCustomerID int OUTPUT
AS 

	set nocount on;

	DECLARE @email varchar(150)
	DECLARE @Transaction varchar(32)
	DECLARE @ErrMsg varchar(32)

	SET @Transaction = 'TestCustomer'

	BEGIN TRAN @Transaction

	--Insert test customer
	INSERT INTO [Staging].[STG_Customer]
	([Description]
	,[CreatedDate]
	,[CreatedBy]
	,[LastModifiedDate]
	,[LastModifiedBy]
	,[ArchivedInd]
	,[MSDID]
	,[SourceCreatedDate]
	,[SourceModifiedDate]
	,[IsStaffInd]
	,[IsBlackListInd]
	,[IsTMCInd]
	,[IsCorporateInd]
	,[Salutation]
	,[FirstName]
	,[MiddleName]
	,[LastName]
	,[IndividualID]
	,[InformationSourceID]
	,[DateFirstPurchase]
	,[DateLastPurchase])
    VALUES
    ('Random Customer for Test'
    ,GETDATE()
    ,99999
    ,GETDATE()
    ,99999
    ,0
    ,CONVERT(varchar(100), NEWID())
    ,GETDATE()
    ,GETDATE()
    ,0
    ,0
    ,0
    ,0
    ,'Mr'
    ,'Test_Name_' + CONVERT(varchar(100), NEWID())
    ,'Test_MiddleName_' +CONVERT(varchar(100), NEWID())
    ,'Test_LastName_' + CONVERT(varchar(100), NEWID())
    ,null
    ,1
    ,DATEADD(Month, DATEDIFF(Month, 0, DATEADD(m, - 18, CURRENT_TIMESTAMP)), 0)
    ,GETDATE())
    	
	IF @@ROWCOUNT = 0
	BEGIN
		ROLLBACK TRAN @Transaction
		SET @ErrMsg = 'Unable to insert test customer' ;
		THROW 90508, @ErrMsg,1
	END
	
	SET @NewCustomerID = SCOPE_IDENTITY()
	
	SET @email = CONVERT(varchar(100), NEWID()) + '@test_vtec.com'
	
	--Insert test customer's email address
	INSERT INTO [Staging].[STG_ElectronicAddress]
	([Name]
	,[Description]
	,[CreatedDate]
	,[CreatedBy]
	,[LastModifiedDate]
	,[LastModifiedBy]
	,[ArchivedInd]
	,[InformationSourceID]
	,[SourceChangeDate]
	,[Address]
	,[PrimaryInd]
	,[UsedInCommunicationInd]
	,[ParsedInd]
	,[ParsedScore]
	,[IndividualID]
	,[CustomerID]
	,[AddressTypeID]
	,[ParsedAddress]
	,[HashedAddress])
    VALUES
    ('Test customer'
    ,'Test'
    ,GETDATE()
    ,99999
    ,GETDATE()
    ,99999
    ,0
    ,1
    ,GETDATE()
    ,@email
    ,1
    ,1
    ,1
    ,1
    ,NULL
    ,@NewCustomerID 
    ,3
    ,@email
    ,Staging.[VT_HASH](@email))
		
	IF @@ROWCOUNT = 0
	BEGIN
		ROLLBACK TRAN @Transaction
		SET @ErrMsg = 'Unable to insert test customer email address' ;
		THROW 90508, @ErrMsg,1
	END

	--Insert test customer's phone number	 
	INSERT INTO [Staging].[STG_ElectronicAddress]
    ([Name]
    ,[Description]
    ,[CreatedDate]
    ,[CreatedBy]
    ,[LastModifiedDate]
    ,[LastModifiedBy]
    ,[ArchivedInd]
    ,[InformationSourceID]
    ,[SourceChangeDate]
    ,[Address]
    ,[PrimaryInd]
    ,[UsedInCommunicationInd]
    ,[ParsedInd]
    ,[ParsedScore]
    ,[IndividualID]
    ,[CustomerID]
    ,[AddressTypeID]
    ,[ParsedAddress]
    ,[HashedAddress])
	VALUES
    ('Test customer'
    ,'Test'
    ,GETDATE()
    ,99999
    ,GETDATE()
    ,99999
    ,0
    ,1
    ,GETDATE()
    ,'999999999'
    ,1
    ,1
    ,1
    ,1
    ,NULL
    ,@NewCustomerID 
    ,4
    ,'999999999'
    ,NULL)

	IF @@ROWCOUNT = 0
	BEGIN
		ROLLBACK TRAN @Transaction
		SET @ErrMsg = 'Unable to insert test customer phone number' ;
		THROW 90508, @ErrMsg,1
	END

	--Insert test customer's address
	INSERT INTO [Staging].[STG_Address]
    ([Name]
    ,[Description]
    ,[CreatedDate]
    ,[CreatedBy]
    ,[LastModifiedDate]
    ,[LastModifiedBy]
    ,[ArchivedInd]
    ,[InformationSourceID]
    ,[SourceCreatedDate]
    ,[SourceModifiedDate]
    ,[AddressLine1]
    ,[AddressLine2]
    ,[AddressLine3]
    ,[AddressLine4]
    ,[AddressLine5]
    ,[TownCity]
    ,[County]
    ,[PostalCode]
    ,[CountryID]
    ,[PrimaryInd]
    ,[AddressTypeID]
    ,[IndividualID]
    ,[CustomerID]
    ,[AddresseeInAddressInd]
    ,[IsShortAddressInd])
     VALUES
    ('Test customer'
    ,'Test customer address'
    ,GETDATE()
    ,99999
    ,GETDATE()
    ,99999
    ,0
    ,1
    ,GETDATE()
    ,GETDATE()
    ,'Test_AddressLine_1'
    ,'Test_AddressLine_2'
    ,'Test_AddressLine_3'
    ,'Test_AddressLine_4'
    ,'Test_AddressLine_5'
    ,'Test_City'
    ,'Test_County'
    ,'Test_PC'
    ,163
    ,1
    ,2
    ,NULL
    ,@NewCustomerID 
    ,0
    ,0)

	IF @@ROWCOUNT = 0
	BEGIN
		ROLLBACK TRAN @Transaction
		SET @ErrMsg = 'Unable to insert test customer address' ;
		THROW 90508, @ErrMsg,1
	END

	--Insert KeyMapping
	INSERT INTO [Staging].[STG_KeyMapping]
    ([Description]
    ,[CreatedDate]
    ,[CreatedBy]
    ,[LastModifiedDate]
    ,[LastModifiedBy]
    ,[CustomerID]
    ,[IndividualID]
    ,[InformationSourceID])
     VALUES
    ('Test customer'
    ,GETDATE()
    ,99999
    ,GETDATE()
    ,99999
    ,@NewCustomerID 
    ,NULL
    ,1)

	IF @@ROWCOUNT = 0
	BEGIN
		ROLLBACK TRAN @Transaction
		SET @ErrMsg = 'Unable to insert test customer keymapping' ;
		THROW 90508, @ErrMsg,1
	END

	COMMIT TRAN @Transaction
	RETURN @@ROWCOUNT