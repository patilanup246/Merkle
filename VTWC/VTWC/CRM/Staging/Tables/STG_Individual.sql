﻿CREATE TABLE [Staging].[STG_Individual] (
    [IndividualID]        INT             IDENTITY (1, 1) NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    [SourceCreatedDate]   DATETIME        NULL,
    [SourceModifiedDate]  DATETIME        NULL,
    [IsStaffInd]          BIT             DEFAULT ((0)) NOT NULL,
    [IsBlackListInd]      BIT             DEFAULT ((0)) NOT NULL,
    [IsTMCInd]            BIT             DEFAULT ((0)) NOT NULL,
    [IsCorporateInd]      BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    [Salutation]          NVARCHAR (64)   NULL,
    [FirstName]           NVARCHAR (64)   NULL,
    [MiddleName]          NVARCHAR (64)   NULL,
    [LastName]            NVARCHAR (64)   NULL,
    [DateFirstPurchase]   DATETIME        NULL,
    [DateLastPurchase]    DATETIME        NULL,
    CONSTRAINT [cndx_PrimaryKey_Stg_Individual] PRIMARY KEY CLUSTERED ([IndividualID] ASC),
    CONSTRAINT [FK_STG_Individual_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);
