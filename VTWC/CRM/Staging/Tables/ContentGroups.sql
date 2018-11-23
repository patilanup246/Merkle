CREATE TABLE [Staging].[ContentGroups] (
    [PageURL]          NVARCHAR (4000) NULL,
    [ContentGroup]     NVARCHAR (256)  NULL,
    [ContentSub-Group] NVARCHAR (256)  NULL,
    [CreatedDate]      DATETIME        DEFAULT (getdate()) NOT NULL
);

