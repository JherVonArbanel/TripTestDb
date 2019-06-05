SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

     
CREATE PROCEDURE [dbo].[usp_JoinSaveTrip_Back]     
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
 @userKey bigint    
)    
AS    
BEGIN     
  
DECLARE @tripSavedKey AS  UNIQUEIDENTIFIER = (SELECT tripSavedKey FROM trip WITH (NOLOCK) WHERE tripKey = @tripKey)  
DECLARE @newTripKey as INT  = 0 

------GET ORIGINAL TRIP PRICE FOR PAX DETAILS PROVIDED   
declare @searchAirPrice as decimal ( 18,2)     
declare @searchAirTax as decimal ( 18,2)      
    
 SELECT      
@searchAirPrice =(( isnull(tripAdultBase,0) * isnull(@noOfAdult ,0) ) + (isnull(tripChildBase,0)*isnull(@noOfChild,0) ) +     
( isnull(tripSeniorBase,0) * isnull(@noOfSenior,0) ) + (isnull(tripYouthBase,0)*isnull(@noOfYouth,0) ) + (isnull(tripInfantBase,0)*isnull(@noOfInfant,0) )  )    
,@searchAirTax =(( isnull(tripAdulttax,0) * isnull(@noOfAdult,0) ) + (isnull(tripChildtax,0)*isnull(@noOfChild,0) ) +     
( isnull(tripSeniortax,0) * isnull(@noOfSenior,0) ) + (isnull(tripYouthtax,0)*isnull(@noOfYouth,0) ) + (isnull(tripInfanttax,0)*isnull(@noOfInfant,0) )  )    
 from TripAirPrices TAP  WITH (NOLOCK)  
inner join TripAirResponse TR WITH (NOLOCK) on TAP.tripAirPriceKey = TR.searchAirPriceBreakupKey     
inner join Trip T WITH (NOLOCK) on TR.tripGUIDKey = T.tripSavedKey  where t.tripKey = @tripKey     
  
 declare @searchHotelPrice as decimal ( 18,2)     
 declare @searchHotelTax as decimal ( 18,2)      
  
    
SELECT DISTINCT   @searchHotelPrice=vw.hotelTotalPrice-hotelTaxRate ,@searchHotelTax  =hotelTaxRate  From Trip T WITH (NOLOCK) inner join       
vw_tripHotelResponseDetails VW on   tripSavedKey  =  vw.tripGUIDKey  where t.tripKey = @tripKey     
  
declare @searchCarPrice as decimal ( 18,2)     
declare @searchCarTax as decimal ( 18,2)      
  
     
select   @searchCarPrice = SearchCarPrice , @searchCarTax = searchCarTax  from Trip T WITH (NOLOCK) Inner join  vw_tripCarResponseDetails VW on    tripSavedKey  =  vw.tripGUIDKey       
where T.tripKey =@tripKey    
  
  
 -----ORIGINAL PRICE CODE END HERE---------  
 INSERT INTO  Trip     
 (  
  tripName,userKey ,startDate,endDate,tripStatusKey,tripSavedKey,agencyKey,tripComponentType ,tripRequestKey    
        ,CreatedDate,siteKey ,isBid,isOnlineBooking,tripAdultsCount,tripSeniorsCount,tripChildCount,tripInfantCount,tripYouthCount    
        ,noOfTotalTraveler,noOfRooms,noOfCars,recordLocator,IsWatching  ,tripOriginalTotalBaseCost,tripOriginalTotalTaxCost  
    )  
 (  
  SELECT TOP 1 tripName, @userKey, startDate, endDate, 14, TS.tripSavedKey, agencyKey, tripComponentType, tripRequestKey   
           , GETDATE(), siteKey, isBid, isOnlineBooking, @noOfAdult, @noOfSenior, @noOfChild, @noOfInfant, @noOfYouth   
           , @noOfTotalTravler, CASE WHEN @noOFRooms = 0 THEN noOfRooms ELSE @noOFRooms END,   
           CASE WHEN @noOFcars = 0 THEN noOfCars ELSE @noOFcars END , '', 1  ,(isNUll(@searchAirPrice ,0)+   isnull(@searchCarPrice,0)  + (isnull(@searchHotelPrice,0) )),(isnull(@searchAirTax,0) + isnull(@searchCarTax,0)+ISNULL(@searchHotelTax,0))  
        FROM TripSaved TS WITH (NOLOCK)
   INNER JOIN Trip t WITH (NOLOCK) on TS.tripSavedKey = T.tripSavedKey and t.userKey = Ts.userKey   
  WHERE ts.tripSavedKey = @tripSavedKey   
 );  
   
  SELECT @newTripKey =SCOPE_IDENTITY()  
 
 
 
DECLARE @dealTable AS TABLE  (dealKey int , componentType int , creationDate datetime )

INSERT @dealTable 
 
select   max(TripsaveddealKey) , componentType, Convert(Date,[creationDate])  From trip..tripsaveddeals where tripKey  = @tripKey    and  [creationDate] > Dateadd(DAY,-2,getdate())
group by tripKey ,componentType ,Convert(Date,[creationDate])  
order by 1 desc 
 

INSERT TripSavedDeals 
SELECT  @newTripKey , responseKey ,TSD.componentType,currentPerPersonPrice,originalPerPersonPrice,fareCategory ,responseDetailKey ,TSD.creationDate,
dealSentDate,processedDate,isAlternate,vendorDetails, 
(( isnull(tripAdultBase,0) * isnull(@noOfAdult ,0) ) + (isnull(tripChildBase,0)*isnull(@noOfChild,0) ) +     
( isnull(tripSeniorBase,0) * isnull(@noOfSenior,0) ) + (isnull(tripYouthBase,0)*isnull(@noOfYouth,0) ) + (isnull(tripInfantBase,0)*isnull(@noOfInfant,0) )  )    
+(( isnull(tripAdulttax,0) * isnull(@noOfAdult,0) ) + (isnull(tripChildtax,0)*isnull(@noOfChild,0) ) +     
( isnull(tripSeniortax,0) * isnull(@noOfSenior,0) ) + (isnull(tripYouthtax,0)*isnull(@noOfYouth,0) ) + (isnull(tripInfanttax,0)*isnull(@noOfInfant,0) )  )     ,(@searchAirPrice+@searchAirTax) ,Remarks

FROM @dealTable D inner join TripSavedDeals TSD on D.dealKey = TSD.TripSavedDealKey 
INNER JOIN TripAirResponse TAR on TSD.responseKey = TAR.airResponseKey  
INNER JOIN TripAirPrices TAP on TAP.tripAirPriceKey = TAR.searchAirPriceBreakupKey 



INSERT TripSavedDeals 
SELECT  @newTripKey ,  responseKey ,TSD.componentType,currentPerPersonPrice,originalPerPersonPrice,fareCategory ,responseDetailKey ,TSD.creationDate,
dealSentDate,processedDate,isAlternate,vendorDetails, 
  currentTotalPrice   ,(@searchHotelPrice+@searchHotelTax) ,Remarks
FROM @dealTable D inner join TripSavedDeals TSD on D.dealKey = TSD.TripSavedDealKey  where ( TSD.componentType = 2 or TSD.componentType = 4)



SELECT @newTripKey 

      
END
GO
