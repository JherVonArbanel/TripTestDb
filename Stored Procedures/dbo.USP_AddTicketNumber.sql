SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddTicketNumber]
(  
	@ticketNumber	VARCHAR(50),
	@airSegmentKey	UNIQUEIDENTIFIER,
	@airLegNumber	INT,
	@tripID			INT
)AS  
  
BEGIN  

	UPDATE TripAirSegments 
	SET ticketNumber = @ticketNumber 
	FROM  TripAirSegments s 
		INNER JOIN tripAirResponse r ON s.airResponseKey = r.airResponseKey   
	WHERE airSegmentKey = @airSegmentKey AND airLegNumber = @airLegNumber AND tripKey= @tripID
 
END  

GO
