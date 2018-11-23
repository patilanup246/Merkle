use crm

declare @InformationSourceID INT, @DataImportTypeID INT

insert into Reference.InformationSource 
(Name, Description,CreatedDate, CreatedBy, LastModifiedDate
,LastModifiedBy,  DisplayName, TypeCode)
select 'NAS', 'Net Advocacy Score',getdate(),0
,getdate(),0, 'NAS','External'

select @InformationSourceID = SCOPE_IDENTITY()

insert into Reference.DataImportType
(name, Description, CreatedDate, CreatedBy, LastModifiedDate
,LastModifiedBy, ArchivedInd, InformationSourceID)
select 'NAS','Used to process NAS survey questions, responses extract'
,getdate(),0,getdate(),0,0,@InformationSourceID

select @DataImportTypeID = SCOPE_IDENTITY()


insert into Reference.DataImportDefinition 
(Name, Description, CreatedDate, CreatedBy, LastModifiedDate, LastModifiedBy
,ArchivedInd, DataImportTypeID, ProcessingOrder, DestinationTable, TypeCode
,LocalCopyInd)
select 'TOC Plus NAS Survey Questions','Used to support processing of the TOC Plus survey questions File'
,getdate(),0, getdate(),0,0,@DataImportTypeID,1,'TOCPLUS_NAS_Question',0,0

insert into Reference.DataImportDefinition 
(Name, Description, CreatedDate, CreatedBy, LastModifiedDate, LastModifiedBy
,ArchivedInd, DataImportTypeID, ProcessingOrder, DestinationTable, TypeCode
,LocalCopyInd)
select 'TOC Plus NAS Survey Push Responses','Used to support processing of the TOC Plus survey push responses File'
,getdate(),0, getdate(),0,0,@DataImportTypeID,2,'TOCPLUS_NAS_Push_Responses',0,0

insert into Reference.DataImportDefinition 
(Name, Description, CreatedDate, CreatedBy, LastModifiedDate, LastModifiedBy
,ArchivedInd, DataImportTypeID, ProcessingOrder, DestinationTable, TypeCode
,LocalCopyInd)
select 'TOC Plus NAS Survey Pull Responses','Used to support processing of the TOC Plus survey pull responses File'
,getdate(),0, getdate(),0,0,@DataImportTypeID,3,'TOCPLUS_NAS_Pull_Responses',0,0

insert into MetadataFileSpecification
(FileSpecificationName, FileDescription, FileNameWildCard)
select 'NAS Survey Questions','Survey questions extract file','*_Questions*.csv'

insert into MetadataFileSpecification
(FileSpecificationName, FileDescription, FileNameWildCard)
select 'NAS Survey Push Responses','Survey push responses extract file','*_PUSH_Responses_*.csv'

insert into MetadataFileSpecification
(FileSpecificationName, FileDescription, FileNameWildCard)
select 'NAS Survey Pull Responses','Survey pull responses extract file','*_PULL_Responses_*.csv'