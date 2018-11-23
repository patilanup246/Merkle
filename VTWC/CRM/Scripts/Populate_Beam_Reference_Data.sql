/* BEAM */
-- Adding a new information source
INSERT INTO Reference.InformationSource
( Name, Description, CreatedDate, CreatedBy, LastModifiedDate, LastModifiedBy, ArchivedInd, DisplayName, TypeCode, ProspectInd, AdditionalInformation)
VALUES
( 'Beam', 'Beam multi-media service', GETDATE(), 0, GETDATE(), 0, 0, 'Beam', 'External', 1,NULL)

