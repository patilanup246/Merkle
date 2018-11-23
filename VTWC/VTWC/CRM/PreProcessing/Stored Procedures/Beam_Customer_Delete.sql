CREATE PROCEDURE [PreProcessing].[Beam_Customer_Delete]
(
	@userid        int = NULL,
	@VisitorId     uniqueidentifier = NULL
)
AS
BEGIN 
    
    SET NOCOUNT ON;

    DECLARE @RowCount      INTEGER      = 0
    DECLARE @ErrMsg        VARCHAR(MAX)

	DECLARE @spname        NVARCHAR(256)
	DECLARE @logmessage    NVARCHAR(MAX)

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

    SET @logmessage = '@userid = '         +  ISNULL(CAST(@userid AS NVARCHAR(256)),'NULL') +
	                  ', @VisitorId = '    +  ISNULL(CAST(@VisitorId AS NVARCHAR(256)),'NULL')
	    
    EXEC [Operations].[LogMessage_Record] @userid          = @userid,
		                                  @logsource       = @spname,
									      @logmessage      = @logmessage,
										  @logmessagelevel = 'ERROR'
	-- Check if @userid is NULL

	IF @userid IS NULL 
	BEGIN
		SET @ErrMsg = 'User Id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	-- Check if @VisitorId is NULL

	IF @VisitorId IS NULL 
	BEGIN
		SET @ErrMsg = 'Visitor id cannot be NULL';
		THROW 90508, @ErrMsg,1
	END

	--Delete beam customer data

	IF EXISTS (SELECT 1 
			   FROM PreProcessing.Beam_Customer
			   WHERE VisitorID = CAST(@VisitorId AS NVARCHAR(256)))
	BEGIN
		--Delete Beam Customer registration data
		DELETE 
		FROM [PreProcessing].[Beam_Customer]
		WHERE VisitorID = CAST(@VisitorId AS NVARCHAR(256))

		SET @RowCount = @@ROWCOUNT
		
		IF @RowCount = 0
		BEGIN
			SET @ErrMsg = 'Unable to delete beam customer registration data' ;
			THROW 90508, @ErrMsg,1
		END
	END
	   						
    RETURN @RowCount;
END