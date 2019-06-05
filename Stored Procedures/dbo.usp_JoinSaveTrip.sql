SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


     
CREATE PROCEDURE [dbo].[usp_JoinSaveTrip]     
(    
 @tripKey int ,    
 @noOfAdult int = 0,     
 @noOfSenior int = 0,    
 @noOfChild int=0 ,    
 @noOfInfant int =0 ,    
 @noOfYouth int =0 ,    
 @noOfTotalTravler int = 0 ,    
 @noOFRooms int = 0 ,    
 @noOFcars int = 0 ,    
 @userKey bigint  ,
 @viewershipType INT = 1  ,
 @tripCreationPath INT = 1 
)    
AS    
BEGIN     
  
DECLARE @tripSavedKey AS  UNIQUEIDENTIFIER = (SELECT tripSavedKey FROM trip WITH (NOLOCK) WHERE tripKey = @tripKey)  
DECLARE @newTripKey as INT  = 0 

-- THIS LINE WAS WRITTEN TO SOLVE TMU ISSUE OF "Mr.TOM D" WHERE :- 1 User has multiple trip with same Save TripKey ...
IF EXISTS (SELECT 1 FROM Trip WITH(NOLOCK) WHERE tripSavedKey = @tripSavedKey AND userKey = @userKey AND IsWatching = 1)
BEGIN 
	SELECT 0
	RETURN
END 


------GET ORIGINAL TRIP PRICE FOR PAX DETAILS PROVIDED   
declare @searchAirPrice as decimal ( 18,2)     
declare @searchAirTax as decimal ( 18,2) 
DECLARE @originalPerPersonPriceAir as decimal (18,2)     
    
 SELECT      
@searchAirPrice =(( isnull(tripAdultBase,0) * isnull(@noOfAdult ,0) ) + (isnull(tripChildBase,0)*isnull(@noOfChild,0) ) +     
( isnull(tripSeniorBase,0) * isnull(@noOfSenior,0) ) + (isnull(tripYouthBase,0)*isnull(@noOfYouth,0) ) + (isnull(tripInfantBase,0)*isnull(@noOfInfant,0) )  )    
,@searchAirTax =(( isnull(tripAdulttax,0) * isnull(@noOfAdult,0) ) + (isnull(tripChildtax,0)*isnull(@noOfChild,0) ) +     
( isnull(tripSeniortax,0) * isnull(@noOfSenior,0) ) + (isnull(tripYouthtax,0)*isnull(@noOfYouth,0) ) + (isnull(tripInfanttax,0)*isnull(@noOfInfant,0) )  )    
,@originalPerPersonPriceAir = (CASE WHEN ISNULL(tripAdultBase,0) > 0 THEN (tripAdultBase + tripAdultTax) ELSE (tripSeniorBase + tripSeniorTax) END)
 from TripAirPrices TAP  WITH (NOLOCK)  
inner join TripAirResponse TR WITH (NOLOCK) on TAP.tripAirPriceKey = TR.searchAirPriceBreakupKey     
inner join Trip T WITH (NOLOCK) on TR.tripGUIDKey = T.tripSavedKey  where t.tripKey = @tripKey     
  
 declare @searchHotelPrice as decimal ( 18,2)     
 declare @searchHotelTax as decimal ( 18,2)      
 declare @originalHotelTotal as decimal (18,2)
  
    
SELECT DISTINCT   @searchHotelPrice=vw.hotelTotalPrice-hotelTaxRate ,@searchHotelTax  =hotelTaxRate,
 @originalHotelTotal=(vw.hotelTotalPrice * @noOFRooms)  From Trip T WITH (NOLOCK) inner join       
TripHotelResponse  VW WITH(NOLOCK) on   tripSavedKey  =  vw.tripGUIDKey  where t.tripKey = @tripKey     
  
declare @searchCarPrice as decimal ( 18,2)     
declare @searchCarTax as decimal ( 18,2)      
  
 --AS car is only 1 in itinerary then per person and total is same    
