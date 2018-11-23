CREATE TABLE [Reference].[LocationGroup] (
    [LocationGroupID]       INT             IDENTITY (1, 1) NOT NULL,
    [Name]                  NVARCHAR (256)  NOT NULL,
    [Description]           NVARCHAR (4000) NULL,
    [CreatedDate]           DATETIME        NOT NULL,
    [CreatedBy]             INT             NOT NULL,
    [LastModifiedDate]      DATETIME        NOT NULL,
    [LastModifiedBy]        INT             NOT NULL,
    [ArchivedInd]           BIT             NOT NULL,
    [LocationGroupIDParent] INT             NULL,
    [LocationCd]            NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_LocationGroup] PRIMARY KEY CLUSTERED ([LocationGroupID] ASC)
);

