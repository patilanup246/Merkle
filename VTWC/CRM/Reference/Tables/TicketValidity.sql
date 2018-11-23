﻿CREATE TABLE [Reference].[TicketValidity] (
    [TicketValidityID]    INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    [Code]                NVARCHAR (2)    NOT NULL,
    [OutboundValidity]    NVARCHAR (8)    NULL,
    [ReturnValidity]      NVARCHAR (8)    NULL,
    [StartDate]           DATETIME        NOT NULL,
    [EndDate]             DATETIME        NULL,
    [ReturnAfter]         NVARCHAR (8)    NULL,
    [IsBreakOutbound]     BIT             NULL,
    [IsBreakReturn]       BIT             NULL,
    [OutboundDescription] NVARCHAR (16)   NULL,
    [ReturnDescription]   NVARCHAR (16)   NULL,
    [SourceCreatedDate]   DATETIME        NOT NULL,
    [SourceModifiedDate]  DATETIME        NOT NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_TicketValidity] PRIMARY KEY CLUSTERED ([TicketValidityID] ASC),
    CONSTRAINT [FK_TicketValidity_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

