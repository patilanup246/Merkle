  CREATE VIEW [api_customer_loyalty].[LoyaltyHistory] AS
    SELECT cla.CustomerID            AS CustomerID,
           lal.LoyaltyAllocationID   AS LoyaltyActivityID,
           lal.SalesTransactionDate  AS ActivityDate,
           lp.DisplayName            AS Program,
           lal.Description           AS Description,
           COALESCE(lal.QualifyingSalesAmount,0) AS Spend,
           COALESCE(lal.LoyaltyCurrencyAmount,0) AS Amount,
           ls.Name                   AS Status,
           ls.Description            AS Reason,
           COALESCE(CAST(ROUND(COALESCE(lal.LoyaltyXChangeRateID, lal.LoyaltyCurrencyAmount/ lal.QualifyingSalesAmount), 0) AS INT),0) AS Rate
      FROM Staging.STG_CustomerLoyaltyAccount cla  LEFT JOIN Staging.STG_LoyaltyAccount lan 
        ON lan.LoyaltyAccountID = cla.CustomerLoyaltyAccountID  INNER JOIN Reference.LoyaltyProgrammeType lp 
        ON lp.LoyaltyProgrammeTypeID = lan.LoyaltyProgrammeTypeID INNER JOIN Staging.STG_LoyaltyAllocation lal
        ON lal.LoyaltyAccountID = lan.LoyaltyAccountID INNER JOIN Reference.LoyaltyStatus ls
        ON ls.LoyaltyStatusID = lal.LoyaltyStatusID;