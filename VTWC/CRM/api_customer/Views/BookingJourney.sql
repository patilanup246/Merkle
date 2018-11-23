CREATE VIEW [api_customer].[BookingJourney] AS
SELECT DISTINCT
        km.TCSCustomerID                  AS TCSCustomerID
    ,st.BookingReference                AS BookingReference
    ,loo.Name                           AS OutwardOrigin
    ,lod.Name                           AS OutwardDestination
    ,CAST(sd.OutTravelDate AS DATE)     AS DepartureDate
    ,CAST(sd.OutTravelDate AS TIME)     AS DepartureTime
    ,CAST(NULL AS Int)                  AS Duration
    ,jr.CRSOrigin                       AS ReturnOrigin
    ,jr.CRSDestination                  AS ReturnDestination
    ,CASE WHEN CAST(jr.JourneyDepartureDateTime AS DATE) = '1900-01-01' THEN NULL
            ELSE CAST(jr.JourneyDepartureDateTime AS DATE)
        END  AS ReturnDate
    ,CASE WHEN CAST(jr.JourneyDepartureDateTime AS DATE) = '1900-01-01' THEN NULL
            ELSE CAST(jr.JourneyDepartureDateTime AS TIME)
        END AS  ReturnTime
    ,NULL                              AS ReturnReservation
    ,NULL                              AS OutwardReservation
    ,st.NumberofAdults                 AS NumberofAdults
    ,st.NumberofChildren               AS NumberofChildren
    ,NULL                              AS TicketType
    ,st.SalesTransactionID             AS SalesTransactionID
FROM Staging.STG_KeyMapping km WITH (NOLOCK)
INNER JOIN Staging.STG_SalesTransaction  st WITH (NOLOCK) ON km.CustomerID      = st.CustomerID
INNER JOIN Staging.stg_salesdetail       sd WITH (NOLOCK) ON st.salestransactionid    = sd.salestransactionid
                                            AND sd.IsTrainTicketInd  = 1
INNER JOIN Staging.STG_Journey           jo WITH (NOLOCK) ON jo.SalesDetailID         = sd.SalesDetailID
                                            AND jo.IsOutboundInd     = 1
INNER JOIN Reference.InformationSource   i WITH (NOLOCK)  ON st.InformationSourceID   = i.InformationSourceID
                                            AND i.Name IN ('Legacy - MSD', 'Delta - MSD')
LEFT JOIN  Reference.Location           loo WITH (NOLOCK) ON jo.LocationIDOrigin      = loo.LocationID
LEFT JOIN  Reference.Location           lod WITH (NOLOCK) ON jo.LocationIDDestination = lod.LocationID
LEFT JOIN (SELECT strn.SalesTransactionID
                ,jrn.DepartureDateTime AS JourneyDepartureDateTime
                ,lor.Name              AS CRSOrigin
                ,ldr.Name              AS CRSDestination
            FROM   staging.stg_salestransaction strn WITH (NOLOCK)
        INNER JOIN Staging.STG_SalesDetail sdrn WITH (NOLOCK) ON strn.SalesTransactionID = sdrn.SalesTransactionID
                                                AND sdrn.IsTrainTicketInd = 1
        INNER JOIN Staging.STG_Journey    jrn WITH (NOLOCK)   ON sdrn.SalesDetailID = jrn.SalesDetailID
                                                AND jrn.IsOutboundInd = 0
        LEFT JOIN Reference.Location      lor WITH (NOLOCK)   ON jrn.LocationIDOrigin = lor.LocationID
        LEFT JOIN Reference.Location      ldr WITH (NOLOCK)   ON jrn.LocationIDDestination = ldr.LocationID            
                        ) jr ON st.SalesTransactionID = jr.SalesTransactionID