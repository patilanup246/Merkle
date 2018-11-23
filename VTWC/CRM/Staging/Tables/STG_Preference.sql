CREATE TABLE [Staging].[STG_Preference] (
    [PreferenceID]         INT           IDENTITY (1, 1) NOT NULL,
    [PreferenceName]       VARCHAR (MAX) NOT NULL,
    [PreferenceDataTypeID] INT           NOT NULL,
    [CreatedDate]          DATETIME      NOT NULL,
    [CreatedBy]            INT           NOT NULL,
    [LastModifiedDate]     DATETIME      NOT NULL,
    [LastModifiedBy]       INT           NOT NULL,
    [ArchivedInd]          BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Preference] PRIMARY KEY CLUSTERED ([PreferenceID] ASC),
    CONSTRAINT [FK_Preference_PreferenceDataType] FOREIGN KEY ([PreferenceDataTypeID]) REFERENCES [Reference].[DataType] ([DataTypeID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is this an archived value? (Archived Indicator | 0 False - 1 True)', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_Preference', @level2type = N'COLUMN', @level2name = N'ArchivedInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who was the last one to modify this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_Preference', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latest date for this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_Preference', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_Preference', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this row was created', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_Preference', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign Key to Preference Data Type', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_Preference', @level2type = N'COLUMN', @level2name = N'PreferenceDataTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Preference text to be displayed as a question.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_Preference', @level2type = N'COLUMN', @level2name = N'PreferenceName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for a preference.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_Preference', @level2type = N'COLUMN', @level2name = N'PreferenceID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Available preferences on CEM.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_Preference';

