CREATE TABLE [Reference].[InformationSource] (
    [InformationSourceID]   INT             IDENTITY (1, 1) NOT NULL,
    [Name]                  NVARCHAR (256)  NOT NULL,
    [Description]           NVARCHAR (4000) NULL,
    [CreatedDate]           DATETIME        NOT NULL,
    [CreatedBy]             INT             NOT NULL,
    [LastModifiedDate]      DATETIME        NOT NULL,
    [LastModifiedBy]        INT             NOT NULL,
    [ArchivedInd]           BIT             DEFAULT ((0)) NOT NULL,
    [DisplayName]           NVARCHAR (256)  NOT NULL,
    [TypeCode]              NVARCHAR (256)  NOT NULL,
    [ProspectInd]           BIT             DEFAULT ((0)) NOT NULL,
    [AdditionalInformation] NVARCHAR (4000) NULL,
    CONSTRAINT [cndx_PrimaryKey_InformationSource] PRIMARY KEY CLUSTERED ([InformationSourceID] ASC)
);

