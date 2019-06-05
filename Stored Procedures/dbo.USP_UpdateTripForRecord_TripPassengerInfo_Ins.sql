SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_TripPassengerInfo_Ins]
(  
	@TripKey INT,
	@PassengerKey INT,
	@PassengerTypeKey INT,
	@IsPrimaryPassenger BIT,
	@TripRequestKey INT,
	@AdditionalRequest NVARCHAR(4000)
)AS  
  
BEGIN  

	INSERT INTO TripPassengerInfo (TripKey,PassengerKey,PassengerTypeKey,IsPrimaryPassenger,TripRequestKey,AdditionalRequest) 
	VALUES (@TripKey,@PassengerKey,@PassengerTypeKey,@IsPrimaryPassenger,@TripRequestKey,@AdditionalRequest) 
   
END  

GO
