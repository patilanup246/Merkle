CREATE TABLE [Staging].[STG_weather_forecast] (
    [location_id]  INT             NOT NULL,
    [date]         DATE            NOT NULL,
    [weather_code] INT             NULL,
    [max_temp]     DECIMAL (18, 2) NULL,
    [min_temp]     DECIMAL (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([location_id] ASC, [date] ASC)
);



