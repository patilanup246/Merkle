CREATE PROCEDURE [PreProcessing].[Check_For_Customer]
(
    @userid                INTEGER = 0,
	@tablename             NVARCHAR(256),
	@dataimportdetailid    INTEGER = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql                 NVARCHAR(MAX)
	DECLARE @from                NVARCHAR(512)

	DECLARE @return              INTEGER

	DECLARE @spname              NVARCHAR(256)	
	DECLARE @recordcount         INTEGER
	DECLARE @logtimingidnew      INTEGER

	SELECT @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	--Log start time--
	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingidnew = @logtimingidnew OUTPUT
   
	IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.TABLES
		   WHERE  TABLE_NAME = @tablename
		   AND TABLE_SCHEMA = 'PreProcessing')
    BEGIN

		--CEM Customer ID 
	    IF EXISTS (SELECT 1 
                   FROM INFORMATION_SCHEMA.COLUMNS
		           WHERE  TABLE_NAME = @tablename
		           AND    TABLE_SCHEMA = 'PreProcessing'
		           AND    COLUMN_NAME  = 'CustomerID')
        BEGIN
		    SELECT @from = 'FROM Preprocessing.' + @tablename + ' a, ' +
	                       'Staging.STG_KeyMapping b ' +
					       'WHERE a.CustomerID = b.CustomerID ' +
					       'AND   b.CustomerID IS NOT NULL ' +
					       'AND   a.ProcessedInd = 0 ' +
				           'AND   a.DataImportDetailID ' + CAST(CASE WHEN @dataimportdetailid IS NULL THEN 'IS NULL' ELSE ' = ' + CAST(@dataimportdetailid AS NVARCHAR(16)) END AS NVARCHAR(16))
  
            SELECT @sql = 'UPDATE a ' + 
                          'SET MatchedInd = 1 ' +
                          @from

            EXEC @return = dbo.sp_executesql @stmt = @sql
        END

		--webTISID
        IF EXISTS (SELECT 1 
                   FROM INFORMATION_SCHEMA.COLUMNS
		           WHERE  TABLE_NAME = @tablename
		           AND    TABLE_SCHEMA = 'PreProcessing'
		           AND    COLUMN_NAME  = 'webTISID')
        BEGIN
		    SELECT @from = 'FROM Preprocessing.' + @tablename + ' a, ' +
	                       'Staging.STG_KeyMapping b ' +
					       'WHERE a.webTISID = b.webTISID ' +
					       'AND   b.CustomerID IS NOT NULL ' +
					       'AND   a.ProcessedInd = 0 ' +
				           'AND   a.DataImportDetailID ' + CAST(CASE WHEN @dataimportdetailid IS NULL THEN 'IS NULL' ELSE ' = ' + CAST(@dataimportdetailid AS NVARCHAR(16)) END AS NVARCHAR(16))

            SELECT @sql = 'UPDATE a ' + 
                          'SET MatchedInd = 1, ' +
				          '    CustomerID = b.CustomerID ' +
                          @from

            EXEC @return = sp_executesql @stmt = @sql
        END
  
		--Emails 
	    IF EXISTS (SELECT 1 
                   FROM INFORMATION_SCHEMA.COLUMNS
		           WHERE  TABLE_NAME = @tablename
		           AND    TABLE_SCHEMA = 'PreProcessing'
		           AND    COLUMN_NAME  = 'ParsedAddressEmail')
        BEGIN
		    SELECT @from = 'FROM Preprocessing.' + @tablename + ' a, ' +
	                       'Staging.STG_ElectronicAddress b, ' +
			    	       'Reference.AddressType c ' +
				           'WHERE a.ParsedAddressEmail = b.ParsedAddress ' +
				           'AND   b.AddressTypeID = c.AddressTypeID ' +
				           'AND   c.Name = ' + '''' + 'Email' + ''' ' +
					       'AND   b.CustomerID IS NOT NULL ' +
				           'AND   a.ProcessedInd = 0 ' +
					       'AND   a.MatchedInd = 0 ' +
				           'AND   a.DataImportDetailID ' + CAST(CASE WHEN @dataimportdetailid IS NULL THEN 'IS NULL' ELSE ' = ' + CAST(@dataimportdetailid AS NVARCHAR(16)) END AS NVARCHAR(16))
  
            SELECT @sql = 'UPDATE a ' + 
                          'SET MatchedInd = 1, ' +
				    	  '    CustomerID = b.CustomerID ' +
                          @from

            EXEC @return = sp_executesql @stmt = @sql
        END

		--Mobiles

	    IF EXISTS (SELECT 1 
                   FROM INFORMATION_SCHEMA.COLUMNS
		           WHERE  TABLE_NAME = @tablename
		           AND    TABLE_SCHEMA = 'PreProcessing'
		           AND    COLUMN_NAME  = 'ParsedAddressMobile')
        BEGIN
		    SELECT @from = 'FROM Preprocessing.' + @tablename + ' a, ' +
	                       'Staging.STG_ElectronicAddress b, ' +
				           'Reference.AddressType c ' +
				           'WHERE a.ParsedAddressMobile = b.ParsedAddress ' +
				           'AND   b.AddressTypeID = c.AddressTypeID ' +
				           'AND   c.Name = ' + '''' + 'Mobile' + ''' ' +
					       'AND   b.CustomerID IS NOT NULL ' +
				           'AND   a.ProcessedInd = 0 ' +
					       'AND   a.MatchedInd = 0 ' +
				           'AND   a.DataImportDetailID ' + CAST(CASE WHEN @dataimportdetailid IS NULL THEN 'IS NULL' ELSE ' = ' + CAST(@dataimportdetailid AS NVARCHAR(16)) END AS NVARCHAR(16))
  
            SELECT @sql = 'UPDATE a ' + 
                          'SET MatchedInd = 1, ' +
				    	  '    CustomerID = b.CustomerID ' +
                          @from

            EXEC @return = sp_executesql @stmt = @sql
        END

    END

    SELECT @recordcount = @@ROWCOUNT

	--Log end time

	EXEC [Operations].[LogTiming_Record] @userid         = @userid,
	                                     @logsource      = @spname,
										 @logtimingid    = @logtimingidnew,
										 @recordcount    = @recordcount,
										 @logtimingidnew = @logtimingidnew OUTPUT
	RETURN
END