select   @searchCarPrice = SearchCarPrice , @searchCarTax = searchCarTax  from Trip T WITH (NOLOCK) Inner join  TripCarResponse VW  WITH(NOLOCK) on    tripSavedKey  =  vw.tripGUIDKey       
where T.tripKey =@tripKey    
  
  
 -----ORIGINAL PRICE CODE END HERE---------  
 INSERT INTO  Trip     
 (  
  tripName,userKey ,startDate,endDate,tripStatusKey,tripSavedKey,agencyKey,tripComponentType ,tripRequestKey    
        ,CreatedDate,siteKey ,isBid,isOnlineBooking,tripAdultsCount,tripSeniorsCount,tripChildCount,tripInfantCount,tripYouthCount    
        ,noOfTotalTraveler,noOfRooms,noOfCars,recordLocator,IsWatching  ,tripOriginalTotalBaseCost,tripOriginalTotalTaxCost 
        ,privacyType , tripCreationPath, isUserCreatedSavedTrip
    )  
 (  
  SELECT TOP 1 tripName, @userKey, startDate, endDate, 14, TS.tripSavedKey, agencyKey, tripComponentType, tripRequestKey   
           , GETDATE(), siteKey, isBid, isOnlineBooking, @noOfAdult, @noOfSenior, @noOfChild, @noOfInfant, @noOfYouth   
           , @noOfTotalTravler, CASE WHEN @noOFRooms = 0 THEN noOfRooms ELSE @noOFRooms END,   
           CASE WHEN @noOFcars = 0 THEN noOfCars ELSE @noOFcars END , '', 1  ,(isNUll(@searchAirPrice ,0)+   isnull(@searchCarPrice,0)  + (isnull(@searchHotelPrice,0) )),(isnull(@searchAirTax,0) + isnull(@searchCarTax,0)+ISNULL(@searchHotelTax,0))  
           ,@viewershipType ,@tripCreationPath, 1
        FROM TripSaved TS WITH (NOLOCK)
   INNER JOIN Trip t WITH (NOLOCK) on TS.tripSavedKey = T.tripSavedKey and t.userKey = Ts.userKey   
  WHERE ts.tripSavedKey = @tripSavedKey   
 );  
   
  SELECT @newTripKey =SCOPE_IDENTITY()  
 
 
 
DECLARE @dealTable AS TABLE  (dealKey int , componentType int , creationDate datetime )

INSERT @dealTable 
 
select   max(TripsaveddealKey) , componentType, Convert(Date,[creationDate])  From trip..tripsaveddeals WITH(NOLOCK) where tripKey  = @tripKey    and  [creationDate] > Dateadd(DAY,-1,Convert(Date,getdate()))
group by tripKey ,componentType ,Convert(Date,[creationDate])  
order by 1 ASC  
 
DECLARE @airDealKey AS INT =0
DECLARE @carDealKey AS INT =0
DECLARE @hotelDealKey AS INT =0
INSERT TripSavedDeals 
SELECT  @newTripKey , responseKey ,TSD.componentType,currentPerPersonPrice,originalPerPersonPrice,fareCategory ,responseDetailKey ,TSD.creationDate,
dealSentDate,processedDate,isAlternate,vendorDetails, 
(( isnull(tripAdultBase,0) * isnull(@noOfAdult ,0) ) + (isnull(tripChildBase,0)*isnull(@noOfChild,0) ) +     
( isnull(tripSeniorBase,0) * isnull(@noOfSenior,0) ) + (isnull(tripYouthBase,0)*isnull(@noOfYouth,0) ) + (isnull(tripInfantBase,0)*isnull(@noOfInfant,0) )  )    
+(( isnull(tripAdulttax,0) * isnull(@noOfAdult,0) ) + (isnull(tripChildtax,0)*isnull(@noOfChild,0) ) +     
( isnull(tripSeniortax,0) * isnull(@noOfSenior,0) ) + (isnull(tripYouthtax,0)*isnull(@noOfYouth,0) ) + (isnull(tripInfanttax,0)*isnull(@noOfInfant,0) )  )     ,(@searchAirPrice+@searchAirTax) ,Remarks

FROM @dealTable D inner join TripSavedDeals TSD WITH(NOLOCK) on D.dealKey = TSD.TripSavedDealKey 
INNER JOIN TripAirResponse TAR WITH(NOLOCK) on TSD.responseKey = TAR.airResponseKey  
INNER JOIN TripAirPrices TAP WITH(NOLOCK) on TAP.tripAirPriceKey = TAR.searchAirPriceBreakupKey 

