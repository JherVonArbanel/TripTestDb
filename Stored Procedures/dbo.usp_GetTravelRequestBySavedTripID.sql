SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--exec usp_GetTravelRequestBySavedTripID 36261  
  
        
CREATE PROCEDURE [dbo].[usp_GetTravelRequestBySavedTripID]           
(          
@tripID INT          
)          
AS           
BEGIN           
DECLARE @tripSavedKey AS uniqueidentifier = (SELECT TripSavedKey from Trip WITH(NOLOCK) where tripKey = @tripID )          
DECLARE @passengerDetails as TABLE           
(          
tripkey INT ,           
tripsavedKey uniqueidentifier ,          
tripAdultsCount INT,          
tripSeniorsCount INT,          
tripChildCount INT,          
tripInfantCount INT,          
tripYouthCount INT,          
tripInfantWithSeatCount INT,          
noOfTotalTraveler INT,          
noOfRooms INT,          
noOfCars INT          
)          
          
INSERT @passengerDetails ( tripkey,tripSavedKey,tripAdultsCount,tripSeniorsCount,tripChildCount,tripInfantCount,tripYouthCount,tripInfantWithSeatCount,noOfTotalTraveler,noofRooms,noOfCars)          
SELECT tripkey,tripSavedKey,tripAdultsCount,tripSeniorsCount,tripChildCount,tripInfantCount,tripYouthCount,tripInfantWithSeatCount,noOfTotalTraveler,noofRooms,noOfCars from Trip WITH(NOLOCK)  where tripKey = @tripId           
select * FRom @passengerDetails           
          
/*        
DECLARE @tripRequestkey AS INT =         
(        
 SELECT TOP 1 tripRequestKey          
 FROM Trip T WITH(NOLOCK)          
  INNER JOIN TripSaved TS  WITH(NOLOCK)  on t.tripSavedKey = ts.tripSavedKey and t.userKey = TS.userKey         
 where TS.tripSavedKey =@tripSavedKey         
)          
*/         
DECLARE @tripRequestkey AS INT =         
(        
 SELECT TOP 1 tripRequestKey          
 FROM Trip T WITH(NOLOCK)      
 WHERE T.tripKey=@tripID     
--WHERE T.tripSavedKey = @tripSavedKey         
)          
       
EXEC USP_GetTravelInfoAsPerRequestID @tripRequestkey          
           
SELECT PassengerTypeKey, PassengerAge FROM PassengerAge WITH(NOLOCK)  WHERE TripKey = @tripID  AND TripRequestKey= @tripRequestkey      
        
EXEC usp_GetFlexibilityOptionsForSaveTrip @tripRequestkey ,@tripID          
           
END
GO
