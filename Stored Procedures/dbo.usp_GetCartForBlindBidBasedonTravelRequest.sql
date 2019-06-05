SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================  
-- Author:  Asha Bhosale	
-- Create date: 4th June 2013  
-- Description: To create blind bid based on data selected 
-- =============================================  
CREATE Procedure [dbo].[usp_GetCartForBlindBidBasedonTravelRequest] 
(
@travelRequestID as INT ,
@excludedAirlines AS VARCHAR( 200) =''
)
AS 
BEGIN 
	DECLARE @airRequestID AS INT 
	DECLARE @hotelRequestID AS INT 
	DECLARE @carRequestID AS INT 

	SET @airRequestID = (SELECT airRequestKey FROM TripRequest_air WITH (NOLOCK)WHERE tripRequestKey = @travelRequestID)
	SET @hotelRequestID = (SELECT hotelRequestkey FROM TripRequest_hotel WITH (NOLOCK) WHERE tripRequestKey = @travelRequestID)
	SET @carRequestID = (SELECT carRequestKey  FROM TripRequest_car WITH (NOLOCK) WHERE tripRequestKey = @travelRequestID)

	DECLARE @noOfStops AS INT =  1 
	SET @noOfStops = (SELECT noofStops  FROM TripAirFlexibilities WITH (NOLOCK) where TripRequestKey = @travelRequestID )
	IF ( @noOfStops is null ) 
	BEGIN
		SET @noOfStops = 1 
	END 
	DECLARE @starRating AS FLOAT = 0 
	DECLARE @regionID AS INT  
	SELECT @starRating =  altHotelRating ,@regionID =RegionId  FROM TripHotelFlexibilities WITH (NOLOCK) where TripRequestKey = @travelRequestID  
	IF ( @starRating IS Null ) 
	BEGIN
		SET @starRating = 0 
	END
	IF ( @regionID IS NULL )
	BEGIN 
		SET @regionID = 0 
	END
	DECLARE @carType AS VARCHAR(20)
	SET @carType = (SELECT flexibleCarType  FROM TripCarFlexibilities WITH (NOLOCK) where TripRequestKey = @travelRequestID )

	EXEC usp_GetLowestAirResponseForAirRequest  @airRequestID ,@noOfStops , @excludedAirlines

	EXEC usp_GetLowestHotelResponseForRequest @hotelRequestID,@starRating,@regionID 
	
	EXEC usp_GetLowestCarResponseForRequest @carRequestID ,@carType

END
GO
