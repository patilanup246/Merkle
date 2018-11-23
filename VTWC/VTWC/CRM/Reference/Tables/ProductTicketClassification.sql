CREATE TABLE [Reference].[ProductTicketClassification] (
    [TicketTypeCode]         NVARCHAR (8) NOT NULL,
    [TicketClassificationID] INT          NOT NULL,
    [CreatedDate]            DATETIME     NOT NULL,
    [CreatedBy]              INT          NOT NULL,
    [LastModifiedDate]       DATETIME     NULL,
    [LastModifiedBy]         INT          NULL,
    [ArchivedInd]            BIT          NOT NULL,
    [InformationSourceID]    INT          NOT NULL,
    CONSTRAINT [pk_ReferenceProductTicketClassification] PRIMARY KEY CLUSTERED ([TicketTypeCode] ASC, [TicketClassificationID] ASC),
    FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    FOREIGN KEY ([TicketClassificationID]) REFERENCES [Reference].[TicketClassification] ([TicketClassificationID])
);

