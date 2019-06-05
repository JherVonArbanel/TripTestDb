SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- Select * from vw_SilverPop_SavedTrip
CREATE VIEW [dbo].[vw_SilverPop_SavedTrip]
AS
	SELECT T.TripKey, 
		T.tripSavedKey SavedTripID
		, TR.tripFromDate1 StartDate
		, TR.tripToDate1 EndDate
		, TR.tripFrom1 OriginCityCode
		, OAL.AirportCode OriginAirportCode
		, OAL.AirportName OriginAirportName
		, OAL.CityName OriginCity
		, OAL.StateCode OriginStateCode
		, OSL.StateName OriginState
		, OAL.CountryCode OriginCountryCode
		, OCL.CountryName OriginCountry
		, TR.tripTo1 DestinationCityCode
		, DAL.AirportCode DestinationAirportCode
		, DAL.AirportName DestinationAirportName
		, DAL.CityName DestinationCity
		, DAL.StateCode DestinationStateCode
		, DSL.StateName DestinationState
		, DAL.CountryCode DestinationCountryCode
		, DCL.CountryName DestinationCountry		
		-- , 'http://auction.its-qa.com/Content/Images/Destination/1/280px-SF_From_Marin_Highlands3.png' DestinationImageURL
		, SC.siteName + '/CMS/Destination/Image/' + CONVERT(VARCHAR, T.tripKey) + '?strImageSize=Large'  DestinationImageURL
		, 'http://' + SC.siteName + '/travel/cart/savetrip?id=' + CONVERT(VARCHAR, T.tripKey) BuyNowURL 
		, '' OptOutURL
		, T.CreatedDate	
	FROM Trip T
		INNER JOIN TripRequest TR ON T.tripRequestKey = TR.tripRequestKey 
			AND T.tripSavedKey IS NOT NULL  AND T.tripComponentType  <> ISNULL(t.PurchaseComponentType ,0) 
		INNER JOIN AirportLookup OAL ON TR.tripFrom1 = OAL.AirportCode
		LEFT OUTER JOIN Vault..StateLookup OSL ON (OAL.StateCode = OSL.StateCode AND OAL.CountryCode = OSL.CountryCode )
		LEFT OUTER JOIN Vault..CountryLookup OCL ON OAL.CountryCode = OCL.CountryCode
		INNER JOIN AirportLookup DAL ON TR.tripTo1 = DAL.AirportCode
		LEFT OUTER JOIN Vault..StateLookup DSL ON (DAL.StateCode = DSL.StateCode AND DAL.CountryCode = DSL.CountryCode )
		LEFT OUTER JOIN Vault..CountryLookup DCL ON DAL.CountryCode = DCL.CountryCode
		INNER JOIN Vault..SiteConfiguration SC ON T.siteKey = SC.siteKey




GO
