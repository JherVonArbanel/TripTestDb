SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 CREATE PROCEDURE [dbo].[usp_GetLowestSaveTripCart]
 ( 
 @tripKey int,
 @tripDate date,
 @userId int = 0 
 ) 
 AS
 BEGIN
 ---SELECT * FROM Trip where tripKey  = @tripKey  
 declare @hotelDealKey as bigint = (select max(TripSavedLowestDealKey) from [dbo].[TripSavedLowestDeal] WITH(NOLOCK) where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate and [componentType]= 4)
select DISTINCT top 1 TND.tripKey, vw.*, TND.creationDate as dealDate 
 from TripsavedLowestDeal   TND   WITH(NOLOCK) 
INNER JOIN  vw_tripHotelResponseDetails vw on TND.ResponseKey = vw.hotelResponseKey 
Where TND.TripSavedLowestDealKey  =@hotelDealKey

 declare @carDealKey as bigint = (select max(TripSavedLowestDealKey) from [dbo].[TripSavedLowestDeal] WITH(NOLOCK) where [tripKey]= @tripKey and Convert(Date,[creationDate])= @tripDate and [componentType]= 2)
select distinct top 1 TND.tripKey, vw.*,TND.creationDate as dealDate  
from TripsavedLowestDeal TND  WITH(NOLOCK) 
INNER JOIN  vw_tripCarResponseDetails vw on TND.responseKey  = vw.carResponseKey 
Where TND.TripSavedLowestDealKey  =@carDealKey

  END
 
GO
