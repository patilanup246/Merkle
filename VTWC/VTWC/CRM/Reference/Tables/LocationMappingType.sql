CREATE TABLE [Reference].[LocationMappingType] (
    [TypeID]           INT        IDENTITY (1, 1) NOT NULL,
    [Name]             NCHAR (10) NOT NULL,
    [Description]      NCHAR (10) NULL,
    [CreatedDate]      DATETIME   NOT NULL,
    [CreatedBy]        INT        NOT NULL,
    [LastModifiedDate] DATETIME   NOT NULL,
    [LastModifiedBy]   INT        NOT NULL,
    [ArchivedInd]      BIT        NOT NULL,
    CONSTRAINT [PK_Type] PRIMARY KEY CLUSTERED ([TypeID] ASC)
);

