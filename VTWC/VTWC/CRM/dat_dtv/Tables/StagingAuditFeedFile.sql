CREATE TABLE [dat_dtv].[StagingAuditFeedFile] (
    [FeedFileKey]   INT           IDENTITY (1, 1) NOT NULL,
    [PkgExecKey]    VARCHAR (50)  NOT NULL,
    [SourceFolder]  VARCHAR (255) NOT NULL,
    [ProcessFolder] VARCHAR (255) NOT NULL,
    [RowData]       VARCHAR (100) NOT NULL,
    [ProcessedDate] DATETIME      CONSTRAINT [DF__DatDTVAuditFeed__Proce__37A5467C] DEFAULT (getdate()) NOT NULL,
    [FileName]      AS            (reverse(substring(reverse([RowData]),(0),charindex(' ',reverse([RowData]))))),
    [FileSizeBytes] AS            (rtrim(ltrim(substring(reverse(substring(reverse([RowData]),charindex(' ',reverse([RowData]))+(1),charindex('  ',reverse([RowData])))),charindex('  ',reverse(substring(reverse([RowData]),charindex(' ',reverse([RowData]))+(1),charindex('  ',reverse([RowData]))))),(20))))),
    [CreateDate]    AS            (substring([RowData],(0),charindex('  ',[RowData]))),
    [FileStatus]    VARCHAR (15)  DEFAULT ('Unknown') NOT NULL,
    CONSTRAINT [PK_DatDTVAuditFeedFile] PRIMARY KEY CLUSTERED ([FeedFileKey] ASC)
);

