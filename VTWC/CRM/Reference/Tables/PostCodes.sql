CREATE TABLE [Reference].[PostCodes]
(
	[Id] INT IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL PRIMARY KEY,
    PostCodeDistrict [varchar](9) NOT NULL, 
    Latitude [decimal](18, 15) NOT NULL, 
    Longitude [decimal](18, 15) NOT NULL
)
  
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'First part of postcode',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'PostCodes',
    @level2type = N'COLUMN',
    @level2name = N'PostCodeDistrict'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Latitude of postcode centre',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'PostCodes',
    @level2type = N'COLUMN',
    @level2name = N'Latitude'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Longitude of postcode centre',
    @level0type = N'SCHEMA',
    @level0name = N'Reference',
    @level1type = N'TABLE',
    @level1name = N'PostCodes',
    @level2type = N'COLUMN',
    @level2name = N'Longitude'