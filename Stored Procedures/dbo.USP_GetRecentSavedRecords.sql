SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* Created By Anupam (24/Aug/2012) */
/* Exec USP_GetRecentSavedRecords 559865,5 */

CREATE PROCEDURE [dbo].[USP_GetRecentSavedRecords]
(
@UserKey INT,
@SiteKey INT
)
AS
BEGIN

/* Get Top 5 Trip Request From Trip Request */
DECLARE @tblPurchase TABLE 
(
tripKey INT,
tripSavedKey uniqueidentifier 
)

INSERT @tblPurchase(tripKey,tripSavedKey)
	SELECT TOP 5 [tripKey],tripSavedKey
	FROM [Trip] WITH(NOLOCK)
	WHERE UserKey = @UserKey
	AND SiteKey = @SiteKey
	AND recordLocator IS NULL OR recordLocator = ''
	AND tripSavedKey IS NOT NULL
	ORDER BY 1 DESC


--Select * From @tblPurchase
/* ------------ TRIP DETAILS -------------------------------*/	
SELECT T.[tripKey],[tripName],[userKey],[recordLocator],[tripStatusKey],T.[tripSavedKey],T.[tripSavedKey]
      ,[tripComponentType],[siteKey],[isOnlineBooking],[tripAdultsCount],[tripSeniorsCount],[tripChildCount]
      ,[tripInfantCount],[tripYouthCount],[noOfTotalTraveler],[noOfRooms],[noOfCars]
 FROM [Trip] T
 INNER JOIN  @tblPurchase R ON R.TripKey = T.[tripKey]

 
/* ------------ TRIP AIR -------------------------------*/	 
SELECT [tripAirResponseKey],TAR.[airResponseKey],TAR.[tripKey],[tripGUIDKey],searchAirPrice,
	   searchAirTax,[actualAirPrice],[actualAirTax],[actualAirPriceBreakupKey]
      ,[CurrencyCodeKey],[repricedAirPrice],[repricedAirTax],[repricedAirPriceBreakupKey],[bookingCharges]
      ,[appliedDiscount],TAL.[ValidatingCarrier],[status],[gdsSourceKey]
      ,TASK.[airLegNumber],[airSegmentMarketingAirlineCode],[airSegmentOperatingAirlineCode],[airSegmentFlightNumber]
      ,[airSegmentDuration],[airSegmentEquipment],[airSegmentMiles],[airSegmentDepartureDate],[airSegmentArrivalDate]
      ,[airSegmentDepartureAirport],[airSegmentArrivalAirport],[airSegmentResBookDesigCode],TASK.[RecordLocator]
     ,departureAirport.AirportName  as departureAirportName ,                  
	  departureAirport.CityCode as departureAirportCityCode,  
	  departureAirport.CityName as departureAirportCityName,  
	  departureAirport.StateCode   as departureAirportStateCode,                   
	  departureAirport.CountryCode as departureAirportCountryCode,                  
	  arrivalAirport.AirportName  as arrivalAirportName ,  
	  arrivalAirport.CityCode as arrivalAirportCityCode,  
	  arrivalAirport.CityName as arrivalAirportCityName,                  
	  arrivalAirport.StateCode  as arrivalAirportStateCode ,  
	  arrivalAirport.CountryCode as arrivalAirportCountryCode,
	  ISNULL (airven.ShortName,TASK.airSegmentMarketingAirlineCode) AS MarketingAirLine,
	  ISNULL (airOperatingven.ShortName,  
	  TASK.airSegmentOperatingAirlineCode ) AS OperatingAirLine,                  
	  TASK.ticketNumber AS TicketNumber ,  
	  TASK.airsegmentcabin AS airsegmentcabin  
	 
