USE [CEM]
GO
/****** Object:  View [api_manager].[LoyaltyRate]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
  CREATE VIEW [api_manager].[LoyaltyRate] AS 
    SELECT lr.LoyaltyRateID,
           lpt.Name AS Program,
           lr.StartDate,
           lr.EndDate,
           pg.ProductGroupID,
           pg.Name AS ProductGroup,
           pg.Description,
           lr.Rate  
      FROM Staging.STG_LoyaltyRate lr
           INNER JOIN Reference.LoyaltyProgrammeType lpt ON lr.LoyaltyProgrammeTypeID = lpt.LoyaltyProgrammeTypeID
           INNER JOIN Reference.ProductGroup pg          ON pg.ProductGroupID = lr.ProductGroupID
     WHERE lr.ArchivedInd = 0
	   AND lpt.ArchivedInd = 0
	   AND pg.ArchivedInd = 0

GO
