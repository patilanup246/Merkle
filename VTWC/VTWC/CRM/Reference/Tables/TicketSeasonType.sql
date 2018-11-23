CREATE TABLE [Reference].[TicketSeasonType] (
    [TicketSeasonTypeID]  INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_TicketSeasonType] PRIMARY KEY CLUSTERED ([TicketSeasonTypeID] ASC),
    CONSTRAINT [FK_TicketSeasonType_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

