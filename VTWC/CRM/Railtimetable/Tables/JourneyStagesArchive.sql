CREATE TABLE [Railtimetable].[JourneyStagesArchive] (
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
    [LocationID]     INT           NULL,
    [archiveDate]    DATETIME      NULL
);

