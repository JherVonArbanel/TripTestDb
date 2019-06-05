SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_Trip_Upd]
(  
	@TripStatusKey	INT, 
	@TripKey		INT, 
	@TripRequestKey	INT
)AS  
  
BEGIN  

	UPDATE Trip 
	SET tripStatusKey = @TripStatusKey 
	WHERE tripKey = @TripKey AND tripRequestKey = @TripRequestKey 
   
END  

GO
