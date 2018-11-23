CREATE TABLE [Railtimetable].[JourneyStages] (
    [rid]            VARCHAR (512) NULL,
    [uid]            VARCHAR (512) NULL,
    [trainId]        VARCHAR (512) NULL,
    [ssd]            VARCHAR (512) NULL,
    [toc]            VARCHAR (512) NULL,
    [trainCat]       VARCHAR (512) NULL,
    [isPassengerSvc] VARCHAR (512) NULL,
    [Stage]          VARCHAR (2)   NOT NULL,
    [tpl]            VARCHAR (512) NULL,
    [act]            VARCHAR (512) NULL,
    [plat]           VARCHAR (512) NULL,
    [pta]            VARCHAR (512) NULL,
    [ptd]            VARCHAR (512) NULL,
    [wta]            VARCHAR (512) NULL,
    [wtd]            VARCHAR (512) NULL,
    [cancelReason]   VARCHAR (512) NULL,
    [TimeTableID]    VARCHAR (20)  NULL,
    [ssd1]           DATE          NULL,
    [LocationID]     INT           NULL
);


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

