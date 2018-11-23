--wifi
use crm

declare @InformationSourceID INT, @DataImportTypeID INT

insert into Reference.InformationSource 
(Name, Description,CreatedDate, CreatedBy, LastModifiedDate
,LastModifiedBy,  DisplayName, TypeCode)
select 'McLaren', 'McLaren - WiFi data provider',getdate(),0
,getdate(),0, 'McLaren','External'

select @InformationSourceID = SCOPE_IDENTITY()

insert into Reference.DataImportType
(name, Description, CreatedDate, CreatedBy, LastModifiedDate
,LastModifiedBy, ArchivedInd, InformationSourceID)
select 'McLaren Wifi','Used to process Mclaren Wifi feed'
,getdate(),0,getdate(),0,0,@InformationSourceID

select @DataImportTypeID = SCOPE_IDENTITY()

insert into Reference.DataImportDefinition 
(Name, Description, CreatedDate, CreatedBy, LastModifiedDate, LastModifiedBy
,ArchivedInd, DataImportTypeID, ProcessingOrder, DestinationTable, TypeCode
,LocalCopyInd)
select 'McLaren Wifi','Used to support processing of the McLaren Wifi File'
,getdate(),0, getdate(),0,0,@DataImportTypeID,1,'McLaren_WiFi',0,0


insert into MetadataFileSpecification
(FileSpecificationName, FileDescription, FileNameWildCard)
select 'McLaren Wifi','McLaren Wifi extract file','*VIRGIN_TRAINS_CT*.csv'