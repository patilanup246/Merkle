CREATE TABLE [dbo].[IPW_SendLog] (
    [TCScustomerID]   BIGINT         NULL,
    [emailaddress]    NVARCHAR (100) NULL,
    [CellName]        VARCHAR (512)  NULL,
    [ContactDateTime] DATETIME2 (7)  NULL,
    [RunDate]         DATETIME2 (7)  NULL,
    [TreatmentCode]   VARCHAR (64)   NULL
);

