USE [CEM]
GO
/****** Object:  StoredProcedure [api_competition].[addQuestionToCompetition]    Script Date: 24/07/2018 14:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
 CREATE PROCEDURE [api_competition].[addQuestionToCompetition] 
  @userid           int,
  -- Search criteria ---------------------
  @CompetitionID    varchar(50)   = NULL,
  @QuestionText     varchar(2048) = NULL,
  @QuestionID       varchar(255) OUTPUT


  AS 

    set nocount on;

    RETURN 1;   


GO
