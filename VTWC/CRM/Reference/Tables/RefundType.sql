﻿CREATE TABLE [Reference].[RefundType] (
    [RefundTypeID]         INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                 NVARCHAR (256)  NULL,
    [Description]          NVARCHAR (4000) NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [CreatedBy]            INT             NOT NULL,
    [LastModifiedDate]     DATETIME        NOT NULL,
    [LastModifiedBy]       INT             NOT NULL,
    [ArchivedInd]          BIT             DEFAULT ((0)) NOT NULL,
    [SourceCreatedDate]    DATETIME        NOT NULL,
    [SourceModifiedDate]   DATETIME        NOT NULL,
    [InformationSourceID]  INT             NOT NULL,
    [Code]                 NVARCHAR (4)    NULL,
    [TicketTypeCode]       NVARCHAR (16)   NULL,
    [IsSumDaysRequiredInd] BIT             DEFAULT ((0)) NULL,
    [ExtReference]         NVARCHAR (256)  NULL,
    [ValidityStartDate]    DATETIME        NOT NULL,
    [ValidityEndDate]      DATETIME        NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_RefundType] PRIMARY KEY CLUSTERED ([RefundTypeID] ASC),
    CONSTRAINT [FK_RefundType_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

