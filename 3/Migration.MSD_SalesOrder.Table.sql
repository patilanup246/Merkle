USE [CEM]
GO
/****** Object:  Table [Migration].[MSD_SalesOrder]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[MSD_SalesOrder](
	[SalesOrderId] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NULL,
	[OrderNumber] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](300) NULL,
	[Description] [nvarchar](max) NULL,
	[TotalAmount] [money] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[ShipTo_Line1] [nvarchar](4000) NULL,
	[ShipTo_Line2] [nvarchar](4000) NULL,
	[ShipTo_Line3] [nvarchar](4000) NULL,
	[out_shipto_line4] [nvarchar](250) NULL,
	[out_shipto_line5] [nvarchar](100) NULL,
	[ShipTo_City] [nvarchar](80) NULL,
	[ShipTo_StateOrProvince] [nvarchar](50) NULL,
	[ShipTo_Country] [nvarchar](80) NULL,
	[ShipTo_PostalCode] [nvarchar](20) NULL,
	[BillTo_Line1] [nvarchar](4000) NULL,
	[BillTo_Line2] [nvarchar](4000) NULL,
	[BillTo_Line3] [nvarchar](4000) NULL,
	[out_billto_line4] [nvarchar](250) NULL,
	[out_billto_line5] [nvarchar](250) NULL,
	[BillTo_City] [nvarchar](80) NULL,
	[BillTo_StateOrProvince] [nvarchar](50) NULL,
	[BillTo_Country] [nvarchar](80) NULL,
	[BillTo_PostalCode] [nvarchar](20) NULL,
	[out_bookingmethod] [nvarchar](100) NULL,
	[out_bookingsourceId] [nvarchar](100) NULL,
	[out_deliverymethod] [nvarchar](100) NULL,
	[out_numberadults] [int] NULL,
	[out_numberchildren] [int] NULL,
	[out_orderfulfilmentdate] [datetime] NULL,
	[out_orderplacedate] [datetime] NULL,
	[out_webtisbookingid] [nvarchar](100) NULL,
	[out_status] [int] NULL,
	[out_supersales] [bit] NULL,
	[out_paymentcardtype] [nvarchar](100) NULL,
	[out_purchasemethod] [int] NULL,
	[out_purchasemethod1] [int] NULL,
	[out_purchasemethod2] [int] NULL,
	[out_purchasemethod3] [int] NULL,
	[out_totalbasketvalue] [money] NULL,
	[out_totalnonrailbasketvalue] [money] NULL,
	[out_totalrailbasketvalue] [money] NULL,
	[out_journeyorigin] [nvarchar](512) NULL,
	[out_journeydestination] [nvarchar](512) NULL,
	[out_route] [nvarchar](max) NULL,
	[out_outlegclass] [nvarchar](100) NULL,
	[out_outretailserviceids] [nvarchar](100) NULL,
	[out_outseatreservations] [nvarchar](640) NULL,
	[out_outserviceoperators] [nvarchar](100) NULL,
	[out_outTOCdestination] [nvarchar](100) NULL,
	[out_outTOCorigin] [nvarchar](100) NULL,
	[out_retlegclass] [nvarchar](100) NULL,
	[out_retretailserviceids] [nvarchar](100) NULL,
	[out_retseatreservations] [nvarchar](640) NULL,
	[out_retserviceoperators] [nvarchar](100) NULL,
	[out_retTOCorigin] [nvarchar](100) NULL,
	[out_retTOCdestination] [nvarchar](100) NULL,
 CONSTRAINT [cndx_PrimaryKey_SalesOrder] PRIMARY KEY CLUSTERED 
(
	[SalesOrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Index [ix_MSD_SalesOrder_ContactId]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_MSD_SalesOrder_ContactId] ON [Migration].[MSD_SalesOrder]
(
	[ContactId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_MSD_SalesOrder_orderplacedate]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_MSD_SalesOrder_orderplacedate] ON [Migration].[MSD_SalesOrder]
(
	[out_orderplacedate] ASC
)
INCLUDE ( 	[ContactId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Migration].[MSD_SalesOrder]  WITH CHECK ADD  CONSTRAINT [FK_SalesOrder_ContactId] FOREIGN KEY([ContactId])
REFERENCES [Migration].[MSD_Contact] ([ContactId])
GO
ALTER TABLE [Migration].[MSD_SalesOrder] CHECK CONSTRAINT [FK_SalesOrder_ContactId]
GO
