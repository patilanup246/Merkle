UPDATE PreProcessing.TOCPLUS_Customer
SET ProcessedInd = 0
WHERE ProcessedInd = 1
AND TCScustomerID = 5687588

DELETE FROM Staging.STG_Address

DBCC CHECKIDENT('Staging.STG_Address',RESEED,0)

DELETE FROM Staging.STG_KeyMapping

DBCC CHECKIDENT('Staging.STG_KeyMapping',RESEED,0)

DELETE FROM Staging.STG_ElectronicAddress

DBCC CHECKIDENT('Staging.STG_ElectronicAddress',RESEED,0)

DELETE FROM Staging.STG_CustomerPreference

DELETE FROM Audit.STG_CustomerPreference

--DBCC CHECKIDENT('Staging.STG_CustomerPreference',RESEED,0)


DELETE FROM Staging.STG_Customer

DBCC CHECKIDENT('Staging.STG_Customer',RESEED,0)
