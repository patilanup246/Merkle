CREATE TABLE [Reference].[ResponseCode] (
    [ResponseCodeID]      INT             IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NOT NULL,
    [ResponseCodeTypeID]  INT             NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    CONSTRAINT [cndx_PrimaryKey_ResponseCode] PRIMARY KEY CLUSTERED ([ResponseCodeID] ASC),
    CONSTRAINT [FK_ResponseCode_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_ResponseCode_ResponseCodeTypeID] FOREIGN KEY ([ResponseCodeTypeID]) REFERENCES [Reference].[ResponseCodeType] ([ResponseCodeTypeID])
);

