

  CREATE FUNCTION [Staging].[GetUKTime]
   (@aDateTime DATETIME)
      RETURNS DATETIME
  AS
  BEGIN
   DECLARE @ReturnDate DATETIME = @aDateTime
    /*BEGIN
      set @ReturnDate = @aDateTime
    END*/

   RETURN @ReturnDate
END