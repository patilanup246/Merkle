CREATE TABLE [Reference].[TicketClassification] (
    [TicketClassificationID] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                   VARCHAR (256)  NOT NULL,
    [Description]            VARCHAR (4000) NULL,
    [CreatedBy]              INT            NOT NULL,
    [LastModifiedDate]       DATETIME       NULL,
    [LastModifiedBy]         INT            NULL,
    [ArchivedInd]            BIT            NOT NULL,
    [InformationSourceID]    INT            NOT NULL,
    CONSTRAINT [pk_ReferenceTicketClassification] PRIMARY KEY CLUSTERED ([TicketClassificationID] ASC),
    FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);



