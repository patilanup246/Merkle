--beam
use crm

declare @InformationSourceID INT, @DataImportTypeID INT

insert into Reference.InformationSource 
(Name, Description,CreatedDate, CreatedBy, LastModifiedDate
,LastModifiedBy,  DisplayName, TypeCode)
select 'Beam', 'Beam multi-media service',getdate(),0
,getdate(),0, 'Beam','External'

select @InformationSourceID = SCOPE_IDENTITY()

insert into Reference.DataImportType
(name, Description, CreatedDate, CreatedBy, LastModifiedDate
,LastModifiedBy, ArchivedInd, InformationSourceID)
select 'Go Media Beam','Used to process go media beam extract'
,getdate(),0,getdate(),0,0,@InformationSourceID

select @DataImportTypeID = SCOPE_IDENTITY()

insert into Reference.DataImportDefinition 
(Name, Description, CreatedDate, CreatedBy, LastModifiedDate, LastModifiedBy
,ArchivedInd, DataImportTypeID, ProcessingOrder, DestinationTable, TypeCode
,LocalCopyInd)
select 'Go Media Beam','Used to support processing of the go media beam csv extract File'
,getdate(),0, getdate(),0,0,@DataImportTypeID,1,'Beam_Customer',0,0

insert into MetadataFileSpecification
(FileSpecificationName, FileDescription, FileNameWildCard)
select 'Go Media Beam','Beam extract file from go media','*Beam.csv'