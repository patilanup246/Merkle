CREATE TABLE [Staging].[STG_SurveyQuestions] (
    [SurveyQuestionsID]         INT            IDENTITY (1, 1) NOT NULL,
    [ID]                        INT            NOT NULL,
    [Question]                  NVARCHAR (MAX) NOT NULL,
    [CreatedDate]               DATETIME       NOT NULL,
    [CreatedBy]                 INT            NOT NULL,
    [CreatedExtractNumber]      INT            NULL,
    [LastModifiedDate]          DATETIME       NOT NULL,
    [LastModifiedBy]            INT            NOT NULL,
    [LastModifiedExtractNumber] INT            NULL,
    [ArchivedInd]               BIT            DEFAULT ((0)) NOT NULL,
    [InformationSourceID]       INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_SurveyQuestions] PRIMARY KEY CLUSTERED ([SurveyQuestionsID] ASC),
    CONSTRAINT [FK_STG_SurveyQuestions_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID])
);
GO

