

  CREATE FUNCTION [Staging].[SetUKTime]
   (@aDateTime DATETIME)
      RETURNS DATETIME
  AS
  BEGIN

   DECLARE @Year VARCHAR(4) = CAST(DATEPART(yyyy, @aDateTime) AS VARCHAR(4))
   DECLARE @LastSundayInMarch DATE = CAST(@Year+'-03-01' AS DATE)
   DECLARE @LastSundayInOctober DATE = CAST(@Year+'-10-01' AS DATE)

   DECLARE @InitTime VARCHAR(8) = ' 01:00:00'
   DECLARE @EndTime VARCHAR(8)  = ' 02:00:00'

   DECLARE @BritishSummerTimeStart as DATETIME
   DECLARE @BritishSummerTimeEnd as DATETIME
   DECLARE @ReturnDate DATETIME = @aDateTime

   SET @BritishSummerTimeStart = CAST(
                     CAST(
                     DATEADD(dd,
                         -DATEPART(WEEKDAY,
                               DATEADD(dd, -DAY(DATEADD(mm, 1, @LastSundayInMarch)),
                                   DATEADD(mm, 1, @LastSundayInMarch))) + 1,
                         DATEADD(dd, -DAY(DATEADD(mm, 1, @LastSundayInMarch)), DATEADD(mm, 1,@LastSundayInMarch))) AS VARCHAR(10)) + @InitTime AS DATETIME) 

   SET @BritishSummerTimeEnd = CAST(
                   CAST( 
                   DATEADD(dd,
                       -DATEPART(WEEKDAY,
                             DATEADD(dd, -DAY(DATEADD(mm, 1, @LastSundayInOctober)),
                                 DATEADD(mm, 1, @LastSundayInOctober))) + 1,
                       DATEADD(dd, -DAY(DATEADD(mm, 1, @LastSundayInOctober)), DATEADD(mm, 1,@LastSundayInOctober))) AS VARCHAR(10)) +@EndTime AS DATETIME) 

   IF @aDateTime BETWEEN @BritishSummerTimeStart AND @BritishSummerTimeEnd
    BEGIN
      set @ReturnDate = DATEADD( hh, 1, @aDateTime )
    END

   RETURN @ReturnDate
END