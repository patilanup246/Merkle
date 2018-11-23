CREATE TABLE [Reference].[ResponseCodeType] (
    [ResponseCodeTypeID]  INT             IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (256)  NOT NULL,
    [Description]         NVARCHAR (4000) NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [CreatedBy]           INT             NOT NULL,
    [LastModifiedDate]    DATETIME        NOT NULL,
    [LastModifiedBy]      INT             NOT NULL,
    [ArchivedInd]         BIT             DEFAULT ((0)) NOT NULL,
    [InformationSourceID] INT             NULL,
    [ExtReference]        NVARCHAR (256)  NULL,
    [IsHardBounceInd]     BIT             NULL,
    CONSTRAINT [cndx_PrimaryKey_ResponseCodeType] PRIMARY KEY CLUSTERED ([ResponseCodeTypeID] ASC),
    CONSTRAINT [FK_ResponseCodeType_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);

