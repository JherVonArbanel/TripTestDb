SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetOptionalServicesForTripBySegmentID]
(  
	@airSegmentKey	UNIQUEIDENTIFIER, 
	@tripID			INT
)AS  
  
BEGIN  

	SELECT DISTINCT * 
	FROM AirSegmentOptionalServices seg 
		INNER JOIN Trip_AirSegmentOptionalServices t ON (seg.airSegmentKey = t.airsegmentKey AND seg.serviceKey = t.serviceKey) 
	WHERE tripkey = @tripID AND seg.airSegmentKey = @airSegmentKey 
	
END  

GO
