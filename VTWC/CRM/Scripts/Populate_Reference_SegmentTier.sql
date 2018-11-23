DECLARE @RC int
DECLARE @userid int = 0
DECLARE @archivedind bit = 0
DECLARE @returnid int

-- Populate Segment Tiers for Virgin Train Segments.

EXECUTE @RC = [Reference].[SegmentTier_Set] 
   @userid  ,'Urban Up and Comers'  ,NULL  ,@archivedind  ,1  ,@returnid OUTPUT

EXECUTE @RC = [Reference].[SegmentTier_Set] 
   @userid  ,'Business Bods'  ,NULL  ,@archivedind  ,2  ,@returnid OUTPUT

EXECUTE @RC = [Reference].[SegmentTier_Set] 
   @userid  ,'Mature Explorers'  ,NULL  ,@archivedind  ,3  ,@returnid OUTPUT

EXECUTE @RC = [Reference].[SegmentTier_Set] 
   @userid  ,'The Inbetweeners'  ,NULL  ,@archivedind  ,4  ,@returnid OUTPUT

EXECUTE @RC = [Reference].[SegmentTier_Set] 
   @userid  ,'The Jones'''  ,NULL  ,@archivedind  ,5  ,@returnid OUTPUT

EXECUTE @RC = [Reference].[SegmentTier_Set] 
   @userid  ,'Value Hunting Families'  ,NULL  ,@archivedind  ,6  ,@returnid OUTPUT

EXECUTE @RC = [Reference].[SegmentTier_Set] 
   @userid  ,'Thrifty Fifties'  ,NULL  ,@archivedind  ,7  ,@returnid OUTPUT

GO