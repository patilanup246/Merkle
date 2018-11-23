CREATE VIEW [api_customer].[CustomerBooking] AS
    SELECT DISTINCT
		 ea.CustomerID						AS [CustomerID]
        ,ea.[HashedAddress]				AS [EncryptedAddress]
        ,km.TCSCustomerID					AS [TCSCustomerID]
        ,st.BookingReference			    AS [BookingReference]
        ,st.SalesTransactionDate			AS [BookingDateTime]
		,st.SalesTransactionID              AS [SalesTransactionID]
        ,ISNULL(st.SalesAmountTotal, 0.00)  AS [TotalCost]   --Booking or Transaction?
        ,NULL                               AS [ShortTicketTC]
        ,fm.Name							AS [FulfilmentMethod]
    FROM Staging.STG_SalesTransaction		st	WITH (NOLOCK)
    INNER JOIN Staging.STG_SalesDetail				sd	WITH (NOLOCK) ON st.SalesTransactionID = sd.SalesTransactionID
	                                                         AND sd.IsTrainTicketInd = 1 
	  INNER JOIN		Staging.STG_ElectronicAddress		ea	WITH (NOLOCK) ON st.CustomerID = ea.CustomerID AND ea.AddressTypeID = 3 AND ea.PrimaryInd = 1
	  INNER JOIN		Reference.AddressType				at	WITH (NOLOCK) ON ea.AddressTypeID = at.AddressTypeID AND at.Name = 'Email'
 LEFT OUTER JOIN		Reference.FulfilmentMethod			fm	WITH (NOLOCK) ON st.FulfilmentMethodID = fm.FulfilmentMethodID
	   LEFT JOIN		Staging.STG_KeyMapping				km	WITH (NOLOCK) ON st.CustomerID = km.CustomerID
	  INNER JOIN		Reference.InformationSource			i	WITH (NOLOCK) ON st.InformationSourceID = i.InformationSourceID
		WHERE   (st.SalesTransactionDate > DATEADD(month, - 12, GETDATE())) --only booking from the last 12 months are relevant for display
		AND		st.ArchivedInd				= 0
		AND		sd.ArchivedInd				= 0
		AND		at.ArchivedInd				= 0 
		AND		ea.ArchivedInd				= 0
		AND		ISNULL(fm.ArchivedInd,0)	= 0
		AND		i.ArchivedInd				= 0
		AND		i.Name IN ('Legacy - MSD', 'Delta - MSD') --only MSD records should be included