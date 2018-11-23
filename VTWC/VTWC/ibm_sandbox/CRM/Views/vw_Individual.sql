CREATE VIEW [CRM].[vw_Individual] AS
    SELECT a.[IndividualID] 

          ,g.[InformationSourceID] 

          ,g.[Name]                   AS [InformationSource] 

          ,a.[CustomerTypeID] 

          ,c.[Name]                   AS [CustomerType] 

          --,a.[SegmentTierID] 
          --,d.[Name]                   AS [SegmentTier] 

		  ,a.[RFV]
		  ,a.[RFVsegmentRecency]													as [RFV_Recency]
		  ,a.[RFVsegmentValue]														as [RFV_Value]
		  ,a.[RFVsegmentFrequency]													as [RFV_Frequency]

          ,a.[LocationIDHomeActual] 

          ,e.[CRSCode]                AS [HomeStationActual] 

          ,a.[LocationIDHomeInferred] 

          ,e.[CRSCode]                AS [HomeStationInferred] 

          ,a.[ValidEmailInd] 

          ,a.[ValidMobileInd] 

          ,a.[OptInLeisureInd] 


          ,a.[OptInCorporateInd] 
          ,a.[CountryID] 

          ,b.[Name]                   AS [Country] 

          ,a.[IsOrganisationInd] 

          ,a.[IsStaffInd] 

          ,a.[IsBlackListInd] 

          ,a.[IsCorporateInd] 

          ,a.[IsTMCInd] 

          ,a.[RailCardUserInd] 

          ,a.[eVoucherUserInd] 

          ,a.[Salutation] 

          ,a.[FirstName] 

          ,a.[MiddleName] 

          ,a.[LastName] 

          ,a.[EmailAddress] 

          ,a.[MobileNumber] 

          ,a.[PostalArea] 

          ,a.[PostalDistrict] 

          ,a.[DateRegistered] 

          ,a.[DateFirstPurchaseAny] 

          ,a.[DateLastPurchaseAny] 

          ,a.[DateFirstPurchaseFirst] 

          ,a.[DateLastPurchaseFirst] 

          ,a.[DateFirstTravelAny] 

          ,a.[DateLastTravelAny] 

          ,a.[DateNextTravelAny] 

          ,a.[DateFirstTravelFirst] 

          ,a.[DateLastTravelFirst] 

          ,a.[DateNextTravelFirst] 

          ,a.[SalesAmountTotal] 

          ,a.[SalesAmount3Mnth] 

          ,a.[SalesAmount6Mnth] 

          ,a.[SalesAmount12Mnth] 

          ,a.[SalesAmountRailTotal] 

          ,a.[SalesAmountRail3Mnth] 

          ,a.[SalesAmountRail6Mnth] 

          ,a.[SalesAmountRail12Mnth] 

          ,a.[SalesAmountNotRailTotal] 

          ,a.[SalesAmountNotRail3Mnth] 

          ,a.[SalesAmountNotRail6Mnth] 

          ,a.[SalesAmountNotRail12Mnth] 

          ,a.[SalesTransactionTotal] 

          ,a.[SalesTransaction3Mnth] 

          ,a.[SalesTransaction6Mnth] 

          ,a.[SalesTransaction12Mnth] 

  FROM  [$(CRMDB)].[Production].[Individual] a with(NOLOCK) 

  LEFT JOIN [$(CRMDB)].[Reference].[Country] b ON b.CountryID = a.CountryID 

  LEFT JOIN [$(CRMDB)].[Reference].[CustomerType] c ON c.CustomerTypeID = a.CustomerTypeID 

  LEFT JOIN [$(CRMDB)].[Reference].[SegmentTier] d ON d.SegmentTierID = a.SegmentTierID 

  LEFT JOIN [$(CRMDB)].[Reference].[Location] e ON e.LocationID = a.LocationIDHomeActual 

  LEFT JOIN [$(CRMDB)].[Reference].[Location] f ON f.LocationID = a.LocationIDHomeInferred 

  LEFT JOIN [$(CRMDB)].[Reference].[InformationSource] g ON g.InformationSourceID = a.InformationSourceID 

  WHERE a.ArchivedInd = 0 
