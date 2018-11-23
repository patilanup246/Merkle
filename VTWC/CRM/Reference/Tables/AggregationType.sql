CREATE TABLE [Reference].[AggregationType] (
    [AggregationTypeID] INT             IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (256)  NOT NULL,
    [Description]       NVARCHAR (4000) NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [CreatedBy]         INT             NOT NULL,
    [LastModifiedDate]  DATETIME        NOT NULL,
    [LastModifiedBy]    INT             NOT NULL,
    [ArchivedInd]       BIT             DEFAULT ((0)) NOT NULL,
    [DisplayName]       NVARCHAR (256)  NULL,
    [DisplayOrder]      INT             NULL,
    CONSTRAINT [cndx_PrimaryKey_AggregationTypeID] PRIMARY KEY CLUSTERED ([AggregationTypeID] ASC)
);

