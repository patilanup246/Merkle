Create PROCEDURE [dbo].[uspSSISModifyMetadataFileSpecification]
/*===========================================================================================
Name:			uspSSISModifyMetadataFileSpecification
Purpose:		Insert/Update Records to MetadataFileSpecification
Created:		2010-10-04 Nitin Khurana
Modified:		2010-11-03 Colin Thomas
Modified:       2012-05-14 Philip Robinson. Increasing row delimiter size to 10.
Modified:       2012-10-17 Will Read. Added fields to support automation in EDP
Modified:       2012-10-26 Will Read. Added FileSpecificationOptions to support automation in EDP & perhaps other processes
                2012-12-04 Michal Zglinski. Modified script for backward compatibility (when new columns does not exist)
                2013-01-10 Colin Thomas. Changed name from uspSSISModifyMetadataFileSpecification to uspSSISModifyMetadataFileSpecification
										 This will make the procs easier to find
				2014-04-30 Neil Butler. Named back to old to match xlam file.

Peer Review:	
Call script:	EXEC [uspSSISModifyMetadataFileSpecification] 
                    @FileSpecificationName=N'XX_Test'
                    , @FileDescription=N'Contains details of xyz'
                    , @ClientCode=N'GENW'
                    , @SupplierCode=N'GEN'
                    , @FileType=N'CUS'
                    , @FileNameElement4=N'C*'
                    , @FileNameElement5=N'GEN'
                    , @EncodingType=N'U'
                    , @SampleFileName=N'XXXX_GEN_CUS_C*_GEN_U00001_20121017.CSV'
                    , @FileFormat = N'Delimited' --Modified Will Read. 17-Oct-2012. New EDP supporting field
                    , @FileNameWildCard=N'XXXX_GEN_CUS_C*_GEN_*.CSV'
                    , @FieldSeperator=N','
                    , @TextQualifier=N'"'
                    , @RowDelimiter=N'{CR}{LF}'
                    , @CodePage=N'ASCII [Windows-1252]'
                    , @EscapeCharacter = '\' --Modified Will Read. 17-Oct-2012. New EDP supporting field
                    , @CommentCharacter = '-' --Modified Will Read. 17-Oct-2012. New EDP supporting field
	                , @FileHeaders = 'N' --Modified Will Read. 17-Oct-2012. New EDP supporting field
                    , @TransferMethod=N'SFTP'
                    , @TransferFrequency=N'Daily'
                    , @FullOrIncremental=N'Records changed since midnight the previous day'
                    , @FilterCriteria=N'None'
                    , @DeletedRecords=N'Records are not deleted in the source'
                    , @RejectedRows=N'Returned to supplier via FTP/SFTP site'
                    , @ColumnMetadataLocked=N'N'
                    , @AdditionalColumnDestination=N'Add as customer attribute'
                    , @FileSpecificationOptions
                    
                    Select * from MetadataFileSpecification where FileSpecificationName='XX_Test'
=================================================================================================*/
(
     @FileSpecificationName             VARCHAR(500)
    ,@FileDescription                   VARCHAR(8000)
    ,@ClientCode                        CHAR(3)
    ,@SupplierCode                      CHAR(3)
    ,@FileType                          CHAR(3)
    ,@FileNameElement4                  CHAR(3)
    ,@FileNameElement5                  CHAR(3)
    ,@EncodingType                      CHAR(1)
    ,@FileNameWildCard                  VARCHAR(100)
    ,@SampleFileName                    VARCHAR(100)
    ,@FileFormat                        VARCHAR(50) = NULL --Modified Will Read. 17-Oct-2012. New EDP supporting field
    ,@FieldSeperator                    VARCHAR(5)
	,@TextQualifier                     VARCHAR(5)
	,@RowDelimiter                      VARCHAR(10)
	,@CodePage                          VARCHAR(100) --Modified Will Read. 17-Oct-2012. Increased size of existing field from 5 to 100
	,@EscapeCharacter                   VARCHAR(10) = NULL --Modified Will Read. 17-Oct-2012. New EDP supporting field
	,@CommentCharacter                  VARCHAR(10) = NULL --Modified Will Read. 17-Oct-2012. New EDP supporting field
	,@FileHeaders                       VARCHAR(1) = NULL --Modified Will Read. 17-Oct-2012. New EDP supporting field
    ,@TransferMethod                    VARCHAR(500)
    ,@TransferFrequency                 VARCHAR(500)
    ,@FullOrIncremental                 VARCHAR(500)
    ,@FilterCriteria                    VARCHAR(500)
    ,@DeletedRecords                    VARCHAR(500)
    ,@RejectedRows                      VARCHAR(500)
    ,@ColumnMetadataLocked              CHAR(1)
    ,@AdditionalColumnDestination       VARCHAR(50)
	,@FileSpecificationOptions			VARCHAR(4000) = NULL --Modified Will Read. 17-Oct-2012. New EDP supporting field
)
AS BEGIN
SET XACT_ABORT ON;

