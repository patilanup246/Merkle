


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Railtimetable].[Archive_JourneyStages] 
	-- Add the parameters for the stored procedure here
	@CutOffDate varchar(32) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @emailSubject varchar(128) = 'Housekeeping on [Rail_Timetable].[dbo].[JourneyStages] SUCCESS'
	DECLARE @emailbody varchar(128) = 'This is an automated message'


    -- Insert statements for procedure here
	IF @CutOffDate IS NULL 
	BEGIN
		SET @CutOffDate = DATEADD(mm, -1, cast(getdate() as date))

	END
	ELSE
	BEGIN
		IF @CutOffDate > DATEADD(mm, -1, cast(getdate() as date))
		BEGIN
			RAISERROR ('Cannot move records from the last month', 16, 1)
			RETURN -1
		END
	END

	BEGIN TRAN

	-- Copy data to archive table
		INSERT INTO [Railtimetable].[JourneyStagesArchive]
		SELECT 
			[rid],
			[uid],
			[trainId],
			[ssd],
			[toc],
			[trainCat],
			[isPassengerSvc],
			[Stage],
			[tpl],
			[act],
			[plat],
			[pta],
			[ptd],
			[wta],
			[wtd],
			[cancelReason],
			[TimeTableID] ,
			[ssd1],
			[LocationID],
			getdate() as [archiveDate]		 
		FROM [Railtimetable].[JourneyStages]
		WHERE cast(ssd as date) < @CutOffDate

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN
			RAISERROR ('Error occured while copying data to [dbo].[JourneyStagesArchive]', 16, 1)
			RETURN -1
		END
	
	-- Remove data from prod table
		DELETE FROM [Railtimetable].[JourneyStages]
		WHERE cast(ssd as date) < @CutOffDate

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN
			RAISERROR ('Error occured while deleting data from [dbo].[JourneyStages]', 16, 1)
			RETURN -1
		END

	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRAN

		--EXEC sp_send_dbmail 
  --  		@profile_name = 'Database mail', 
  --  		@recipients = 'support.vt@merkleinc.com',
  --  		@subject = @emailSubject,
  --  		@body = @emailbody,
  --  		@body_format = 'HTML';
		
		RETURN 0
	END

END