CREATE TABLE Staging.STG_MclarenWiFiHistory(
KeyMappingID INT NOT NULL,
McLaren_WiFiID INT NOT NULL,
TransactionDateTime DATETIME NOT NULL,
DeviceID NVARCHAR(30),
CountryOfOrigin NVARCHAR(50), 
Language NVARCHAR(100),
DateOfBirth NVARCHAR(30),
AgeGroup NVARCHAR(30),
SiteID NVARCHAR(30),
Location NVARCHAR(30),
SSID NVARCHAR(30),
ProductName NVARCHAR(100),
HasUserPaidForService BIT,
DeviceDetails NVARCHAR(2000),
DataImportDetailID INT
CONSTRAINT PK_McLarenWiFiHistory PRIMARY KEY (KeyMappingID, McLaren_WiFiID)
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'FK to Staging.STG_KeyMapping.KeyMappingID',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'KeyMappingID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique row ID',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'McLaren_WiFiID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'When this transaction happened (Not related to the date when this row was loaded)',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'TransactionDateTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique Device identifier',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'DeviceID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User country of origin',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'CountryOfOrigin'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User language',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'Language'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User date of birth',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'DateOfBirth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User age group',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'AgeGroup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique idetifier for a wifi site',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'SiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Where this connection happened',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'Location'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'WiFi Service Set Identifier',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'SSID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purchased product name',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'ProductName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'OS and borwser information',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'DeviceDetails'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique ID used to track back from where this row is coming from.',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'DataImportDetailID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Flat to know if that user has paid for the service',
    @level0type = N'SCHEMA',
    @level0name = N'Staging',
    @level1type = N'TABLE',
    @level1name = N'STG_MclarenWiFiHistory',
    @level2type = N'COLUMN',
    @level2name = N'HasUserPaidForService'