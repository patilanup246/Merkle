USE [CEM]
GO
/****** Object:  StoredProcedure [api_customer_competition].[addCustomerAnswer]    Script Date: 24/07/2018 14:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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

GO
