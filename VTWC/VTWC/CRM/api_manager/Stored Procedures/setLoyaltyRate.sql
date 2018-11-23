  CREATE PROCEDURE [api_manager].[setLoyaltyRate] 
     @userid             int,          -- who has requested the action
     @LoyaltyRateID int = -1,
     @Program varchar(256),
     @StartDate datetime,
     @EndDate datetime,
     @ProductGroupID int,
     @Rate float
     
  AS 

   set nocount on;
   
   DECLARE @ErrMsg varchar(512)
   DECLARE @RowCount int = 0
   DECLARE @LoylatyProgrammeTypeID int

   SELECT @LoylatyProgrammeTypeID = lpt.LoyaltyProgrammeTypeID
     FROM Reference.LoyaltyProgrammeType lpt
    WHERE lpt.Name = @Program
    AND lpt.ArchivedInd = 0

   IF @LoylatyProgrammeTypeID IS NULL
     BEGIN
      SET @ErrMsg = 'Unable to find Loyalty Program (' + @Program + ')' ;
      THROW 90508, @ErrMsg,1
   END

   IF EXISTS ( SELECT 1 
                 FROM Staging.STG_LoyaltyRate lr
                WHERE lr.LoyaltyRateID = @LoyaltyRateID
                  AND lr.ArchivedInd = 0)
       BEGIN
         UPDATE Staging.STG_LoyaltyRate
            SET ArchivedInd = 1,
                LastModifiedDate = GETDATE(),
                LastModifiedBy = @userid
          WHERE LoyaltyRateID = @LoyaltyRateID
            AND ArchivedInd = 0
       END

   INSERT INTO Staging.STG_LoyaltyRate
     (LoyaltyProgrammeTypeID,
      StartDate,
      EndDate,
      ProductGroupID,
      Rate,
      CreatedDate,
      CreatedBy,
      LastModifiedDate,
      LastModifiedBy
     )
     VALUES
     ( 
      @LoylatyProgrammeTypeID,
      @StartDate,
      @EndDate,
      @ProductGroupID,
      @Rate,
      GETDATE(),
      @userid,
      GETDATE(),
      @userid
     )
     
   SET @RowCount = @@ROWCOUNT


   IF @RowCount = 0
     BEGIN
      SET @ErrMsg = 'Unable to add LoyaltyRate' ;
      THROW 90508, @ErrMsg,1
   END  
    return @RowCount;