FROM [TripAirResponse] TAR
INNER JOIN @tblPurchase TP ON TAR.[tripGUIDKey] = TP.tripSavedKey
INNER JOIN [TripAirLegs] TAL ON TAL.[airResponseKey] = TAR.[airResponseKey]
INNER JOIN [tripAirSegments] TASK ON TASK.[airResponseKey] = TAR.[airResponseKey]
AND TASK.tripAirLegsKey = TAL.tripAirLegsKey
LEFT OUTER JOIN AirVendorLookup airVen                   
 ON TASK.airSegmentMarketingAirlineCode = airVen .AirlineCode                   
 LEFT OUTER JOIN AirVendorLookup airOperatingVen                   
 ON TASK .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                   
 LEFT OUTER JOIN AirportLookup departureAirport                   
 ON departureAirport .AirportCode = TASK .airSegmentdepartureAirport                   
 LEFT OUTER JOIN AirportLookup arrivalAirport                   
 ON arrivalAirport.AirportCode = TASK .airSegmentarrivalAirport       
WHERE ISNULL(TAL.ISDELETED,0) = 0 AND ISNULL (TASK.ISDELETED ,0) = 0 
ORDER BY 1 ASC
/* ------------ AIR END  -------------------------------*/	 

/* ------------ CAR -------------------------------*/	 
/****** Script for SelectTopNRows command from SSMS  ******/
/*SELECT TCR.[tripKey],[tripGUIDKey],[carVendorKey],[supplierId],[carCategoryCode],[carLocationCode]
      ,[carLocationCategoryCode],[minRate],[minRateTax],[DailyRate],[TotalChargeAmt]
      ,[NoOfDays] ,[SearchCarPrice],[searchCarTax],[actualCarPrice],[actualCarTax],[pickUpDate]
      ,[dropOutDate],[recordLocator],[confirmationNumber],[CurrencyCodeKey]
       ,location.CityCode as CityCode,  
	  location.CityName as CityName,  
	  location.StateCode  as StateCode,                   
	  location.CountryCode as CountryCode    
	  ,CC.CarCompanyName
	  ,SC.[SippCodeDescription]
	  
FROM [TripCarResponse] TCR*/
SELECT  * 
FROM vw_TripCarResponseDetails TCR
INNER JOIN @tblPurchase TP ON TCR.[tripGUIDKey] = TP.tripSavedKey
/* ------------ CAR END -------------------------------*/

/* ------------ HOTEL  -------------------------------*/	 	
/*SELECT [supplierHotelKey],THR.[tripKey],[tripGUIDKey],[supplierId],[minRate],[minRateTax],[hotelDailyPrice]
      ,[hotelDescription],[hotelRatePlanCode],[hotelTotalPrice],[hotelPriceType],[hotelTaxRate]
      ,[SearchHotelPrice],[searchHotelTax],[actualHotelPrice],[actualHotelTax],[checkInDate],[checkOutDate]
      ,[recordLocator],[confirmationNumber],[CurrencyCodeKey],[hotelCheckInTime],[hotelCheckOutTime]
      ,[status],[vendorCode],[cityCode]
  FROM [TripHotelResponse] THR*/
  SELECT *
  FROM [vw_TripHotelResponseDetails] THR
  INNER JOIN @tblPurchase TP ON THR.[tripGUIDKey] = TP.tripSavedKey
  --WHERE ISNULL(THR.IsDeleted,0) = 0
/* ------------ END HOTEL  -------------------------------*/	 	


/* ------------ CRUES  -------------------------------*/	 	
SELECT TCSR.[tripKey],[tripGUIDKey],[confirmationNumber],[recordLocator],[tripCruiseTotalPrice]
      ,[CruiseLineCode],[ShipCode],[SailingDepartureDate],[SailingDuration],[ArrivalPort]
      ,[DeparturePort],[RegionCode],[berthedCategory],[shipLocation],[cabinNbr],[deckId],[status]
FROM [TripCruiseResponse] TCSR
INNER JOIN @tblPurchase TP ON TCSR.[tripGUIDKey] = TP.tripSavedKey
/* ------------ END CRUES  -------------------------------*/	

END
GO
