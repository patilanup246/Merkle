USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_ContactHistory]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_ContactHistory](
	[CampaignHistoryID] [nvarchar](256) NOT NULL,
	[InsertDate] [nvarchar](256) NOT NULL,
	[CampaignName] [nvarchar](256) NOT NULL,
	[CampaignGroupName] [nvarchar](256) NOT NULL,
	[CTIRecipientID] [nvarchar](256) NOT NULL,
	[Email] [nvarchar](512) NULL,
	[c2tier] [nvarchar](256) NULL,
	[c2TierDesc] [nvarchar](256) NULL,
	[AvailablePoints] [nvarchar](256) NULL,
	[LoyaltyMember] [nvarchar](256) NULL,
	[Segment] [nvarchar](256) NULL,
	[ControlCell] [nvarchar](256) NULL,
	[PendingPoints] [nvarchar](256) NULL,
	[HomeStation] [nvarchar](256) NULL,
	[ECHomeStation] [nvarchar](256) NULL,
	[PostCode] [nvarchar](256) NULL,
	[SubSegment] [nvarchar](256) NULL,
	[Voucher] [nvarchar](256) NULL,
	[VoucherExpiry] [nvarchar](256) NULL,
	[VoucherID] [nvarchar](256) NULL,
	[VoucherValue] [nvarchar](256) NULL,
	[PostcodeRegion] [nvarchar](256) NULL,
	[ECMLRegion] [nvarchar](256) NULL,
	[Miscellaneous] [nvarchar](256) NULL,
	[OrderID] [nvarchar](256) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_ContactHistory_CampaignName]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_ContactHistory_CampaignName] ON [Migration].[Zeta_ContactHistory]
(
	[CampaignName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_ContactHistory_CTIRecipientID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_ContactHistory_CTIRecipientID] ON [Migration].[Zeta_ContactHistory]
(
	[CTIRecipientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_ContactHistory_OrderID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_ContactHistory_OrderID] ON [Migration].[Zeta_ContactHistory]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
