USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_ContactHistory_Final]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_ContactHistory_Final](
	[ID] [varchar](512) NULL,
	[InsertDate] [varchar](512) NULL,
	[CampaignName] [varchar](512) NULL,
	[CampaignGroupName] [varchar](512) NULL,
	[CTIRecipientID] [varchar](512) NULL,
	[Email] [varchar](512) NULL,
	[c2tier] [varchar](512) NULL,
	[c2TierDesc] [varchar](512) NULL,
	[AvailablePoints] [varchar](512) NULL,
	[LoyaltyMember] [varchar](512) NULL,
	[Segment] [varchar](512) NULL,
	[ControlCell] [varchar](512) NULL,
	[PendingPoints] [varchar](512) NULL,
	[HomeStation] [varchar](512) NULL,
	[ECHomeStation] [varchar](512) NULL,
	[PostCode] [varchar](512) NULL,
	[SubSegment] [varchar](512) NULL,
	[Voucher] [varchar](512) NULL,
	[VoucherExpiry] [varchar](512) NULL,
	[VoucherID] [varchar](512) NULL,
	[VoucherValue] [varchar](512) NULL,
	[PostcodeRegion] [varchar](512) NULL,
	[ECMLRegion] [varchar](512) NULL,
	[Miscellaneous] [varchar](512) NULL,
	[OrderID] [varchar](512) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_ContactHistory_Final_CampaignGroupName]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_ContactHistory_Final_CampaignGroupName] ON [Migration].[Zeta_ContactHistory_Final]
(
	[CampaignGroupName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_ContactHistory_FinalCampaignName]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_ContactHistory_FinalCampaignName] ON [Migration].[Zeta_ContactHistory_Final]
(
	[CampaignName] ASC
)
INCLUDE ( 	[CampaignGroupName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