BEGIN TRANSACTION
BEGIN TRY
    -- START YOUR DDL HERE
    DECLARE @EDPRequiredFieldsArePopulated BIT = 0; --set a default value of "NO"
    
    DECLARE @CountTheNumberOfEDPFields INT = (
    	SELECT COUNT(1) FROM sys.all_columns WHERE OBJECT_ID = OBJECT_ID('MetadataFileSpecification')
	    AND name IN ('FileFormat', 'EscapeCharacter', 'CommentCharacter', 'FileHeaders', 'FileSpecificationOptions')
    )
    
    --Check if any of the EPD fields are populated
    IF @FileFormat IS NOT NULL 
        OR @EscapeCharacter IS NOT NULL 
        OR @CommentCharacter IS NOT NULL 
        OR @FileHeaders IS NOT NULL
        OR @FileSpecificationOptions IS NOT NULL
    BEGIN
        SET @EDPRequiredFieldsArePopulated = 1;
    END
        
    
	IF NOT EXISTS(SELECT * FROM MetadataFileSpecification WHERE FileSpecificationName = @FileSpecificationName)
    BEGIN
        INSERT MetadataFileSpecification
        (
            FileSpecificationName 
           ,FileDescription 
           ,ClientCode 
           ,SupplierCode 
           ,FileType 
           ,FileNameElement4
           ,FileNameElement5
           ,EncodingType
           ,FileNameWildCard 
           ,SampleFileName
           ,FieldSeperator
           ,TextQualifier
           ,RowDelimiter
           ,[CodePage]
           ,TransferMethod 
           ,TransferFrequency 
           ,FullOrIncremental 
           ,FilterCriteria 
           ,DeletedRecords 
           ,RejectedRows
           ,ColumnMetadataLocked
           ,AdditionalColumnDestination
        )
        VALUES
        (
			@FileSpecificationName
           ,@FileDescription   
           ,@ClientCode       
           ,@SupplierCode     
           ,@FileType
           ,@FileNameElement4      
           ,@FileNameElement5     
           ,@EncodingType      
           ,@FileNameWildCard 
           ,@SampleFileName
           ,@FieldSeperator
		   ,@TextQualifier
		   ,@RowDelimiter
		   ,@CodePage
           ,@TransferMethod   
           ,@TransferFrequency
           ,@FullOrIncremental
           ,@FilterCriteria   
           ,@DeletedRecords   
           ,@RejectedRows 
           ,@ColumnMetadataLocked
           ,@AdditionalColumnDestination  
        )
	END
	ELSE
	BEGIN
		IF(SELECT ISNULL(ColumnMetadataLocked,'N') FROM MetadataFileSpecification WHERE FileSpecificationName = @FileSpecificationName) <> 'Y'
		BEGIN
			UPDATE MetadataFileSpecification
			SET FileDescription  = @FileDescription 
			   ,ClientCode       = @ClientCode 
			   ,SupplierCode     = @SupplierCode 
			   ,FileType         = @FileType
			   ,FileNameElement4 = @FileNameElement4
			   ,FileNameElement5 = @FileNameElement5
			   ,EncodingType     = @EncodingType 
			   ,FileNameWildCard = @FileNameWildCard 
			   ,SampleFileName   = @SampleFileName
			   ,FieldSeperator   = @FieldSeperator
		       ,TextQualifier    = @TextQualifier
		       ,RowDelimiter     = @RowDelimiter
		       ,[CodePage]		 = @CodePage
			   ,TransferMethod   = @TransferMethod 
			   ,TransferFrequency= @TransferFrequency 
			   ,FullOrIncremental= @FullOrIncremental 
			   ,FilterCriteria   = @FilterCriteria 
			   ,DeletedRecords   = @DeletedRecords 
			   ,RejectedRows     = @RejectedRows
			   ,ColumnMetadataLocked = @ColumnMetadataLocked
			   ,AdditionalColumnDestination = @AdditionalColumnDestination
			   ,FileSpecificationOptions = @FileSpecificationOptions
			 WHERE FileSpecificationName = @FileSpecificationName   
		END	 
		ELSE
		BEGIN
			    RAISERROR('Updates Not allowed: Row is locked',16,1)
		END
	END
	
	
	--Update the EDP fields (if applicable)
	--Check that the input fields are populated
	IF @EDPRequiredFieldsArePopulated = 1
	BEGIN
	    --Check that the destination table actually contains the EDP fields
	    IF @CountTheNumberOfEDPFields = 5
	    BEGIN
	        DECLARE @SQL NVARCHAR(2000)
	        SET @SQL=N'
	        UPDATE MetadataFileSpecification
		    SET FileFormat                  = @FileFormat 
		       ,EscapeCharacter             = @EscapeCharacter 
		       ,CommentCharacter            = @CommentCharacter 
		       ,FileHeaders                 = @FileHeaders
		       ,FileSpecificationOptions    = @FileSpecificationOptions
			WHERE FileSpecificationName = @FileSpecificationName   
		   '
		   EXEC sp_executesql @SQL, @params=N'@FileFormat VARCHAR(50),
		   @EscapeCharacter VARCHAR(10), @CommentCharacter VARCHAR(10),
		   @FileHeaders VARCHAR(1), @FileSpecificationOptions VARCHAR(4000),
		   @FileSpecificationName VARCHAR(500)',
		   @FileFormat = @FileFormat, @EscapeCharacter = @EscapeCharacter ,
		   @CommentCharacter = @CommentCharacter, @FileHeaders = @FileHeaders,
		   @FileSpecificationOptions = @FileSpecificationOptions,
		   @FileSpecificationName = @FileSpecificationName
		END
		--ELSE
		--BEGIN
		    --RAISERROR('Updates Not allowed: MetadataFileSpecification does not contain EDP fields',16,1)
		--END
	END
	
    -- END YOUR DDL HERE
    IF XACT_STATE() = 1
    BEGIN
        COMMIT TRANSACTION;
    END;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage VARCHAR(4000)
           ,@ErrorNumber INT
           ,@ErrorSeverity INT
           ,@ErrorState INT
           ,@ErrorLine INT
           ,@ErrorProcedure VARCHAR(126);
    SELECT @ErrorNumber = ERROR_NUMBER()
          ,@ErrorSeverity = ERROR_SEVERITY()
          ,@ErrorState = ERROR_STATE()
          ,@ErrorLine = ERROR_LINE()
          ,@ErrorProcedure =ISNULL(ERROR_PROCEDURE(),'N/A');
    --Build the error message string
    SELECT @ErrorMessage = 'Error %d, Level %d, State %d, Procedure %s, Line %d, ' +
                                       'Message: '+ERROR_MESSAGE()
    --Place cleanup and logging code
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    --Rethrow the error
    RAISERROR
    (
        @ErrorMessage
       ,@ErrorSeverity
       ,1
       ,@ErrorNumber
       ,@ErrorSeverity
       ,@ErrorState
       ,@ErrorProcedure
       ,@ErrorLine
    );
END CATCH
END