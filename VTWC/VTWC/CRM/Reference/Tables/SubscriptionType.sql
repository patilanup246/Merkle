CREATE TABLE [Reference].[SubscriptionType] (
    [SubscriptionTypeID] INT             IDENTITY (1, 1) NOT NULL,
    [Name]               NVARCHAR (256)  NOT NULL,
    [Description]        NVARCHAR (4000) NULL,
    [CreatedDate]        DATETIME        NOT NULL,
    [CreatedBy]          INT             NOT NULL,
    [LastModifiedDate]   DATETIME        NOT NULL,
    [LastModifiedBy]     INT             NOT NULL,
    [ArchivedInd]        BIT             NOT NULL,
    [AllowMultipleInd]   BIT             DEFAULT ((0)) NOT NULL,
    [CaptureTimeInd]     BIT             DEFAULT ((0)) NOT NULL,
    [OptInDefault]       BIT             DEFAULT ((0)) NOT NULL,
    [DisplayName]        NVARCHAR (512)  NOT NULL,
    [DisplayDescription] NVARCHAR (2000) NULL,
    [MessageTypeCd]      NVARCHAR (256)  NOT NULL,
    [OptInMandatoryInd]  BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_SubscriptionType] PRIMARY KEY CLUSTERED ([SubscriptionTypeID] ASC),
    CONSTRAINT [IX_SubscriptionType] UNIQUE NONCLUSTERED ([SubscriptionTypeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to indicate that the Customer or Individual cannot opt out of the Subscription type. If true, then the Customer/Individual can decide on the channel to be receive the information and they must select at least one Channel Type.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'OptInMandatoryInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code to determine the type of subscription to differentiate between, for example marketing and service message subscriptions.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'MessageTypeCd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Subscription description displayed to the visitor on front end system.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'DisplayDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Subscription name displayed to the visitor on front end system.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'DisplayName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to indicate whether by default the Customer/Contact is to be opted in if no preference is available.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'OptInDefault';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to indicate if the contact is required to specify a time to receive communications.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'CaptureTimeInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag to indicate if a contact can have multiple current entries for the subscription type.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'AllowMultipleInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is this an archived value? (Archived Indicator | 0 False - 1 True)', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'ArchivedInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who was the last one to modify this row', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latest date for this row', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this row was created', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for support purposes.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Internal name and should be unique.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SubscriptionType.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'SubscriptionType';

