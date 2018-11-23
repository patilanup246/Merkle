USE [CRM]
GO

ALTER TABLE [Staging].[STG_Customer] DROP CONSTRAINT [FK_STG_Customer_InformationSourceID]
GO

ALTER TABLE [Staging].[STG_Customer] DROP CONSTRAINT [FK_STG_Customer_IndividualID]
GO

ALTER TABLE [Staging].[STG_Customer] DROP CONSTRAINT [DF_STG_Customer_HasSetPrefInd]
GO

ALTER TABLE [Staging].[STG_Customer] DROP CONSTRAINT [DF_IsPersonInd]
GO

ALTER TABLE [Staging].[STG_Customer] DROP CONSTRAINT [DF__STG_Custo__IsCor__5C02A283]
GO

ALTER TABLE [Staging].[STG_Customer] DROP CONSTRAINT [DF__STG_Custo__IsTMC__5B0E7E4A]
GO

ALTER TABLE [Staging].[STG_Customer] DROP CONSTRAINT [DF__STG_Custo__IsBla__5A1A5A11]
GO

ALTER TABLE [Staging].[STG_Customer] DROP CONSTRAINT [DF__STG_Custo__IsSta__592635D8]
GO

ALTER TABLE [Staging].[STG_Customer] DROP CONSTRAINT [DF__STG_Custo__Archi__5832119F]
GO

/****** Object:  Table [Staging].[STG_Customer]    Script Date: 26/07/2018 12:57:05 ******/
DROP TABLE [Staging].[STG_Customer]
GO

/****** Object:  Table [Staging].[STG_Customer]    Script Date: 26/07/2018 12:57:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Staging].[STG_Customer](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](4000) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[ArchivedInd] [bit] NOT NULL,
	[MSDID] [uniqueidentifier] NULL,
	[SourceCreatedDate] [datetime] NOT NULL,
	[SourceModifiedDate] [datetime] NOT NULL,
	[IsStaffInd] [bit] NOT NULL,
	[IsBlackListInd] [bit] NOT NULL,
	[IsTMCInd] [bit] NOT NULL,
	[IsCorporateInd] [bit] NOT NULL,
	[Salutation] [nvarchar](64) NULL,
	[FirstName] [nvarchar](64) NULL,
	[MiddleName] [nvarchar](64) NULL,
	[LastName] [nvarchar](64) NULL,
	[IndividualID] [int] NULL,
	[InformationSourceID] [int] NOT NULL,
	[DateFirstPurchase] [datetime] NULL,
	[DateLastPurchase] [datetime] NULL,
	[IsPersonInd] [bit] NOT NULL,
	[HasSetPrefInd] [bit] NULL,
 CONSTRAINT [cndx_PrimaryKey_STG_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [Staging].[STG_Customer] ADD  DEFAULT ((0)) FOR [ArchivedInd]
GO

ALTER TABLE [Staging].[STG_Customer] ADD  DEFAULT ((0)) FOR [IsStaffInd]
GO

ALTER TABLE [Staging].[STG_Customer] ADD  DEFAULT ((0)) FOR [IsBlackListInd]
GO

ALTER TABLE [Staging].[STG_Customer] ADD  DEFAULT ((0)) FOR [IsTMCInd]
GO

ALTER TABLE [Staging].[STG_Customer] ADD  DEFAULT ((0)) FOR [IsCorporateInd]
GO

ALTER TABLE [Staging].[STG_Customer] ADD  CONSTRAINT [DF_IsPersonInd]  DEFAULT ((1)) FOR [IsPersonInd]
GO

ALTER TABLE [Staging].[STG_Customer] ADD  CONSTRAINT [DF_STG_Customer_HasSetPrefInd]  DEFAULT ((0)) FOR [HasSetPrefInd]
GO

ALTER TABLE [Staging].[STG_Customer]  WITH CHECK ADD  CONSTRAINT [FK_STG_Customer_IndividualID] FOREIGN KEY([IndividualID])
REFERENCES [Staging].[STG_Individual] ([IndividualID])
GO

ALTER TABLE [Staging].[STG_Customer] CHECK CONSTRAINT [FK_STG_Customer_IndividualID]
GO

ALTER TABLE [Staging].[STG_Customer]  WITH CHECK ADD  CONSTRAINT [FK_STG_Customer_InformationSourceID] FOREIGN KEY([InformationSourceID])
REFERENCES [Reference].[InformationSource] ([InformationSourceID])
GO

ALTER TABLE [Staging].[STG_Customer] CHECK CONSTRAINT [FK_STG_Customer_InformationSourceID]
GO


