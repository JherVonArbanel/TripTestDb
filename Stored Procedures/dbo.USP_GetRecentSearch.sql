SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Created By Anupam (24/Aug/2012) */
/* Exec USP_GetRecentSearch 0 */

CREATE PROCEDURE [dbo].[USP_GetRecentSearch]
(
@UserKey INT
)

AS

BEGIN

/* Get Top 5 Trip Request From Trip Request */
DECLARE @tblRequest TABLE 
(
RequestKey INT
)

INSERT @tblRequest(RequestKey)
	SELECT TOP 5 [tripRequestKey]
	FROM [TripRequest] WITH(NOLOCK)
	WHERE (@UserKey= 0 OR UserKey = @UserKey)
	AND UserKey > 0
	ORDER BY 1 DESC


/* ------------ TRAVEL REQUEST  -------------------------------*/	
SELECT [tripRequestKey] 
	  ,[tripAdultsCount]
      ,[tripSeniorsCount]
      ,[tripChildrenCount]
      ,[tripInfantCount]
      ,[tripYouthCount]
      ,[tripTotalTravlersCount]
      ,U.[userKey]
      ,[userFirstName]
      ,[userLastName]
 FROM [TripRequest] TR 
 INNER JOIN  @tblRequest R ON R.[RequestKey] = TR.[tripRequestKey]
 INNER JOIN  vault.dbo.[User] U ON U.UserKey = TR.UserKey

 
/* ------------ AIR -------------------------------*/	 
SELECT TA.[tripRequestKey],AR.[airRequestTypeKey],AR.[isInternationalTrip],AR.[tripRequestKey]
,AR.[airRequestClassKey],AR.[airRequestIsNonStop],ASR.[airRequestDepartureAirport],ASR.[airRequestArrivalAirport]
,ASR.[airRequestDepartureDate],ASR.[airRequestArrivalDate]
FROM [TripRequest_air] TA
INNER JOIN @tblRequest R ON TA.[tripRequestKey] = R.[RequestKey]
INNER JOIN [AirRequest] AR ON TA.[airRequestKey] = AR.[airRequestKey]
INNER JOIN [AirSubRequest] ASR ON ASR.[airRequestKey] = AR.[airRequestKey]
/* ------------ AIR END  -------------------------------*/	 

/* ------------ CAR -------------------------------*/	 
SELECT [tripRequestKey],[carClass],[pickupCityCode],[dropoffCityCode],[pickupDate],[dropoffDate],[NoofCars]
FROM [TripRequest_car] TC
INNER JOIN @tblRequest R ON TC.[tripRequestKey] = R.[RequestKey]
INNER JOIN [CarRequest] CR ON CR.[carRequestKey] = TC.[carRequestKey]
/* ------------ CAR END -------------------------------*/

/* ------------ HOTEL  -------------------------------*/	 	
SELECT [tripRequestKey],[noOfGuests],[hotelCityCode],[checkInDate],[checkOutDate]
      ,[hotelAddress],[NoofRooms]
FROM [TripRequest_hotel] TH
INNER JOIN @tblRequest R ON TH.[tripRequestKey] = R.[RequestKey]
INNER JOIN [HotelRequest] HR ON HR.[hotelRequestKey] = TH.[hotelRequestKey]
/* ------------ END HOTEL  -------------------------------*/	 	


/* ------------ CRUES  -------------------------------*/	 	
SELECT [tripRequestKey],[destinationRegionCode],[sailingDuration],[maxSailingDuration],[DepartureDate]
      ,[DepartureCityCode],[cruiseLineCode],[NoofGuests]
FROM [TripRequest_cruise] CS
INNER JOIN @tblRequest R ON CS.[tripRequestKey] = R.[RequestKey]
INNER JOIN [CruiseRequest] CSR ON CSR.[cruiseRequestKey] = CS.[cruiseRequestKey]
/* ------------ END CRUES  -------------------------------*/	

END
GO
