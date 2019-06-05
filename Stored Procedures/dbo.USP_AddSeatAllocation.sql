SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddSeatAllocation]
(  
	@seatNumber		VARCHAR(10),
	@airSegmentKey	UNIQUEIDENTIFIER,
	@airLegNumber	INT,
	@tripID			INT
)AS  
  
BEGIN  

	UPDATE TripAirSegments 
	SET airSelectedSeatNumber = @seatNumber 
	FROM  TripAirSegments s 
		INNER JOIN tripAirResponse r ON s.airResponseKey = r.airResponseKey 
	WHERE airSegmentKey = @airSegmentKey AND airLegNumber = @airLegNumber AND tripKey = @tripID
 
END  

GO
