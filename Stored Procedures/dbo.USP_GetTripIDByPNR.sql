SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetTripIDByPNR]  
(    
 @recordLocator VARCHAR(50),  
 @gdsSourceKey int =0
)    
AS      
      
BEGIN      
declare @tripKey int        

	if(@gdsSourceKey=0)
		begin

		SELECT @tripKey=tripKey FROM Trip WHERE recordLocator = @recordLocator and endDate > GETDATE()
		SELECT @tripKey = TP.tripKey FROM Trip..TripAirLegs TA    
		INNER JOIN Trip..TripAirResponse TAR ON TAR.airResponseKey = TA.airResponseKey    
		INNER JOIN Trip..Trip TP ON TP.tripPurchasedKey = TAR.tripGUIDKey    
		WHERE TA.recordLocator = @recordLocator  and tp.endDate > GETDATE()
		SELECT top 1 @tripKey = TP.tripKey FROM Trip..TripAirLegs TA    
		INNER JOIN Trip..TripAirResponse TAR ON TAR.airResponseKey = TA.airResponseKey    
		INNER JOIN trip..TripAirSegments TS on TS.airResponseKey = TAR.airResponseKey
		INNER JOIN Trip..Trip TP ON TP.tripPurchasedKey = TAR.tripGUIDKey    
		WHERE TS.RecordLocator = @recordLocator  and tp.endDate > GETDATE()
		end
		else
		begin
		SELECT @tripKey=tripKey FROM Trip WHERE recordLocator = @recordLocator and endDate > GETDATE()
		SELECT @tripKey = TP.tripKey FROM Trip..TripAirLegs TA    
		INNER JOIN Trip..TripAirResponse TAR ON TAR.airResponseKey = TA.airResponseKey    
		INNER JOIN Trip..Trip TP ON TP.tripPurchasedKey = TAR.tripGUIDKey    
		WHERE TA.recordLocator = @recordLocator  and ta.gdsSourceKey=@gdsSourceKey and tp.endDate > GETDATE()
		end  
    
    SELECT ISNULL(@tripKey,0) as tripKey    
END 
GO
