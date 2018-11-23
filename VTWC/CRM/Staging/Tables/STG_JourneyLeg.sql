CREATE TABLE [Staging].[STG_JourneyLeg](
	[JourneyLegID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NULL,
	[Description] [nvarchar](4000) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[ArchivedInd] [bit] NOT NULL,
	[JourneyID] [int] NOT NULL,
	[LegNumber] [int] NULL,
	[RSID] [nvarchar](256) NULL,
	[TicketClassID] [int] NULL,
	[LocationIDOrigin] [int] NULL,
	[LocationIDDestination] [int] NULL,
	[DepartureDateTime] [datetime] NULL,
	[InferredDepartureInd] [int] NULL,
	[ArrivalDateTime] [datetime] NULL,
	[InferredArrivalInd] [int] NULL,
	[ModeOfTransportID] [int] NULL,
	[TOCID] [int] NULL,
	[SeatReservation] [nvarchar](256) NULL,
	[DirectionCd] [nvarchar](8) NULL,
	[DayPlusOne] [bit] NULL,
	[RecommendedXferTime] [int] NULL,
	[CateringCode] [nvarchar](256) NULL,
	[JourneyTrainID] [int] NULL,
	[ExtReference] [bigint] NULL,
	[InformationSourceID] [int] NULL,
	[SourceCreatedDate] [datetime] NULL,
	[SourceModifiedDate] [datetime] NULL,
	[WiFiCode] [nvarchar](32) NULL,
	[QuietZone_YN] [nchar](1) NULL,
	[TrainUID] [nvarchar](20) NULL,
	[JLType] [nchar](1) NULL,
	[CreatedExtractNumber] [int] NULL,
	[LastModifiedExtractNumber] [int] NULL,
 CONSTRAINT [cndx_PrimaryKey_STG_JourneyLeg] PRIMARY KEY CLUSTERED 
(
	[JourneyLegID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [Staging].[STG_JourneyLeg] ADD  DEFAULT ((0)) FOR [ArchivedInd]
GO

ALTER TABLE [Staging].[STG_JourneyLeg] ADD  CONSTRAINT [DF_STG_JourneyLeg_DayPlusOne]  DEFAULT ((0)) FOR [DayPlusOne]
GO

ALTER TABLE [Staging].[STG_JourneyLeg]  WITH CHECK ADD  CONSTRAINT [FK_STG_JourneyLeg_InformationSourceID] FOREIGN KEY([InformationSourceID])
REFERENCES [Reference].[InformationSource] ([InformationSourceID])
GO

ALTER TABLE [Staging].[STG_JourneyLeg] CHECK CONSTRAINT [FK_STG_JourneyLeg_InformationSourceID]
GO

ALTER TABLE [Staging].[STG_JourneyLeg]  WITH CHECK ADD  CONSTRAINT [FK_STG_JourneyLeg_JourneyID] FOREIGN KEY([JourneyID])
REFERENCES [Staging].[STG_Journey] ([JourneyID])
GO

ALTER TABLE [Staging].[STG_JourneyLeg] CHECK CONSTRAINT [FK_STG_JourneyLeg_JourneyID]
GO

ALTER TABLE [Staging].[STG_JourneyLeg]  WITH CHECK ADD  CONSTRAINT [FK_STG_JourneyLeg_JourneyTrainID] FOREIGN KEY([JourneyTrainID])
REFERENCES [Staging].[STG_JourneyTrain] ([JourneyTrainID])
GO

ALTER TABLE [Staging].[STG_JourneyLeg] CHECK CONSTRAINT [FK_STG_JourneyLeg_JourneyTrainID]
GO

ALTER TABLE [Staging].[STG_JourneyLeg]  WITH CHECK ADD  CONSTRAINT [FK_STG_JourneyLeg_LocationIDDestination] FOREIGN KEY([LocationIDDestination])
REFERENCES [Reference].[Location] ([LocationID])
GO

ALTER TABLE [Staging].[STG_JourneyLeg] CHECK CONSTRAINT [FK_STG_JourneyLeg_LocationIDDestination]
GO

ALTER TABLE [Staging].[STG_JourneyLeg]  WITH CHECK ADD  CONSTRAINT [FK_STG_JourneyLeg_LocationIDOrigin] FOREIGN KEY([LocationIDOrigin])
REFERENCES [Reference].[Location] ([LocationID])
GO

ALTER TABLE [Staging].[STG_JourneyLeg] CHECK CONSTRAINT [FK_STG_JourneyLeg_LocationIDOrigin]
GO

ALTER TABLE [Staging].[STG_JourneyLeg]  WITH CHECK ADD  CONSTRAINT [FK_STG_JourneyLeg_ModeOfTransportID] FOREIGN KEY([ModeOfTransportID])
REFERENCES [Reference].[ModeOfTransport] ([ModeOfTransportID])
GO

ALTER TABLE [Staging].[STG_JourneyLeg] CHECK CONSTRAINT [FK_STG_JourneyLeg_ModeOfTransportID]
GO

CREATE NONCLUSTERED INDEX [IDX_Staging_STG_JourneyLeg_ExtReference] ON [Staging].[STG_JourneyLeg]
(
	[ExtReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
