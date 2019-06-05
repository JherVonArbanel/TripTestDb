SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetRecordLocator]                    
(                
 @tripID   INT,                  
 @tripRequestID INT = 0                  
)                
AS                    
BEGIN                  
IF @tripID IS NOT NULL
BEGIN
		 SELECT T.recordLocator, P.PassengerFirstName, P.PassengerLastName
		 FROM Trip..Trip T
		 INNER JOIN TripPassengerInfo P ON T.tripKey = P.TripKey
		 WHERE T.tripKey = @tripID
END  
ELSE
BEGIN
		 SELECT TOP 1 T.recordLocator, P.PassengerFirstName, P.PassengerLastName
		 FROM Trip..Trip  T
		 INNER JOIN TripPassengerInfo P ON T.tripKey = P.TripKey
		 WHERE T.tripRequestKey = @tripRequestID
END
END
GO
