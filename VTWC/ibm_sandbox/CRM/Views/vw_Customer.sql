CREATE VIEW [CRM].[vw_Customer]
AS 
SELECT a.[CustomerID] 
          ,a.[IndividualID] 
          ,g.[InformationSourceID] 
          ,g.[Name]                                                                AS [InformationSource] 

		  ,a.[RFV]
		  ,a.[RFVsegmentRecency]													AS [RFV_Recency]
		  ,a.[RFVsegmentValue]														AS [RFV_Value]
		  ,a.[RFVsegmentFrequency]													AS [RFV_Frequency]

          ,a.[LocationIDHomeActual],			l1.CRSCode [CVIHomeStation]
		  ,a.[LocationIDHomeInferred],			l2.CRSCode [InferredHomeStation]
		  ,e.LocationID [LocationIDNearest],	l3.CRSCode [NearestStation]
		  ,COALESCE(l1.CRSCode,l3.CRSCode,l2.CRSCode)   AS [HomeStation]
		  		  		  
          ,a.[ValidEmailInd] 
          ,a.[ValidMobileInd] 

		  ,a.[OptInLeisureInd]
		  ,a.[OptInCorporateInd]

          ,case when h.Customer_ID is not null then 1 else a.[IsFallowCellInd] end AS [IsFallowCellInd] 
  
          ,a.[CountryID] 
          ,b.[Name]                                                                AS [Country] 
          ,a.[IsOrganisationInd] 

          ,case when a.EmailAddress like '%virgintrains.co.uk' then 1 else a.[IsStaffInd] end AS [IsStaffInd]  -- virgintrains.co.uk email address - should fixed up in Refresh?

          ,case when ISNULL(k.CustomerID, k.EmailAddress) is not null then 1 else a.[IsBlackListInd] end AS [IsBlackListInd] 

          ,case when l.EmailAddress is not null then 1 else a.[IsTMCInd] end AS [IsTMCInd] 

          ,a.[RailCardUserInd] 
          ,a.[eVoucherUserInd] 

          ,a.[Salutation] [Title]
          ,a.[FirstName] 
          ,a.[LastName] 

          ,a.[EmailAddress] 
          ,a.[MobileNumber] 
          ,a.[PostalArea] 
          ,a.[PostalDistrict] 

		  ,a.[DateOfBirth]
		  ,DATEDIFF(year,[DateOfBirth],getdate()) [Age]

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
          ,a.[SalesTransaction1Mnth]
          ,a.[SalesTransaction3Mnth]
          ,a.[SalesTransaction6Mnth]
          ,a.[SalesTransaction12Mnth]
          ,a.[SalesTransaction24Mnth]
          ,a.[SalesTransaction36Mnth]
		  ,a.VTSegment [VTSegmentID]
		  ,t.Name [VTSegment]
		  ,a.AccountStatus
		  ,a.RegChannel
		  ,a.RegOriginatingSystemType
		  ,a.FirstCallTranDate
		  ,a.FirstIntTranDate
		  ,a.FirstMobAppTranDate
		  ,a.FirstMobWebTranDate
		  ,a.ExperianHouseholdIncome
		  ,a.ExperianAgeBand
		  ,u.EncryptedAddress

  FROM [$(CRMDB)].[Production].[Customer]              a with (nolock)  
  LEFT JOIN [$(CRMDB)].[Reference].[Country]           b with (nolock) ON b.CountryID = a.CountryID  

  LEFT JOIN [$(CRMDB)].[Reference].[InformationSource] g with (nolock) ON g.InformationSourceID = a.InformationSourceID 
  LEFT JOIN [CRM].[crm_fallow_group]                   h with (nolock) on h.Customer_ID=a.CustomerID and getdate() between date_added and isnull(h.date_removed, getdate()) 
  
  --LEFT JOIN [CRM].[vw_Customer_ChannelPreferences]i with (nolock) on a.CustomerID = i.CustomerID 

  LEFT JOIN [CRM].[Blacklist] k with(nolock) on  k.CustomerID = a.CustomerID 
											 or (k.EmailAddress=a.EmailAddress and a.ValidEmailInd=1)
											 or (k.MobileTelephoneNo=a.MobileNumber and a.ValidMobileInd=1)

  LEFT JOIN [CRM].[CorporatesTMC_Flag] l with(nolock) on (l.EmailAddress=a.EmailAddress and a.ValidEmailInd=1)

  LEFT JOIN [$(CRMDB)].[Reference].[SegmentTier] t with(nolock) on t.SegmentTierID=a.VTSegment

  LEFT JOIN [$(CRMDB)].[Reference].LocationPostCodeLookUp e on e.PostCodeDistrict=a.PostalDistrict
  LEFT JOIN [$(CRMDB)].[Reference].[Location]   l1 with (nolock) ON l1.LocationID = a.LocationIDHomeActual
  LEFT JOIN [$(CRMDB)].[Reference].[Location]   l2 with (nolock) ON l2.LocationID = a.LocationIDHomeInferred
  LEFT JOIN [$(CRMDB)].[Reference].[Location]   l3 with (nolock) ON l3.LocationID = e.LocationID

  left join [$(CRMDB)].[Staging].[STG_ElectronicAddress] u on u.customerid=a.customerid and u.addresstypeid=3 and u.primaryInd=1

  WHERE a.ArchivedInd = 0 
