  CREATE PROCEDURE [api_customer].[deleteAlert]
     @userid int,
     @EncryptedEmail varchar(256),
     @AlertID int 
  
  AS 

    set nocount on;

    DECLARE @CustomerID int
    DECLARE @IndividualID int
    DECLARE @ErrMsg varchar(512)
    DECLARE @RowCountRes int

    -- Validating that CRS Code exists.
    IF NOT EXISTS (SELECT CAST(1 AS BIT)
				   FROM Staging.STG_CustomerAlert
				   WHERE CustomerAlertID = @AlertID AND ArchivedInd = 0)
    BEGIN
	    IF NOT EXISTS (SELECT CAST(1 AS BIT)
				   FROM Staging.STG_IndividualAlert
				   WHERE IndividualAlertID = @AlertID AND ArchivedInd = 0)
		BEGIN
			SET @ErrMsg = 'Unable to find the AlertID  ('+ COALESCE(CAST(@AlertID AS VARCHAR(100)), 'NULL') +')';
			THROW 51403, @ErrMsg,1
		END   		
    END   

	IF EXISTS (SELECT CAST(1 AS BIT)
			   FROM Staging.STG_CustomerAlert
			   WHERE CustomerAlertID = @AlertID AND EncryptedEmail = @EncryptedEmail AND ArchivedInd = 0)
    BEGIN
		UPDATE Staging.STG_CustomerAlert
		SET ArchivedInd = 1,
			LastModifiedDate = GETDATE(),
			LastModifiedBy = @userid
		WHERE CustomerAlertID = @AlertID AND EncryptedEmail = @EncryptedEmail AND ArchivedInd = 0

		SET @RowCountRes = @@ROWCOUNT

		IF @RowCountRes = 0
		BEGIN
			SET @ErrMsg = 'Unable to delete AlertID  ('+ COALESCE(CAST(@AlertID AS VARCHAR(100)), 'NULL') +')';
			THROW 51403, @ErrMsg,1
		END        						
    END        
    ELSE
	BEGIN
		IF EXISTS (SELECT CAST(1 AS BIT)
				   FROM Staging.STG_IndividualAlert
				   WHERE IndividualAlertID = @AlertID AND EncryptedEmail = @EncryptedEmail AND ArchivedInd = 0)
		BEGIN
			UPDATE Staging.STG_IndividualAlert
			SET ArchivedInd = 1,
				LastModifiedDate = GETDATE(),
				LastModifiedBy = @userid
			WHERE IndividualAlertID = @AlertID AND EncryptedEmail = @EncryptedEmail AND ArchivedInd = 0

			SET @RowCountRes = @@ROWCOUNT

			IF @RowCountRes = 0
			BEGIN
				SET @ErrMsg = 'Unable to delete AlertID  ('+ COALESCE(CAST(@AlertID AS VARCHAR(100)), 'NULL') +')';
				THROW 51403, @ErrMsg,1
			END        						
		END        
		ELSE
		BEGIN
			SET @ErrMsg = 'Unable to find the Associated Email Addres for AlertID   ('+ COALESCE(CAST(@AlertID AS VARCHAR(100)), 'NULL') +')';
			THROW 51403, @ErrMsg,1	
		END	
	END
	
	RETURN @RowCountRes