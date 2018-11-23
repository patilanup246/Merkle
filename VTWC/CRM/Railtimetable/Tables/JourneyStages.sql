CREATE TABLE [Railtimetable].[JourneyStages](
	[rid] [varchar](512) NULL,
	[uid] [varchar](512) NULL,
	[trainId] [varchar](512) NULL,
	[ssd] [varchar](512) NULL,
	[toc] [varchar](512) NULL,
	[trainCat] [varchar](512) NULL,
	[isPassengerSvc] [varchar](512) NULL,
	[Stage] [varchar](2) NOT NULL,
	[tpl] [varchar](512) NULL,
	[act] [varchar](512) NULL,
	[plat] [varchar](512) NULL,
	[pta] [varchar](512) NULL,
	[ptd] [varchar](512) NULL,
	[wta] [varchar](512) NULL,
	[wtd] [varchar](512) NULL,
	[cancelReason] [varchar](512) NULL,
	[TimeTableID] [varchar](20) NULL,
	[ssd1] [date] NULL,
	[LocationID] [int] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedExtractNumber] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[LastModifiedExtractNumber] [int] NOT NULL
) ON [PRIMARY]
GO


GO
CREATE NONCLUSTERED INDEX [JourneyStages_uid_ssd_pta_ptd]
    ON [Railtimetable].[JourneyStages]([toc] ASC, [Stage] ASC)
    INCLUDE([uid], [ssd], [tpl], [pta], [ptd], [wta], [wtd]);


GO
CREATE NONCLUSTERED INDEX [ix_JourneyStages_toc_trainid]
    ON [Railtimetable].[JourneyStages]([toc] ASC)
    INCLUDE([uid], [trainId], [ssd]);


GO
CREATE NONCLUSTERED INDEX [ix_JourneyStages_toc_stage]
    ON [Railtimetable].[JourneyStages]([toc] ASC, [Stage] ASC)
    INCLUDE([rid], [uid], [ssd], [tpl], [ptd], [wtd]);


GO
CREATE NONCLUSTERED INDEX [ix_JourneyStages_toc_LocationID]
    ON [Railtimetable].[JourneyStages]([toc] ASC)
    INCLUDE([rid], [uid], [ssd], [pta], [wta], [LocationID]);


GO
CREATE NONCLUSTERED INDEX [ix_JourneyStages_toc_Location_stage]
    ON [Railtimetable].[JourneyStages]([toc] ASC, [LocationID] ASC, [Stage] ASC)
    INCLUDE([rid], [uid], [ssd], [ptd], [wtd]);


GO
CREATE NONCLUSTERED INDEX [ix_JourneyStages_toc]
    ON [Railtimetable].[JourneyStages]([toc] ASC)
    INCLUDE([rid], [uid], [ssd], [tpl], [pta], [wta]);


GO
CREATE NONCLUSTERED INDEX [IDX_JourneyStages_Toc]
    ON [Railtimetable].[JourneyStages]([toc] ASC)
    INCLUDE([trainId], [ssd], [tpl], [ptd], [wtd]);

