SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--select * from [dbo].[vw_SilverPop_DealOfDay]
CREATE VIEW [dbo].[vw_SilverPop_DealOfDay]
AS

	SELECT tripKey,        tripSavedKey        ,  
               CASE WHEN SUM(TripComponentType)  = 1 THEN 'Air'
                       WHEN SUM(TripComponentType)  = 2 THEN 'Car'
                       WHEN SUM(TripComponentType)  = 3 THEN 'Air, Car'
                       WHEN SUM(TripComponentType)  = 4 THEN 'Hotel'
                       WHEN SUM(TripComponentType)  = 5 THEN 'Air, Hotel'
                       WHEN SUM(TripComponentType)  = 6 THEN 'Car, Hotel' 
                      WHEN SUM(TripComponentType)  = 7 THEN 'Air, Car, Hotel'
               END TripComponentType 

,SUM(        currentPrice) currentPrice,        sum(originalPrice) originalPrice,        MAX(OfferDate)OfferDate ,        0 as  AlternativeDescription        ,sum(originalTotalPrice) originalTotalPrice        ,sum(currentTotalPrice) currentTotalPrice,        max(ModifiedDateTime) ModifiedDateTime,        OriginAirportCode        ,DestinationAirportCode        ,SUM(OriginalTripCost) OriginalTripCost        ,sum(ActualTripCost)ActualTripCost         ,AdultCount        ,ChildCount
FROM  
(

SELECT  T.tripKey, T.tripSavedKey, 
               TSD.componenttype TripComponentType, TSD.currentPerPersonPrice As currentPrice, TSD.originalPerPersonPrice As originalPrice, TSD.dealSentDate OfferDate, 
               TSD.isAlternate AlternativeDescription ,TSD.originalTotalPrice ,TSD.currentTotalPrice
                ,T.ModifiedDateTime, TR.tripFrom1 OriginAirportCode, TR.tripTo1 DestinationAirportCode
                , TSD.originalTotalPrice OriginalTripCost, TSD.currentTotalPrice ActualTripCost, T.tripAdultsCount AdultCount
                , T.tripChildCount ChildCount
        FROM Trip T
                LEFT OUTER JOIN TripRequest  TR ON T.tripRequestKey = TR.tripRequestKey  
                LEFT OUTER JOIN Tripsaveddeals TSD On           (  t.tripKey = tsd.tripKey  )
                INNER JOIN
                
                (SELECT MAX(TSD1.TripSavedDealKey) TripSavedDealKey, TSD1.tripKey, TSD1.componentType
        FROM TripSavedDeals TSD1 
                 where Convert(Date,[creationDate])= Convert(Date,GETDATE())
        GROUP BY TSD1.TripKey, TSD1.componentType
          )
         TSD2 on (TSD.TripSavedDealKey = TSD2.TripSavedDealKey   )

         
        WHERE T.tripSavedKey IS NOT NULL AND T.tripStatusKey IN (14, 15) AND IsWatching = 1
         ) T 
         
         GROUP BY tripKey,        tripSavedKey        ,        OfferDate,                                  OriginAirportCode        ,DestinationAirportCode        , AdultCount        ,ChildCount
GO
