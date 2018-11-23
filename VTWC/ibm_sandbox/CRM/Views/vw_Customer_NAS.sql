CREATE VIEW [CRM].[vw_Customer_NAS]
	AS 
select 1 res
/*
    SELECT c.CustomerID, 

           CAST(b.ExecutionDate AS DATE) AS ExecutionDate, 

           CAST(c.TravelDate AS DATE) AS TravelDate, 

           d.Name AS Segment, 

           d.SegmentCode, 

           c.RSID, 

           CAST(c.Score AS INTEGER) AS Score, 

           CAST(c.SurveyDate AS DATE) AS SurveyDate 

    FROM [$(CRMDB)].Reference.ModelDefinition a, 

         [$(CRMDB)].Production.ModelRun b, 

         [$(CRMDB)].Production.ModelSegmentCustomer c, 

         [$(CRMDB)].Reference.ModelSegment d 

    WHERE a.ModelDefinitionID = b.ModelDefinitionID 

    AND   b.ModelRunID = c.ModelRunID 

    AND   c.ModelSegmentID = d.ModelSegmentID 

    AND   a.Name = 'Post Travel - NAS' 

    and d.SegmentCode is not null 
*/