SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_UpdateRegionAirportGroupCrowdAndImage]   
@IsDestinationRequired int = 1 
AS  
BEGIN  
  
DECLARE @CrowdCounttbl TABLE ( TripTo VARCHAR(50), CrowdCount INT);  
  
DECLARE @CrowdImagetbl TABLE (ImageCnt INT,DestinationId INT,AptCode VARCHAR(50));  
  
DECLARE @DefaultCrowdImagetbl TABLE (ImageCnt INT,DestinationId INT,AptCode VARCHAR(50));  
  
DECLARE @DestinationId int;  
DECLARE @ImageNo int;  
  
WITH tbl(TripTo,CrowdCount)    
AS  
(  
 SELECT      
  TD.tripTo,COUNT(TD.tripTo)  
 FROM TRIP..TripDetails TD WITH (NOLOCK)    
 INNER JOIN Trip..Trip T WITH (NOLOCK) ON T.tripKey = TD.tripKey     
 WHERE     
 T.tripStatusKey <> 17       
 AND TD.tripTo IS NOT NULL    
 AND TD.tripStartDate >= DATEADD(D,0, GetDate())    
 AND T.PrivacyType <>2              
 AND T.IsWatching = 1 AND T.isUserCreatedSavedTrip =1     
 GROUP BY TD.tripTo,T.DestinationSmallImageURL   
)  
  
 INSERT INTO @CrowdCounttbl(TripTo,CrowdCount)  
 SELECT TripTo, COUNT(TripTo) as [CrowdCount] FROM tbl GROUP BY TripTo  
  
  
 --SELECT * FROM @CrowdCounttbl   
  
  
 UPDATE RAG   
 SET RAG.CrowdCount= TT.CrowdCount    
 FROM Trip..RegionAirportGroup RAG  
 INNER JOIN @CrowdCounttbl TT ON TT.TripTo = RAG.AirportCode    
  
  
  
 IF @IsDestinationRequired = 1  
 BEGIN  
 /*this condition has been added to update Image only once not everytime*/  
  update Trip..RegionAirportGroup set ImageUrl= null
  
  INSERT INTO @CrowdImagetbl(ImageCnt ,DestinationId ,AptCode )  
  SELECT COUNT(DI.DestinationId) AS [ImageCnt],DI.DestinationId, D.AptCode FROM CMS..DestinationImages DI  
  INNER JOIN CMS..Destination D ON D.DestinationId = DI.DestinationId AND D.AptCode <> '' AND DI.IsEnabled = 1  
  group by DI.DestinationId , D.AptCode  
  
  --SELECT * FROM @CrowdImagetbl  
  
  UPDATE RAG   
  SET RAG.ImageUrl= DS.ImageURL  
  FROM Trip..RegionAirportGroup RAG  
  INNER JOIN @CrowdImagetbl DT ON DT.AptCode = RAG.AirportCode    
  INNER JOIN CMS..DestinationImages DS on Ds.DestinationId = DT.DestinationId and DS.OrderId = FLOOR(RAND() * DT.ImageCnt + 1)   
  
    
  INSERT INTO @DefaultCrowdImagetbl(ImageCnt ,DestinationId ,AptCode )  
  SELECT TOP 1 COUNT(DI.DestinationId) AS [ImageCnt] , DI.DestinationId, D.AptCode FROM CMS..DestinationImages DI  
  INNER JOIN CMS..Destination D ON D.DestinationId = DI.DestinationId AND D.AptCode = '' AND DI.IsEnabled = 1  
  group by DI.DestinationId , D.AptCode  
  order by NEWID()  
  
  --select * from @DefaultCrowdImagetbl  
  
  SELECT @DestinationId = DestinationId, @ImageNo = ImageCnt FROM @DefaultCrowdImagetbl  
  --print @DestinationId   
  --print @ImageNo   
  
  UPDATE Trip..RegionAirportGroup   
  SET ImageUrl= (select ImageURL from CMS..DestinationImages where DestinationId=@DestinationId and OrderId = FLOOR(RAND() * @ImageNo) + 1 )  
  where ImageUrl is null  
  
  
 END  
  
END
GO
