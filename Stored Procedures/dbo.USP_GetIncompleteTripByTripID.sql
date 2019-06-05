SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--USP_GetIncompleteTripByTripID 10230, 1
CREATE PROCEDURE  [dbo].[USP_GetIncompleteTripByTripID]
	 @TripKey INT,
	 @TotalTravellerCnt INT 
AS
BEGIN
	DECLARE @tripRequestKey INT
    DECLARE @tripTotalTravellerCount INT
    	
	SELECT  @tripRequestKey = tripRequestKey
	FROM Trip WITH(NOLOCK)
	WHERE TripKey = @TripKey
	
	SELECT @tripTotalTravellerCount=tripTotalTravlersCount
	FROM TripRequest WITH(NOLOCK)
	WHERE tripRequestKey = @tripRequestKey

	IF (@tripTotalTravellerCount > @TotalTravellerCnt)
	BEGIN
	    SELECT P.PassengerFirstName, P.PassengerLastName FROM Trip T WITH(NOLOCK)
	    INNER JOIN TripPassengerInfo P WITH(NOLOCK) ON T.tripKey = P.tripKey
	    WHERE tripStatusKey=17 AND T.tripRequestKey = @tripRequestKey
	END
END
GO
