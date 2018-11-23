  
 CREATE PROCEDURE [api_competition].[addCompetition] 
  @userid           int,
  -- Search criteria ---------------------
  @Name             varchar(50)  = NULL,
  @Description      varchar(500) = NULL,
  @CreateDate       datetime     = NULL,
  @StartDate        datetime     = NULL,
  @EndDate          datetime     = NULL,
  @CompetitionID    varchar(255) OUTPUT
  ----------------------------------------

  AS 

    set nocount on;

    RETURN 1;