CREATE VIEW [api_customer].[LoyaltyHistory] AS
SELECT km.CustomerID                         AS CustomerID
      ,ea.[HashedAddress]                   AS EncryptedEmail
      ,km.TCSCustomerID                      AS TCSCustomerID
	  ,en.SalesTransactionID                 AS LoyaltyActivityID  --Change: la.LoyaltyAllocationID
	  ,en.SalesTransactionDate               AS ActivityDate
	  ,en.ProgrammeName                      AS Program
	  ,en.Description                        AS Description
      ,en.Spend                              AS Spend
      ,en.Amount                             AS Amount
      ,en.Name                               AS Status
      ,en.Description                        AS Reason
      ,en.Rate                               AS Rate
      ,en.CardNumber                         AS CardNumber
FROM Staging.STG_KeyMapping km WITH (NOLOCK)
INNER JOIN Staging.STG_SalesTransaction   st  WITH (NOLOCK) ON km.CustomerID             = st.CustomerID
INNER JOIN (SELECT la.SalesTransactionID                      AS SalesTransactionID
                  ,la.SalesTransactionDate                    AS SalesTransactionDate
				  ,(LEFT(lat.LoyaltyReference, 4) + ' **** ' + RIGHT(lat.LoyaltyReference, 3)) AS CardNumber
                  ,lp.ProgrammeName                           AS ProgrammeName
                  ,ls.Name                                    AS Name
                  ,la.Description                             AS Description
				  ,COALESCE(CAST(ROUND(COALESCE(la.LoyaltyXChangeRateID, la.LoyaltyCurrencyAmount/ la.QualifyingSalesAmount), 0) AS INT),0) AS Rate
                  ,SUM(COALESCE(la.QualifyingSalesAmount,0))  AS Spend
                  ,SUM(COALESCE(la.LoyaltyCurrencyAmount,0))  AS Amount
                  FROM Staging.STG_LoyaltyAllocation  la WITH (NOLOCK)
                  INNER JOIN Staging.STG_LoyaltyAccount     lat WITH (NOLOCK) ON lat.LoyaltyAccountID      = la.LoyaltyAccountID
                  INNER JOIN Reference.LoyaltyStatus        ls  WITH (NOLOCK) ON ls.LoyaltyStatusID        = la.LoyaltyStatusID
                  INNER JOIN Reference.LoyaltyProgrammeType lp  WITH (NOLOCK) ON lp.LoyaltyProgrammeTypeID = lat.LoyaltyProgrammeTypeID
				  WHERE lat.ArchivedInd = 0
				  AND   la.ArchivedInd  = 0
				  GROUP BY la.SalesTransactionID
				          ,la.SalesTransactionDate
						  ,(LEFT(lat.LoyaltyReference, 4) + ' **** ' + RIGHT(lat.LoyaltyReference, 3))
				          ,lp.ProgrammeName
                          ,ls.Name
                          ,la.Description
						  ,COALESCE(CAST(ROUND(COALESCE(la.LoyaltyXChangeRateID, la.LoyaltyCurrencyAmount/ la.QualifyingSalesAmount), 0) AS INT),0)
						  ) en ON en.SalesTransactionID = st.SalesTransactionID
INNER JOIN Staging.STG_ElectronicAddress  ea  WITH (NOLOCK) ON km.CustomerID            = ea.CustomerID
                                                              AND ea.AddressTypeID       = 3
															  AND ea.PrimaryInd = 1

WHERE ea.ArchivedInd = 0