SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetPassengerInfo]
 @tripKey  INT    
AS  
BEGIN
	SELECT TripPassengerInfoKey,TravelReferenceNo 
	  FROM TripPassengerInfo 
	 WHERE TripKey = @tripKey
END
GO
