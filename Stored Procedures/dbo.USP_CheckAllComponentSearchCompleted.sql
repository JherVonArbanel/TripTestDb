SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--USP_CheckAllComponentSearchCompleted 139614
CREATE PROCEDURE [dbo].[USP_CheckAllComponentSearchCompleted]
( 
 @tripRequestKey  INT 
)
AS
BEGIN
DECLARE @airRequestKey		INT,
        @hotelRequestKey	INT,
        @carRequestKey		INT
        
DECLARE @isAirCompleted BIT = 1, @isHotelCompleted BIT = 1, @isCarCompleted BIT = 1

SELECT @airRequestKey = airRequestKey	FROM TripRequest_air	WHERE tripRequestKey = @tripRequestKey
SELECT @hotelRequestKey = hotelRequestKey FROM TripRequest_hotel	WHERE tripRequestKey = @tripRequestKey
SELECT @carRequestKey = carRequestKey	FROM TripRequest_car	WHERE tripRequestKey = @tripRequestKey
DECLARE @componentType AS INT = 0 
IF (@airRequestKey IS NOT NULL AND @airRequestKey > 0) 
BEGIN
	SET @componentType = 1 
	--EXEC [dbo].USP_CheckAirSearchCompleted @airRequestKey, @isAirCompleted
	IF ( SELECT COUNT(*) FROM BFMRequestCompletion WHERE AirRequestId = @airRequestKey ) =(SELECt NoOFRequestSentToGDS  FROM TripRequest_air WHERE airRequestKey = @airRequestKey )
	BEGIN 
	SET @isAirCompleted = 1 
	END
	ELSE 
	BEGIN 
	SET @isAirCompleted = 0 
	END
END
IF (@hotelRequestKey IS NOT NULL AND @hotelRequestKey > 0 ) 
BEGIN
	SET @componentType = @componentType + 4  
	IF EXISTS(SELECT 1 FROM HotelResponse WHERE hotelRequestKey = @hotelRequestKey)
	BEGIN
		SET @isHotelCompleted = 1
	END
	ELSE
	BEGIN
		SET @isHotelCompleted = 0
	END
END
IF (@carRequestKey IS NOT NULL AND @carRequestKey > 0 ) 
BEGIN
	SET @componentType = @componentType + 2
	IF EXISTS(SELECT 1 FROM CarResponse CR INNER JOIN CarResponseDetail CRD ON CR.carResponseKey = CRD.carResponseKey WHERE carRequestKey = @carRequestKey)
	BEGIN
		SET @isCarCompleted = 1
	END
	ELSE
	BEGIN
		SET @isCarCompleted = 0
	END
END

IF ((@isAirCompleted=1) AND (@isHotelCompleted=1) AND (@isCarCompleted=1))
	SELECT 1
ELSE
	SELECT 0
END


SELECT @isAirCompleted AS isAirSuccess ,@isHotelCompleted AS isHotelSuccess ,@isCarCompleted AS isCarSuccess , @componentType AS tripComponentType
GO
