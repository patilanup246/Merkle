USE [CEM]
GO
/****** Object:  StoredProcedure [api_competition].[deleteCompetition]    Script Date: 24/07/2018 14:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
 CREATE PROCEDURE [api_competition].[deleteCompetition] 
    @userid int,
  -- Search criteria ---------------------
    @CompetitionID varchar(255) 

  AS 
    set nocount on;

    RETURN 1;   


GO
