CREATE TABLE [dbo].[AuditFeedFile] (
    [FeedFileKey]          INT           IDENTITY (1, 1) NOT NULL,
    [PkgExecKey]           INT           DEFAULT ((-1)) NOT NULL,
    [FileSpecificationKey] INT           NULL,
    [SourceFolder]         VARCHAR (255) NULL,
    [ProcessFolder]        VARCHAR (255) NULL,
    [ArchiveFolder]        VARCHAR (255) NULL,
    [ErrorFolder]          VARCHAR (255) NULL,
    [OriginalFileName]     VARCHAR (100) NULL,
    [ProcessedFileName]    VARCHAR (100) NULL,
    [VerifyReference]      CHAR (32)     NULL,
    [DropDate]             DATETIME      NULL,
    [DropRowCount]         INT           NULL,
    [DropFileSize]         BIGINT        NULL,
    [PreProcessMessage]    VARCHAR (255) NULL,
    [ProcessStatus]        VARCHAR (15)  NULL,
    [ProcessedDate]        DATETIME      NULL,
    [ProcessingRowCount]   INT           NULL,
    [ProcessingFileSize]   BIGINT        NULL,
    [ETLStartDate]         DATETIME      NULL,
    [ETLStopDate]          DATETIME      NULL,
    [SuccessFlag]          CHAR (1)      NULL,
    [ExtractGoodCount]     INT           NULL,
    [ExtractErrorCount]    INT           NULL,
    [FeedType]             VARCHAR (20)  NULL,
    [ShowInLoadReport]     CHAR (1)      DEFAULT ('N') NULL,
    [EDPTrackingCode]      CHAR (36)     NULL,
    [DateCreated]          DATETIME      DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_AuditFeedFile] PRIMARY KEY NONCLUSTERED ([FeedFileKey] ASC),
    CONSTRAINT [FK_AuditFeedFile_PkgExecKey] FOREIGN KEY ([PkgExecKey]) REFERENCES [dbo].[AuditPkgExecution] ([PkgExecKey])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the row was inserted into the database.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code used by EDP process', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'EDPTrackingCode';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'EDP Tracking Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'EDPTrackingCode';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ShowInLoadReport';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Should this audit row be shown in the standard Data Load Summary report?  One of ''Y''=Yes or ''N''=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ShowInLoadReport';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Y, N', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ShowInLoadReport';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Show In Load Report', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ShowInLoadReport';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The type of feed file. (e.g. Customer, Sales etc.)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FeedType';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Feed Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FeedType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A count of the number of rows that had error when being extracted from the source file.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ExtractErrorCount';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Extract Error Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ExtractErrorCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A count of the number of rows that were extracted from the source file.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ExtractGoodCount';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Extract Good Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ExtractGoodCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Did package execution complete without error?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'Y, N', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Success Flag', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'SuccessFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the ETL process finished.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ETLStopDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'ETL Finish Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ETLStopDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the ETL process started.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ETLStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'ETL Start Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ETLStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The size of the file after any production processing has taken place in bytes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessingFileSize';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Processing File Size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessingFileSize';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The number of rows that were processed sucessfully by Production.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessingRowCount';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Processing Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessingRowCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the file was moved to the Process folder by Production.  This is the date/time production processing finished.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Processed Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'States the status of Data Services Processing.  One of ''Received'' - File was received into the S/FTP site, ''Mirrored'' - File was sucessfully mirrored, ''PARMS Started'' - File was picked up by PARMS process, ''Verify Started'' - File was picked up by Verify process or ''Success'' - File processed sucessfully, ''Duplicate'' - File was not processed because a duplicate file was found, ''FormatError'' - File processing was abandoned due to format errors, ''BadLines'' - File was processed, but some lines were rejected due to format errors.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessStatus';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Process Status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A place to record any pre-processing messages that might help the auditing process.  ''NameChange'' - File processed sucessfully, but its name was changed,  ''Overwrite'' - File was processed, but a file with the same name was overwritten.  E.g. DAT and DEM files that have to be processed in pairs.  If one is not available this would contain the message ''DAT file has no DEM'' or ''DEM file has no DAT''.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'PreProcessMessage';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Pre-process Message', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'PreProcessMessage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The size of the file as received from the customer in bytes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'DropFileSize';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Drop File Size', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'DropFileSize';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The number of rows that were in the original file.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'DropRowCount';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Drop Row Count', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'DropRowCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The date and time the file was delivered to the FTP folder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'DropDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Drop Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'DropDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Verify generated GUID (less the hyphens).  This is generated by the PARMS process and written to the table when this row is inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'VerifyReference';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Verify Reference', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'VerifyReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the feed file that was processed.  This may be different from the name of the file that was received.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessedFileName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Processed File Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessedFileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The name of the feed file that was received.  This file name may be changed by the receipt process if a file with the same name has already been archived.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'OriginalFileName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Original File Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'OriginalFileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The folder where the file was moved to if an error occured.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ErrorFolder';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Error folder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ErrorFolder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The folder where the file was archived.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ArchiveFolder';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Archive Folder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ArchiveFolder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The folder where the file was delivered to by the Production process.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessFolder';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Process Folder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'ProcessFolder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The folder where the file was picked up from by the Production process.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'SourceFolder';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Source Folder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'SourceFolder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'File specificationKey from MetadataFileSpecification', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FileSpecificationKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'File Specification Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FileSpecificationKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to AuditPkgExecution.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'FK To', @value = N'AuditPkgExecution.PkgExecKey', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Pkg Exec Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'PkgExecKey';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Feed File Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile', @level2type = N'COLUMN', @level2name = N'FeedFileKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Audit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Receives a row for each Feed file processed.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'AuditFeedFile', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditFeedFile';

