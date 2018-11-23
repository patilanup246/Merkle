CREATE TABLE [dbo].[DimDate] (
    [DateKey]                          INT          NOT NULL,
    [TheDate]                          DATE         NOT NULL,
    [DateISO]                          VARCHAR (10) NULL,
    [DateText]                         VARCHAR (20) NULL,
    [DateAbbrev]                       VARCHAR (11) NULL,
    [DayOfWeekNumber]                  TINYINT      NULL,
    [DayOfWeekName]                    VARCHAR (9)  NULL,
    [DayOfWeekNameShort]               CHAR (3)     NULL,
    [FirstDateOfWeek]                  DATETIME     NULL,
    [LastDateOfWeek]                   DATETIME     NULL,
    [DayOfMonth]                       TINYINT      NULL,
    [DayOfMonthNumber]                 SMALLINT     NULL,
    [MonthName]                        VARCHAR (9)  NULL,
    [MonthNameWithYear]                VARCHAR (15) NULL,
    [MonthShortName]                   VARCHAR (3)  NULL,
    [MonthShortNameWithYear]           CHAR (8)     NULL,
    [DayOfMonthName]                   VARCHAR (16) NULL,
    [FirstDateOfMonth]                 DATETIME     NULL,
    [LastDateOfMonth]                  DATETIME     NULL,
    [CalendarWeekNumber]               TINYINT      NULL,
    [CalendarWeekName]                 VARCHAR (7)  NULL,
    [CalendarWeekNameWithYear]         VARCHAR (13) NULL,
    [CalendarWeekShortName]            CHAR (4)     NULL,
    [CalendarWeekShortNameWithYear]    CHAR (9)     NULL,
    [CalendarWeek_YY_WK]               CHAR (5)     NULL,
    [CalendarMonthNumber]              TINYINT      NULL,
    [CalendarMonth_YY_MM]              CHAR (5)     NULL,
    [CalendarYearMonth]                VARCHAR (8)  NULL,
    [CalendarYearMonth_YY_MMM]         CHAR (6)     NULL,
    [CalendarQuarterNumber]            TINYINT      NULL,
    [CalendarQuarterName]              CHAR (9)     NULL,
    [CalendarQuarterNameWithYear]      CHAR (15)    NULL,
    [CalendarQuarterShortName]         CHAR (2)     NULL,
    [CalendarQuarterShortNameWithYear] CHAR (7)     NULL,
    [CalendarQuarter_YY_QQ]            CHAR (5)     NULL,
    [CalendarYearQuarter]              VARCHAR (8)  NULL,
    [CalendarDayOfQuarter]             TINYINT      NULL,
    [CalendarDayOfQuarterName]         VARCHAR (16) NULL,
    [CalendarFirstDateOfQuarter]       DATETIME     NULL,
    [CalendarLastDateOfQuarter]        DATETIME     NULL,
    [CalendarHalfNumber]               TINYINT      NULL,
    [CalendarHalfName]                 CHAR (6)     NULL,
    [CalendarHalfNameWithYear]         CHAR (12)    NULL,
    [CalendarHalfShortName]            CHAR (2)     NULL,
    [CalendarHalfShortNameWithYear]    CHAR (7)     NULL,
    [CalendarDayOfHalf]                TINYINT      NULL,
    [CalendarDayOfHalfName]            VARCHAR (16) NULL,
    [CalendarFirstDateOfHalf]          DATETIME     NULL,
    [CalendarLastDateOfHalf]           DATETIME     NULL,
    [CalendarYearNumber]               SMALLINT     NULL,
    [CalendarYearName]                 CHAR (4)     NULL,
    [CalendarYearShortName]            CHAR (2)     NULL,
    [CalendarDayOfYear]                SMALLINT     NULL,
    [CalendarDayOfYearName]            VARCHAR (20) NULL,
    [CalendarFirstDateOfYear]          DATETIME     NULL,
    [CalendarLastDateOfYear]           DATETIME     NULL,
    [FiscalWeekNumber]                 TINYINT      NULL,
    [FiscalWeekName]                   VARCHAR (7)  NULL,
    [FiscalWeekNameWithYear]           VARCHAR (13) NULL,
    [FiscalWeekShortName]              CHAR (4)     NULL,
    [FiscalWeekShortNameWithYear]      CHAR (9)     NULL,
    [FiscalWeek_YY_WK]                 CHAR (5)     NULL,
    [FiscalMonthNumber]                TINYINT      NULL,
    [FiscalMonth_YY_MM]                CHAR (5)     NULL,
    [FiscalYearMonth]                  VARCHAR (8)  NULL,
    [FiscalYearMonth_YY_MMM]           CHAR (6)     NULL,
    [FiscalQuarterNumber]              TINYINT      NULL,
    [FiscalQuarterName]                CHAR (9)     NULL,
    [FiscalQuarterNameWithYear]        CHAR (15)    NULL,
    [FiscalQuarterShortName]           CHAR (2)     NULL,
    [FiscalQuarterShortNameWithYear]   CHAR (7)     NULL,
    [FiscalQuarter_YY_QQ]              CHAR (5)     NULL,
    [FiscalYearQuarter]                VARCHAR (8)  NULL,
    [FiscalDayOfQuarter]               TINYINT      NULL,
    [FiscalDayOfQuarterName]           VARCHAR (16) NULL,
    [FiscalFirstDateOfQuarter]         DATETIME     NULL,
    [FiscalLastDateOfQuarter]          DATETIME     NULL,
    [FiscalHalfNumber]                 TINYINT      NULL,
    [FiscalHalfName]                   CHAR (6)     NULL,
    [FiscalHalfNameWithYear]           CHAR (12)    NULL,
    [FiscalHalfShortName]              CHAR (2)     NULL,
    [FiscalHalfShortNameWithYear]      CHAR (7)     NULL,
    [FiscalDayOfHalf]                  TINYINT      NULL,
    [FiscalDayOfHalfName]              VARCHAR (16) NULL,
    [FiscalFirstDateOfHalf]            DATETIME     NULL,
    [FiscalLastDateOfHalf]             DATETIME     NULL,
    [FiscalYearNumber]                 SMALLINT     NULL,
    [FiscalYearName]                   CHAR (4)     NULL,
    [FiscalYearShortName]              CHAR (2)     NULL,
    [FiscalDayOfYear]                  SMALLINT     NULL,
    [FiscalDayOfYearName]              VARCHAR (20) NULL,
    [FiscalFirstDateOfYear]            DATETIME     NULL,
    [FiscalLastDateOfYear]             DATETIME     NULL,
    [WeekdayIndicator]                 VARCHAR (7)  NULL,
    [HolidayIndicator]                 VARCHAR (12) NULL,
    [MajorEvent]                       VARCHAR (50) NULL,
    [SeasonFull]                       CHAR (6)     NULL,
    [SeasonShort]                      CHAR (3)     NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Short season name (Win, Spr, Sum or Aut.  Calculated based on the 21st day of Mar, Jun, Sep and Dec.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'SeasonShort';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Season Short', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'SeasonShort';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Full season name (Winter, Spring, Summer or Autumn.  Calculated based on the 21st day of Mar, Jun, Sep and Dec.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'SeasonFull';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Season Full', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'SeasonFull';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Major Event', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'MajorEvent';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Holiday Indicator', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'HolidayIndicator';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Weekday Indicator', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'WeekdayIndicator';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Last Date Of Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalLastDateOfYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal First Date Of Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalFirstDateOfYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Day Of Year Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalDayOfYearName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Day Of Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalDayOfYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Year Short Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalYearShortName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Year Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalYearName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Year Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalYearNumber';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Last Date Of Half', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalLastDateOfHalf';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal First Date Of Half', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalFirstDateOfHalf';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Day Of Half Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalDayOfHalfName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Day Of Half', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalDayOfHalf';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Half Short Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalHalfShortNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Half Short Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalHalfShortName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Half Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalHalfNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Half Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalHalfName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Half Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalHalfNumber';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Last Date Of Quarter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalLastDateOfQuarter';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal First Date Of Quarter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalFirstDateOfQuarter';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Day Of Quarter Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalDayOfQuarterName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Day Of Quarter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalDayOfQuarter';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Year Quarter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalYearQuarter';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date in YY_QQ format (e.g. 09-Q1 to 09-Q4)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalQuarter_YY_QQ';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Quarter YY_QQ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalQuarter_YY_QQ';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Quarter Short Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalQuarterShortNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Quarter Short Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalQuarterShortName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Quarter Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalQuarterNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Quarter Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalQuarterName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Quarter Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalQuarterNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date in YY_mmm format (e.g. 09-Jan to 09-Dec).  Cannot be sorted in isolation - useCalendarMonth_YY_MM.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalYearMonth_YY_MMM';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Year Month YY_MMM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalYearMonth_YY_MMM';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Year Month', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalYearMonth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date in YY_MM format (e.g. 09-01 to 09-12)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalMonth_YY_MM';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Month YY_WK', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalMonth_YY_MM';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Month Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalMonthNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date in YY_WK format (e.g. 09-01 to 09-53)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalWeek_YY_WK';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Week YY_WK', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalWeek_YY_WK';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Week Short Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalWeekShortNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Week Short Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalWeekShortName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Week Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalWeekNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Week Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalWeekName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Fiscal Week Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FiscalWeekNumber';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Last Date Of Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarLastDateOfYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar First Date Of Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarFirstDateOfYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Day Of Year Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarDayOfYearName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Day Of Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarDayOfYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Year Short Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarYearShortName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Year Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarYearName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Year Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarYearNumber';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Last Date Of Half', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarLastDateOfHalf';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar First Date Of Half', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarFirstDateOfHalf';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Day Of Half Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarDayOfHalfName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Day Of Half', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarDayOfHalf';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Half Short Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarHalfShortNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Half Short Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarHalfShortName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Half Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarHalfNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Half Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarHalfName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Half Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarHalfNumber';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Last Date Of Quarter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarLastDateOfQuarter';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar First Date Of Quarter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarFirstDateOfQuarter';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Day Of Quarter Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarDayOfQuarterName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Day Of Quarter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarDayOfQuarter';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Year Quarter', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarYearQuarter';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date in YY_QQ format (e.g. 09-Q1 to 09-Q4)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarQuarter_YY_QQ';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Quarter YY_QQ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarQuarter_YY_QQ';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Quarter Short Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarQuarterShortNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Quarter Short Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarQuarterShortName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Quarter Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarQuarterNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Quarter Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarQuarterName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Quarter Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarQuarterNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date in YY_mmm format (e.g. 09-Jan to 09-Dec).  Cannot be sorted in isolation - useCalendarMonth_YY_MM.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarYearMonth_YY_MMM';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Year Month YY_MMM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarYearMonth_YY_MMM';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Year Month', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarYearMonth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date in YY_MM format (e.g. 09-01 to 09-12)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarMonth_YY_MM';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Month YY_WK', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarMonth_YY_MM';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Month Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarMonthNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date in YY_WK format (e.g. 09-01 to 09-53)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarWeek_YY_WK';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Week YY_WK', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarWeek_YY_WK';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Week Short Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarWeekShortNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Week Short Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarWeekShortName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Week Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarWeekNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Week Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarWeekName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Calendar Week Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'CalendarWeekNumber';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Last Date Of Month', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'LastDateOfMonth';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'First Date Of Month', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FirstDateOfMonth';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Day Of Month Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DayOfMonthName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Month Short Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'MonthShortNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Month Short Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'MonthShortName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Month Name With Year', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'MonthNameWithYear';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Month Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'MonthName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This represents numerically the month plus the day and is calculated as MonthNumber * 100 + DayOfMonth.  The 30th October would be 1030', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DayOfMonthNumber';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Day Of Month Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DayOfMonthNumber';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Day Of Month', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DayOfMonth';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Last Date Of Week', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'LastDateOfWeek';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'First Date Of Week', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'FirstDateOfWeek';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Day Of Week Name Short', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DayOfWeekNameShort';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Day Of Week Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DayOfWeekName';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Day Of Week Number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DayOfWeekNumber';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Abbrev', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DateAbbrev';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Text', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DateText';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date ISO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DateISO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The actual date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'TheDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'TheDate';


GO
EXECUTE sp_addextendedproperty @name = N'Source System', @value = N'Derived', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DateKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Surrogate primary key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DateKey';


GO
EXECUTE sp_addextendedproperty @name = N'Example Values', @value = N'1, 2, 3…', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DateKey';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'Date Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate', @level2type = N'COLUMN', @level2name = N'DateKey';


GO
EXECUTE sp_addextendedproperty @name = N'Used in schemas', @value = N'dbo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate';


GO
EXECUTE sp_addextendedproperty @name = N'Table Type', @value = N'Dimension', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table hold one row for every day in the calendar between 2 dates.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate';


GO
EXECUTE sp_addextendedproperty @name = N'Display Name', @value = N'DimDate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DimDate';

