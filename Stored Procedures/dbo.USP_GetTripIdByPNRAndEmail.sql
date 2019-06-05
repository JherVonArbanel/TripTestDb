SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetTripIdByPNRAndEmail]  
(    
	@passengerEmail varchar(100),
	@pnr VARCHAR(50),  
	@siteKey int =0,
	@passengerFirstName nvarchar(200),
	@passengerLastName nvarchar(200)
)    
AS      
      
BEGIN   
declare @tripKey int    

SELECT top 1 @tripKey=tpik.TripKey
FROM TripPassengerInfo tpik, trip t 
WHERE tpik.TripKey = t.TripKey AND t.recordLocator = @pnr 
AND t.siteKey = @siteKey 
AND (tpik.PassengerEmailID = @passengerEmail OR tpik.PassengerFirstName = @passengerFirstName 
OR tpik.PassengerLastName = @passengerLastName)

SELECT top 1 @tripKey=tripPsg.TripKey
FROM TripPassengerInfo tripPsg
Inner JOIN trip trip on tripPsg.TripKey = trip.TripKey
INNER JOIN TripAirResponse TAR ON TAR.tripGUIDKey = trip.tripPurchasedKey    
inner join TripAirLegs TA  on TA.airResponseKey=tar.airResponseKey
INNER JOIN TripAirSegments TS on TS.airResponseKey = TAR.airResponseKey
WHERE  (trip.recordLocator = @pnr OR TS.RecordLocator=@pnr )
AND trip.siteKey = @siteKey 
AND (tripPsg.PassengerEmailID = @passengerEmail OR tripPsg.PassengerFirstName = @passengerFirstName OR tripPsg.PassengerLastName = @passengerLastName)

SELECT ISNULL(@tripKey,0) as tripKey
 
END 

GO
