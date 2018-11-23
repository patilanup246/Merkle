CREATE TABLE [Staging].[STG_CustomerAlert] (
    [CustomerAlertID]   INT           IDENTITY (1, 1) NOT NULL,
    [Title]             VARCHAR (64)  NOT NULL,
    [Forename]          VARCHAR (64)  NOT NULL,
    [Surname]           VARCHAR (64)  NOT NULL,
    [Email]             VARCHAR (256) NOT NULL,
    [EncryptedEmail]    VARCHAR (256) NULL,
    [LocationFrom]      CHAR (3)      NOT NULL,
    [LocationTo]        CHAR (3)      NOT NULL,
    [AlertName]         VARCHAR (MAX) NOT NULL,
    [DurationStartDate] DATETIME      NULL,
    [DurationEndDate]   DATETIME      NULL,
    [OutwardJourney]    DATETIME      NULL,
    [ReturnJourney]     DATETIME      NULL,
    [CreatedDate]       DATETIME      NOT NULL,
    [CreatedBy]         INT           NOT NULL,
    [LastModifiedDate]  DATETIME      NOT NULL,
    [LastModifiedBy]    INT           NOT NULL,
    [ArchivedInd]       BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Staging_STG_CustomerAlert] PRIMARY KEY CLUSTERED ([CustomerAlertID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is this an archived value? (Archived Indicator | 0 False - 1 True)', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'ArchivedInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who was the last one to modify this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latest date for this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this row was created', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'To date of the travel the client is interested', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'ReturnJourney';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CRS Code From date of the travel the client is interested', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'OutwardJourney';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CRS Code Origin of the travel the client is interested.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'LocationTo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'If a customer does not has a defined value for a particular preference this one will be presented as the preference value.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'LocationFrom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Customer Alert Email address. It does not need to match with any of the existing customers email addresses', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Customer Last name', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'Surname';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Customer First Name', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'Forename';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Customer Salutation', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'Title';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for a Customer Alert.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert', @level2type = N'COLUMN', @level2name = N'CustomerAlertID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CEM Customer Alerts.', @level0type = N'SCHEMA', @level0name = N'Staging', @level1type = N'TABLE', @level1name = N'STG_CustomerAlert';

