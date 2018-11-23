CREATE VIEW [CRM].[vw_Customer]
AS 
SELECT a.[CustomerID] 
          ,a.[IndividualID] 
          ,a.[CustomerTypeID] 
          ,g.[InformationSourceID] 
          ,g.[Name]                                                                as [InformationSource] 
          ,c.[Name]                                                                as [CustomerSubType] 
          --,a.[SegmentTierID] 
          --,d.[Name]                                                                as [SegmentTier] 

		  ,a.[RFV]
		  ,a.[RFVsegmentRecency]													as [RFV_Recency]
		  ,a.[RFVsegmentValue]														as [RFV_Value]
		  ,a.[RFVsegmentFrequency]													as [RFV_Frequency]

          ,a.[LocationIDHomeInferred] 
          ,a.[ValidEmailInd] 
          ,a.[ValidMobileInd] 
          ,a.[OptInLeisureInd]                                                     as [MSD_OptInInd] 

          --,isnull(i.Email_OptIn,a.[OptInLeisureInd])                               as [OptInLeisureInd] 
		  ,NULL as [OptInLeisureInd] /* SPF TBD */

          ,case when h.Customer_ID is not null then 1 else a.[IsFallowCellInd] end as [IsFallowCellInd] 
  
          ,a.[CountryID] 
          ,b.[Name]                                                                as [Country] 
          ,a.[IsOrganisationInd] 

          ,case when a.EmailAddress like '%virgintrains.co.uk' then 1 else a.[IsStaffInd] end as [IsStaffInd]  -- virgintrains.co.uk email address - should fixed up in Refresh?

          ,case when ISNULL(k.CustomerID, k.EmailAddress) is not null then 1 else a.[IsBlackListInd] end as [IsBlackListInd] 

          ,case when l.EmailAddress is not null then 1 else a.[IsTMCInd] end as [IsTMCInd] 

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

		  ,a.[DateOfBirth]

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
		  ,a.VTSegment
		  ,a.AccountStatus
		  ,a.RegChannel
		  ,a.RegOriginatingSystemType
		  ,a.FirstCallTranDate
		  ,a.FirstIntTranDate
		  ,a.FirstMobAppTranDate
		  ,a.FirstMobWebTranDate
		  ,a.ExperianHouseholdIncome
		  ,a.ExperianAgeBand

  FROM [$(CRMDB)].[Production].[Customer]              a with (nolock)  
  LEFT JOIN [$(CRMDB)].[Reference].[Country]           b with (nolock) ON b.CountryID = a.CountryID  
  LEFT JOIN [$(CRMDB)].[Reference].[CustomerType]      c with (nolock) ON c.CustomerTypeID = a.CustomerTypeID 
  LEFT JOIN [$(CRMDB)].[Reference].[SegmentTier]       d with (nolock) ON d.SegmentTierID = a.SegmentTierID 

 --LEFT JOIN [CEM].[Reference].[Location]          f with (nolock) ON f.LocationID = a.LocationIDHomeInferred 
--LEFT JOIN emm_sandbox.CEM.vw_NearestTrainStation e ON e.LocationIDNearestStation = f.LocationID AND e.[CustomerID] = a.[CustomerID] 

  LEFT JOIN [$(CRMDB)].[Reference].[InformationSource] g with (nolock) ON g.InformationSourceID = a.InformationSourceID 
  LEFT JOIN [CRM].[CRMFallowGroup]          h with (nolock) on h.Customer_ID=a.CustomerID and getdate() between date_added and isnull(h.date_removed, getdate()) 
  
  --LEFT JOIN [CRM].[vw_Customer_ChannelPreferences]i with (nolock) on a.CustomerID = i.CustomerID 

  LEFT JOIN [CRM].[Blacklist] k with(nolock) on  k.CustomerID = a.CustomerID 
											 or (k.EmailAddress=a.EmailAddress and a.ValidEmailInd=1)
											 or (k.MobileTelephoneNo=a.MobileNumber and a.ValidMobileInd=1)

  LEFT JOIN [CRM].[CorporatesTMC_Flag] l with(nolock) on (l.EmailAddress=a.EmailAddress and a.ValidEmailInd=1)

  WHERE a.ArchivedInd = 0 
