CREATE TABLE [Staging].[Searches] (
    [ID]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [CreatedDate]           DATETIME       CONSTRAINT [DF_CreatedDateSearches] DEFAULT (getdate()) NOT NULL,
    [SessionID]             NVARCHAR (50)  NULL,
    [SessionStartDateTime]  DATETIME       NULL,
    [EventDateTime]         DATETIME       NULL,
    [EventSequenceNumber]   INT            NULL,
    [RawVisitorID]          NVARCHAR (512) NULL,
    [ContactEmail]          NVARCHAR (512) NULL,
    [CustomerID]            INT            NULL,
    [CBE_ID]                INT            NULL,
    [AmazeID]               NVARCHAR (256) NULL,
    [OriginNLC]             NVARCHAR (256) NULL,
    [DestinationNLC]        NVARCHAR (256) NULL,
    [ViaNLC]                NVARCHAR (256) NULL,
    [AvoidNLC]              NVARCHAR (256) NULL,
    [Direct]                CHAR (3)       NULL,
    [OutwardDate]           DATE           NULL,
    [OutwardTime]           TIME (7)       NULL,
    [OutwardTimePreference] CHAR (3)       NULL,
    [JourneyType]           NVARCHAR (256) NULL,
    [OpenReturn]            CHAR (3)       NULL,
    [ReturnDate]            DATE           NULL,
    [ReturnTime]            TIME (7)       NULL,
    [ReturnTimePreference]  CHAR (3)       NULL,
    [NoAdults]              INT            NULL,
    [NoChildren]            INT            NULL,
    [Railcards]             NVARCHAR (512) NULL,
    [DeviceType]            NVARCHAR (256) NULL,
    [DeviceBrand]           NVARCHAR (256) NULL,
    [DeviceMarketingName]   NVARCHAR (256) NULL,
    [DeviceModel]           NVARCHAR (256) NULL,
    [City]                  NVARCHAR (256) NULL,
    [Postcode]              NVARCHAR (12)  NULL,
    [Latitude]              NVARCHAR (512) NULL,
    [Longitude]             NVARCHAR (512) NULL,
    CONSTRAINT [PK_Searches] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_Searches_Email]
    ON [Staging].[Searches]([ContactEmail] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_Searches_CustomerID]
    ON [Staging].[Searches]([CustomerID] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_Searches_cookie]
    ON [Staging].[Searches]([RawVisitorID] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_Searches_CBEID]
    ON [Staging].[Searches]([CBE_ID] ASC);

