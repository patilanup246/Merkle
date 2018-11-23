CREATE TABLE [Audit].[STG_CustomerPreference] (
    [CustomerID]       INT      NOT NULL,
    [PreferenceID]     INT      NOT NULL,
    [ChannelID]        INT      NOT NULL,
    [ActionTimestamp]  DATETIME NOT NULL,
    [Value]            BIT      NOT NULL,
    [Action]           CHAR (1) NULL,
    [CreatedDate]      DATETIME NOT NULL,
    [CreatedBy]        INT      NOT NULL,
    [LastModifiedDate] DATETIME NOT NULL,
    [LastModifiedBy]   INT      NOT NULL,
    CONSTRAINT [PK_CustomerPreference] PRIMARY KEY CLUSTERED ([CustomerID] ASC, [PreferenceID] ASC, [ChannelID] ASC, [ActionTimestamp] ASC)
);

