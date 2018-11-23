CREATE TABLE [Reference].[SubscriptionChannelType] (
    [SubscriptionChannelTypeID] INT             IDENTITY (1, 1) NOT NULL,
    [Name]                      NVARCHAR (256)  NULL,
    [Description]               NVARCHAR (4000) NULL,
    [CreatedDate]               DATETIME        NOT NULL,
    [CreatedBy]                 INT             NOT NULL,
    [LastModifiedDate]          DATETIME        NOT NULL,
    [LastModifiedBy]            INT             NOT NULL,
    [ArchivedInd]               BIT             DEFAULT ((0)) NOT NULL,
    [SubscriptionTypeID]        INT             NOT NULL,
    [ChannelTypeID]             INT             NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_SubscriptionChannelType] PRIMARY KEY CLUSTERED ([SubscriptionChannelTypeID] ASC),
    CONSTRAINT [FK_SubscriptionChannelType_ChannelTypeID] FOREIGN KEY ([ChannelTypeID]) REFERENCES [Reference].[ChannelType] ([ChannelTypeID]),
    CONSTRAINT [FK_SubscriptionChannelType_SubscriptionTypeID] FOREIGN KEY ([SubscriptionTypeID]) REFERENCES [Reference].[SubscriptionType] ([SubscriptionTypeID])
);

