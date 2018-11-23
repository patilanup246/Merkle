CREATE TABLE [Staging].[STG_CustomerPreference] (
    [CustomerID]       INT      NOT NULL,
    [PreferenceID]     INT      NOT NULL,
    [ChannelID]        INT      NOT NULL,
    [Value]            BIT      NOT NULL,
    [CreatedDate]      DATETIME NOT NULL,
    [CreatedBy]        INT      NOT NULL,
    [LastModifiedDate] DATETIME NOT NULL,
    [LastModifiedBy]   INT      NOT NULL,
    CONSTRAINT [PK_CustomerPreference] PRIMARY KEY CLUSTERED ([CustomerID] ASC, [PreferenceID] ASC, [ChannelID] ASC),
    CONSTRAINT [FK_CustomerPreference_REF_Channel] FOREIGN KEY ([ChannelID]) REFERENCES [Reference].[Channel] ([ChannelID]),
    CONSTRAINT [FK_CustomerPreference_REF_Preference] FOREIGN KEY ([PreferenceID]) REFERENCES [Reference].[Preference] ([PreferenceID]),
    CONSTRAINT [FK_CustomerPreference_STG_Customer] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID])
);




GO



GO



GO



GO



GO



GO



GO



GO
CREATE NONCLUSTERED INDEX [idx_stg_customerpreference_Subscriptions]
    ON [Staging].[STG_CustomerPreference]([CustomerID] ASC, [PreferenceID] ASC, [ChannelID] ASC);


GO

CREATE NONCLUSTERED INDEX idx_STG_CustomerPreference_PreferenceID
ON [Staging].[STG_CustomerPreference] ([PreferenceID])
INCLUDE ([CustomerID],[ChannelID],[Value])


