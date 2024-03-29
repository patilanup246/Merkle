USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_Prospect]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_Prospect](
	[ZetaProspectID] [int] IDENTITY(1,1) NOT NULL,
	[ZetaCustomerID] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedPeriod] [nvarchar](256) NULL,
	[Contactable] [bit] NOT NULL,
	[EmailAddress] [nvarchar](256) NULL,
	[MobileNumber] [nvarchar](256) NULL,
	[FirstName] [nvarchar](256) NULL,
	[LastName] [nvarchar](256) NULL,
	[DefunctInd] [bit] NOT NULL,
	[HardBounceInd] [bit] NOT NULL,
	[ValidEmailInd] [bit] NOT NULL,
	[RespondedInd] [bit] NOT NULL,
	[LastRespondDate] [datetime] NULL,
	[InMSDInd] [bit] NULL,
	[NonResponderInd] [bit] NULL,
	[OptOutInd] [bit] NULL,
	[MigrateInd] [bit] NOT NULL,
	[FinalMigrateInd] [bit] NULL,
	[InCEMInd] [bit] NULL,
	[FinalMigrateInd1] [bit] NULL,
 CONSTRAINT [cndx_PrimaryKey_ZetaProspect] PRIMARY KEY CLUSTERED 
(
	[ZetaProspectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [ix_Zeta_Prospect_ZetaCustomerId]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_Zeta_Prospect_ZetaCustomerId] ON [Migration].[Zeta_Prospect]
(
	[ZetaCustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ZetaProspect_IX_Email]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ZetaProspect_IX_Email] ON [Migration].[Zeta_Prospect]
(
	[EmailAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [Contactable]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [DefunctInd]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [HardBounceInd]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [ValidEmailInd]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [RespondedInd]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [InMSDInd]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [NonResponderInd]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [OptOutInd]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [MigrateInd]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [FinalMigrateInd]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [InCEMInd]
GO
ALTER TABLE [Migration].[Zeta_Prospect] ADD  DEFAULT ((0)) FOR [FinalMigrateInd1]
GO
