CREATE TABLE [Reference].[Period] (
    [PeriodID]         INT             IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (256)  NOT NULL,
    [Description]      NVARCHAR (4000) NULL,
    [CreatedDate]      DATETIME        NOT NULL,
    [CreatedBy]        INT             NOT NULL,
    [LastModifiedDate] DATETIME        NOT NULL,
    [LastModifiedBy]   INT             NOT NULL,
    [ArchivedInd]      BIT             DEFAULT ((0)) NOT NULL,
    [DisplayName]      NVARCHAR (256)  NULL,
    [PeriodTypeID]     INT             NOT NULL,
    [DateStart]        DATETIME        NOT NULL,
    [DateEnd]          DATETIME        NOT NULL,
    [ExtReference]     NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_Period] PRIMARY KEY CLUSTERED ([PeriodID] ASC),
    CONSTRAINT [FK_Period_PeriodTypeID] FOREIGN KEY ([PeriodTypeID]) REFERENCES [Reference].[PeriodType] ([PeriodTypeID])
);

