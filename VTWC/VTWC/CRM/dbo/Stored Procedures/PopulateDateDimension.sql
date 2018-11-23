/*===========================================================================================
Name:			DDL_SP_Generic PopulateDateDimension.sql
Purpose:		This file contains the stored proc to populate the DimDate table
FILE PATH:		C:\SourceCode\Generic Data Warehouse\Development\Phase 1\Database\Warehouse Server\Stored Procedures\DDL_SP_Generic PopulateDateDimension.sql
Modified:		2010-01-18 Colin Thomas - restructured to simplify code and added new columns:
				DayOfWeekNameShort, DayOfMonthNumber,
				CalendarWeek_YY_WK, CalendarWeek_YY_MM, CalendarMonth_YY_MMM, CalendarQuarter_YY_QQ
				FiscalWeek_YY_WK, FiscalWeek_YY_MM, FiscalMonth_YY_MMM, FiscalQuarter_YY_QQ,
				SeasonFull, SeasonShort
				   2010-02-09 Ken Shier Bug fix to stop it converting -1 dateKey to a datekey of theDate
				   2010-05-19 Colin Thomas - added explicit DATEFIRST setting to ensure correct calculation
										  of week day number and weekday indicator
Modified:  2010-12-16	NK -	end date variable @dend set to 50 to load date keys	upto next 50 years.				  
Modified:  2011-02-09	Philip Robinson. Added param to contorl fiscal date population as fiscal dates
						in DimDate when not asked for causes confusion.
						If fiscal dates are needed, run the proc with @IncludeFiscal=1.
						Moved comment block into same batch as CREATE PROC.
			2012-08-16	George Hudd. Added param to facilitate manual date additions. If further dates are 
						required that are not within DimDate under the standard range (1900/01/02	- 2062/08/12)
						use the new param @RetainExistingDates = 1. If this param is not used, the proc will 
						attempt to remove any exisitng dates not in the secified range of dates to add.
=================================================================================================*/

CREATE PROCEDURE [dbo].[PopulateDateDimension]  (
      @StartDate DATETIME
    , @EndDate DATETIME
    , @IncludeFiscal bit = 0
	, @RetainExistingDates bit = 0
      
)
AS BEGIN

SET NOCOUNT ON
SET DATEFIRST 1 -- Forces first day of week to be Monday, just in case user's language is US English.

--Create temp table with dates
CREATE TABLE #dates (datevalue datetime)

DECLARE @Date datetime
set @date = @StartDate
WHILE DATEDIFF(day, @Date, @EndDate) >= 0
BEGIN
	INSERT INTO #dates (datevalue) VALUES (@Date)
	SET @Date = DATEADD(day, 1, @Date)
END
 
--Ensure all the dates exist in dimDate
PRINT 'Checking all dates exist in DimDate between:'

INSERT INTO DimDate (theDate, dateKey)
SELECT datevalue, CONVERT(CHAR(8), datevalue, 112) FROM #dates d
WHERE NOT EXISTS (SELECT * FROM DimDate dd where dd.theDate=d.datevalue)

PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' new dates added'

