USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_CampaignResponse_Final]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_CampaignResponse_Final](
	[ActivityID] [varchar](512) NULL,
	[ActionDate] [varchar](512) NULL,
	[ActivityTypeID] [varchar](512) NULL,
	[OrderID] [varchar](512) NULL,
	[CTIRecipientID] [varchar](512) NULL
) ON [PRIMARY]

GO
