CREATE TABLE [Staging].[STG_LoyaltyRate] (
    [LoyaltyRateID]          INT        IDENTITY (1, 1) NOT NULL,
    [LoyaltyProgrammeTypeID] INT        NOT NULL,
    [StartDate]              DATETIME   NOT NULL,
    [EndDate]                DATETIME   NOT NULL,
    [ProductGroupID]         INT        NOT NULL,
    [Rate]                   FLOAT (53) NULL,
    [CreatedDate]            DATETIME   NOT NULL,
    [CreatedBy]              INT        NOT NULL,
    [LastModifiedDate]       DATETIME   NOT NULL,
    [LastModifiedBy]         INT        NOT NULL,
    [ArchivedInd]            BIT        DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Staging_STG_LoyaltyRate] PRIMARY KEY CLUSTERED ([LoyaltyRateID] ASC),
    CONSTRAINT [FK_Staging_STG_LoyaltyRate_LoyaltyProgrammeType] FOREIGN KEY ([LoyaltyProgrammeTypeID]) REFERENCES [Reference].[LoyaltyProgrammeType] ([LoyaltyProgrammeTypeID]),
    CONSTRAINT [FK_Staging_STG_LoyaltyRate_ProductGroup] FOREIGN KEY ([ProductGroupID]) REFERENCES [Reference].[ProductGroup] ([ProductGroupID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is this an archived value? (Archived Indicator | 0 False - 1 True)', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'ArchivedInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who was the last one to modify this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latest date for this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this row was created', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Loyalty Program rate for the specified Product Group.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'Rate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'What/Which products the rate belongs to.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'ProductGroupID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this rate finish.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this rate starts.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'StartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'What is the program associated to this rate?. Foreign Key to Reference.LoyaltyProgrammeType ( LoyaltyProgrammeTypeID ).', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'LoyaltyProgrammeTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique ID for a Loyalty Rate.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate', @level2type = N'COLUMN', @level2name = N'LoyaltyRateID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Program Loyalty Rates.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_LoyaltyRate';

