SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[usp_ChangeTripComponent] 
	@xml XML
AS
BEGIN
  
	UPDATE T SET T.IsChangeTripSeg = X.IsChangeTripSeg FROM [dbo].[TripAirSegments] T 
		INNER JOIN (SELECT 	seg.value('(IsChangeTripSeg/text())[1]','bit') AS IsChangeTripSeg,
					        seg.value('(AirSegmentKey/text())[1]','VARCHAR(50)') AS AirSegmentKey							
					FROM @xml.nodes('/Travel/Air/AirLeg/AirSegments')AS TEMPTABLE(seg)) X ON T.airSegmentKey = X.AirSegmentKey 

	UPDATE TH SET TH.IsChangeTripHotel = H.IsChangeTripHotel FROM [dbo].[TripHotelResponse] TH 
		INNER JOIN (SELECT 	hotel.value('(IsChangeTripHotel/text())[1]','bit') AS IsChangeTripHotel,
					        hotel.value('(HotelResponseKey/text())[1]','VARCHAR(50)') AS HotelResponseKey							
					FROM @xml.nodes('/Travel/Hotel')AS TEMPTABLE(hotel)) H ON TH.hotelResponseKey = H.HotelResponseKey 

	UPDATE TC SET TC.IsChangeTripCar = C.IsChangeTripCar FROM [dbo].[TripCarResponse] TC 
		INNER JOIN (SELECT 	car.value('(IsChangeTripCar/text())[1]','bit') AS IsChangeTripCar,
					        car.value('(CarResponseKey/text())[1]','VARCHAR(50)') AS CarResponseKey							
					FROM @xml.nodes('/Travel/Car')AS TEMPTABLE(car)) C ON TC.carResponseKey = C.CarResponseKey 
END
GO
