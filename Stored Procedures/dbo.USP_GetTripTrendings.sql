SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Rohita Patel>
-- Create date: <17-Feb-2016>
-- Description:	<Get city wise trip trending list>
-- Exec USP_GetTripTrendings
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripTrendings] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from	
	SET NOCOUNT ON;
	
	DECLARE @tbl TABLE (ImageURL VARCHAR(5000), TripTo VARCHAR(50), CrowdCount INT,CityName VARCHAR(150))

	INSERT INTO @tbl(ImageURL,TripTo, CrowdCount)
		SELECT TRIP.dbo.getImageURLFromCityCode(TD.tripTo), TD.tripTo,COUNT(TD.tripTo) 
		FROM TRIP..TripDetails TD	
		GROUP BY TD.tripTo ORDER BY COUNT(TD.tripTo) DESC

	UPDATE t SET CityName = AL.CityName 
	FROM @tbl t 
		INNER JOIN trip..AirportLookup AL ON t.TripTo = AL.AirportCode 
		
	UPDATE t SET CityName = AL.FriendlyName 
	FROM @tbl t 
		INNER JOIN CMS..CustomHotelGroup AL ON t.TripTo = AL.AirportCode 

	SELECT * FROM @tbl

END
GO
