  CREATE PROCEDURE [api_customer_competition].[addCustomerAnswer] 
      @userid         int,
    -- Search criteria ---------------------
      @encryptedEmail varchar(255),
      @competitionID  varchar(255),
      @QuestionID     varchar(255),
      @Answer         varchar(512)
    AS 

      set nocount on;
      
      return 1;