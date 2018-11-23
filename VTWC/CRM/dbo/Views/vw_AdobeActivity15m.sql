CREATE VIEW [dbo].[vw_AdobeActivity15m] as
SELECT
act.*
, ROW_NUMBER()OVER(ORDER BY 
			act.[M3Clicks] DESC
			, act.[M3Opens] DESC
			, act.[M6Clicks] DESC
			, act.[M6Opens] DESC
			, act.[M9Clicks] DESC
			, act.[M9Opens] DESC
			, act.[M12Clicks] DESC
			, act.[M12Opens] DESC
			, act.[M15Clicks] DESC
			, act.[M15Opens] DESC
			, act.[M3Sends] DESC
			, act.[M6Sends] DESC
			, act.[M9Sends] DESC
			, act.[M12Sends] DESC
			, act.[M15Sends] DESC) AS RowNum
from
(SELECT
l.tcs_customer_id
, LOWER(c.emailaddress) AS emailaddress
, right(LOWER(c.emailaddress),(LEN(c.emailaddress) - CHARINDEX('@',c.emailaddress))) AS Domain
, SUM(CASE WHEN response_type = 'Email click' AND log_date BETWEEN GETDATE()- 90 AND GETDATE() THEN 1 ELSE 0 END) AS "M3Clicks"
, SUM(CASE WHEN response_type = 'Open' AND log_date BETWEEN GETDATE()- 90 AND GETDATE() THEN 1 ELSE 0 END) AS "M3Opens"
, SUM(CASE WHEN sent_date BETWEEN GETDATE()- 90 AND GETDATE() THEN 1 ELSE 0 END) AS "M3Sends"

, SUM(CASE WHEN response_type = 'Email click' AND log_date BETWEEN GETDATE()- 180 AND GETDATE() - 91 THEN 1 ELSE 0 END) AS "M6Clicks"
, SUM(CASE WHEN response_type = 'Open' AND log_date BETWEEN GETDATE()- 180 AND GETDATE() - 91 THEN 1 ELSE 0 END) AS "M6Opens"
, SUM(CASE WHEN sent_date BETWEEN GETDATE()- 180 AND GETDATE() - 91 THEN 1 ELSE 0 END) AS "M6Sends"

, SUM(CASE WHEN response_type = 'Email click' AND log_date BETWEEN GETDATE()- 270 AND GETDATE() - 181 THEN 1 ELSE 0 END) AS "M9Clicks"
, SUM(CASE WHEN response_type = 'Open' AND log_date BETWEEN GETDATE()- 270 AND GETDATE() - 181 THEN 1 ELSE 0 END) AS "M9Opens"
, SUM(CASE WHEN sent_date BETWEEN GETDATE()- 270 AND GETDATE() - 181 THEN 1 ELSE 0 END) AS "M9Sends"

, SUM(CASE WHEN response_type = 'Email click' AND log_date BETWEEN GETDATE()- 360 AND GETDATE() - 271 THEN 1 ELSE 0 END) AS "M12Clicks"
, SUM(CASE WHEN response_type = 'Open' AND log_date BETWEEN GETDATE()- 360 AND GETDATE() - 271 THEN 1 ELSE 0 END) AS "M12Opens"
, SUM(CASE WHEN sent_date BETWEEN GETDATE()- 360 AND GETDATE() - 271 THEN 1 ELSE 0 END) AS "M12Sends"

, SUM(CASE WHEN response_type = 'Email click' AND log_date BETWEEN GETDATE()- 450 AND GETDATE() - 361 THEN 1 ELSE 0 END) AS "M15Clicks"
, SUM(CASE WHEN response_type = 'Open' AND log_date BETWEEN GETDATE()- 450 AND GETDATE() - 361 THEN 1 ELSE 0 END) AS "M15Opens"
, SUM(CASE WHEN sent_date BETWEEN GETDATE()- 450 AND GETDATE() - 361 THEN 1 ELSE 0 END) AS "M15Sends"

FROM
[Migration].[tracking_logs] l
INNER JOIN PreProcessing.TOCPLUS_Customer c ON l.tcs_customer_id = c.TCScustomerID
WHERE 
l.sent_date > GETDATE() -450
and l.tcs_customer_id > 0
group by
l.TCS_Customer_ID
,c.emailaddress
) act