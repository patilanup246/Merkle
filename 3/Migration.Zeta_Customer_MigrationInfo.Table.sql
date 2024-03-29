USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_Customer_MigrationInfo]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_Customer_MigrationInfo](
	[ZetaCustomerID] [varchar](512) NULL,
	[DateCreated] [varchar](19) NULL,
	[CreatedPeriod] [nvarchar](6) NULL,
	[Contactable] [varchar](512) NULL,
	[ContactEmail] [varchar](512) NULL,
	[MobileTelephoneNo] [varchar](512) NULL,
	[ContactFirstName] [varchar](512) NULL,
	[ContactLastName] [varchar](512) NULL,
	[IsCorp] [varchar](512) NULL,
	[IsTMC] [varchar](512) NULL,
	[Corp_OptOut] [varchar](512) NULL,
	[DefunctInd] [int] NOT NULL,
	[HardBounceInd] [int] NOT NULL,
	[MigrateInd] [int] NOT NULL,
	[IsGUIDInd] [int] NULL,
	[RespondedInd] [bit] NULL,
	[LastRespondDate] [datetime] NULL,
	[InMSDInd] [bit] NULL,
	[InCEMInd] [bit] NULL,
	[MSDID] [nvarchar](512) NULL,
	[LastPurchasedDate] [datetime] NULL
) ON [PRIMARY]

GO
ALTER TABLE [Migration].[Zeta_Customer_MigrationInfo] ADD  DEFAULT ((0)) FOR [Contactable]
GO
ALTER TABLE [Migration].[Zeta_Customer_MigrationInfo] ADD  DEFAULT ((0)) FOR [DefunctInd]
GO
ALTER TABLE [Migration].[Zeta_Customer_MigrationInfo] ADD  DEFAULT ((0)) FOR [HardBounceInd]
GO
ALTER TABLE [Migration].[Zeta_Customer_MigrationInfo] ADD  DEFAULT ((0)) FOR [MigrateInd]
GO
ALTER TABLE [Migration].[Zeta_Customer_MigrationInfo] ADD  DEFAULT ((0)) FOR [IsGUIDInd]
GO
ALTER TABLE [Migration].[Zeta_Customer_MigrationInfo] ADD  DEFAULT ((0)) FOR [RespondedInd]
GO
ALTER TABLE [Migration].[Zeta_Customer_MigrationInfo] ADD  DEFAULT ((0)) FOR [InMSDInd]
GO
ALTER TABLE [Migration].[Zeta_Customer_MigrationInfo] ADD  DEFAULT ((0)) FOR [InCEMInd]
GO
