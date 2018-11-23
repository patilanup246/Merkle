CREATE TABLE [Reference].[Location] (
    [LocationID]             INT             IDENTITY (1, 1) NOT NULL,
    [LocationIDParent]       INT             NULL,
    [Name]                   NVARCHAR (256)  NOT NULL,
    [Description]            NVARCHAR (4000) NULL,
    [TIPLOC]                 NVARCHAR (8)    NULL,
    [NLCCode]                NVARCHAR (256)  NULL,
    [CRSCode]                NVARCHAR (256)  NULL,
    [CATEType]               INT             NULL,
    [3AlphaCode]             NVARCHAR (4)    NULL,
    [3AlphaCodeSub]          NVARCHAR (4)    NULL,
    [Longitude]              NVARCHAR (512)  NULL,
    [Latitude]               NVARCHAR (512)  NULL,
    [Northing]               NVARCHAR (512)  NULL,
    [Easting]                NVARCHAR (512)  NULL,
    [ChangeTime]             INT             NULL,
    [DescriptionATOC]        NVARCHAR (512)  NULL,
    [DescriptionATOC_ATB]    NVARCHAR (512)  NULL,
    [NLCPlusbus]             NVARCHAR (256)  NULL,
    [PTECode]                NVARCHAR (16)   NULL,
    [IsPlusbusInd]           BIT             NULL,
    [IsGroupStationInd]      BIT             NULL,
    [LondonZoneNumber]       INT             NULL,
    [PartOfAllZones]         NVARCHAR (16)   NULL,
    [IDMSDisplayName]        NVARCHAR (256)  NULL,
    [IDMSPrintingName]       NVARCHAR (256)  NULL,
    [IsIDMSAttendedTISInd]   BIT             NULL,
    [IsIDMSUnattendedTISInd] BIT             NULL,
    [IDMSAdviceMessage]      NVARCHAR (256)  NULL,
    [ExtReference]           NVARCHAR (256)  NULL,
    [SourceCreatedDate]      DATETIME        NULL,
    [SourceModifiedDate]     DATETIME        NULL,
    [CreatedDate]            DATETIME        NULL,
    [LastModifiedDate]       DATETIME        NULL,
    CONSTRAINT [cndx_PrimaryKey_Location] PRIMARY KEY CLUSTERED ([LocationID] ASC),
    CONSTRAINT [FK_Location_LocationIDParent] FOREIGN KEY ([LocationIDParent]) REFERENCES [Reference].[Location] ([LocationID])
);


GO
CREATE NONCLUSTERED INDEX [ix_Location_Name_CRS]
    ON [Reference].[Location]([Name] ASC)
    INCLUDE([LocationID], [CRSCode]);


GO

CREATE NONCLUSTERED INDEX IX_Reference_Location_CRSCODE ON [Reference].[Location] ([CRSCode]) INCLUDE ([LocationID])
