USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_EmailBounces]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_EmailBounces](
	[CTIRecipientID] [nvarchar](256) NULL,
	[OrderID] [nvarchar](256) NULL,
	[BounceBackDate] [nvarchar](256) NULL,
	[BounceBackLevelID] [nvarchar](256) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_EmailBounces_CTIRecipientID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_EmailBounces_CTIRecipientID] ON [Migration].[Zeta_EmailBounces]
(
	[CTIRecipientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_Zeta_EmailBounces_OrderID]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_EmailBounces_OrderID] ON [Migration].[Zeta_EmailBounces]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
