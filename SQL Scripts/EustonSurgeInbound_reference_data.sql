use crm

declare @InformationSourceID INT, @DataImportTypeID INT

insert into Reference.InformationSource 
(Name, Description,CreatedDate, CreatedBy, LastModifiedDate
,LastModifiedBy,  DisplayName, TypeCode)
select 'Euston Surge ', 'GoMedia - sevice message provider',getdate(),0
,getdate(),0, 'Euston Surge Inbound','External'

select @InformationSourceID = SCOPE_IDENTITY()


insert into Reference.DataImportType
(name, Description, CreatedDate, CreatedBy, LastModifiedDate
,LastModifiedBy, ArchivedInd, InformationSourceID)
select 'Go Media Euston Surge Inbound','Used to process go media euston surge inbound extract'
,getdate(),0,getdate(),0,0,@InformationSourceID

select @DataImportTypeID = SCOPE_IDENTITY()

insert into Reference.DataImportDefinition 
(Name, Description, CreatedDate, CreatedBy, LastModifiedDate, LastModifiedBy
,ArchivedInd, DataImportTypeID, ProcessingOrder, DestinationTable, TypeCode
,LocalCopyInd)
select 'Go Media Euston Surge Inbound','Used to support processing of the go media euston surge inbound csv extract File'
,getdate(),0, getdate(),0,0,@DataImportTypeID,1,'EustonSurge_Inbound',0,0

select *
from MetadataFileSpecification

insert into MetadataFileSpecification
(FileSpecificationName, FileDescription, FileNameWildCard)
select 'Euston Surge Inbound','Euston surge inbound file from go media','blacklist*.csv'