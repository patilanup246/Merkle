CREATE TABLE [Staging].[STG_PreferenceOptions] (
    [OptionID]         INT           IDENTITY (1, 1) NOT NULL,
    [PreferenceID]     INT           NOT NULL,
    [OptionName]       VARCHAR (MAX) NOT NULL,
    [DefaultValue]     BIT           NOT NULL,
    [CreatedDate]      DATETIME      NOT NULL,
    [CreatedBy]        INT           NOT NULL,
    [LastModifiedDate] DATETIME      NOT NULL,
    [LastModifiedBy]   INT           NOT NULL,
    [ArchivedInd]      BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PreferenceOptions] PRIMARY KEY CLUSTERED ([OptionID] ASC),
    CONSTRAINT [FK_PreferenceOptions_Preference] FOREIGN KEY ([PreferenceID]) REFERENCES [Staging].[STG_Preference] ([PreferenceID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who was the last one to modify this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_PreferenceOptions', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latest date for this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_PreferenceOptions', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_PreferenceOptions', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this row was created', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_PreferenceOptions', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Default value for the option to be used for each customer', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_PreferenceOptions', @level2type = N'COLUMN', @level2name = N'DefaultValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the accepted option for the related preference', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_PreferenceOptions', @level2type = N'COLUMN', @level2name = N'OptionName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to STG_Preference', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_PreferenceOptions', @level2type = N'COLUMN', @level2name = N'PreferenceID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for a preference default value.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_PreferenceOptions', @level2type = N'COLUMN', @level2name = N'OptionID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valid preference values for preferences on CEM.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_PreferenceOptions';

