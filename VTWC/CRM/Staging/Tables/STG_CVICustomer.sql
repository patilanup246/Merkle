CREATE TABLE Staging.STG_CVICustomer (
CustomerID     INT NOT NULL,
CVIQuestionID    INT NOT NULL,
CVIAnswerID      INT NOT NULL,
CreatedDate      DATETIME NOT NULL,
CreatedBy        INT NOT NULL,
LastModifiedDate DATETIME NOT NULL,
LastModifiedBy   INT NOT NULL,
primary key (CustomerID, CVIQuestionID,CVIAnswerID),
CONSTRAINT FK_STG_Customer_Customer FOREIGN KEY (CustomerID)
    REFERENCES Staging.STG_Customer (CustomerID)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE,
CONSTRAINT FK_CVIQuestion_Customer FOREIGN KEY (CVIQuestionID)
    REFERENCES Reference.CVIQuestion (CVIQuestionID)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE,
CONSTRAINT FK_CVIStandardAnswer_Customer FOREIGN KEY (CVIAnswerID)
    REFERENCES Reference.CVIStandardAnswer (CVIAnswerID)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique Customer Identifier',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_CVICustomer',
    @level2type = N'COLUMN',
    @level2name = N'CustomerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique Question Identifier',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_CVICustomer',
    @level2type = N'COLUMN',
    @level2name = N'CVIQuestionID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique Answer Identifier',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_CVICustomer',
    @level2type = N'COLUMN',
    @level2name = N'CVIAnswerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date when this row was created',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_CVICustomer',
    @level2type = N'COLUMN',
    @level2name = N'CreatedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Who has created this row',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_CVICustomer',
    @level2type = N'COLUMN',
    @level2name = N'CreatedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date when this row as modified',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_CVICustomer',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Who has modified this row',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_CVICustomer',
    @level2type = N'COLUMN',
    @level2name = N'LastModifiedBy'