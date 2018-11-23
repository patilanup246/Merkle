USE [CEM]
GO
/****** Object:  StoredProcedure [api_competition].[addCompetition]    Script Date: 24/07/2018 14:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
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


GO
