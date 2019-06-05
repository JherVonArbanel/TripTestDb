SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetFilteredTripID]
(
	@userkey			INT,
	@tripName			VARCHAR(100) = NULL,
	@AgencyKey			INT = NULL,
	@RecordLocator		VARCHAR(50) = NULL,
	@AirLocator			VARCHAR(50) = NULL
)
AS
BEGIN		
	
	DECLARE @tblUser as table 
	(
	 	UserKey Int
	)	
	INSERT INTO @tblUser
	SELECT DISTINCT userKey from Vault.dbo.GetAllArrangees(@userkey,NULL)
	
	SELECT TOP 1 Trip.* 
	FROM trip 
	INNER JOIN Vault.dbo.[User] U on trip.userKey =  U.UserKey 
	INNER JOIN @tblUser TU ON U.userKey = TU.userKey  
	INNER JOIN TripAirResponse AR on AR.tripKey = trip.tripKey
	INNER JOIN TripAirLegs AL on AL.airResponseKey = AR.airResponseKey
	WHERE trip.tripName = ISNULL(@tripName, trip.tripName) 
	And trip.AgencyKey = ISNULL(@AgencyKey, trip.AgencyKey) 
	And trip.RecordLocator = ISNULL(@RecordLocator, trip.RecordLocator)	
	AND AL.recordLocator = ISNULL(@AirLocator,AL.recordLocator)	
END
GO
