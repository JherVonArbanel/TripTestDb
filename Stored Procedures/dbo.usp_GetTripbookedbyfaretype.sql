SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[usp_GetTripbookedbyfaretype]

AS

BEGIN

/****** Booking by fare type******/
SELECT TYPE='Booking by fare type',  airSegmentResBookDesigCode ,
		COUNT(airSegmentResBookDesigCode) 
FROM 
		Trip
		
INNER JOIN 
		TripAirlegs ON Trip.tripKey = TripAirlegs.tripKey		
INNER JOIN 
		TripAirSegments ON TripAirlegs.tripAirLegsKey  = TripAirSegments.tripAirLegsKey 
WHERE 
	        Trip.tripStatusKey = 4	group by  	TripAirSegments.airSegmentResBookDesigCode
	        
 END
 
GO
