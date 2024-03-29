
INSERT INTO Reference.Location
(CRSCode, Name, NLCCode, CATEType, CreatedDate, LastModifiedDate, SourceCreatedDate, SourceModifiedDate)
SELECT ShortCode, NAME, ShortCode, 1, CreatedDate, LastModifiedDate, EffectiveFromDate, EffectiveToDate
FROM Reference.Station AS S
WHERE NOT EXISTS (SELECT * FROM Reference.Location_NLCCode_VW AS L WHERE S.ShortCode = L.CRSCode)
