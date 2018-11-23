CREATE TABLE [Reference].[FulfilmentMethod] (
    [FulfilmentMethodID]  INT             IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    [DisplayName]         NVARCHAR (32)   NULL,
    [Charge]              DECIMAL (14, 2) NULL,
    [SourceCreatedDate]   DATETIME        NULL,
    [SourceModifiedDate]  DATETIME        NULL,
    [ValidityStartDate]   DATETIME        NULL,
    [ValidityEndDate]     DATETIME        NOT NULL,
    [ShortCode]           NVARCHAR (50)   NULL,
    CONSTRAINT [cndx_PrimaryKey_FulfilmentMethod] PRIMARY KEY CLUSTERED ([FulfilmentMethodID] ASC)
);
GO

