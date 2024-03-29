USE [CEM]
GO
/****** Object:  Table [Migration].[MSD_LoyaltyProgrammeMembership]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[MSD_LoyaltyProgrammeMembership](
	[MSD_LoyaltyProgrammeMembershipID] [int] IDENTITY(1,1) NOT NULL,
	[out_loyaltymembershipId] [uniqueidentifier] NULL,
	[out_customerId] [uniqueidentifier] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[out_loyaltycardnumber] [nvarchar](100) NULL,
	[out_loyaltyenddate] [datetime] NULL,
	[out_loyaltystartdate] [datetime] NULL,
	[out_loyaltytype] [nvarchar](100) NULL,
 CONSTRAINT [cndx_PrimaryKey_LoyaltyProgrammeMembership] PRIMARY KEY CLUSTERED 
(
	[MSD_LoyaltyProgrammeMembershipID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [ix_MSD_LoyaltyProgramme_customerId]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_MSD_LoyaltyProgramme_customerId] ON [Migration].[MSD_LoyaltyProgrammeMembership]
(
	[out_customerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_MSD_LoyaltyProgrammeyProgrammeMembership_loyaltymembershipId]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_MSD_LoyaltyProgrammeyProgrammeMembership_loyaltymembershipId] ON [Migration].[MSD_LoyaltyProgrammeMembership]
(
	[out_loyaltymembershipId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
