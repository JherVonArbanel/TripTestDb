SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
    
CREATE Procedure [dbo].[usp_GetFlexibilityOptionsForSaveTrip]    
(@tripRequestKey bigint,    
@tripKey bigInt    
)    
AS     
select * FROM TripAirFlexibilities WITH(NOLOCK) where TripRequestKey = @tripRequestKey AND TripKey = @tripKey     
select * FROM TripCarFlexibilities WITH(NOLOCK) where TripRequestKey = @tripRequestKey AND TripKey = @tripKey     
    
declare @regionID as bigInt = 0   
DECLARE @rating AS float = 0    
--SET @regionID = (select top 1 regionid from TripHotelFlexibilities TH WITH(NOLOCK)     
--   where TripRequestKey = @tripRequestKey AND TripKey = @tripKey )    
       
   if ( @regionId = 0 )    
   BEGIN     
    
DECLARE @hotelId AS INT     
    
         
DECLARE @hotelResponsekey AS Uniqueidentifier     
    
 --SELECT TOP 1 @hotelResponsekey = hotelResponseKey   FROM TripHotelResponse TH WITH(NOLOCK)  inner join Trip T WITH(NOLOCK)  ON TH.tripGUIDKey = T.tripsavedkey        
 --    WHERE T.tripKey = @tripKey    
       
          
  SELECT TOP 1 @hotelId = Convert(int,vendorDetails)   FROM TripSavedDeals TH WITH(NOLOCK)  inner join Trip T WITH(NOLOCK)  ON TH.tripKey = T.tripKey        
      WHERE T.tripKey = @tripKey  and componentType = 4 order by TripSavedDealKey DESC   

     SELECT @rating = HotelRating FROM TripDetails WITH(NOLOCK) WHERE tripKey= @tripKey  
         
     SELECT @RegionId = RegionId FROM HotelContent.dbo.RegionHotelIDMapping WITH (NOLOCK)    
     WHERE HotelId = @HotelId    
     IF ( @rating = 0 )   
     BEGIN  
       SELECT @rating = convert(float, isnull(altHotelRating,0)) FROM TripHotelFlexibilities TH WITH(NOLOCK)    WHERE tripKey= @tripKey  
     END   
       
    IF ( @RegionId = 0 )   
     BEGIN  
       SELECT @RegionId = convert(float, isnull(RegionId,0)) FROM TripHotelFlexibilities TH WITH(NOLOCK)    WHERE tripKey= @tripKey  
     END   
       
   END    

     
   select @rating AS altHotelRating , @RegionId AS regionKey   
     
-- select TH.* , @RegionId AS regionKey FROM TripHotelFlexibilities TH WITH(NOLOCK)     
-----inner join HotelContent..ParentRegionList P WITH(NOLOCK)on TH.RegionId = P.RegionID     
--  where TripRequestKey = @tripRequestKey   AND TripKey = @tripKey   
      
GO
