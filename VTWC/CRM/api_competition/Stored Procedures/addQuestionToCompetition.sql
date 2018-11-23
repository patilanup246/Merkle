  
 CREATE PROCEDURE [api_competition].[addQuestionToCompetition] 
  @userid           int,
  -- Search criteria ---------------------
  @CompetitionID    varchar(50)   = NULL,
  @QuestionText     varchar(2048) = NULL,
  @QuestionID       varchar(255) OUTPUT


  AS 

    set nocount on;

    RETURN 1;