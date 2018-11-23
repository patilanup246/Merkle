CREATE VIEW [CRM].[vw_Weather_Forecast]
	AS 
select [location_id] 
      ,[date] 
      ,[weather_code] 
      ,[max_temp] 
      ,[min_temp] 
from [$(CRMDB)].Staging.STG_weather_forecast with(nolock) 
