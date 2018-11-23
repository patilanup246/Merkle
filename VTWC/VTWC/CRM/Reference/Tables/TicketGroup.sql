CREATE TABLE [Reference].[TicketGroup] (
    [TicketGroupID]       INT             IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_TicketGroup] PRIMARY KEY CLUSTERED ([TicketGroupID] ASC),
    CONSTRAINT [FK_TicketGroup_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

