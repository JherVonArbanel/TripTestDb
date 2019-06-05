SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


  
CREATE PROCEDURE [dbo].[usp_UpdateSavedTripToPurchase]     
 -- Add the parameters for the stored procedure here    
 @xml XML    
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    

BEGIN TRY    

Declare @Userkey    [INT] = 0,    
			@TripRequestkey   [INT] = 0,    
			@Type     [VARCHAR](100)= '',    
			@WSName     [VARCHAR](50) = '',    
			@XmlData    [XML] = '',    
			@Event     [VARCHAR](500) = '',    
			@Details    [VARCHAR](1000) = '' ,    
			@ExceptionMessage  [VARCHAR](max)  = '',    
			@StackTrace    [VARCHAR](max)  = '',    
			@SessionId    [VARCHAR](200)  = '',    
			@LogLevelKey   [INT]  = 0,    
			@Comment    [VARCHAR](500)  = '',    
			@URL     [VARCHAR](1000)  = '',
			@SingleBookThreadId [nvarchar](50) ='',
			@GroupBookThreadId [nvarchar](50)='' 

SELECT @Userkey = Trip.value('(userKey/text())[1]','int'),
	  @TripRequestkey = Trip.value('(tripRequestKey/text())[1]','int'),
	  @Type = 'StoredProcedure', @WSName = 'SavePurchaseTrip_UpdateSavedTripToPurchase',
	  @XmlData = @xml, @Event = '', @Details = '',
	  @ExceptionMessage = ERROR_MESSAGE(),
	  @StackTrace = ERROR_STATE(),
	  @SessionId = ERROR_NUMBER(),
	  @LogLevelKey = ERROR_LINE(),
	  @Comment = ERROR_SEVERITY(),
	  @URL = '',
	  @SingleBookThreadId = '',
	  @GroupBookThreadId =''
	FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/Trip')AS TEMPTABLE(Trip)

	--SELECT   
 --       ERROR_NUMBER() AS ErrorNumber  
 --       ,ERROR_SEVERITY() AS ErrorSeverity  
 --       ,ERROR_STATE() AS ErrorState  
 --       ,ERROR_PROCEDURE() AS ErrorProcedure  
 --       ,ERROR_LINE() AS ErrorLine  
 --       ,ERROR_MESSAGE() AS ErrorMessage;
	--ROLLBACK TRANSACTION;
	--print 'Rollback'
	Exec [Log].[dbo].[USP_InsertLogs] @Userkey, @TripRequestkey, @Type, @WSName, @XmlData, @Event, @Details, @ExceptionMessage, @StackTrace, @SessionId, @LogLevelKey, @Comment, @URL, @SingleBookThreadId, @GroupBookThreadId
	     
 Declare @TripPurchaseKey uniqueidentifier --= NEWID()    
 Declare @tripId int    
 SELECT @tripId = T.value('(tripKey/text())[1]','int')    
 FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/Trip')AS TEMPTABLE(T)    
     
   --print @tripId  
  -- print @TripPurchaseKey  
