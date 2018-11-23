CREATE TABLE [Reference].[SegmentTier] (
    [SegmentTierID]    INT             IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (256)  NOT NULL,
    [Description]      NVARCHAR (4000) NULL,
    [CreatedDate]      DATETIME        NOT NULL,
    [CreatedBy]        INT             NOT NULL,
    [LastModifiedDate] DATETIME        NOT NULL,
    [LastModifiedBy]   INT             NOT NULL,
    [ArchivedInd]      BIT             DEFAULT ((0)) NOT NULL,
    [SegmentOrder]     INT             NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_RFVSegmentTier] PRIMARY KEY CLUSTERED ([SegmentTierID] ASC)
);

