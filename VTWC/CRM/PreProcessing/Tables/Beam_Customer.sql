CREATE TABLE [PreProcessing].[Beam_Customer] (
    [Beam_CustomerID]    INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [VisitorID]          NVARCHAR (256) NOT NULL,
    [FirstName]          NVARCHAR (64)  NOT NULL,
    [LastName]           NVARCHAR (64)  NOT NULL,
    [EmailAddress]       NVARCHAR (256) NOT NULL,
    [OptIn]              BIT            NOT NULL,
    [CreatedDate]        DATETIME       CONSTRAINT [DF_Beam_Customer_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          INT            NOT NULL,
    [LastModifiedDate]   DATETIME       CONSTRAINT [DF_Beam_Customer_LastModifiedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedBy]     INT            NOT NULL,
    [CustomerID]         INT            NULL,
    [IndividualID]       INT            NULL,
    [MatchedInd]         BIT            DEFAULT ((0)) NULL,
    [ParsedAddressEmail] NVARCHAR (100) NULL,
    [ParsedEmailInd]     BIT            DEFAULT ((0)) NULL,
    [ParsedEmailScore]   INT            DEFAULT ((0)) NULL,
    [ProfanityInd]       BIT            DEFAULT ((0)) NULL,
    [ProcessedInd]       BIT            DEFAULT ((0)) NOT NULL,
    [DataImportDetailID] INT            NULL,
    CONSTRAINT [PK_Beam_Customer] PRIMARY KEY CLUSTERED ([Beam_CustomerID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to Operations.DataImportDetail', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'DataImportDetailID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Has record been processed into Staging', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'ProcessedInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Does the email address contain Profanity', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'ProfanityInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Score from email parsing algorithmn to indicate how good the address is ranging from 0 to 100', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'ParsedEmailScore';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Has the email address been parsed', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'ParsedEmailInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Email address after parsing using Spectrum', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'ParsedAddressEmail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Has a match been found - either with Customer or Individual', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'MatchedInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CEM Individual ID if match found during processing', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'IndividualID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CEM Customer ID if match found during processing', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'CustomerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who was the last one to modify this row', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latest date for this row', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'When this row was created', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Whether the customer has opted in or out of market emails.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'OptIn';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Email address of the customer.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'EmailAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Last name of the customer.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'LastName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'First name of the customer.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'FirstName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique id which we assign to the customer. This id is used to track the usage on the app. VTEC will be able to match the registered data to the usage data.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer', @level2type = N'COLUMN', @level2name = N'VisitorID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Beam customer registration data.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Beam_Customer';

