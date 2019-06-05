SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_SelectAirSegMiles]
(  
	@airResponseKey UNIQUEIDENTIFIER,
	@airSegmentDepartureAirport VARCHAR(50),
	@airSegmentArrivalAirport VARCHAR(50)
)
AS  
  
BEGIN  

	SELECT airSegmentMiles 
	FROM TripAirSegments 
	WHERE airResponseKey = @airResponseKey 
		AND airSegmentDepartureAirport = @airSegmentDepartureAirport 
		AND airSegmentArrivalAirport = @airSegmentArrivalAirport 
		AND ISNULL(airSegmentMiles,0) > 0 
 
END  

GO
