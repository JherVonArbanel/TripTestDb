SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 10th May 2013
-- Description:	It select's the latest recommended deals excluding the failed trip saved deals
-- =============================================
--EXEC USP_GetRecommendedDeals
CREATE PROCEDURE [dbo].[USP_GetRecommendedDeals]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Tbl_TripSavedDeals AS TABLE (TripSavedDealKey INT, TripKey INT, ComponentType INT)

	INSERT INTO @Tbl_TripSavedDeals(TripSavedDealKey, TripKey, ComponentType)
	SELECT MAX(TSD1.TripSavedDealKey) TripSavedDealKey, TSD1.tripKey, TSD1.componentType
    FROM TripSavedDeals TSD1 WHERE componentType = 4 AND responseDetailKey IS NOT NULL AND Remarks NOT LIKE 'All conditions fail%'
    GROUP BY TSD1.TripKey, TSD1.componentType

	INSERT INTO @Tbl_TripSavedDeals(TripSavedDealKey, TripKey, ComponentType)
	SELECT MAX(TSD1.TripSavedDealKey) TripSavedDealKey, TSD1.tripKey, TSD1.componentType
    FROM TripSavedDeals TSD1 WHERE componentType = 1 AND Remarks NOT LIKE 'Failed Trip Key%' AND Remarks NOT LIKE 'All conditions fail%'
    GROUP BY TSD1.TripKey, TSD1.componentType

	INSERT INTO @Tbl_TripSavedDeals(TripSavedDealKey, TripKey, ComponentType)
	SELECT MAX(TSD1.TripSavedDealKey) TripSavedDealKey, TSD1.tripKey, TSD1.componentType
    FROM TripSavedDeals TSD1 WHERE componentType = 2 AND responseDetailKey IS NOT NULL AND Remarks NOT LIKE 'Failed Trip Key%' 
    AND Remarks NOT LIKE 'All conditions fail%'
    GROUP BY TSD1.TripKey, TSD1.componentType


	SELECT T.tripKey, T.tripSavedKey, SUM(T.TripComponentType) TripComponentType
	,SUM(T.currentPrice) currentPrice, SUM(T.originalPrice) originalPrice, SUM(T.originalTotalPrice) originalTotalPrice
	,SUM(T.currentTotalPrice) currentTotalPrice, T.OriginAirportCode, T.DestinationAirportCode, T.AdultCount, T.ChildCount
	,(SUM(T.currentPrice) - SUM(T.originalPrice)) AS savings
	FROM  
	(
		SELECT  T.tripKey, T.tripSavedKey, TSD.componenttype TripComponentType
        ,( CASE WHEN  TSD.componentType = 1 THEN  TSD.currentPerPersonPrice ELSE TSD.currentTotalPrice END )  AS currentPrice
        ,( CASE WHEN  TSD.componentType = 1 THEN  TSD.originalPerPersonPrice ELSE TSD.originalTotalPrice END) AS originalPrice, 
        TSD.originalTotalPrice ,TSD.currentTotalPrice, TR.tripFrom1 OriginAirportCode, TR.tripTo1 DestinationAirportCode
        ,T.tripAdultsCount AdultCount, T.tripChildCount ChildCount
        FROM Trip T
                LEFT OUTER JOIN TripRequest  TR ON T.tripRequestKey = TR.tripRequestKey  
                LEFT OUTER JOIN Tripsaveddeals TSD ON (t.tripKey = tsd.tripKey)
                INNER JOIN
                (
					SELECT MAX(TSD1.TripSavedDealKey) TripSavedDealKey, TSD1.TripKey, TSD1.ComponentType
					FROM @Tbl_TripSavedDeals TSD1 
					GROUP BY TSD1.TripKey, TSD1.ComponentType
				) TSD2
				ON (TSD.TripSavedDealKey = TSD2.TripSavedDealKey)
				WHERE T.tripSavedKey IS NOT NULL  AND T.Startdate >  DATEADD(D,2, GetDate()) AND T.tripStatusKey <> 17 
    ) T
    
    GROUP BY T.tripKey,T.tripSavedKey,T.OriginAirportCode,T.DestinationAirportCode,T.AdultCount,T.ChildCount
    HAVING (SUM(T.currentPrice) - SUM(T.originalPrice)) <= -10
    
END
GO
