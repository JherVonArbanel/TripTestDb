SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vw_RecommendedTripsSavings] as

SELECT tripKey, tripSavedKey, SUM(TripComponentType) TripComponentType
,SUM(currentPrice) currentPrice, SUM(originalPrice) originalPrice, SUM(originalTotalPrice) originalTotalPrice
,SUM(currentTotalPrice) currentTotalPrice, OriginAirportCode, DestinationAirportCode, AdultCount, ChildCount
,(SUM(currentPrice) - SUM(originalPrice)) As savings
FROM  
(
SELECT  T.tripKey, T.tripSavedKey, 
            TSD.componenttype TripComponentType
            ,( Case when  TSD.componentType = 1 then  TSD.currentPerPersonPrice ELSE TSD.currentTotalPrice END )  As currentPrice
            ,( Case when  TSD.componentType = 1 then  TSD.originalPerPersonPrice ELSE TSD.originalTotalPrice END) As originalPrice, 
            TSD.originalTotalPrice ,TSD.currentTotalPrice,
			TR.tripFrom1 OriginAirportCode, TR.tripTo1 DestinationAirportCode,
            T.tripAdultsCount AdultCount
            ,T.tripChildCount ChildCount
        FROM Trip T
                LEFT OUTER JOIN TripRequest  TR ON T.tripRequestKey = TR.tripRequestKey  
                LEFT OUTER JOIN Tripsaveddeals TSD ON (t.tripKey = tsd.tripKey)
                INNER JOIN
                (SELECT MAX(TSD1.TripSavedDealKey) TripSavedDealKey, TSD1.tripKey, TSD1.componentType
        FROM TripSavedDeals TSD1 
        GROUP BY TSD1.TripKey, TSD1.componentType
          )
         TSD2 ON (TSD.TripSavedDealKey = TSD2.TripSavedDealKey)
        WHERE T.tripSavedKey IS NOT NULL  AND T.Startdate >  DATEADD(D,2, GetDate()) AND T.tripStatusKey <> 17 
         ) T 
         GROUP BY tripKey,tripSavedKey,OriginAirportCode,DestinationAirportCode, AdultCount,ChildCount
GO
