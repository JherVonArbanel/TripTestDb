SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
  
  
  
  
/* Created By Anupam */    
/* Exec [USP_DeleteTripDetailsForMultiPax] 'OLIBZY' ,5*/  
CREATE PROCEDURE  [dbo].[USP_DeleteTripDetailsForMultiPax]    
@recordLocator varchar(20),    
@status int    
  
AS    
   
BEGIN    
  -- SET NOCOUNT ON added to prevent extra result sets from    
  -- interfering with SELECT statements.    
  SET NOCOUNT ON;    
     
  DECLARE @tripKey  AS INT     
  DECLare @tripPurchasedKey AS uniqueidentifier  
  DECLare @gdsSourceKey AS INT
    
 SELECT @tripKey = tripKey , @tripPurchasedKey = tripPurchasedKey  
 FROM Trip WITH(NOLOCK) WHERE recordLocator = @recordLocator   
 
-- IF(@tripKey IS NULL)
-- BEGIN
    SELECT  @tripKey = TP.tripKey, @tripPurchasedKey = tripPurchasedKey,@gdsSourceKey= TA.gdsSourceKey  FROM Trip..TripAirLegs TA
		INNER JOIN Trip..TripAirResponse TAR ON TAR.airResponseKey = TA.airResponseKey
		INNER JOIN Trip..Trip TP ON TP.tripPurchasedKey = TAR.tripGUIDKey
	WHERE TA.recordLocator = @recordLocator
-- END
  
 SELECT @tripKey     
      
  IF @status = 5 /* For Cancelled */    
  BEGIN    
      
   UPDATE Trip WITH(ROWLOCK) SET tripStatusKey = 5 WHERE recordLocator =@recordLocator   
   /* UserHistory # 1024 */    
   IF @@ROWCOUNT <> 0    
    BEGIN    
    /* Set Value Zero if status is cancelled */  
    /* AIR */  
  UPDATE TripAirResponse     
  SET  actualAirPrice = 0.0, actualAirTax = 0.0    
  WHERE tripGUIDKey IN    
   (SELECT tripPurchasedKey FROM Trip Where recordLocator =@recordLocator)    
    /* Car */  
  UPDATE TripCarResponse     
  SET  actualCarPrice = 0.0, actualCarTax = 0.0,minRate = 0.0  
  WHERE tripGUIDKey IN    
   (SELECT tripPurchasedKey FROM Trip Where recordLocator =@recordLocator)      
  /* Hotel */  
  UPDATE TripHotelResponse     
  SET  actualHotelPrice = 0.0, actualHotelTax = 0.0    
  WHERE tripGUIDKey IN    
   (SELECT tripPurchasedKey FROM Trip Where recordLocator =@recordLocator)     
     
   /* Insurance */  
  UPDATE TripPurchasedInsurance     
  SET  Amount = 0.0  
  WHERE tripKey IN    
   (SELECT tripKey FROM Trip Where recordLocator =@recordLocator)     
     
    /* Activity */  
  UPDATE TripActivityResponse     
  SET  TotalPrice = 0.0  
  WHERE tripGUIDKey IN    
   (SELECT tripPurchasedKey FROM Trip Where recordLocator =@recordLocator)     
   
  UPDATE TripTicketInfo       
  SET  TotalFare = 0.0  
  WHERE tripKey IN      
   (SELECT tripKey FROM Trip Where recordLocator =@recordLocator)  
     
    END    
        
  END     
  ELSE IF @status = 13 /* For Banked */    
  BEGIN    
   UPDATE Trip WITH(ROWLOCK) SET tripStatusKey = 13 WHERE recordLocator =@recordLocator AND tripStatusKey <> 1    
  END     
  ELSE    
  BEGIN    
    
   Update  [Trip] WITH(ROWLOCK) set tripStatusKey = @status Where tripKey = @tripKey    
        
   UPDATE TripAirSegmentOptionalServices WITH(ROWLOCK) SET ISDELETED = 1   WHERE  tripKey = @tripKey       
     
   UPDATE TripAirSegments WITH(ROWLOCK) SET ISDELETED = 1    
   fROM TripAirSegments SEG   
   INNER JOIN TripAirResponse TR ON Seg.airResponseKey = TR.airResponseKey  
   INNER JOIN  TripAirLegs LEG  ON LEG.tripAirLegsKey = SEG.tripAirLegsKey --and LEG.gdsSourceKey = @gdsSourceKey     
   WHERE TR.tripGUIDKey = @tripPurchasedKey     
     
   UPDATE TripAirLegs WITH(ROWLOCK)    
   SET ISDELETED = 1   
   fROM TripAirLegs Leg   
   INNER JOIN TripAirResponse TR ON Leg.airResponseKey = TR.airResponseKey  --and LEG.gdsSourceKey = @gdsSourceKey   
   WHERE TR.tripGUIDKey = @tripPurchasedKey     
     
     
          
   IF(@status <> 12) /* Exchanged Status is added.*/    
   BEGIN    
   Update TripAirResponseTax     
   Set TripAirResponseTax.Active  = 0     
   FROM TripAirResponseTax TT INNER JOIN TripAirResponse   TA on TT.airResponseKey = Ta.airResponseKey     
   Where TA.tripGUIDKey = @tripPurchasedKey    
   END    
       
   /*Update TripPassengerAirPreference set Active= 0 where TripKey = @tripKey*/    
       
   /* Anupam has changed - Task # 1031*/    
   /*Update TripPassengerUDIDInfo WITH(ROWLOCK) set Active = 0 where TripKey = @tripKey   */  
     
   Update TripPNRRemarks WITH(ROWLOCK) set Active = 0 where TripKey = @tripKey AND GeneratedType in (4,103)    
     
  END   
    
  IF Not Exists(Select *  From TripStatusHistory Where tripStatusHistoryKey =  
  ( Select top 1 tripStatusHistoryKey From TripStatusHistory  Where TripKey = @tripKey   
     Order By 1 Desc  
  )  
 And tripStatusKey = @status  
 )  
 BEGIN  
 INSERT INTO [TripStatusHistory](tripKey,tripStatusKey,createdDateTime) Values (@tripKey,@status,GetDate())  
 END  
END   
  
GO
