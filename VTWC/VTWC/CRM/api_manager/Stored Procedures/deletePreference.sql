  CREATE PROCEDURE [api_manager].[deletePreference] 
     @userid                 int,          -- who has requested the action
     @PreferenceId           int
     
  AS 
  select 1
	--set nocount on;

	--DECLARE @ErrMsg varchar(512)
	--DECLARE @RowCount int = 0
	
	--IF NOT EXISTS (SELECT 1
	--			   FROM Staging.STG_Preference p
	--			   WHERE p.PreferenceID = @PreferenceID AND ArchivedInd = 0)
	--BEGIN
	--	SET @ErrMsg = 'Preference with id ' + CAST(@PreferenceId as varchar) + ' does not exist or is already deleted';
	--	THROW 90508, @ErrMsg,1	
	--END
	--ELSE
	--BEGIN
	--	--DELETE CUSTOMER PREFERENCES
	--	UPDATE Staging.STG_CustomerPreference SET ArchivedInd = 1
	--	WHERE OptionID IN (SELECT OptionID 
	--					   FROM Staging.STG_PreferenceOptions 
	--					   WHERE PreferenceID = @PreferenceId AND ArchivedInd = 0)

	--	--DELETE OPTIONS
	--	UPDATE Staging.STG_PreferenceOptions SET ArchivedInd = 1
	--	WHERE PreferenceID = @PreferenceId AND ArchivedInd = 0
		
	--	--DELETE PREFERENCE
	--	UPDATE Staging.STG_Preference SET ArchivedInd = 1
	--	WHERE PreferenceID = @PreferenceId AND ArchivedInd = 0		
	--END
     
	--SET @RowCount = @@ROWCOUNT

	--IF @RowCount  = 0
	--BEGIN
	--	SET @ErrMsg = 'Unable to delete PreferenceID (' + @PreferenceID + ')' ;
	--	THROW 90508, @ErrMsg,1
	--END  
    
	--RETURN @RowCount;