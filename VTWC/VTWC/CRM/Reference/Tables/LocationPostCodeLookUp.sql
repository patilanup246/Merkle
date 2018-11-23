CREATE TABLE [Reference].[LocationPostCodeLookUp] (
    [PostCodeID]          INT            IDENTITY (1, 1) NOT NULL,
    [PostCodeDistrict]    NCHAR (5)      NOT NULL,
    [KMtoNeaarestStation] NUMERIC (6, 2) NOT NULL,
    [LocationID]          INT            NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [CreatedBy]           INT            NOT NULL,
    [LastModifiedDate]    DATETIME       NOT NULL,
    [LastModifiedBy]      INT            NOT NULL,
    [ArchivedInd]         BIT            NOT NULL,
    CONSTRAINT [PK_PostCodeLocationLookUp] PRIMARY KEY CLUSTERED ([PostCodeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Stores the flag if the record is Archived', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'LocationPostCodeLookUp', @level2type = N'COLUMN', @level2name = N'ArchivedInd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The recent Modification was crried out by', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'LocationPostCodeLookUp', @level2type = N'COLUMN', @level2name = N'LastModifiedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The recent record Modification date', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'LocationPostCodeLookUp', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Who has created this row', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'LocationPostCodeLookUp', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Record Created Date Time', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'LocationPostCodeLookUp', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique Identifier of the Location from Location Table', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'LocationPostCodeLookUp', @level2type = N'COLUMN', @level2name = N'LocationID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kilometer distance to the Nearest Station', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'LocationPostCodeLookUp', @level2type = N'COLUMN', @level2name = N'KMtoNeaarestStation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PostCode Area & District Information ', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'LocationPostCodeLookUp', @level2type = N'COLUMN', @level2name = N'PostCodeDistrict';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for a PostCode', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'LocationPostCodeLookUp', @level2type = N'COLUMN', @level2name = N'PostCodeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Stores PostCode District and Distance to Nearest Station.', @level0type = N'SCHEMA', @level0name = N'Reference', @level1type = N'TABLE', @level1name = N'LocationPostCodeLookUp';