--Remove dates in DimDate outside specifed date range
DELETE FROM dimDate
WHERE NOT EXISTS (SELECT * FROM #dates d where dimDate.theDate=d.datevalue)
AND DateKey <> -1
AND @RetainExistingDates = 0

PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' dates removed'

--Now Update Date Column Values
UPDATE dimDate SET DateKey = CONVERT(CHAR(8), theDate, 112) WHERE ISNULL(DateKey,0) <> -1 
UPDATE dimDate SET DateISO = CONVERT(CHAR(10), theDate, 126)
UPDATE dimDate SET DateText = LEFT(CONVERT(CHAR(20), theDate, 113),3) + DATENAME(month, theDate) + ' ' + DATENAME(YY, theDate)
UPDATE dimDate SET DateAbbrev = CONVERT(CHAR(11), theDate, 113)

--Calendar Columns
UPDATE dimDate SET CalendarYearNumber = DATEPART(yy, theDate)
UPDATE dimDate SET CalendarYearName = RIGHT('0000' + CAST(CalendarYearNumber AS NVARCHAR(4)), 4)
UPDATE dimDate SET CalendarYearShortName = RIGHT('0000' + CAST(CalendarYearNumber AS NVARCHAR(4)), 2)
UPDATE dimDate SET CalendarFirstDateOfYear = CONVERT(DATETIME,CalendarYearName + '-01-01',120)
UPDATE dimDate SET CalendarLastDateOfYear = CONVERT(DATETIME,CalendarYearName + '-12-31',120)
UPDATE dimDate SET CalendarDayOfYear = DATEPART(dy, theDate)
UPDATE dimDate SET CalendarQuarterNumber = DATEPART(q, theDate)
UPDATE dimDate SET CalendarQuarterName = 'Quarter ' + CAST(CalendarQuarterNumber AS CHAR(1))
UPDATE dimDate SET CalendarQuarterNameWithYear = CalendarQuarterName + ', ' + CalendarYearName
UPDATE dimDate SET CalendarQuarterShortName = 'Q' + CAST(CalendarQuarterNumber AS CHAR(1))
UPDATE dimDate SET CalendarQuarterShortNameWithYear = CalendarQuarterShortName + ' ' + CalendarYearName
UPDATE dimDate SET CalendarYearQuarter = 'C' + CalendarYearName + '-'
                + RIGHT('00' + CAST(CalendarQuarterNumber AS NVARCHAR(2)), 2)
UPDATE dimDate SET CalendarFirstDateOfQuarter = CASE CalendarQuarterNumber
                                                WHEN 1 THEN CONVERT(DATETIME,CalendarYearName + '-01-01',120)
                                                WHEN 2 THEN CONVERT(DATETIME,CalendarYearName + '-04-01',120)
                                                WHEN 3 THEN CONVERT(DATETIME,CalendarYearName + '-07-01',120)
                                                WHEN 4 THEN CONVERT(DATETIME,CalendarYearName + '-10-01',120)
                                              END
UPDATE dimDate SET CalendarLastDateOfQuarter = DATEADD(day, -1, DATEADD(q, 1, CalendarFirstDateOfQuarter))
UPDATE dimDate SET CalendarDayOfQuarter = DATEDIFF(day, CalendarFirstDateOfQuarter, theDate) + 1
UPDATE dimDate SET CalendarDayOfQuarterName = 'Day '
                + CAST(DATEDIFF(day, CalendarFirstDateOfQuarter, theDate) + 1 AS NVARCHAR(2))
                + ' of Q' + CAST(CalendarQuarterNumber AS CHAR(1))
UPDATE dimDate SET CalendarHalfNumber = CASE WHEN DATEPART(q, theDate) <= 2 THEN 1 ELSE 2 END
UPDATE dimDate SET CalendarHalfName = 'Half ' + CAST(CalendarHalfNumber AS CHAR(1))
UPDATE dimDate SET CalendarHalfShortName = 'H' + CAST(CalendarHalfNumber AS CHAR(1))
UPDATE dimDate SET CalendarHalfNameWithYear = CalendarHalfName + ', ' + CalendarYearName
UPDATE dimDate SET CalendarHalfShortNameWithYear = CalendarHalfShortName + ' ' + CalendarYearName
UPDATE dimDate SET CalendarFirstDateOfHalf = CASE CalendarHalfNumber
                                             WHEN 1 THEN CONVERT(DATETIME,CalendarYearName + '-01-01',120)
                                             WHEN 2 THEN CONVERT(DATETIME,CalendarYearName + '-07-01',120)
                                           END
UPDATE dimDate SET CalendarLastDateOfHalf = CASE CalendarHalfNumber
                                            WHEN 1 THEN CONVERT(DATETIME,CalendarYearName+ '-06-30',120)
                                            WHEN 2 THEN CONVERT(DATETIME,CalendarYearName + '-12-31',120)
                                          END                
UPDATE dimDate SET CalendarDayOfHalf = DATEDIFF(day, CalendarFirstDateOfHalf, theDate) + 1
UPDATE dimDate SET CalendarDayOfHalfName = 'Day '
                + CAST(DATEDIFF(day, CalendarFirstDateOfHalf, theDate) + 1 AS NVARCHAR(3))
                + ' of H' + CAST(CalendarHalfNumber AS CHAR(1))
UPDATE dimDate SET CalendarMonthNumber = LEFT(DATEPART(m, theDate),3)
UPDATE dimDate SET CalendarYearMonth = 'C' + CalendarYearName + '-' + RIGHT('00' + CAST(CalendarMonthNumber AS NVARCHAR(2)), 2)



-- Fiscal


--Month dimentions
UPDATE dimDate SET [MonthName] = DATENAME(mm, theDate)
UPDATE dimDate SET MonthNameWithYear = MonthName + ', ' + CalendarYearName
UPDATE dimDate SET MonthShortName = LEFT(DATENAME(m, theDate),3)
UPDATE dimDate SET MonthShortNameWithYear = MonthShortName + ' ' + CalendarYearName
UPDATE dimDate SET FirstDateOfMonth = CONVERT(DATETIME,CalendarYearName + '-'+ MonthShortName + '-01',120)
UPDATE dimDate SET LastDateOfMonth = DATEADD(day, -1,DATEADD(m, 1, FirstDateOfMonth))
UPDATE dimDate SET [DayOfMonth] = DATEPART(d, theDate)
UPDATE dimDate SET DayOfMonthName = DATENAME(m, theDate) + ' '
                + CAST(DATEPART(d, theDate) AS NVARCHAR(2))
                + CASE LEFT(RIGHT('00' + CAST(DATEPART(d, theDate) AS NVARCHAR(2)), 2), 1)
                    WHEN '1' THEN 'th'
                    ELSE CASE RIGHT(RIGHT('00' + CAST(DATEPART(d, theDate) AS NVARCHAR(2)), 2), 1)
                           WHEN '1' THEN 'st'
                           WHEN '2' THEN 'nd'
                           WHEN '3' THEN 'rd'
                           ELSE 'th'
                         END
                  END


UPDATE dimDate SET CalendarDayOfYearName = DayOfMonthName + ', ' + CalendarYearName

--Week Dimensions
UPDATE dimDate SET CalendarWeekNumber = DATEPART(isowk, theDate)
UPDATE dimDate SET CalendarWeekName = 'Week ' + CAST(CalendarWeekNumber as varchar(2))
UPDATE dimDate SET CalendarWeekNameWithYear = 
	CalendarWeekName + ', ' + 
	case when calendarmonthnumber=1 and CalendarWeekNumber>50
		  then cast(CalendarYearNumber-1 as varchar(5)) 
		 when calendarmonthnumber=12 and CalendarWeekNumber=1 
		  then cast(CalendarYearNumber+1 as varchar(5)) 
		 else CalendarYearName end
UPDATE dimDate SET CalendarWeekShortName = 'WK' + RIGHT('00' + CalendarWeekName,2)
UPDATE dimDate SET CalendarWeekShortNameWithYear = CalendarWeekShortName + ' ' 
	+ 	case when calendarmonthnumber=1 and CalendarWeekNumber>50
		  then cast(CalendarYearNumber-1 as varchar(5)) 
		 when calendarmonthnumber=12 and CalendarWeekNumber=1 
		  then cast(CalendarYearNumber+1 as varchar(5)) 
		 else CalendarYearName end

UPDATE dimDate SET FirstDateOfWeek = DATEADD(day, ( DATEPART(dw, theDate) - 1 ) * -1, theDate)
UPDATE dimDate SET LastDateOfWeek = DATEADD(day, -1, DATEADD(wk, 1, FirstDateOfWeek))
UPDATE dimDate SET DayOfWeekNumber = DATEPART(dw, theDate)
UPDATE dimDate SET DayOfWeekName = DATENAME(dw, theDate)
UPDATE dimDate SET WeekdayIndicator = CASE WHEN DATEPART(dw, theDate) IN (6,7) THEN 'Weekend'
                                       ELSE 'Weekday'
                                      END -- Note, SET DATEFIRST must be 1 (Monday)
UPDATE dimDate SET HolidayIndicator = 'Non-Holiday'
UPDATE dimDate SET MajorEvent = 'None'

--20100115 New Columns Added By Colin Thomas
UPDATE dimDate SET DayOfWeekNameShort = LEFT(DayOfWeekName,3)
UPDATE dimDate SET DayOfMonthNumber=Calendarmonthnumber*100+DayOfMonth

--Additional calendar columns
UPDATE dimDate SET CalendarWeek_YY_WK=RIGHT(CalendarWeekNameWithYear,2)+'-'+
						 ISNULL(REPLICATE('0', 2 - LEN(ISNULL(CAST(calendarWeekNumber as varchar(2)) ,0))), '') + CAST(calendarWeekNumber as varchar(2))
UPDATE dimDate SET CalendarMonth_YY_MM=RIGHT(YEAR([theDate]),2)+'-'+
						 ISNULL(REPLICATE('0', 2 - len(ISNULL(CAST(calendarMonthNumber as varchar(2)) ,0))), '') + CAST(calendarMonthNumber as varchar(2))
UPDATE dimDate SET CalendarQuarter_YY_QQ=RIGHT(YEAR([theDate]),2) + '-Q' + CAST(calendarQuarterNumber as char(1))
UPDATE dimDate SET CalendarYearMonth_YY_MMM=RIGHT(YEAR([theDate]),2) + '-' + monthshortname


--Populate Seasons
UPDATE dimDate SET
	  SeasonFull = case 
					when DayOfMonthNumber < 0321 then 'Winter'
					when DayOfMonthNumber between 321 and 620 then 'Spring'
					when DayOfMonthNumber between 621 and 920 then 'Summer'
					when DayOfMonthNumber between 921 and 1220 then 'Autumn'
					when DayOfMonthNumber > 1220 then 'Winter' end
UPDATE dimDate SET
	  SeasonShort = case 
					when DayOfMonthNumber < 0321 then 'Win'
					when DayOfMonthNumber between 321 and 620 then 'Spr'
					when DayOfMonthNumber between 621 and 920 then 'Sum'
					when DayOfMonthNumber between 921 and 1220 then 'Aut'
					when DayOfMonthNumber > 1220 then 'Win' end
END


-- *****************************************************************
-- Fiscal Dates: run with param @IncludeFiscal=1
-- *****************************************************************
IF @IncludeFiscal=1
BEGIN
    PRINT 'Updating Fiscal dates...'
    UPDATE dimDate SET FiscalYearNumber = CASE WHEN DATEPART(mm, theDate) > 6
							    THEN DATEPART(yy, theDate) + 1
                              ELSE CalendarYearNumber
                              END
    UPDATE dimDate SET FiscalYearName = RIGHT('0000' + CAST(FiscalYearNumber AS NVARCHAR(4)), 4)
    UPDATE dimDate SET FiscalYearShortName = RIGHT('0000' + CAST(FiscalYearNumber AS NVARCHAR(4)), 2)
    UPDATE dimDate SET FiscalFirstDateOfYear = CONVERT(DATETIME,CAST(( FiscalYearNumber - 1 ) AS NVARCHAR)+ '-07-01',120)
    UPDATE dimDate SET FiscalLastDateOfYear = CONVERT(DATETIME,FiscalYearName + '-06-30',120)
    UPDATE dimDate SET FiscalDayOfYear = DATEDIFF(day, FiscalFirstDateOfYear, theDate) + 1
    UPDATE dimDate SET FiscalQuarterNumber = CASE WHEN CalendarQuarterNumber > 2
                                                THEN CalendarQuarterNumber - 2
                                                ELSE CalendarQuarterNumber + 2
                                           END
    UPDATE dimDate SET FiscalQuarterName = 'Quarter ' + CAST(FiscalQuarterNumber AS CHAR(1))
    UPDATE dimDate SET FiscalQuarterNameWithYear = FiscalQuarterName + ', ' + FiscalYearName
    UPDATE dimDate SET FiscalQuarterShortName = 'Q' + CAST(FiscalQuarterNumber AS CHAR(1))
    UPDATE dimDate SET FiscalQuarterShortNameWithYear = FiscalQuarterShortName + ' ' + FiscalYearName
    UPDATE dimDate SET FiscalYearQuarter = 'F' + FiscalYearName + '-' + RIGHT('00' + CAST(FiscalQuarterNumber AS NVARCHAR(2)), 2)
    UPDATE dimDate SET FiscalFirstDateOfQuarter = CASE FiscalQuarterNumber
                                                  WHEN 1 THEN CONVERT(DATETIME,CalendarYearName + '-07-01',120)
                                                  WHEN 2 THEN CONVERT(DATETIME,CalendarYearName + '-10-01',120)
                                                  WHEN 3 THEN CONVERT(DATETIME,FiscalYearName + '-01-01',120)
                                                  WHEN 4 THEN CONVERT(DATETIME,FiscalYearName + '-04-01',120)
                                                END
    UPDATE dimDate SET FiscalLastDateOfQuarter = CASE FiscalQuarterNumber
                                                 WHEN 1 THEN CONVERT(DATETIME,CalendarYearName + '-09-30',120)
                                                 WHEN 2 THEN CONVERT(DATETIME,CalendarYearName + '-12-31',120)
                                                 WHEN 3 THEN CONVERT(DATETIME,FiscalYearName + '-03-31',120)
                                                 WHEN 4 THEN CONVERT(DATETIME,FiscalYearName + '-06-30',120)
                                               END

    UPDATE dimDate SET FiscalDayOfQuarter = DATEDIFF(day, FiscalFirstDateOfQuarter, theDate) + 1
    UPDATE dimDate SET FiscalDayOfQuarterName = 'Day '
                    + CAST(DATEDIFF(day, FiscalFirstDateOfQuarter, theDate) + 1 AS NVARCHAR(2))
                    + ' of Q' + CAST(FiscalQuarterNumber AS CHAR(1))


    UPDATE dimDate SET FiscalHalfNumber = CASE WHEN DATEPART(q, theDate) <= 2 THEN 2 ELSE 1 END
    UPDATE dimDate SET FiscalHalfName = 'Half ' + CAST(FiscalHalfNumber AS CHAR(1))
    UPDATE dimDate SET FiscalHalfShortName = 'H' + CAST(FiscalHalfNumber AS CHAR(1))
    UPDATE dimDate SET FiscalHalfNameWithYear = FiscalHalfName + ', ' + FiscalYearName
    UPDATE dimDate SET FiscalHalfShortNameWithYear = FiscalHalfShortName + ' ' + FiscalYearName

    UPDATE dimDate SET FiscalFirstDateOfHalf = CASE FiscalHalfNumber
                                               WHEN 1 THEN CONVERT(DATETIME,CalendarYearName + '-07-01',120)
                                               WHEN 2 THEN CONVERT(DATETIME,FiscalYearName + '-01-01',120)
                                             END
    UPDATE dimDate SET FiscalLastDateOfHalf = CASE FiscalHalfNumber
                                              WHEN 1 THEN CONVERT(DATETIME,CalendarYearName + '-12-31',120)
                                              WHEN 2 THEN CONVERT(DATETIME,FiscalYearName + '-06-30',120)
                                            END
    UPDATE dimDate SET FiscalDayOfHalf = DATEDIFF(day, FiscalFirstDateOfHalf, theDate)   + 1
    UPDATE dimDate SET FiscalDayOfHalfName = 'Day '
                    + CAST(DATEDIFF(day, FiscalFirstDateOfHalf, theDate) + 1 AS NVARCHAR(3))
                    + ' of H' + CAST(FiscalHalfNumber AS CHAR(1))
    UPDATE dimDate SET FiscalMonthNumber = DATEDIFF(m, FiscalFirstDateOfYear, theDate) + 1
    UPDATE dimDate SET FiscalYearMonth = 'F' + FiscalYearName + '-' + RIGHT('00' + CAST(FiscalMonthNumber AS NVARCHAR(2)), 2)

    --UPDATE dimDate SET FiscalDayOfYearName = DayOfMonthName + ', ' + CalendarYearName  -- this is wrong.
    UPDATE dimDate SET FiscalWeekNumber = DATEDIFF(wk, FiscalFirstDateOfYear, theDate) + 1
    UPDATE dimDate SET FiscalWeekName = 'Week ' + CAST(DATEDIFF(wk, FiscalFirstDateOfYear, theDate) + 1 AS NVARCHAR)
    UPDATE dimDate SET FiscalWeekNameWithYear = FiscalWeekName + ', ' + FiscalYearName
    UPDATE dimDate SET FiscalWeekShortName = 'WK' + RIGHT('00' + CAST(DATEDIFF(wk, FiscalFirstDateOfYear, theDate) + 1 AS NVARCHAR), 2)
    UPDATE dimDate SET FiscalWeekShortNameWithYear = FiscalWeekShortName + ' ' + FiscalYearName
    --Additional fiscal columns
    UPDATE dimDate SET FiscalWeek_YY_WK=RIGHT(FiscalYearName,2)+'-'+
						     ISNULL(REPLICATE('0', 2 - LEN(ISNULL(CAST(FiscalWeekNumber as varchar(2)) ,0))), '') + CAST(FiscalWeekNumber as varchar(2))
    UPDATE dimDate SET FiscalMonth_YY_MM=RIGHT(FiscalYearName,2)+'-'+
						     ISNULL(REPLICATE('0', 2 - len(ISNULL(CAST(FiscalMonthNumber as varchar(2)) ,0))), '') + CAST(FiscalMonthNumber as varchar(2))
    UPDATE dimDate SET FiscalQuarter_YY_QQ=RIGHT(FiscalYearName,2) + '-Q' + CAST(FiscalQuarterNumber as char(1))
    UPDATE dimDate SET FiscalYearMonth_YY_MMM=RIGHT(FiscalYearName,2) + '-' + monthshortname

    PRINT 'Completed: Updating Fiscal dates.'

END -- END @IncludeFiscal=1