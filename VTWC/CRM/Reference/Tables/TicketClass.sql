CREATE TABLE [Reference].[TicketClass] (
    [TicketClassID]       INT             IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    [ShortCode]           NVARCHAR (20)   NULL,
    CONSTRAINT [cndx_PrimaryKey_TicketClass] PRIMARY KEY CLUSTERED ([TicketClassID] ASC),
    CONSTRAINT [FK_TicketClass_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);
GO

