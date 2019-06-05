SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- EXEC usp_GetFriendlyNameAsPerTravelRequestIdForHotel 67361
CREATE PROC [dbo].[usp_GetFriendlyNameAsPerTravelRequestId]
(
	@TravelRequestId INT
)
AS
BEGIN 

DECLARE @HotelRequestId INT,
@FriendlyName VARCHAR(100)


	--DECLARE @HotelRequestId INT,
	--		@FriendlyName VARCHAR(100),
	--		@AptCode VARCHAR(5)
			

	--SELECT @HotelGroupId = ISNULL(tripToHotelGroupId,0),
	--		@AptCode = ISNULL(tripTo1,'')
	--FROM Trip..TripRequest WITH(NOLOCK)
	--WHERE tripRequestKey = @TravelRequestId 


	--SELECT @FriendlyName = ISNULL(FriendlyName,'') FROM CustomHotelGroup WITH(NOLOCK)
	--WHERE HotelGroupId = @HotelGroupId
	
	
	
	--IF @FriendlyName = '' OR @FriendlyName IS NULL
	--BEGIN 
		
	--	SELECT @FriendlyName = CityName FROM Trip..AirportLookup WITH(NOLOCK)
	--	WHERE AirportCode = @AptCode    
	
	--END 
	
	SELECT @FriendlyName
	

END
GO
