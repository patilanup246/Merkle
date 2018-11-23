CREATE TABLE [Staging].[STG_Collection] (
    [CollectionID]      INT             IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (256)  NULL,
    [Description]       NVARCHAR (4000) NULL,
    [CreatedDate]       DATETIME        NULL,
    [CreatedBy]         NVARCHAR (256)  NULL,
    [LastModifiedDate]  DATETIME        NULL,
    [LastModifiedBy]    INT             NULL,
    [ArchivedInd]       BIT             DEFAULT ((0)) NULL,
    [CollectionNumber]  INT             NULL,
    [CustomerIDPrimary] INT             NULL,
    [SegmentTierID]     INT             NULL,
    [OptInLeisureInd]   BIT             DEFAULT ((0)) NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_Collection] PRIMARY KEY CLUSTERED ([CollectionID] ASC),
    CONSTRAINT [FK_STG_Collection_SegmentTierID] FOREIGN KEY ([SegmentTierID]) REFERENCES [Reference].[SegmentTier] ([SegmentTierID])
);

