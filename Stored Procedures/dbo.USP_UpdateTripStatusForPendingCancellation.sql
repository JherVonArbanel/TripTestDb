SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Exec [USP_UpdateTripStatusForPendingCancellation] 'LHIGYV' ,18*/
CREATE PROCEDURE [dbo].[USP_UpdateTripStatusForPendingCancellation]  
@recordLocator VARCHAR(20),  
@status INT
AS  
 BEGIN  
	 -- SET NOCOUNT ON added to prevent extra result sets from  
	 SET NOCOUNT ON;  
	 --DECLARE @tripKey  AS INT   
	 --DECLare @tripPurchasedKey AS uniqueidentifier
	 
	 --SELECT @tripKey = tripKey , @tripPurchasedKey = tripPurchasedKey
	 --FROM Trip WITH(NOLOCK) WHERE recordLocator = @recordLocator 
    
 	 UPDATE Trip WITH(ROWLOCK) SET tripStatusKey = @status WHERE recordLocator =@recordLocator 
	 --IF @@ROWCOUNT <> 0  
	 --BEGIN  
	 --/* AIR */
	 --UPDATE TripAirResponse   
	 --SET  actualAirPrice = 0.0, actualAirTax = 0.0  
	 --WHERE tripGUIDKey IN  
	 --(SELECT tripPurchasedKey FROM Trip Where recordLocator =@recordLocator)  
	 --/* Car */
	 --UPDATE TripCarResponse   
	 --SET  actualCarPrice = 0.0, actualCarTax = 0.0,minRate = 0.0
	 --WHERE tripGUIDKey IN  
	 --(SELECT tripPurchasedKey FROM Trip Where recordLocator =@recordLocator)  		
	 --/* Hotel */
	 --UPDATE TripHotelResponse   
	 --SET  actualHotelPrice = 0.0, actualHotelTax = 0.0  
	 --WHERE tripGUIDKey IN  
	 --(SELECT tripPurchasedKey FROM Trip Where recordLocator =@recordLocator)  	
	 --END		 
	 --IF NOT EXISTS(Select *  From TripStatusHistory Where tripStatusHistoryKey =
		--( Select top 1 tripStatusHistoryKey From TripStatusHistory  Where TripKey = @tripKey 
		--   Order By 1 Desc
		--)
	 --AND tripStatusKey = @status)
	 --BEGIN
		--INSERT INTO [TripStatusHistory](tripKey,tripStatusKey,createdDateTime) Values (@tripKey,@status,GetDate())
	 --END
END 
GO
