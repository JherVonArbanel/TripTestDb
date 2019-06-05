SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--usp_GetSavingsTrendForSpecifiedPeriod 9685,10 ,0  
CREATE PROCEDURE [dbo].[usp_GetSavingsTrendForSpecifiedPeriod]  
(  
@tripKey INT,  
@duration INT,  
@userKey INT = 0   
)  
AS  
BEGIN   
  
DECLARE @startDate AS DATETIME  = DATEADD(DAY,-(@duration),GETDATE())  
DECLARE @isWatcher AS BIT = 0   
IF ( SELECT COUNT(*) FROM Trip WITH(NOLOCK)  WHERE tripKey = @tripKey AND userKey = @userKey ) > 0   
BEGIN   
SET @isWatcher = 1   
END  
DECLARE @tripSavings AS TABLE   
(  
 dealDate DATE ,  
 savings FLOAT ,  
 componetType INT  
)  
  
DECLARE @tripLatestDeals AS TABLE   
(  
 dealDate DATE ,  
 dealKey INT ,  
 componetType INT  
 )  
INSERT @tripLatestDeals (dealKey ,dealDate,componetType)  
  select max(TripSavedDealKey),Convert(Date,[creationDate]),componentType  from [dbo].[TripSavedDeals]  WITH(NOLOCK)     
  WHERE tripkey = @tripKey AND creationDate >  @startDate    
   group by tripKey ,  Convert(Date,[creationDate]),componentType   
  
INSERT @tripSavings (dealDate ,savings, componetType )   
(  
SELECT creationDate  , (CASE WHEN @isWatcher =0 THEN (currentPerPersonPrice )ELSE (currentTotalPrice)END )AS Savings ,1 FROM TripSavedDeals  TSD  WITH(NOLOCK)       
 INNER JOIN @tripLatestDeals TLD ON TSD.TripSavedDealKey  = TLD.dealKey  
WHERE componentType = 1 AND tripKey = @tripKey AND creationDate >  @startDate     
UNION   
SELECT creationDate ,  (currentTotalPrice) AS Savings ,2 FROM TripSavedDeals  TSD    WITH(NOLOCK)     
INNER JOIN @tripLatestDeals TLD ON TSD.TripSavedDealKey  = TLD.dealKey  
WHERE  componentType = 2 AND tripKey = @tripKey AND creationDate >  @startDate     
UNION   
SELECT creationDate , (currentTotalPrice) AS Savings,4 FROM TripSavedDeals  TSD    WITH(NOLOCK)     
 INNER JOIN @tripLatestDeals TLD ON TSD.TripSavedDealKey  = TLD.dealKey  
  WHERE componentType = 4 AND tripKey = @tripKey AND creationDate >  @startDate      
)  
SELECT dealDate ,SUM(savings) AS TotalSavings FROM @tripSavings GROUP BY dealDate ORDER BY dealDate   
  
END  
  
  
  
  
  
  
GO
