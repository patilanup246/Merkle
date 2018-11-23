CREATE TABLE [dat_dtv].[ETLEventHandler] (
    [eventid]           INT            IDENTITY (1, 1) NOT NULL,
    [EventType]         VARCHAR (50)   NOT NULL,
    [ExecutablePackage] VARCHAR (50)   NOT NULL,
    [ExecutableTask]    VARCHAR (50)   NOT NULL,
    [EventMessage]      VARCHAR (2000) NULL,
    [EventDateTime]     DATETIME       NOT NULL
);

