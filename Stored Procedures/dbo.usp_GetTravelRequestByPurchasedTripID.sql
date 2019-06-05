SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetTravelRequestByPurchasedTripID] 
(    
@tripID INT    
)    
AS     
BEGIN     
DECLARE @trippurchasedKey AS uniqueidentifier = (SELECT tripPurchasedKey from Trip where tripKey = @tripID )    
DECLARE @passengerDetails as TABLE     
(    
tripkey INT ,     
trippurchasedKey uniqueidentifier ,    
tripAdultsCount INT,    
tripSeniorsCount INT,    
tripChildCount INT,    
tripInfantCount INT,    
tripYouthCount INT,    
noOfTotalTraveler INT,    
noOfRooms INT,    
noOfCars INT    
)        
INSERT @passengerDetails ( tripkey,trippurchasedKey,tripAdultsCount,tripSeniorsCount,tripChildCount,tripInfantCount,tripYouthCount,noOfTotalTraveler,noofRooms,noOfCars)    
SELECT tripkey,tripSavedKey,tripAdultsCount,tripSeniorsCount,tripChildCount,tripInfantCount,tripYouthCount,noOfTotalTraveler,noofRooms,noOfCars from Trip where tripKey = @tripId     

select * FRom @passengerDetails       
     
DECLARE @tripRequestkey AS INT = (SELECT TOP 1 tripRequestKey  FROM Trip T INNER JOIN TripPurchased TS on 
t.tripPurchasedKey = ts.tripPurchasedKey  where 
TS.tripPurchasedKey = @trippurchasedKey )    
     
EXEC USP_GetTravelInfoAsPerRequestID @tripRequestkey    
     
END
GO
