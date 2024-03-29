USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_SolicitationHistory]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_SolicitationHistory](
	[SolicitationHistoryID] [nvarchar](256) NULL,
	[CTIRecipientID] [nvarchar](256) NULL,
	[CTIOrderID] [nvarchar](256) NULL,
	[CTIEventID] [nvarchar](512) NULL,
	[SendDate] [nvarchar](256) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_SolicitationHistory_CTIOrderID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_SolicitationHistory_CTIOrderID] ON [Migration].[Zeta_SolicitationHistory]
(
	[CTIOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_SolicitationHistory_CTIRecipientID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_SolicitationHistory_CTIRecipientID] ON [Migration].[Zeta_SolicitationHistory]
(
	[CTIRecipientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Solicitation_ORDERS_IX]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [Solicitation_ORDERS_IX] ON [Migration].[Zeta_SolicitationHistory]
(
	[CTIOrderID] ASC
)
INCLUDE ( 	[CTIRecipientID],
	[SendDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
