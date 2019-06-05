SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoSabre_TripPassengerInfo_Ins]  
(    
	@TripKey INT,  
	@PassengerKey INT,  
	@PassengerTypeKey INT,  
	@IsPrimaryPassenger BIT,  
	@TripRequestKey INT,  
	@AdditionalRequest NVARCHAR(3000), 
	@PassengerEmailID VARCHAR(100), 
	@PassengerFirstName NVARCHAR(200), 
	@PassengerLastName NVARCHAR(200), 
	@PassengerLocale NVARCHAR(10)
)
AS 
    
BEGIN    
  
	INSERT INTO TripPassengerInfo(TripKey, PassengerKey, PassengerTypeKey, IsPrimaryPassenger, TripRequestKey, AdditionalRequest,
		PassengerEmailID, PassengerFirstName, PassengerLastName, PassengerLocale)
	VALUES(@TripKey, @PassengerKey, @PassengerTypeKey, @IsPrimaryPassenger, @TripRequestKey, @AdditionalRequest, 
		@PassengerEmailID, @PassengerFirstName, @PassengerLastName, @PassengerLocale)
	
	SELECT Scope_Identity()  
   
END    
  
GO
