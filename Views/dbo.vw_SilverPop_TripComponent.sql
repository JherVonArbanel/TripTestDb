SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_SilverPop_TripComponent]
AS

	SELECT DISTINCT T.TripKey, T.tripComponentType ComponentType
		, CASE WHEN T.tripComponentType = 1 THEN 'Air'
			WHEN T.tripComponentType = 2 THEN 'Car'
			WHEN T.tripComponentType = 3 THEN 'Air, Car'
			WHEN T.tripComponentType = 4 THEN 'Hotel'
			WHEN T.tripComponentType = 5 THEN 'Air, Hotel'
			WHEN T.tripComponentType = 6 THEN 'Car, Hotel' 
			WHEN T.tripComponentType = 7 THEN 'Air, Car, Hotel'
		END TripComponentType
		, T.tripSavedKey SavedTripID
		, T.tripStatusKey 
		, TSL.tripStatusName [Status]
		, ISNULL(THR.hotelTotalPrice,0) HotelPurchasePrice
		, (ISNULL(TCR.SearchCarPrice,0) + ISNULL(TCR.SearchCarTax,0)) CarPurchasePrice
		, (ISNULL(TAR.repricedAirPrice,0) + ISNULL(TAR.repricedAirTax,0)) AirPurchasePrice
		, T.CreatedDate PurchaseDate
		, THR.supplierID HotelSupplierName
		, THR.supplierHotelKey HotelSupplierCode
		, TCR.supplierID CarSupplierName
		, TCR.carVendorKey CarSupplierCode
		, GS.GDSName AirSupplierName
		, TAS.airSegmentMarketingAirlineCode SupplierCode
	FROM Trip T
		INNER JOIN TripStatusLookup TSL ON T.tripStatusKey = TSL.tripStatusKey AND T.tripPurchasedKey IS NOT NULL
		LEFT OUTER JOIN TripHotelResponse THR ON t.tripPurchasedKey = THR.tripGUIDKey
		LEFT OUTER JOIN TripCarResponse TCR ON t.tripPurchasedKey = TCR.tripGUIDKey
		LEFT OUTER JOIN TripAirResponse TAR ON t.tripPurchasedKey = TAR.tripGUIDKey
		LEFT OUTER JOIN TripAirLegs TAL ON TAR.airResponseKey = TAL.airResponseKey
		LEFT OUTER JOIN [vault].[dbo].[GDSSourceLookup] GS ON TAL.gdsSourceKey = GS.gdsSourceKey
		LEFT OUTER JOIN TripAirSegments TAS ON TAR.airResponseKey = TAS.airResponseKey
GO
