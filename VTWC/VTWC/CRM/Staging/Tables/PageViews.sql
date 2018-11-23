CREATE TABLE [Staging].[PageViews] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [CreatedDate]          DATETIME        CONSTRAINT [DF_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [SessionID]            NVARCHAR (50)   NULL,
    [SessionStartDateTime] DATETIME        NULL,
    [EventDateTime]        DATETIME        NULL,
    [EventSequenceNumber]  INT             NULL,
    [RawVisitorID]         VARCHAR (512)   NULL,
    [ContactEmail]         NVARCHAR (512)  NULL,
    [CustomerID]           INT             NULL,
    [CBE_ID]               INT             NULL,
    [AmazeID]              NVARCHAR (256)  NULL,
    [ContentGroup]         NVARCHAR (256)  NULL,
    [ContentSubGroup]      NVARCHAR (256)  NULL,
    [PageTitle]            NVARCHAR (256)  NULL,
    [PageURL]              NVARCHAR (4000) NULL,
    [CampaignID]           NVARCHAR (256)  NULL,
    [DeviceType]           NVARCHAR (256)  NULL,
    [DeviceBrand]          NVARCHAR (256)  NULL,
    [DeviceMarketingName]  NVARCHAR (256)  NULL,
    [DeviceModel]          NVARCHAR (256)  NULL,
    [City]                 NVARCHAR (256)  NULL,
    [Postcode]             NVARCHAR (50)   NULL,
    [Latitude]             NVARCHAR (512)  NULL,
    [Longitude]            NVARCHAR (512)  NULL,
    CONSTRAINT [PK_PageViews] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_PageViews_CustomerID]
    ON [Staging].[PageViews]([CustomerID] ASC)
    INCLUDE([CBE_ID], [ContactEmail], [RawVisitorID]);


GO
CREATE NONCLUSTERED INDEX [ix_pageview_date]
    ON [Staging].[PageViews]([EventDateTime] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_page_view_visitor]
    ON [Staging].[PageViews]([RawVisitorID] ASC);

