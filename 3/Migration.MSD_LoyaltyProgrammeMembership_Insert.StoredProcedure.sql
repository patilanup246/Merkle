USE [CEM]
GO
/****** Object:  StoredProcedure [Migration].[MSD_LoyaltyProgrammeMembership_Insert]    Script Date: 24/07/2018 14:20:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Migration].[MSD_LoyaltyProgrammeMembership_Insert]
(
    @userid         INTEGER = 0,
	@return         INTEGER OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @source              NVARCHAR(256)
    DECLARE @destinationtable    NVARCHAR(256) = 'Migration.MSD_LoyaltyProgrammeMembership'
	DECLARE @from                NVARCHAR(512)
    DECLARE @sql                 NVARCHAR(MAX)
	
	DECLARE @spname              NVARCHAR(256)	
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT
   
    --Get data
    SELECT @source = [Reference].[Configuration_GetSetting] ('Migration','MSD Source Database') + '.' + 
	                 [Reference].[Configuration_GetSetting] ('Migration','MSD Source Schema') + '.'

	SELECT @destinationtable = [Reference].[Configuration_GetSetting] ('Migration','MSD Destination Database') + '.' +
                               @destinationtable

    SELECT @from = 'FROM ' + @source + 'out_loyaltymembershipBase a, ' +
	               @source + 'out_loyaltymembershipExtensionBase b ' +
				   'WHERE a.out_loyaltymembershipId = b.out_loyaltymembershipId '
  
    SELECT @sql = 'INSERT INTO ' + @destinationtable + ' ' +
                  '([out_loyaltymembershipId] ' +
                  ',[out_customerId] ' +
                  ',[CreatedOn] ' +
                  ',[ModifiedOn] ' +
                  ',[out_loyaltycardnumber] ' +
                  ',[out_loyaltyenddate] ' +
                  ',[out_loyaltystartdate] ' +
                  ',[out_loyaltytype]) '

        SELECT @sql = @sql + 'SELECT b.[out_loyaltymembershipId] ' +
                  ',b.[out_customerId] ' +
                  ',a.[CreatedOn] ' +
                  ',a.[ModifiedOn] ' +
                  ',b.[out_loyaltycardnumber] ' +
                  ',b.[out_loyaltyenddate] ' +
                  ',b.[out_loyaltystartdate] ' +
                  ',b.[out_loyaltytype] ' +
                  @from

    EXEC @return = sp_executesql @stmt = @sql

    SELECT @recordcount = @@ROWCOUNT

	--Log SQL statement
    
	EXEC [Operations].[LogMessage_Record] @userid          = @userid,
	                                      @logsource       = @spname,
										  @logmessage      = @sql,
										  @logmessagelevel = 'DEBUG',
										  @messagetypecd   = 'SQL Check'

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN
END












GO
