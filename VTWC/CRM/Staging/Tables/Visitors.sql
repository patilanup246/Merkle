CREATE TABLE [Staging].[Visitors] (
    [ContactEmail]      NVARCHAR (512) NULL,
    [ExternalVisitorId] NVARCHAR (512) NULL,
    [RawVisitorId]      NVARCHAR (512) NULL,
    [CEM_ID]            NVARCHAR (512) NULL,
    [CBE_ID]            INT            NULL,
    [AmazeID]           NVARCHAR (256) NULL,
    [CreatedDate]       DATETIME       DEFAULT (getdate()) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [ix_Visitors_VisitorID_ContactEmail]
    ON [Staging].[Visitors]([RawVisitorId] ASC)
    INCLUDE([ContactEmail], [ExternalVisitorId]);


GO
CREATE NONCLUSTERED INDEX [ix_Visitors_VisitorID]
    ON [Staging].[Visitors]([RawVisitorId] ASC);

