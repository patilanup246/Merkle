USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_Customer]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_Customer](
	[MSDID] [varchar](512) NULL,
	[BestTimeToCall] [varchar](512) NULL,
	[MobileTelephoneNo] [varchar](512) NULL,
	[BillingAddressLine1] [varchar](512) NULL,
	[BillingAddressLine2] [varchar](512) NULL,
	[BillingAddressLine3] [varchar](512) NULL,
	[BillingAddressLine4] [varchar](512) NULL,
	[BillingAddressLine5] [varchar](512) NULL,
	[BillingTown] [varchar](512) NULL,
	[BillingCounty] [varchar](512) NULL,
	[BillingCountry] [varchar](512) NULL,
	[ContactType] [varchar](512) NULL,
	[DateCreated] [varchar](512) NULL,
	[Notes] [varchar](512) NULL,
	[ContactEmail] [varchar](512) NULL,
	[WebTISID] [varchar](512) NULL,
	[ContactFirstName] [varchar](512) NULL,
	[HomePhone] [varchar](512) NULL,
	[LastActivityDate] [varchar](512) NULL,
	[ContactLastName] [varchar](512) NULL,
	[ModifiedBy] [varchar](512) NULL,
	[ModifiedDate] [varchar](512) NULL,
	[Contactable] [varchar](512) NULL,
	[RewardsOptinAtClosure] [varchar](512) NULL,
	[WorkPhone] [varchar](512) NULL,
	[Caution] [varchar](512) NULL,
	[UserStatus] [varchar](512) NULL,
	[dGNER_Marketing_Date_of_Optin] [varchar](512) NULL,
	[dGNER_and_third_party_Date_of_Optin] [varchar](512) NULL,
	[dDate_of_First_Purchase] [varchar](512) NULL,
	[iNumber_of_logins_before_first_purchase] [varchar](512) NULL,
	[Internal_Referrers] [varchar](512) NULL,
	[External_Referrers] [varchar](512) NULL,
	[Marketing_Source_of_Optin] [varchar](512) NULL,
	[Marketing_and_third_party_Source_of_OptIn] [varchar](512) NULL,
	[Title] [varchar](512) NULL,
	[xpiryDate] [varchar](512) NULL,
	[LoyaltyExpiryDate] [varchar](512) NULL,
	[wWebTIS_Customer_Link] [varchar](512) NULL,
	[Segment] [varchar](512) NULL,
	[Research_Opt_In] [varchar](512) NULL,
	[Customer_Status] [varchar](512) NULL,
	[LoyaltyMember] [varchar](512) NULL,
	[LoyaltyPrivilege] [varchar](512) NULL,
	[Loyalty365Member] [varchar](512) NULL,
	[PhotoCardID] [varchar](512) NULL,
	[OwnerAlias] [varchar](512) NULL,
	[DateOfBirth] [varchar](512) NULL,
	[SegmentSiebel] [varchar](512) NULL,
	[CurrencyCode] [varchar](512) NULL,
	[CustomerId] [varchar](512) NULL,
	[ManagerIntegrationId] [varchar](512) NULL,
	[CreatedByUserSignInId] [varchar](512) NULL,
	[ModifiedByUserSignInId] [varchar](512) NULL,
	[ThirdPartyOptOut] [varchar](512) NULL,
	[GNERMarketingOptInDate] [varchar](512) NULL,
	[GNER3rdPartyOfferOptInDate] [varchar](512) NULL,
	[SeasonTicketHolder] [varchar](512) NULL,
	[CustomerType] [varchar](512) NULL,
	[ZetaCustomerID] [varchar](512) NULL,
	[Source] [varchar](512) NULL,
	[SourceObject] [varchar](512) NULL,
	[Dest3GETLID] [varchar](512) NULL,
	[LastPostCode] [varchar](512) NULL,
	[LastCounty] [varchar](512) NULL,
	[AvailablePoints] [varchar](512) NULL,
	[ExpiredPoints] [varchar](512) NULL,
	[PendingPoints] [varchar](512) NULL,
	[LastRedemptionDate] [varchar](512) NULL,
	[LastRedemptionProduct] [varchar](512) NULL,
	[TotalPurchaseValue] [varchar](512) NULL,
	[AveragePurchaseValue] [varchar](512) NULL,
	[LastPurchaseDate] [varchar](512) NULL,
	[TotalJourneys] [varchar](512) NULL,
	[AverageJourneysPerBasket] [varchar](512) NULL,
	[LastAccruedPointsDate] [varchar](512) NULL,
	[LastAccruedPoints] [varchar](512) NULL,
	[HasUsedRailCard] [varchar](512) NULL,
	[LastEVoucherConsumed] [varchar](512) NULL,
	[EVoucherTotalToDate] [varchar](512) NULL,
	[TotalCO2] [varchar](512) NULL,
	[TotalAdults] [varchar](512) NULL,
	[TotalChildren] [varchar](512) NULL,
	[TotalBaskets] [varchar](512) NULL,
	[AverageAdultsPerBasket] [varchar](512) NULL,
	[AverageChildPerBasket] [varchar](512) NULL,
	[DateOfNextPointExpiry] [varchar](512) NULL,
	[FailedFraudRulesCount] [varchar](512) NULL,
	[LastFailedFraudRulesDate] [varchar](512) NULL,
	[NextTravelDate] [varchar](512) NULL,
	[NextReturnDate] [varchar](512) NULL,
	[LastTravelDate] [varchar](512) NULL,
	[LastReturnDate] [varchar](512) NULL,
	[WebTISCreated] [varchar](512) NULL,
	[Last1stClassTicket] [varchar](512) NULL,
	[NoOf1stClassTickets] [varchar](512) NULL,
	[NoOfStdClassTickets] [varchar](512) NULL,
	[LastWeekendTravelDate] [varchar](512) NULL,
	[LastWeekdayTravelDate] [varchar](512) NULL,
	[NearestEastCoastStation] [varchar](512) NULL,
	[NearestStation] [varchar](512) NULL,
	[YearOfBirth] [varchar](512) NULL,
	[ReasonForMajorityTravel] [varchar](512) NULL,
	[Children] [varchar](512) NULL,
	[RecipientType] [varchar](512) NULL,
	[OldRewardsLoyaltyMember] [varchar](512) NULL,
	[KnownStaffMember] [varchar](512) NULL,
	[HomeStation] [varchar](512) NULL,
	[TierNumber] [varchar](512) NULL,
	[TierName] [varchar](512) NULL,
	[c2Bounced] [varchar](512) NULL,
	[LastBilledCountry] [varchar](512) NULL,
	[LastAlloctedSTPointsDate] [varchar](512) NULL,
	[IsStaff] [varchar](512) NULL,
	[ReasonForTravelBusinessBooker] [varchar](512) NULL,
	[ReasonForTravelBusinessBookerEver] [varchar](512) NULL,
	[ReasonForTravelBusinessMajorityLast6Months] [varchar](512) NULL,
	[IsCorp] [varchar](512) NULL,
	[IsTMC] [varchar](512) NULL,
	[PointsExpiringIn30Days] [varchar](512) NULL,
	[Corp_OptOut] [varchar](512) NULL,
	[hasBTA] [varchar](512) NULL,
	[hasSTH] [varchar](512) NULL,
	[ProspectConversionStamp] [varchar](512) NULL,
	[DynamicsCRMOptedIn] [varchar](512) NULL,
	[InactiveStamp] [varchar](512) NULL,
	[CRMMasterQueueID] [varchar](512) NULL,
	[CRMOptedInLastUpdateFromMasterQ] [varchar](512) NULL,
	[IsNectar] [varchar](512) NULL,
	[IsFlyingClub] [varchar](512) NULL,
	[HasBeenNectar] [varchar](512) NULL,
	[HasBeenFlyingClub] [varchar](512) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_Customer_MSDID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_Customer_MSDID] ON [Migration].[Zeta_Customer]
(
	[MSDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_Customer_ZetaCustomerID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_Customer_ZetaCustomerID] ON [Migration].[Zeta_Customer]
(
	[ZetaCustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ZetaCustomer_IX_Email]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ZetaCustomer_IX_Email] ON [Migration].[Zeta_Customer]
(
	[ContactEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
