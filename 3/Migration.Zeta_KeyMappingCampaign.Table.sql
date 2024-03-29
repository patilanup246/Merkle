USE [CEM]
GO
/****** Object:  Table [Migration].[Zeta_KeyMappingCampaign]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[Zeta_KeyMappingCampaign](
	[ZetaCustomerID] [int] NOT NULL,
	[CTIRecipientID] [int] NOT NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[CustomerID_KeyMapping] [int] NULL,
	[IndividualID_KeyMapping] [int] NULL,
	[CustomerID_ElectronicAddress] [int] NULL,
	[IndividualID_ElectronicAddress] [int] NULL,
	[MSDID_PreProcessing] [nvarchar](256) NULL
) ON [PRIMARY]

GO
