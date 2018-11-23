CREATE VIEW [CRM].[vw_Product]
	AS
SELECT [ProductID] 

      ,a.[Name] 

      ,a.[Description] 

      ,a.[TicketTypeCode] 

      ,a.[ProductGroupID] 

      ,f.[Name]                AS [ProductGroup] 

      ,a.[TicketClassID] 

      ,b.Name                  AS [TicketClass] 

      ,a.[TicketTypeID] 

      ,d.[Name]                AS [TicketType] 

      ,a.[TicketGroupID] 

      ,c.Name                  AS [TicketGroup] 

      ,a.[TOCIDSpecific] 

      ,e.Name                  AS [TOCSpecific] 

      ,a.[ReturnInd] 

      ,a.LongDescription       AS [ATOCDescription] 

      ,isnull(a.isSeasonTicketInd,0) as isSeasonTicketInd 

  FROM [Reference].[Product] a 
  LEFT JOIN [Reference].[TicketClass] b ON a.TicketClassID = b.TicketClassID 
  LEFT JOIN [Reference].[TicketGroup] c ON a.TicketGroupID = c.TicketGroupID 
  LEFT JOIN [Reference].[TicketType] d  ON a.TicketTypeID  = d.TicketTypeID 
  LEFT JOIN [Reference].[TOC] e ON a.TOCIDSpecific = e.TOCID 
  LEFT JOIN [Reference].[ProductGroup] f ON a.ProductGroupID = f.ProductGroupID 
