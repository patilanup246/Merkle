SELECT *
FROM Reference.Product AS P
INNER JOIN Reference.TicketType AS TT
	ON P.TicketTypeCode = TT.Code 

	SELECT *
	FROM Reference.TicketType

	SET IDENTITY_INSERT Reference.TicketType ON 
	INSERT INTO Reference.TicketType
	(TicketTypeID, CODE,NAME,ShortName,CreatedDate,CreatedBy,LastModifiedDate,LastModifiedBy,InformationSourceID)
	SELECT -1, 'U', 'Unknown', 'Unknown',GETDATE(),0,GETDATE(),0,1

	SET IDENTITY_INSERT Reference.TicketType OFF

	UPDATE Reference.Product
	SET TicketTypeCode = 'U'
	WHERE ProductID = -1

	UPDATE P
	SET P.TicketTypeID = TT.TicketTypeID
	FROM Reference.Product AS P
	INNER JOIN Reference.TicketType AS TT
		ON P.TicketTypeCode = TT.Code 