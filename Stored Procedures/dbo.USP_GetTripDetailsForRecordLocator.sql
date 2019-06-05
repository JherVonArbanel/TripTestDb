SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec USP_GetTripDetailsForRecordLocator 'UEVKST','Desai',64
CREATE PROCEDURE [dbo].[USP_GetTripDetailsForRecordLocator]      
(      
@RecordLocator VARCHAR(6),
@LastName VARCHAR(400),
@siteKey INT
)      
AS       
BEGIN 

SELECT TOP 1 T.tripKey FROM Trip..Trip T
INNER JOIN TripPassengerInfo P ON T.tripKey = P.TripKey
WHERE T.recordLocator = @RecordLocator AND LTRIM(RTRIM(P.PassengerLastName)) = LTRIM(RTRIM(@LastName)) and siteKey = @siteKey
ORDER BY TripKey desc
END
GO
