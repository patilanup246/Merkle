CREATE TABLE [Production].[ModelSegmentCustomer] (
    [ModelSegmentCustomerID] INT             IDENTITY (1, 1) NOT NULL,
    [Name]                   NVARCHAR (256)  NOT NULL,
    [Description]            NVARCHAR (4000) NULL,
    [CreatedDate]            DATETIME        NOT NULL,
    [CreatedBy]              INT             NOT NULL,
    [LastModifiedDate]       DATETIME        NOT NULL,
    [LastModifiedBy]         INT             NOT NULL,
    [ArchivedInd]            BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID]    INT             NOT NULL,
    [CustomerID]             INT             NOT NULL,
    [ModelSegmentID]         INT             NOT NULL,
    [ModelRunID]             INT             NOT NULL,
    [Score]                  DECIMAL (14, 2) NULL,
    [RSID]                   NVARCHAR (256)  NULL,
    [TravelDate]             DATETIME        NULL,
    [SurveyDate]             DATETIME        NULL,
    CONSTRAINT [cndx_PrimaryKey_ModelSegmentCustomer] PRIMARY KEY CLUSTERED ([ModelSegmentCustomerID] ASC),
    CONSTRAINT [FK_ModelSegmentCustomer_CustomerID] FOREIGN KEY ([CustomerID]) REFERENCES [Staging].[STG_Customer] ([CustomerID]),
    CONSTRAINT [FK_ModelSegmentCustomer_ModelRunID] FOREIGN KEY ([ModelRunID]) REFERENCES [Production].[ModelRun] ([ModelRunID]),
    CONSTRAINT [FK_ModelSegmentCustomer_ModelSegmentID] FOREIGN KEY ([ModelSegmentID]) REFERENCES [Reference].[ModelSegment] ([ModelSegmentID])
);


GO
CREATE NONCLUSTERED INDEX [ix_ModelSegmentCustomer_ModelRunID]
    ON [Production].[ModelSegmentCustomer]([ModelRunID] ASC)
    INCLUDE([CustomerID], [ModelSegmentID]);


GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
    ON [Production].[ModelSegmentCustomer]([Name] ASC, [ModelSegmentID] ASC, [TravelDate] ASC)
    INCLUDE([Score]);

