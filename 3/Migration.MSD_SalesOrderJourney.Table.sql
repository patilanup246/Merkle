USE [CEM]
GO
/****** Object:  Table [Migration].[MSD_SalesOrderJourney]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Migration].[MSD_SalesOrderJourney](
	[MSD_SalesOrderJourneyId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SalesOrderId] [uniqueidentifier] NULL,
	[ContactID] [uniqueidentifier] NULL,
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
	[leg_seqno] [int] NULL,
	[leg_rsid] [nvarchar](100) NULL,
	[leg_TOC] [nvarchar](2) NULL,
	[leg_origin] [nvarchar](100) NULL,
	[leg_destination] [nvarchar](100) NULL,
	[leg_class] [nvarchar](100) NULL,
	[leg_reservation] [nvarchar](100) NULL,
	[leg_outboundind] [bit] NULL,
 CONSTRAINT [cndx_MSD_SalesOrderJourney] PRIMARY KEY CLUSTERED 
(
	[MSD_SalesOrderJourneyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Index [ix_MSD_SalesOrderJouney_SalesOrderIdDeqNo]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_MSD_SalesOrderJouney_SalesOrderIdDeqNo] ON [Migration].[MSD_SalesOrderJourney]
(
	[SalesOrderId] ASC,
	[leg_seqno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_MSD_SalesOrderJouney_TOC]    Script Date: 24/07/2018 14:20:09 ******/
CREATE NONCLUSTERED INDEX [ix_MSD_SalesOrderJouney_TOC] ON [Migration].[MSD_SalesOrderJourney]
(
	[leg_TOC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
