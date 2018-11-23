CREATE TABLE [CRM].[Retention_RAG]
(
	[CustomerID] INT NULL, 
    [FreqRoute_LastTravelled] DATE NULL, 
    [FreqRoute_TimesTravelled] INT NULL, 
    [RAGStatus_FreqRoute] VARCHAR(20) NULL, 
    [LessFreqRoute_LastTravelled] DATE NULL, 
    [LessFreqRoute_TimesTravelled] INT NULL, 
    [RAGStatus_LessFreqRoute] VARCHAR(20) NULL
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Identifier',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Retention_RAG',
    @level2type = N'COLUMN',
    @level2name = N'CustomerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last date travelled for most frequent route',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Retention_RAG',
    @level2type = N'COLUMN',
    @level2name = N'FreqRoute_LastTravelled'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number of journeys',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Retention_RAG',
    @level2type = N'COLUMN',
    @level2name = N'FreqRoute_TimesTravelled'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RAG Status',
    @level0type = N'SCHEMA',
    @level0name = N'CRM',
    @level1type = N'TABLE',
    @level1name = N'Retention_RAG',
    @level2type = N'COLUMN',
    @level2name = N'RAGStatus_FreqRoute'
GO

CREATE INDEX [IX_Retention_RAG_CustomerID] ON [CRM].[Retention_RAG] (CustomerID)
