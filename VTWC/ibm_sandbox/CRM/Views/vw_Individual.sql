CREATE VIEW [CRM].[vw_Individual] AS
select 1 res
/*
    SELECT a.[IndividualID] 

          ,g.[InformationSourceID] 

          ,g.[Name]                   AS [InformationSource] 

          --,a.[CustomerTypeID] 
          --,c.[Name]                   AS [CustomerType] 

          --,a.[SegmentTierID] 
          --,d.[Name]                   AS [SegmentTier] 

		  ,a.[RFV]
		  ,a.[RFVsegmentRecency]													as [RFV_Recency]
		  ,a.[RFVsegmentValue]														as [RFV_Value]
		  ,a.[RFVsegmentFrequency]													as [RFV_Frequency]

          ,a.[LocationIDHomeActual]
          ,e.[CRSCode]                AS [CVIHomeStation] 

          ,a.[LocationIDHomeInferred] 
          ,f.[CRSCode]                AS [InferredHomeStation] 

		  ,h.LocationID [LocationIDNearest],	
		  j.CRSCode [NearestStation]

		  ,COALESCE(e.CRSCode,f.CRSCode,j.CRSCode)   AS [HomeStation]

          ,a.[ValidEmailInd] 

          ,a.[ValidMobileInd] 

          ,a.[OptInLeisureInd] 

          ,a.[OptInCorporateInd] 

          ,a.[CountryID] 
          ,b.[Name]                   AS [Country] 

          ,case when m.IndividualID is not null then 1 else a.[IsFallowCellInd] end AS [IsFallowCellInd] 

          ,a.[IsOrganisationInd] 

          ,case when a.EmailAddress like '%virgintrains.co.uk' then 1 else a.[IsStaffInd] end AS [IsStaffInd]  -- virgintrains.co.uk email address - should fixed up in Refresh?

          ,case when ISNULL(k.CustomerID, k.EmailAddress) is not null then 1 else a.[IsBlackListInd] end AS [IsBlackListInd] 

          ,a.[IsCorporateInd] 

          ,case when l.EmailAddress is not null then 1 else a.[IsTMCInd] end AS [IsTMCInd] 

          ,a.[RailCardUserInd] 

          ,a.[eVoucherUserInd] 

          ,a.[Salutation] [Title]

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

  LEFT JOIN [$(CRMDB)].[Reference].[Location] e ON e.LocationID = a.LocationIDHomeActual 

  LEFT JOIN [$(CRMDB)].[Reference].[Location] f ON f.LocationID = a.LocationIDHomeInferred 

  LEFT JOIN [$(CRMDB)].[Reference].[InformationSource] g ON g.InformationSourceID = a.InformationSourceID 

  LEFT JOIN [$(CRMDB)].[Reference].LocationPostCodeLookUp h on h.PostCodeDistrict=a.PostalDistrict
  LEFT JOIN [$(CRMDB)].[Reference].[Location]   j with (nolock) ON j.LocationID = h.LocationID

  LEFT JOIN [CRM].[Blacklist] k with(nolock) on  k.IndividualID = a.IndividualID 
											 or (k.EmailAddress=a.EmailAddress and a.ValidEmailInd=1)
											 or (k.MobileTelephoneNo=a.MobileNumber and a.ValidMobileInd=1)

  LEFT JOIN [CRM].[CorporatesTMC_Flag] l with(nolock) on (l.EmailAddress=a.EmailAddress and a.ValidEmailInd=1)

  LEFT JOIN [CRM].[crm_fallow_group]                   m with (nolock) on m.IndividualID=a.IndividualID and getdate() between m.date_added and isnull(m.date_removed, getdate()) 

  WHERE a.ArchivedInd = 0 
*/