SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_TripAirResponse_Upd]
(  
	@PolicyReasonCodeID INT, 
	@PolicyKey			INT, 
	@PolicyResaonCode	NVARCHAR(200),
	@airResponseKey		UNIQUEIDENTIFIER
)AS  
  
BEGIN  

	UPDATE  [TripAirResponse] 
	SET PolicyReasonCodeID = @PolicyReasonCodeID, 
		PolicyKey = @PolicyKey, 
		PolicyResaonCode = @PolicyResaonCode
	WHERE airResponseKey = @airResponseKey  
   
END  

GO
