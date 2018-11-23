CREATE TABLE [Reference].[ModeOfTransport] (
    [ModeOfTransportID]   INT             IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    [ShortCode]           NVARCHAR (16)   NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_ModeOfTransport] PRIMARY KEY CLUSTERED ([ModeOfTransportID] ASC),
    CONSTRAINT [FK_ModeOfTransport_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);
GO

