USE [CEM]
GO
/****** Object:  View [api_customer].[BeamCustomers]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [api_customer].[BeamCustomers]
AS
SELECT        PreProcessing.Beam_Customer.* 
FROM            PreProcessing.Beam_Customer -- I like this view a lot :D Tomas
		

GO
