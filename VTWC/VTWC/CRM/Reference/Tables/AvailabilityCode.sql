CREATE TABLE [Reference].[AvailabilityCode] (
    [AvailabilityCodeID]  INT             IDENTITY (1, 1) NOT NULL,
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
    [URLInformation]      NVARCHAR (512)  NULL,
    CONSTRAINT [cndx_PrimaryKey_AvailabilityCode] PRIMARY KEY CLUSTERED ([AvailabilityCodeID] ASC),
    CONSTRAINT [FK_AvailabilityCode_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);
GO

