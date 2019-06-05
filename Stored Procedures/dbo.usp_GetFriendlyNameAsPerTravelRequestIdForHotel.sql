SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- EXEC usp_GetFriendlyNameAsPerTravelRequestIdForHotel 474526 474526 
CREATE PROC [dbo].[usp_GetFriendlyNameAsPerTravelRequestIdForHotel]
(
	@TravelRequestId INT
)
AS
BEGIN 

	DECLARE @hotelRequestKey INT,
	@FriendlyName VARCHAR(100),
	@CityId INT,
	@ZipCodeId INT

	SELECT @hotelRequestKey = hotelRequestKey 
	FROM TripRequest_hotel 
	WHERE tripRequestKey = @TravelRequestId

	SELECT @CityId = ISNULL(CityId,0),@ZipCodeId = ISNULL(ZipCodeID,0)
	FROM HotelRequest 
	WHERE hotelrequestkey = @hotelRequestKey
	
	IF( @CityId > 0)
	BEGIN
		SELECT @FriendlyName = DisplayText FROM CMS..CityLookup2Fast2 
		WHERE CityKey = @CityId
	END
	ELSE IF (@ZipCodeId > 0)
	BEGIN
		SELECT @FriendlyName = DisplayText FROM HotelAutoCompleteForZipCodeSearch 
		WHERE Id = @ZipCodeId
	END
	
	SELECT @FriendlyName
	

END
GO
