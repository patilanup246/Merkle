  CREATE PROCEDURE [api_customer_competition].[enterToCompetition] 
     @userid           int,
  -- Search criteria ---------------------
     @encryptedEmail   varchar(255),
     @competitionID    int,
     @registrationDate datetime,
     @startDate        datetime,
     @endDate          datetime,
     @status           varchar(50)
  ----------------------------------------

  AS 

    set nocount on;
    
    return 1;