SELECT @airDealKey = (SELECT top 1 TripSavedDealKey FROM  TripSavedDeals TSD WITH(NOLOCK) WHERE tripKey = @newTripKey AND componentType = 1 ORDER BY 1 DESC)

INSERT TripSavedDeals 
SELECT  @newTripKey ,  responseKey ,TSD.componentType,currentPerPersonPrice,originalPerPersonPrice,fareCategory ,responseDetailKey ,TSD.creationDate,
dealSentDate,processedDate,isAlternate,vendorDetails, 
  currentTotalPrice   ,(@searchHotelPrice+@searchHotelTax) ,Remarks
FROM @dealTable D inner join TripSavedDeals TSD on D.dealKey = TSD.TripSavedDealKey  where (  TSD.componentType = 4)
 SELECT @hotelDealKey = (SELECT top 1 TripSavedDealKey FROM  TripSavedDeals TSD WITH(NOLOCK) WHERE tripKey = @newTripKey AND componentType = 4 ORDER BY 1 DESC)

INSERT TripSavedDeals 
SELECT  @newTripKey ,  responseKey ,TSD.componentType,currentPerPersonPrice,originalPerPersonPrice,fareCategory ,responseDetailKey ,TSD.creationDate,
dealSentDate,processedDate,isAlternate,vendorDetails, 
  currentTotalPrice   ,(@searchCarPrice +@searchCarTax ) ,Remarks
FROM @dealTable D inner join TripSavedDeals TSD on D.dealKey = TSD.TripSavedDealKey  where ( TSD.componentType = 2 )

SELECT @carDealKey = (SELECT top 1 TripSavedDealKey FROM  TripSavedDeals TSD WITH(NOLOCK) WHERE tripKey = @newTripKey AND componentType = 2 ORDER BY 1 DESC)

SELECT @newTripKey 


DECLARE @FollowersCount INT
SET @FollowersCount = 0

SELECT @FollowersCount =  dbo.udf_GetFollowersCount(@tripSavedKey)
--PRINT '@FollowersCount ' + CAST(@FollowersCount AS VARCHAR)

UPDATE Trip
SET FollowersCount = @FollowersCount  
WHERE tripKey = @newTripKey 

EXEC CMS..usp_SaveDestinationImageUrlByTripId @newTripKey, 'Small'

