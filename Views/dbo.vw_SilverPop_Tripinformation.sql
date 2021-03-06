SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--SELECT * FROm vw_SilverPop_Tripinformation
CREATE VIEW [dbo].[vw_SilverPop_Tripinformation]
AS

	SELECT T.tripKey TripID, T.userKey userId, T.tripSavedKey SavedTripId, T.tripStatusKey StatusId, 
		TSL.tripStatusName [Status], T.createdDate WatchDate, TR.tripFromDate1 TripStartDate, TR.tripToDate1 TripEndDate, 
		TR.tripFrom1 OriginAirportCode, TR.tripTo1 DestinationAirportCode, DAL.CityName DestinationCity, 
		DAL.StateCode DestinationStateCode, DSL.StateName DestinationState, DAL.CountryCode DestinationCountryCode, 
		DCL.CountryName DestinationCountry, T.recordLocator PNR, TSD.originalTotalPrice OriginalTripCost,
		TSD.currentTotalPrice ActualTripCost, T.tripAdultsCount AdultCount, T.tripChildCount ChildCount, 
		CASE WHEN TSD.componentType = 1 THEN 'Air'
			WHEN TSD.componentType = 2 THEN 'Car'
			WHEN TSD.componentType = 3 THEN 'Air, Car'
			WHEN TSD.componentType = 4 THEN 'Hotel'
			WHEN TSD.componentType = 5 THEN 'Air, Hotel'
			WHEN TSD.componentType = 6 THEN 'Car, Hotel' 
			WHEN TSD.componentType = 7 THEN 'Air, Car, Hotel'
		END TripComponentType, ISNULL(THR.hotelTotalPrice,0) HotelPurchasePrice, 
		(ISNULL(TCR.SearchCarPrice,0) + ISNULL(TCR.SearchCarTax,0)) CarPurchasePrice, 
		(ISNULL(TAR.repricedAirPrice,0) + ISNULL(TAR.repricedAirTax,0)) AirPurchasePrice, 
		GS.GDSName AirSupplierName, THR.supplierID HotelSupplierName, THR.supplierHotelKey HotelSupplierCode
	FROM Trip T
		LEFT OUTER JOIN TripRequest TR ON T.tripRequestKey = TR.tripRequestKey AND T.tripPurchasedKey IS NOT NULL
		LEFT OUTER JOIN TripSavedDeals TSD ON T.tripKey = TSD.tripKey
		INNER JOIN tripstatuslookup TSL ON T.tripStatusKey = TSL.tripStatusKey
		INNER JOIN AirportLookup OAL ON TR.tripFrom1 = OAL.AirportCode
		LEFT OUTER JOIN Vault..StateLookup OSL ON OAL.StateCode = OSL.StateCode
		LEFT OUTER JOIN Vault..CountryLookup OCL ON OAL.CountryCode = OCL.CountryCode
		INNER JOIN AirportLookup DAL ON TR.tripTo1 = DAL.AirportCode
		LEFT OUTER JOIN Vault..StateLookup DSL ON DAL.StateCode = DSL.StateCode
		LEFT OUTER JOIN Vault..CountryLookup DCL ON DAL.CountryCode = DCL.CountryCode
		LEFT OUTER JOIN TripHotelResponse THR ON t.tripPurchasedKey = THR.tripGUIDKey
		LEFT OUTER JOIN TripCarResponse TCR ON t.tripPurchasedKey = TCR.tripGUIDKey
		LEFT OUTER JOIN TripAirResponse TAR ON t.tripPurchasedKey = TAR.tripGUIDKey
		LEFT OUTER JOIN TripAirLegs TAL ON TAR.airResponseKey = TAL.airResponseKey
		LEFT OUTER JOIN [vault].[dbo].[GDSSourceLookup] GS ON TAL.gdsSourceKey = GS.gdsSourceKey
GO
