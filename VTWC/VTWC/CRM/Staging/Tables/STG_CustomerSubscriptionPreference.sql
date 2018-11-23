CREATE TABLE [Staging].[STG_CustomerSubscriptionPreference] (
    [CustomerSubscriptionPreferenceID] INT             IDENTITY (1, 1) NOT NULL,
    [Name]                             NVARCHAR (256)  NULL,
    [Description]                      NVARCHAR (4000) NULL,
    [CreatedDate]                      DATETIME        NOT NULL,
    [CreatedBy]                        INT             NOT NULL,
    [LastModifiedDate]                 DATETIME        NOT NULL,
    [LastModifiedBy]                   INT             NOT NULL,
    [ArchivedInd]                      BIT             DEFAULT ((0)) NOT NULL,
    [SourceChangeDate]                 DATETIME        NOT NULL,
    [CustomerID]                       INT             NOT NULL,
    [SubscriptionChannelTypeID]        INT             NOT NULL,
    [OptInInd]                         BIT             DEFAULT ((0)) NOT NULL,
    [StartTime]                        DATETIME        NULL,
    [EndTime]                          DATETIME        NULL,
    [DaysofWeek]                       NVARCHAR (16)   NULL,
    [InformationSourceID]              INT             NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_CustomerSubscriptionPreference] PRIMARY KEY CLUSTERED ([CustomerSubscriptionPreferenceID] ASC),
    CONSTRAINT [FK_STG_CustomerSubscriptionPreference_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_CustomerSubscriptionPreference_SubscriptionChannelTypeID] FOREIGN KEY ([SubscriptionChannelTypeID]) REFERENCES [Reference].[SubscriptionChannelType] ([SubscriptionChannelTypeID])
);


GO
CREATE NONCLUSTERED INDEX [Missing_IXNC_STG_CustomerSubscriptionPreference_CustomerID_SubscriptionChannelTypeID]
    ON [Staging].[STG_CustomerSubscriptionPreference]([CustomerID] ASC, [SubscriptionChannelTypeID] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_STG_CustomerSubscriptionPreference_CustomerID]
    ON [Staging].[STG_CustomerSubscriptionPreference]([ArchivedInd] ASC, [CustomerID] ASC, [SubscriptionChannelTypeID] ASC, [OptInInd] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Reference to the source identificator from which the subscription came from', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'InformationSourceID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'String holding day values to specify on which days of a week should the subscription be sent out', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'DaysofWeek';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Time specifying when the subscription ceases its effect', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'EndTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Time specifying when the subscription comes in effect', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'StartTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = opted in; 0 = opted out', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'OptInInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to a table where all allowed combinations of subscriptions and channels are stored', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'SubscriptionChannelTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to STG_Customer to link the subscription to a specific customer record', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'CustomerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'???', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'SourceChangeDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to hide the record for support/maintenance purposes', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'ArchivedInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who was the last one to modify this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latest date for this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this row was created', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Subscription description for internal usage', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Subscription name for internal usage', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identificator for customer subscription preferences', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference', @level2type = N'COLUMN', @level2name = N'CustomerSubscriptionPreferenceID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Subscriptions that customers have opted into/out of', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerSubscriptionPreference';

