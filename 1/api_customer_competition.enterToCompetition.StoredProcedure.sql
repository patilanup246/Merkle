USE [CEM]
GO
/****** Object:  StoredProcedure [api_customer_competition].[enterToCompetition]    Script Date: 24/07/2018 14:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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

GO
