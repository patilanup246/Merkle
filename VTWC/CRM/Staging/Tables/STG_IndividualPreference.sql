CREATE TABLE [Staging].[STG_IndividualPreference](
	[IndividualID] [int] NOT NULL,
	[PreferenceID] [int] NOT NULL,
	[ChannelID] [int] NOT NULL,
	[Value] [bit] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
 CONSTRAINT [PK_IndividualPreference] PRIMARY KEY CLUSTERED 
( [IndividualID] ASC, [PreferenceID] ASC, [ChannelID] ASC )
)
GO

ALTER TABLE [Staging].[STG_IndividualPreference]  WITH CHECK ADD  CONSTRAINT [FK_IndividualPreference_REF_Channel] FOREIGN KEY([ChannelID])
REFERENCES [Reference].[Channel] ([ChannelID])
GO

ALTER TABLE [Staging].[STG_IndividualPreference] CHECK CONSTRAINT [FK_IndividualPreference_REF_Channel]
GO

ALTER TABLE [Staging].[STG_IndividualPreference]  WITH CHECK ADD  CONSTRAINT [FK_IndividualPreference_REF_Preference] FOREIGN KEY([PreferenceID])
REFERENCES [Reference].[Preference] ([PreferenceID])
GO

ALTER TABLE [Staging].[STG_IndividualPreference] CHECK CONSTRAINT [FK_IndividualPreference_REF_Preference]
GO

ALTER TABLE [Staging].[STG_IndividualPreference]  WITH CHECK ADD  CONSTRAINT [FK_IndividualPreference_STG_Individual] FOREIGN KEY([IndividualID])
REFERENCES [Staging].[STG_Individual] ([IndividualID])
GO

ALTER TABLE [Staging].[STG_IndividualPreference] CHECK CONSTRAINT [FK_IndividualPreference_STG_Individual]
GO



EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique Individual identifier. FK to Staging.STG_Individual Table',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_IndividualPreference',
    @level2type = N'COLUMN',
    @level2name = N'IndividualID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Preference Identifier. FK to Reference.Preference',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_IndividualPreference',
    @level2type = N'COLUMN',
    @level2name = N'PreferenceID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Channel Identifier. FK to Reference.Channel',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_IndividualPreference',
    @level2type = N'COLUMN',
    @level2name = N'ChannelID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Boolean value for the given preference and channel. ',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_IndividualPreference',
    @level2type = N'COLUMN',
    @level2name = N'Value'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date when this row was created',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_IndividualPreference',
    @level2type = N'COLUMN',
    @level2name = N'CreatedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Data Import detail ID that created this row',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_IndividualPreference',
    @level2type = N'COLUMN',
    @level2name = N'CreatedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When this row was modified',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_IndividualPreference',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Data Import detail ID that modified this row',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_IndividualPreference',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedBy'