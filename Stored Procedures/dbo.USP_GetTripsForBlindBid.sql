SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 6th Jun 2013
-- Description:	Get all the blind bid's for current date and current date - 1 and store temporarily in db
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripsForBlindBid]
	@SiteKey INT
AS
BEGIN
	
	SET NOCOUNT ON;
	
	TRUNCATE TABLE TripRequestBlindBid
	
	INSERT INTO TripRequestBlindBid (TripRequestKey, TripKey, TripComponentType, AirRequestTypeKey, DepartureAirport, ArrivalAirport
	,TripFromDate, TripToDate, AdultCount, SeniorCount, ChildCount, InfantCount, YouthCount, TotalTraveler
	, TripSavedKey, NoOfDays, NoOfRooms, NoOfCars)
	SELECT T.tripRequestKey, T.tripKey, t.tripComponentType, AR.airRequestTypeKey, TA.tripFrom1, TA.tripTo1
	,T.startDate, T.endDate, T.tripAdultsCount, T.tripSeniorsCount, T.tripChildCount, T.tripInfantCount, T.tripYouthCount, T.noOfTotalTraveler
	,T.tripSavedKey, DATEDIFF(day, CONVERT(VARCHAR(10), T.startDate, 120), CONVERT(VARCHAR(10), T.endDate, 120)), T.noOfRooms, T.noOfCars
	FROM Trip T INNER JOIN TripRequest TA 
	ON T.tripRequestKey = TA.tripRequestKey INNER JOIN TripRequest_air TRA
	ON T.tripRequestKey = TRA.tripRequestKey INNER JOIN AirRequest AR
	ON TRA.airRequestKey = AR.airRequestKey 
	WHERE (CONVERT(VARCHAR, T.CreatedDate, 103) = CONVERT(VARCHAR, GETDATE(), 103) 
	OR CONVERT(VARCHAR, T.CreatedDate, 103) = CONVERT(VARCHAR, GETDATE()-1, 103))
	AND T.tripStatusKey = 16
	AND T.siteKey = @SiteKey
	
	SELECT TripRequestKey, TripKey, TripSavedKey, ArrivalAirport FROM TripRequestBlindBid where TripComponentType = 7
    
END
GO
