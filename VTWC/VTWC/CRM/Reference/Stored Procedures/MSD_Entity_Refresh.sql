CREATE PROCEDURE [Reference].[MSD_Entity_Refresh]
(
	@userid         INTEGER = 0,   
	@return         INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @sourcetable         NVARCHAR(256) = 'Entity'
    DECLARE @destinationtable    NVARCHAR(256) = 'Reference.MSD_Entity'
    DECLARE @sql                 NVARCHAR(MAX)

	DECLARE @spname              NVARCHAR(256)
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT

	--SELECT @sourcetable = [Reference].[Configuration_GetSetting] ('Migration','MSD Source Database') + '.' + 
	--                      [Reference].[Configuration_GetSetting] ('Migration','MSD Source Schema') + '.' +
 --                         @sourcetable

	--SELECT @destinationtable = [Reference].[Configuration_GetSetting] ('Migration','MSD Destination Database') + '.' +
 --                              @destinationtable
     
	----Cleardown destination table
	
	--SELECT @sql = 'DELETE FROM ' + @destinationtable

	--EXEC @return = sp_executesql @stmt = @sql

	--IF @return != 0
	--BEGIN
	--    RETURN
	--END
	                       
 --   SELECT @sql = 'INSERT INTO ' + @destinationtable + ' ' +
 --                 '([EntityId] ' +
 --                 ',[Name] ' +
 --                 ',[ObjectTypeCode] ' +
 --                 ',[PhysicalName] ' +
 --                 ',[LogicalName] ' +
 --                 ',[CollectionName] ' +
 --                 ',[BaseTableName] ' +
 --                 ',[LogicalCollectionName] ' +
 --                 ',[IsIntersect] ' +
 --                 ',[IsSecurityIntersect] ' +
 --                 ',[IsLookupTable] ' +
 --                 ',[EventMask] ' +
 --                 ',[IsLogicalEntity] ' +
 --                 ',[IsCustomizable] ' +
 --                 ',[IsCollaboration] ' +
 --                 ',[IsActivity] ' +
 --                 ',[AddressTableName] ' +
 --                 ',[IsMappable] ' +
 --                 ',[OwnershipTypeMask] ' +
 --                 ',[IsAudited] ' +
 --                 ',[UsesFullnameConventionRules] ' +
 --                 ',[IsParented] ' +
 --                 ',[EntityMask] ' +
 --                 ',[IsReplicated] ' +
 --                 ',[IsReplicationUserFiltered] ' +
 --                 ',[IsChildEntity] ' +
 --                 ',[IsCustomEntity] ' +
 --                 ',[IsActivityParty] ' +
 --                 ',[IsValidForAdvancedFind] ' +
 --                 ',[ExtensionTableName] ' +
 --                 ',[ReportViewName] ' +
 --                 ',[IsRequiredOffline] ' +
 --                 ',[IsRenameable] ' +
 --                 ',[EntityClassName] ' +
 --                 ',[ServiceClassName] ' +
 --                 ',[EntityAssembly] ' +
 --                 ',[ServiceAssembly] ' +
 --                 ',[EntityRowId] ' +
 --                 ',[IsDuplicateCheckSupported] ' +
 --                 ',[IsImportable] ' +
 --                 ',[IsShareableAcrossOrgs] ' +
 --                 ',[IsPublishable] ' +
 --                 ',[OriginalLocalizedName] ' +
 --                 ',[OriginalLocalizedCollectionName] ' +
 --                 ',[CanTriggerWorkflow] ' +
 --                 ',[WorkflowSupport] ' +
 --                 ',[CanBeChildInCustomRelationship] ' +
 --                 ',[CanBeInCustomEntityAssociation] ' +
 --                 ',[CanBeInCustomReflexiveRelationship] ' +
 --                 ',[IsMailMergeEnabled] ' +
 --                 ',[RecurrenceTypeMask] ' +
 --                 ',[RecurrenceBaseEntityId] ' +
 --                 ',[IsDocumentManagementEnabled] ' +
 --                 ',[MobileAccessLevelMask] ' +
 --                 ',[IsVisibleInMobile] ' +
 --                 ',[IsMultipleQueueEnabled] ' +
 --                 ',[AutoRouteToOwnerQueue] ' +
 --                 ',[IsAuditEnabled] ' +
 --                 ',[IsConnectionsEnabled] ' +
 --                 ',[IsReadingPaneEnabled] ' +
 --                 ',[IsMapiGridEnabled] ' +
 --                 ',[IsEnabledForCharts] ' +
 --                 ',[IconLargeName] ' +
 --                 ',[IconMediumName] ' +
 --                 ',[IconSmallName] ' +
 --                 ',[NextCustomAttributeColumnNumber] ' +
 --                 ',[ActivityTypeMask] ' +
 --                 ',[IsSolutionAware] ' +
 --                 ',[SolutionId] ' +
 --                 ',[SupportingSolutionId] ' +
 --                 ',[ComponentState] ' +
 --                 ',[OverwriteTime] ' +
 --                 ',[InheritsFrom] ' +
 --                 ',[IsInheritedFrom] ' +
 --                 ',[CanBeSecured] ' +
 --                 ',[CanModifyConnectionSettings] ' +
 --                 ',[CanModifyDuplicateDetectionSettings] ' +
 --                 ',[CanModifyMailMergeSettings] ' +
 --                 ',[CanModifyQueueSettings] ' +
 --                 ',[CanCreateAttributes] ' +
 --                 ',[CanBeRelatedEntityInRelationship] ' +
 --                 ',[CanBePrimaryEntityInRelationship] ' +
 --                 ',[CanBeInManyToMany] ' +
 --                 ',[CanCreateForms] ' +
 --                 ',[CanCreateCharts] ' +
 --                 ',[CanCreateViews] ' +
 --                 ',[CanModifyAuditSettings] ' +
 --                 ',[CanModifyMobileVisibility] ' +
 --                 ',[ParentComponentType] ' +
 --                 ',[ParentControllingAttributeName] ' +
 --                 ',[IsManaged] ' +
 --                 ',[CanModifyAdditionalSettings]) '

 --       SELECT @sql = @sql + 'SELECT  [EntityId] ' +
 --                 ',[Name] ' +
 --                 ',[ObjectTypeCode] ' +
 --                 ',[PhysicalName] ' +
 --                 ',[LogicalName] ' +
 --                 ',[CollectionName] ' +
 --                 ',[BaseTableName] ' +
 --                 ',[LogicalCollectionName] ' +
 --                 ',[IsIntersect] ' +
 --                 ',[IsSecurityIntersect] ' +
 --                 ',[IsLookupTable] ' +
 --                 ',[EventMask] ' +
 --                 ',[IsLogicalEntity] ' +
 --                 ',[IsCustomizable] ' +
 --                 ',[IsCollaboration] ' +
 --                 ',[IsActivity] ' +
 --                 ',[AddressTableName] ' +
 --                 ',[IsMappable] ' +
 --                 ',[OwnershipTypeMask] ' +
 --                 ',[IsAudited] ' +
 --                 ',[UsesFullnameConventionRules] ' +
 --                 ',[IsParented] ' +
 --                 ',[EntityMask] ' +
 --                 ',[IsReplicated] ' +
 --                 ',[IsReplicationUserFiltered] ' +
 --                 ',[IsChildEntity] ' +
 --                 ',[IsCustomEntity] ' +
 --                 ',[IsActivityParty] ' +
 --                 ',[IsValidForAdvancedFind] ' +
 --                 ',[ExtensionTableName] ' +
 --                 ',[ReportViewName] ' +
 --                 ',[IsRequiredOffline] ' +
 --                 ',[IsRenameable] ' +
 --                 ',[EntityClassName] ' +
 --                 ',[ServiceClassName] ' +
 --                 ',[EntityAssembly] ' +
 --                 ',[ServiceAssembly] ' +
 --                 ',[EntityRowId] ' +
 --                 ',[IsDuplicateCheckSupported] ' +
 --                 ',[IsImportable] ' +
 --                 ',[IsShareableAcrossOrgs] ' +
 --                 ',[IsPublishable] ' +
 --                 ',[OriginalLocalizedName] ' +
 --                 ',[OriginalLocalizedCollectionName] ' +
 --                 ',[CanTriggerWorkflow] ' +
 --                 ',[WorkflowSupport] ' +
 --                 ',[CanBeChildInCustomRelationship] ' +
 --                 ',[CanBeInCustomEntityAssociation] ' +
 --                 ',[CanBeInCustomReflexiveRelationship] ' +
 --                 ',[IsMailMergeEnabled] ' +
 --                 ',[RecurrenceTypeMask] ' +
 --                 ',[RecurrenceBaseEntityId] ' +
 --                 ',[IsDocumentManagementEnabled] ' +
 --                 ',[MobileAccessLevelMask] ' +
 --                 ',[IsVisibleInMobile] ' +
 --                 ',[IsMultipleQueueEnabled] ' +
 --                 ',[AutoRouteToOwnerQueue] ' +
 --                 ',[IsAuditEnabled] ' +
 --                 ',[IsConnectionsEnabled] ' +
 --                 ',[IsReadingPaneEnabled] ' +
 --                 ',[IsMapiGridEnabled] ' +
 --                 ',[IsEnabledForCharts] ' +
 --                 ',[IconLargeName] ' +
 --                 ',[IconMediumName] ' +
 --                 ',[IconSmallName] ' +
 --                 ',[NextCustomAttributeColumnNumber] ' +
 --                 ',[ActivityTypeMask] ' +
 --                 ',[IsSolutionAware] ' +
 --                 ',[SolutionId] ' +
 --                 ',[SupportingSolutionId] ' +
 --                 ',[ComponentState] ' +
 --                 ',[OverwriteTime] ' +
 --                 ',[InheritsFrom] ' +
 --                 ',[IsInheritedFrom] ' +
 --                 ',[CanBeSecured] ' +
 --                 ',[CanModifyConnectionSettings] ' +
 --                 ',[CanModifyDuplicateDetectionSettings] ' +
 --                 ',[CanModifyMailMergeSettings] ' +
 --                 ',[CanModifyQueueSettings] ' +
 --                 ',[CanCreateAttributes] ' +
 --                 ',[CanBeRelatedEntityInRelationship] ' +
 --                 ',[CanBePrimaryEntityInRelationship] ' +
 --                 ',[CanBeInManyToMany] ' +
 --                 ',[CanCreateForms] ' +
 --                 ',[CanCreateCharts] ' +
 --                 ',[CanCreateViews] ' +
 --                 ',[CanModifyAuditSettings] ' +
 --                 ',[CanModifyMobileVisibility] ' +
 --                 ',[ParentComponentType] ' +
 --                 ',[ParentControllingAttributeName] ' +
 --                 ',[IsManaged] ' +
 --                 ',[CanModifyAdditionalSettings] ' +
	--			  'FROM ' + @sourcetable

 --   EXEC @return = sp_executesql @stmt = @sql

	SELECT @recordcount = @@ROWCOUNT

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
    RETURN
END