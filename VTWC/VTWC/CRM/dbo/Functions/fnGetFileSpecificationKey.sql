  
CREATE  FUNCTION [dbo].[fnGetFileSpecificationKey](@FeedFileName varchar(100))   
RETURNS int  
AS  
/*===========================================================================================  
Name:   fnGetFileSpecificationKey  
Purpose:  Returns a valid file specification key for filename supplied  
Parameters:  @FeedFileName  
Return Value: 0 - No match  
    -1- Multiple matches  
    any other number = FileSpecificationKey  
Created:  20101015 Nitin   
Modified:  20120312 Colin - added clause to ensure filespec has associated column specification rows  
Peer Review:   
Call script: @fnGetFileSpecificationKey(?)  
=================================================================================================*/  
  
BEGIN  
 DECLARE @Counter    INT  
 DECLARE @ErrorMsg    VARCHAR(100)  
 DECLARE @FileSpecificationKey INT  
 DECLARE @Minimum    INT  
   
 DECLARE @temp TABLE   
 (  
  FileSpecificationKey int  
  ,WildCardCounts int  
 )  
   
 INSERT INTO @temp   
 SELECT (FileSpecificationKey),MIN([dbo].[fnCountChar] (FileNameWildCard,'*')) WildCardCounts  
 FROM dbo.MetadataFileSpecification fs  
 WHERE  @FeedFileName like REPLACE(FileNameWildCard,'*','%')  
 --AND EXISTS (SELECT 1   
 --   FROM dbo.MetadataColumnSpecification cs   
 --   WHERE cs.FileSpecificationKey=fs.FileSpecificationKey) -- Check that filespec has column specifications  
 GROUP BY FileSpecificationKey  
  
 SELECT @minimum = min(WildCardCounts) from @temp  
  
 SELECT @counter = count(*)  
 FROM @temp  
 WHERE WildCardCounts = @minimum  
   
 IF @counter = 0  
  SET @FileSpecificationKey = 0  
 ELSE IF @counter > 1  
   SET @FileSpecificationKey = -1  
   ELSE  
   SELECT @FileSpecificationKey = FileSpecificationKey  
   FROM @temp  
   WHERE WildCardCounts = @minimum  
   
   
 RETURN @FileSpecificationKey  
END
