CREATE VIEW [CRM].[vw_ProductTicketClassification]
	AS
SELECT ptc.TicketTypeCode, 
		ptc.TicketClassificationID, 
		tc.Name, 
		tc.Description, 
		tc.ArchivedInd, 
		tc.InformationSourceID 

FROM		Reference.ProductTicketClassification ptc  
INNER JOIN	Reference.TicketClassification tc ON tc.TicketClassificationID = ptc.TicketClassificationID 