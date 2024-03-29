﻿CREATE TABLE [Reference].[TicketRestriction] (
    [TicketRestrictionID]          INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                         NVARCHAR (256)  NULL,
    [Description]                  NVARCHAR (4000) NULL,
    [CreatedDate]                  DATETIME        NOT NULL,
    [CreatedBy]                    INT             NOT NULL,
    [LastModifiedDate]             DATETIME        NOT NULL,
    [LastModifiedBy]               INT             NOT NULL,
    [ArchivedInd]                  BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID]          INT             NOT NULL,
    [Code]                         NVARCHAR (2)    NOT NULL,
    [OutboundDescription]          NVARCHAR (256)  NULL,
    [ReturnDescription]            NVARCHAR (256)  NULL,
    [SourceCreatedDate]            DATETIME        NOT NULL,
    [SourceModifiedDate]           DATETIME        NOT NULL,
    [NRESName]                     NVARCHAR (64)   NULL,
    [NRESOutward_Direction]        NVARCHAR (32)   NULL,
    [NRESReturn_Direction]         NVARCHAR (32)   NULL,
    [NRESOutward_Status]           NVARCHAR (64)   NULL,
    [NRESReturn_Status]            NVARCHAR (64)   NULL,
    [NRESRestriction_Type]         NVARCHAR (16)   NULL,
    [NRESDetail_Page_Link]         NVARCHAR (128)  NULL,
    [NRESRestriction_Identifier]   NVARCHAR (64)   NULL,
    [NRESEasement_Info]            NVARCHAR (MAX)  NULL,
    [NRESApplicable_Days_Info]     NVARCHAR (512)  NULL,
    [NRESNotes]                    NVARCHAR (MAX)  NULL,
    [NRESSeasonal_Variations_Info] NVARCHAR (MAX)  NULL,
    [ExtReference]                 NVARCHAR (256)  NULL,
    [ValidityStartDate]            DATETIME        NOT NULL,
    [ValidityEndDate]              DATETIME        NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_TicketRestriction] PRIMARY KEY CLUSTERED ([TicketRestrictionID] ASC),
    CONSTRAINT [FK_TicketRestriction_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

