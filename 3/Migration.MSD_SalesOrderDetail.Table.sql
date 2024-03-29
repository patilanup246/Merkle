USE [CEM]
GO
/****** Object:  Table [Migration].[MSD_SalesOrderDetail]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[MSD_SalesOrderDetail](
	[SalesOrderDetailId] [uniqueidentifier] NOT NULL,
	[SalesOrderId] [uniqueidentifier] NOT NULL,
	[ProductId] [uniqueidentifier] NULL,
	[Quantity] [decimal](23, 10) NULL,
	[PricePerUnit] [money] NULL,
	[BaseAmount] [money] NULL,
	[Description] [nvarchar](max) NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[out_deliverymethod] [nvarchar](100) NULL,
	[out_productcategory] [int] NULL,
	[out_traveldate] [datetime] NULL,
	[out_RailCardType] [nvarchar](100) NULL,
	[out_returndate] [datetime] NULL,
	[out_status] [int] NULL,
 CONSTRAINT [cndx_PrimaryKey_SalesOrderDetail] PRIMARY KEY NONCLUSTERED 
(
	[SalesOrderDetailId] ASC,
	[SalesOrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Index [is_MSD_SalesOrderDetail_SalesOrderId]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [is_MSD_SalesOrderDetail_SalesOrderId] ON [Migration].[MSD_SalesOrderDetail]
(
	[SalesOrderId] ASC,
	[out_traveldate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Migration].[MSD_SalesOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_SalesOrderDetail_SalesOrderId] FOREIGN KEY([SalesOrderId])
REFERENCES [Migration].[MSD_SalesOrder] ([SalesOrderId])
GO
ALTER TABLE [Migration].[MSD_SalesOrderDetail] CHECK CONSTRAINT [FK_SalesOrderDetail_SalesOrderId]
GO