-- Insert into [dbo].[TripPurchased] (tripPurchasedKey) values (@TripPurchaseKey)     
      
		 INSERT INTO [TripStatusHistory] ([tripKey],[tripStatusKey],[createdDateTime])    
		 SELECT @tripId,TripStatusHistory.value('(tripStatusKey/text())[1]','int') AS tripStatusKey,getdate()      
		 FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/Trip')AS TEMPTABLE(TripStatusHistory)    
     	
		SELECT @TripPurchaseKey=tripPurchasedKey
		FROM Trip..trip 
		WHERE tripKey=@tripId
		
		if isnull(@TripPurchaseKey,null) IS NULL
		begin
			set @TripPurchaseKey = NEWID() 
			Insert into [dbo].[TripPurchased] (tripPurchasedKey) values (@TripPurchaseKey)
		End
		ELSE
		BEGIN
			UPDATE TripAirResponse     
			SET  isDeleted = 1    
			WHERE tripGUIDKey = @TripPurchaseKey    
			UPDATE TripCarResponse     
			SET  isDeleted = 1 
			WHERE tripGUIDKey = @TripPurchaseKey
			UPDATE TripAirSegments WITH(ROWLOCK) SET ISDELETED = 1    
			fROM TripAirSegments SEG   
			INNER JOIN TripAirResponse TR ON Seg.airResponseKey = TR.airResponseKey  
			INNER JOIN  TripAirLegs LEG  ON LEG.tripAirLegsKey = SEG.tripAirLegsKey --and LEG.gdsSourceKey = @gdsSourceKey     
			WHERE TR.tripGUIDKey = @TripPurchaseKey     
			UPDATE TripAirLegs WITH(ROWLOCK)    
			SET ISDELETED = 1   
			fROM TripAirLegs Leg   
			INNER JOIN TripAirResponse TR ON Leg.airResponseKey = TR.airResponseKey  --and LEG.gdsSourceKey = @gdsSourceKey   
			WHERE TR.tripGUIDKey = @TripPurchaseKey 
		End

  --  print '[TripStatusHistory] info'  
  
 ---------------Passenger Info-----------------    


 declare @xmlTripPassenger xml, @TripPassenger SavePurchaseTrip_TripPassenger    
 --select @xmlTripPassenger = @xml.query('/SavePurchasedTrip/TripPassenger')    
 --INSERT INTO @TripPassenger EXEC [dbo].[SavePurchaseTrip_TripPassenger_Insert] @xmlTripPassenger, @TripPurchaseKey, @tripId      
  INSERT INTO @TripPassenger
 select TripHistoryKey as TripHistoryKey,PassengerKey as PassengerKey,TripPassengerInfoKey as tripPassengerInfoKey  from TripPassengerInfo where TripKey=@tripId
 
   
 --print 'passenger info'  
        
 ---------------Travel Component-----------------          
 declare @xmlTripAir xml    
 select @xmlTripAir = @xml.query('/SavePurchasedTrip/TripComponents/Air')  
  if(@xmlTripAir is not null and Cast(@xmlTripAir as nvarchar(max))<>'')    
 EXEC [dbo].[SavePurchaseTrip_TravelComponent_Air_Insert] @xmlTripAir, @TripPurchaseKey, @tripId, @TripPassenger    
     
    --print 'air comp'  
  
 declare @xmlTripHotel xml    
 select @xmlTripHotel = @xml.query('/SavePurchasedTrip/TripComponents/Hotel')  
  
  --print 'air comp 1'   
 if(@xmlTripHotel is not null and Cast(@xmlTripHotel as nvarchar(max))<>'')  
 --EXEC [dbo].[SavePurchaseTrip_TravelComponent_Hotel_Insert] @xmlTripHotel, @TripPurchaseKey,@tripId, @TripPassenger    
                 begin
					declare @hotelResponseKey VARCHAR(50)=''
					declare @recordLocator VARCHAR(50)=''
					declare @rateKey VARCHAR(max)=''

		 			SELECT @hotelResponseKey =TripHotelResponse.value('(HotelResponseKey/text())[1]','VARCHAR(50)')
					FROM @xmlTripHotel.nodes('/Hotel/TripHotelResponse')AS TEMPTABLE(TripHotelResponse)	

					SELECT @recordLocator =TripHotelResponse.value('(recordLocator/text())[1]','VARCHAR(50)')
					FROM @xmlTripHotel.nodes('/Hotel/TripHotelResponse')AS TEMPTABLE(TripHotelResponse)

					SELECT @rateKey =TripHotelResponse.value('(rateKey/text())[1]','VARCHAR(max)')
					FROM @xmlTripHotel.nodes('/Hotel/TripHotelResponse')AS TEMPTABLE(TripHotelResponse)

					IF @recordLocator = ''					
					BEGIN
						SELECT @recordLocator =TripHotelResponse.value('(recordLocator/text())[1]','VARCHAR(50)')  
						FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/Trip')AS TEMPTABLE(TripHotelResponse) 
					END
		 --Update TripHotelResponse set tripGUIDKey = @TripPurchaseKey, recordLocator=@recordLocator where hotelResponseKey = @hotelResponseKey
		 IF @xml.exist('(SavePurchasedTrip/TripComponents/Hotel/TripHotelResponsePassengerInfos/TripHotelResponsePassengerInfo)')=1
		 BEGIN	
				UPDATE A
				SET  A.tripGUIDKey = @TripPurchaseKey, 
				A.recordLocator=@recordLocator,
				A.rateKey = @rateKey
				FROM TripHotelResponse A
				WHERE A.tripGUIDKey in(SELECT tripSavedKey from trip..Trip where tripKey=@tripId)
   
				INSERT INTO [TripHotelResponsePassengerInfo] ([hotelResponseKey],[TripPassengerInfoKey],[confirmationNumber],[ItineraryNumber])
				SELECT TripHotelResponsePassengerInfo.value('(HotelResponseKey/text())[1]','VARCHAR(50)') AS hotelResponseKey, 
						P.TripPassengerInfoKey,		
						TripHotelResponsePassengerInfo.value('(confirmationNumber/text())[1]','VARCHAR(50)') AS confirmationNumber,
						TripHotelResponsePassengerInfo.value('(ItineraryNumber/text())[1]','VARCHAR(50)') AS ItineraryNumber
				FROM @xmlTripHotel.nodes('/Hotel/TripHotelResponsePassengerInfos/TripHotelResponsePassengerInfo')AS TEMPTABLE(TripHotelResponsePassengerInfo)
				left outer join @TripPassenger P on TripHotelResponsePassengerInfo.value('(TripPassengerInfoKey/text())[1]','int') = P.PassengerKey

		END
