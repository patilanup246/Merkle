USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_SolicitationHistory_Final]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_SolicitationHistory_Final](
	[SolicitationHistoryRecipientID] [varchar](512) NULL,
	[CTIRecipientID] [varchar](512) NULL,
	[CTIOrderID] [varchar](512) NULL,
	[CTIEventID] [varchar](512) NULL,
	[SendDate] [varchar](512) NULL
) ON [PRIMARY]

GO
