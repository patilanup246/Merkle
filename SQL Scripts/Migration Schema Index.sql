USE [CRM]
GO

ALTER TABLE [Migration].[Broad_Log] 
ALTER COLUMN [delivery_log_id] BIGINT NOT NULL
GO

ALTER TABLE [Migration].[Broad_Log] ADD PRIMARY KEY CLUSTERED 
(
	[delivery_log_id] ASC
)
GO

ALTER TABLE [Migration].[Delivery]
ALTER COLUMN [primary_key] BIGINT NOT NULL
GO

ALTER TABLE [Migration].[Delivery] ADD PRIMARY KEY CLUSTERED 
(
	[primary_key] ASC
)
GO

ALTER TABLE [Migration].[Extension]
ALTER COLUMN [tcs_customer_id] BIGINT NOT NULL
GO

ALTER TABLE [Migration].[Extension] ADD PRIMARY KEY CLUSTERED 
(
	[tcs_customer_id] ASC
)
GO

ALTER TABLE [Migration].[Tracking_Logs]
ALTER COLUMN [log_id] BIGINT NOT NULL
GO

ALTER TABLE [Migration].[Tracking_Logs]
ALTER COLUMN [tcs_customer_id] BIGINT NOT NULL
GO

ALTER TABLE [Migration].[Tracking_Logs]
ALTER COLUMN [delivery_id] BIGINT NOT NULL
GO

ALTER TABLE [Migration].[Tracking_Logs]
ALTER COLUMN [campaign_id] BIGINT NOT NULL
GO

ALTER TABLE [Migration].[Tracking_Logs] ADD PRIMARY KEY CLUSTERED 
(
	[log_id] ASC,
	[tcs_customer_id] ASC,
	[delivery_id] ASC,
	[campaign_id] ASC
)
GO