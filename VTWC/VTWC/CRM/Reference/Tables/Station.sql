CREATE TABLE [Reference].[Station] (
    [StationID]           INT             IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    [ShortCode]           NVARCHAR (16)   NOT NULL,
    [EffectiveFromDate]   DATETIME        NOT NULL,
    [EffectiveToDate]     DATETIME        NULL,
    [County]              NVARCHAR (256)  NOT NULL,
    [PostCode]            NVARCHAR (256)  NOT NULL,
    [GroupStation]        NVARCHAR (256)  NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_Station] PRIMARY KEY CLUSTERED ([StationID] ASC),
    CONSTRAINT [FK_Station_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);
GO

