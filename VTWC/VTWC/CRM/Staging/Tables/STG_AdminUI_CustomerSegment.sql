CREATE TABLE [Staging].[STG_AdminUI_CustomerSegment] (
    [CustomerSegmentID]  INT             IDENTITY (1, 1) NOT NULL,
    [Name]               NVARCHAR (256)  NOT NULL,
    [Description]        NVARCHAR (4000) NULL,
    [CreatedDate]        DATETIME        NOT NULL,
    [CreatedBy]          INT             NOT NULL,
    [LastModifiedDate]   DATETIME        NOT NULL,
    [LastModifiedBy]     INT             NOT NULL,
    [ArchivedInd]        BIT             CONSTRAINT [DF_STG_AdminUI_CustomerSegment_ArchivedInd] DEFAULT ((0)) NOT NULL,
    [SourceCreatedDate]  DATETIME        NOT NULL,
    [SourceModifiedDate] DATETIME        NOT NULL,
    [EmailAddress]       NVARCHAR (256)  NOT NULL,
    [CustomerReference]  NVARCHAR (128)  NULL,
    [CSGID]              INT             NOT NULL,
    [CSGIDPrevious]      INT             NULL,
    [CSLID]              INT             NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_AdminUI_CustomerSegment] PRIMARY KEY CLUSTERED ([CustomerSegmentID] ASC)
);