end
         
   -- print 'hotel comp'  
  
 declare @xmlTripCar xml    
 select @xmlTripCar = @xml.query('/SavePurchasedTrip/TripComponents/Car')  

  if(@xmlTripCar is not null and Cast(@xmlTripCar as nvarchar(max))<>'')    
 EXEC [dbo].[SavePurchaseTrip_TravelComponent_Car_Insert] @xmlTripCar, @TripPurchaseKey,@tripId, @TripPassenger    
     
    -- print 'car comp'  

 ---------------Travel Component-----------------       
  -- print 'update travel component'  
  
     
 UPDATE T SET T.tripPurchasedKey = @TripPurchaseKey, T.recordLocator = X.recordLocator, T.PurchaseComponentType  = X.PurchaseComponentType,     
    T.tripStatusKey = X.tripStatusKey, T.tripTotalBaseCost = X.tripTotalBaseCost, T.tripTotalTaxCost = X.tripTotalTaxCost, T.FailureReason = X.FailureReason,
	T.AncillaryServices=X.AncillaryServices, T.AncillaryFees=X.AncillaryFees,T.SabreCreationDate = X.SabreCreationDate ,T.isUpgradeBooking = X.isUpgradeBooking,
	T.cross_reference_trip_id = X.cross_reference_trip_id, T.[type] = X.[type]
	 FROM [dbo].[Trip] T     
  INNER JOIN (SELECT @TripPurchaseKey as tripPurchasedKey, @tripId as tripId,     
       UpdateTrip.value('(recordLocator/text())[1]','VARCHAR(50)') AS recordLocator,    
       UpdateTrip.value('(PurchaseComponentType/text())[1]','int') AS PurchaseComponentType,    
       UpdateTrip.value('(tripStatusKey/text())[1]','int') AS tripStatusKey,    
       UpdateTrip.value('(tripTotalBaseCost/text())[1]','float') AS tripTotalBaseCost,    
       UpdateTrip.value('(tripTotalTaxCost/text())[1]','float') AS tripTotalTaxCost,
	   UpdateTrip.value('(FailureReason/text())[1]','VARCHAR(4000)') AS FailureReason, 
		CONVERT(Datetime, UpdateTrip.value('(SabreCreationDate/text())[1]','varchar(30)'), 101) AS SabreCreationDate,
	   UpdateTrip.value('(AncillaryServices/text())[1]','VARCHAR(50)') AS AncillaryServices, 
	   --UpdateTrip.value('(AncillaryFees/text())[1]','float') AS AncillaryFees 
	   CASE WHEN TRY_CONVERT(float, UpdateTrip.value('(AncillaryFees/text())[1]','varchar(10)')) IS NULL THEN 0 ELSE UpdateTrip.value('(AncillaryFees/text())[1]','float') END AS AncillaryFees,
	   UpdateTrip.value('(isUpgradeBooking/text())[1]','tinyint') AS isUpgradeBooking,
	   UpdateTrip.value('(CrossReferenceTripId/text())[1]','int') AS cross_reference_trip_id,
	   UpdateTrip.value('(type/text())[1]','NVARCHAR(20)') AS [type]
     FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/Trip')AS TEMPTABLE(UpdateTrip))X ON T.tripKey = X.tripId     
     
          
 INSERT INTO [TripConfirmationFriendEmail] ([tripKey],[friendEmailAddress])     
 SELECT @tripId,      
   TripConfirmationFriendEmail.value('(FriendEmailAddress/text())[1]','VARCHAR(100)') AS FriendEmailAddress    
 FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/TripConfirmationFriendEmails/TripConfirmationFriendEmail')AS TEMPTABLE(TripConfirmationFriendEmail)    

  ---------------Trip Ticket Info-----------------  
 /* Condition for same ticket is exist or not */  
 Declare @tripKey int, @isExchanged bit, @isVoided bit, @isRefunded bit, @oldTicketNumber varchar(20)  
 Select @tripKey = TripTicketInfo.value('(tripKey/text())[1]','int'),  
    @isExchanged = TripTicketInfo.value('(isExchanged/text())[1]','bit'),  
    @isVoided = TripTicketInfo.value('(isVoided/text())[1]','bit'),  
    @isRefunded = TripTicketInfo.value('(isRefunded/text())[1]','bit'),  
    @oldTicketNumber = TripTicketInfo.value('(oldTicketNumber/text())[1]','VARCHAR(20)')           
  FROM @xml.nodes('/SavePurchasedTrip/TripTicketInfos/TripTicketInfo')AS TEMPTABLE(TripTicketInfo)  
    
--print '1'

 BEGIN   
  INSERT INTO TripTicketInfo (tripKey, recordLocator, isExchanged, isVoided, isRefunded, oldTicketNumber, newTicketNumber, createdDate, issuedDate,  
    currency, oldFare, newFare, addCollectFare, serviceCharge, residualFare, TotalFare, ExchangeFee, BaseFare, TaxFare, IsHostStatusTicketed )  
  SELECT @tripId,      
     TripTicketInfo.value('(recordLocator/text())[1]','VARCHAR(10)') AS recordLocator,  
     @isExchanged, @isVoided, @isRefunded,   
     TripTicketInfo.value('(oldTicketNumber/text())[1]','VARCHAR(20)') AS oldTicketNumber,  
     TripTicketInfo.value('(newTicketNumber/text())[1]','VARCHAR(20)') AS newTicketNumber,  
     GETDATE(),  
     (case when (charindex('-', TripTicketInfo.value('(issuedDate/text())[1]','VARCHAR(30)')) > 0)   
     then CONVERT(datetime, TripTicketInfo.value('(issuedDate/text())[1]','VARCHAR(30)'), 103)   
     else TripTicketInfo.value('(issuedDate/text())[1]','datetime') end) AS issuedDate,  
     TripTicketInfo.value('(currency/text())[1]','VARCHAR(10)') AS currency,  
     TripTicketInfo.value('(oldFare/text())[1]','float') AS oldFare,  
     TripTicketInfo.value('(newFare/text())[1]','float') AS newFare,  
     TripTicketInfo.value('(addCollectFare/text())[1]','float') AS addCollectFare,  
     TripTicketInfo.value('(serviceCharge/text())[1]','float') AS serviceCharge,  
     TripTicketInfo.value('(residualFare/text())[1]','float') AS residualFare,  
     TripTicketInfo.value('(TotalFare/text())[1]','float') AS TotalFare,  
     TripTicketInfo.value('(ExchangeFee/text())[1]','float') AS ExchangeFee,  
     TripTicketInfo.value('(BaseFare/text())[1]','float') AS BaseFare,  
     TripTicketInfo.value('(TaxFare/text())[1]','float') AS TaxFare,
	 TripTicketInfo.value('(isHostStatusTicketed/text())[1]','bit') as IsHostStatusTicketed    
  FROM @xml.nodes('/SavePurchasedTrip/TripTicketInfos/TripTicketInfo')AS TEMPTABLE(TripTicketInfo)  
 END  
   
 --  print '2'
 ---------------Trip EMD Ticket Info-----------------  
 INSERT INTO TripEMDTicketInfo (tripKey, recordLocator, DocumentNumber, TotalFare, TotalBaseFare, TotalTaxFare,FlightNumber, createdDate, AirlineCode, SeatNumber, IssuedDate)  
  SELECT @tripId,      
     TripEMDTicketInfo.value('(recordLocator/text())[1]','VARCHAR(10)') AS recordLocator,  
     TripEMDTicketInfo.value('(DocumentNumber/text())[1]','VARCHAR(20)') AS DocumentNumber,  
     TripEMDTicketInfo.value('(TotalFare/text())[1]','float') AS TotalFare,  
     TripEMDTicketInfo.value('(BaseFare/text())[1]','float') AS BaseFare,  
     TripEMDTicketInfo.value('(TaxFare/text())[1]','float') AS TaxFare,  
     TripEMDTicketInfo.value('(FlightNumber/text())[1]','VARCHAR(20)') AS FlightNumber,      
     GETDATE(),  
     TripEMDTicketInfo.value('(AirlineCode/text())[1]','VARCHAR(2)') AS AirlineCode,   
     TripEMDTicketInfo.value('(SeatNumber/text())[1]','VARCHAR(10)') AS SeatNumber,  
     TripEMDTicketInfo.value('(IssuedDate/text())[1]','datetime') AS IssuedDate   
  FROM @xml.nodes('/SavePurchasedTrip/TripEMDTicketInfos/EMDTicketInfo')AS TEMPTABLE(TripEMDTicketInfo)  

    -- print '3'
   
END TRY    
BEGIN CATCH    
 
 SELECT @Userkey = Trip.value('(userKey/text())[1]','int'),
	  @TripRequestkey = Trip.value('(tripRequestKey/text())[1]','int'),
	  @Type = 'StoredProcedure', @WSName = 'SavePurchaseTrip_UpdateSavedTripToPurchase_Error',
	  @XmlData = @xml, @Event = '', @Details = '',
	  @ExceptionMessage = ERROR_MESSAGE(),
	  @StackTrace = ERROR_STATE(),
	  @SessionId = ERROR_NUMBER(),
	  @LogLevelKey = ERROR_LINE(),
	  @Comment = ERROR_SEVERITY(),
	  @URL = '',
	  @SingleBookThreadId = '',
	  @GroupBookThreadId =''
	FROM @xml.nodes('/SavePurchasedTrip/SaveTrip/Trip')AS TEMPTABLE(Trip)

	--SELECT   
 --       ERROR_NUMBER() AS ErrorNumber  
 --       ,ERROR_SEVERITY() AS ErrorSeverity  
 --       ,ERROR_STATE() AS ErrorState  
 --       ,ERROR_PROCEDURE() AS ErrorProcedure  
 --       ,ERROR_LINE() AS ErrorLine  
 --       ,ERROR_MESSAGE() AS ErrorMessage;
	--ROLLBACK TRANSACTION;
	--print 'Rollback'
	Exec [Log].[dbo].[USP_InsertLogs] @Userkey, @TripRequestkey, @Type, @WSName, @XmlData, @Event, @Details, @ExceptionMessage, @StackTrace, @SessionId, @LogLevelKey, @Comment, @URL, @SingleBookThreadId, @GroupBookThreadId
END CATCH    
     
END 
GO
