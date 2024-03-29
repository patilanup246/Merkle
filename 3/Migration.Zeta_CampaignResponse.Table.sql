USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_CampaignResponse]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_CampaignResponse](
	[ActivityID] [nvarchar](256) NOT NULL,
	[ActionDate] [nvarchar](256) NOT NULL,
	[ActivityTypeID] [nvarchar](256) NOT NULL,
	[OrderID] [nvarchar](256) NOT NULL,
	[CTIRecipientID] [nvarchar](256) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_CampaignResponse_CTIRecipientID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_CampaignResponse_CTIRecipientID] ON [Migration].[Zeta_CampaignResponse]
(
	[CTIRecipientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_CampaignResponse_OrderID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_CampaignResponse_OrderID] ON [Migration].[Zeta_CampaignResponse]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
