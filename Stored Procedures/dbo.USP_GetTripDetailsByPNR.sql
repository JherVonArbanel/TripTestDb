SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- EXEC [USP_GetTripDetailsByPNR] 'mlad@rinira.com','CNUBCV'
CREATE PROCEDURE [dbo].[USP_GetTripDetailsByPNR]  
(  
 @passengerEmail varchar(100),
 @pnr varchar(50)
)  
AS  
BEGIN  
 select tpik.TripKey, tpik.TripRequestKey from TripPassengerInfo tpik, trip t 
 where tpik.TripKey = t.TripKey  and t.recordLocator = @pnr and 
 tpik.PassengerEmailID = @passengerEmail
END  
GO
