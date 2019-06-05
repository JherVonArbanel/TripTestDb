SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetTripCurrencyCulture]
(  
	@tripID INT,
	@tripRequestID INT
)AS  
  
BEGIN  

	SELECT PassengerLocale 
	FROM TripPassengerInfo 
	WHERE tripKey = @tripID AND tripRequestKey = @tripRequestID
 
END  

GO