/*INSERT DATA INTO TripDetails TABLE WHEN THERE IS A FOLLOW DEAL - TMU*/
IF((SELECT COUNT(tripKey) FROM TripDetails WHERE tripKey = @tripKey) > 0)
BEGIN
	  DECLARE @latestDealAirSavingsPerPerson  FLOAT
		,@latestDealHotelSavingsPerPerson FLOAT		
		,@latestDealAirSavingsTotal FLOAT
		,@latestDealHotelSavingsTotal FLOAT
		,@latestDealCarSavingsTotal FLOAT
		,@latestDealAirPricePerPerson FLOAT
		,@latestDealHotelPricePerPerson	FLOAT	
		,@latestDealAirPriceTotal FLOAT
		,@latestDealHotelPriceTotal FLOAT
		,@latestDealCarPriceTotal FLOAT
		
	   IF(isnull(@airDealKey,0) > 0 ) 
	   BEGIN 
		   SELECT @latestDealAirPricePerPerson = currentPerPersonPrice ,
		   @latestDealAirPriceTotal =currentTotalPrice ,
		   @latestDealAirSavingsPerPerson = (originalPerPersonPrice-currentPerPersonPrice) ,
		   @latestDealAirSavingsTotal =(originalTotalPrice-currentTotalPrice ) 
		   FROM TripSavedDeals WITH(NOLOCK) WHERE TripSavedDealKey =@airDealKey
	   END 
	   
	   IF ( ISNULL(@hotelDealKey,0) > 0 ) 
	   BEGIN
		   SELECT @latestDealHotelPricePerPerson = currentTotalPrice ,
		   @latestDealHotelPriceTotal =currentTotalPrice * @noOFRooms ,--- currentTotalPrice & originalTotalPrice stores per room total
		   @latestDealHotelSavingsPerPerson = (originalTotalPrice-currentTotalPrice) ,
		   @latestDealHotelSavingsTotal =(originalTotalPrice * @noOFRooms)-(currentTotalPrice * @noOFRooms ) 
		   FROM TripSavedDeals WITH(NOLOCK) WHERE TripSavedDealKey =@hotelDealKey
	   END
	   
	   IF (ISNULL( @carDealKey ,0)> 0 ) 
	   BEGIN
	      SELECT 
		   @latestDealCarPriceTotal =currentTotalPrice,		   
		   @latestDealCarSavingsTotal =(originalTotalPrice )-(currentTotalPrice  ) 
		   FROM TripSavedDeals WITH(NOLOCK) WHERE TripSavedDealKey =@carDealKey
	   END 
	INSERT INTO TripDetails 
	(
		tripKey
		,tripSavedKey
		,userKey
		,tripFrom
		,tripTo
		,tripStartDate
		,tripEndMonth
		,tripEndYear
		,latestDealAirSavingsPerPerson
		,latestDealHotelSavingsPerPerson		
		,latestDealAirSavingsTotal
		,latestDealHotelSavingsTotal
		,latestDealCarSavingsTotal
		,latestDealAirPricePerPerson
		,latestDealHotelPricePerPerson		
		,latestDealAirPriceTotal
		,latestDealHotelPriceTotal
		,latestDealCarPriceTotal
		,AirRequestTypeName
		,AirCabin
		,HotelRegionName
		,HotelRating
		,HotelName
		,CarClass
		,CarVendorCode
		,fromCountryCode
		,fromCountryName
		,fromStateCode
		,fromCityName
		,toCountryCode
		,toCountryName
		,toStateCode
		,toCityName
		,tripEndDate
		,HotelResponseKey
		,originalPerPersonPriceAir
		,originalTotalPriceAir		 
		,originalTotalPriceCar
		,originalPerPersonPriceHotel
		,originalTotalPriceHotel
	)
		SELECT 
		@newTripKey
		,tripSavedKey
		,@userKey
		,tripFrom
		,tripTo
		,tripStartDate
		,tripEndMonth
		,tripEndYear
		,@latestDealAirSavingsPerPerson 
		,@latestDealHotelSavingsPerPerson 		 
		,@latestDealAirSavingsTotal 
		,@latestDealHotelSavingsTotal 
		,@latestDealCarSavingsTotal 
		,@latestDealAirPricePerPerson 
		,@latestDealHotelPricePerPerson 		
		,@latestDealAirPriceTotal 
		,@latestDealHotelPriceTotal 
		,@latestDealCarPriceTotal 
		,AirRequestTypeName
		,AirCabin
		,HotelRegionName
		,HotelRating
		,HotelName
		,CarClass
		,CarVendorCode		
		,fromCountryCode
		,fromCountryName
		,fromStateCode
		,fromCityName
		,toCountryCode
		,toCountryName
		,toStateCode
		,toCityName
		,tripEndDate
		,ISNULL(HotelResponseKey, '00000000-0000-0000-0000-000000000000')
		,@originalPerPersonPriceAir --originalPerPersonPriceAir
		,(@searchAirPrice + @searchAirTax) --originalTotalPriceAir		 
		,(@searchCarPrice +@searchCarTax) --originalTotalPriceCar
		,(@searchHotelPrice + @searchHotelTax) --originalPerPersonPriceHotel
		, @originalHotelTotal--originalTotalPriceHotel
		FROM TripDetails
		WHERE tripKey = @tripKey	
END
ELSE
BEGIN
	INSERT INTO TripSavedDealLog 
	(
		TripKey
		,Remarks
		,ErrorDate
		,InitiatedFrom
	)
	VALUES
	(
		@tripKey
		,'Original trip key not found in TripDetails table while doing follow deal'
		,GETDATE()
		,'JoinSaveTrip'
	)
END
/*END: INSERT DATA INTO TripDetails TABLE WHEN THERE IS A FOLLOW DEAL - TMU*/
      
END    



GO
