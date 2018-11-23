
  CREATE PROCEDURE [api_customer].[setProspectCustomer]
     @userid int,
     @EncryptedEmail varchar(512),
     @FormID varchar(256),
     @FormName varchar(256),
     @Email varchar(256),
     @Salutation varchar(256),
     @FirstName varchar(256),
     @Surname varchar(256)

  AS 
    set nocount on;
    
    DECLARE @ErrMsg varchar(256)

    IF EXISTS ( SELECT CAST(1 AS BIT)
                  FROM PreProcessing.ProspectCustomer
                 WHERE ProspectEmail = @Email
				   AND FormID = @FormID)
      BEGIN
		UPDATE PreProcessing.ProspectCustomer
		   SET ArchivedInd = 1,
		       LastModifiedDate = GETDATE(),
			   LastModifiedBy = @userid
		 WHERE ProspectEmail = @Email
		   AND FormID = @FormID
      END        

    INSERT INTO PreProcessing.ProspectCustomer
        (ProspectEmail ,
         FormID ,
         FormName ,
         Salutation ,
         FirstName ,
         Surname ,
         CreatedDate,
         CreatedBy ,
         LastModifiedDate ,
         LastModifiedBy)
        VALUES
        (@Email,
         @FormID,
         @FormName,
         @Salutation,
         @FirstName,
         @Surname,
         GETDATE(),
         @userid,
         GETDATE(),
         @userid)

  RETURN @@ROWCOUNT;