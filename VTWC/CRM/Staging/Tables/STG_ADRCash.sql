﻿CREATE TABLE [Staging].[STG_ADRCash] (
    [ADRCashID]                 INT             IDENTITY (1, 1) NOT NULL,
    [Name]                      NVARCHAR (256)  NULL,
    [Description]               NVARCHAR (4000) NULL,
    [CreatedDate]               DATETIME        NOT NULL,
    [CreatedBy]                 INT             NOT NULL,
    [CreatedExtractNumber]      INT             NULL,
    [LastModifiedDate]          DATETIME        NOT NULL,
    [LastModifiedBy]            INT             NOT NULL,
    [LastModifiedExtractNumber] INT             NULL,
    [ArchivedInd]               BIT             DEFAULT ((0)) NOT NULL,
    [CustomerID]                INT             NULL,
    [SalesTransactionID]        INT             NOT NULL,
    [iTotalDelayMinutes]        INT             NOT NULL,
    [sADRGroup]                 NVARCHAR (10)   NOT NULL,
    [fRefundAmount]             DECIMAL (14, 2) NULL,
    [sDepartureStation]         NVARCHAR (100)  NULL,
    [sDestinationStation]       NVARCHAR (100)  NULL,
    [dtScheduledDepart]         DATETIME        NULL,
    [dtScheduledArrive]         DATETIME        NULL,
    [dtProcessed]               DATETIME        NULL,
    [sVTCaseNumber]             NVARCHAR (20)   NULL,
    [sJourneyReference]         BIGINT          NULL,
    [ExtReference]              NVARCHAR (256)  NOT NULL,
    [InformationSourceID]       INT             NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_STG_ADRCash] PRIMARY KEY CLUSTERED ([ADRCashID] ASC),
    CONSTRAINT [FK_STG_ADRCash_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_STG_ADRCash_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_STG_ADRCash_SalesTransactionID] FOREIGN KEY ([SalesTransactionID]) REFERENCES [Staging].[STG_SalesTransaction] ([SalesTransactionID])
);
GO

