

CREATE PROCEDURE [Operations].[GetDataimportdetailID] 
	@Filetype nvarchar (50),
	@DataImportLogID int

	AS  
BEGIN  
declare @DataimportdetailID int


select @DataimportdetailID = a.DataImportDetailID from  [Operations].[DataImportDetail] a
inner join [Reference].[DataImportDefinition] b on a.DataImportDefinitionID = b.DataImportDefinitionID
where [DataImportLogID] = @DataImportLogID
and  b.[Name] = @Filetype

return @DataimportdetailID
end