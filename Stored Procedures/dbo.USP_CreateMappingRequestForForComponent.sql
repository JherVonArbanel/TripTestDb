SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_CreateMappingRequestForForComponent] 
(
@tripRequestKeyOld int , 
@tripRequestKeyNew int 
) 
AS 
BEGIN 
IF EXISTS(SELECT 1 FROM TripRequest_hotel C WHERE tripRequestKey = @tripRequestKeyOld)
BEGIN
INSERT INTO TripRequest_hotel(tripRequestKey,hotelRequestKey,noOfGuests,NoOFRequestSentToGDS) SELECT @tripRequestKeyNew,H.hotelRequestKey,H.noOfGuests,H.NoOFRequestSentToGDS FROM TripRequest_hotel H WHERE tripRequestKey = @tripRequestKeyOld
END
IF EXISTS(SELECT 1 FROM TripRequest_car C WHERE tripRequestKey = @tripRequestKeyOld)
BEGIN
INSERT INTO TripRequest_car(tripRequestKey,carRequestKey,carClass,NoOFRequestSentToGDS) SELECT @tripRequestKeyNew,C.carRequestKey,C.carClass,C.NoOFRequestSentToGDS FROM TripRequest_car C WHERE tripRequestKey = @tripRequestKeyOld
END
END
GO
