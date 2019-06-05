SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  <Manoj Naik>  
-- Create date: <20th Dec 17>  
-- Description: <To Insert into TripTicketInfo and EMDTicketInfo>  
-- EXEC [dbo].[SavePurchaseTripTicketInfo] @xmldata, @tripId
-- =============================================  
CREATE PROCEDURE [dbo].[SavePurchaseTripTicketInfo]   
 -- Add the parameters for the stored procedure here  
 @xml XML,
 @tripId int
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
BEGIN TRANSACTION  
BEGIN TRY  

   
 ---------------Trip Ticket Info-----------------  
 /* Condition for same ticket is exist or not */  
 Declare @tripKey int, @isExchanged bit, @isVoided bit, @isRefunded bit, @oldTicketNumber varchar(20)  
 Select @tripKey = TripTicketInfo.value('(tripKey/text())[1]','int'),  
    @isExchanged = TripTicketInfo.value('(isExchanged/text())[1]','bit'),  
    @isVoided = TripTicketInfo.value('(isVoided/text())[1]','bit'),  
    @isRefunded = TripTicketInfo.value('(isRefunded/text())[1]','bit'),  
    @oldTicketNumber = TripTicketInfo.value('(oldTicketNumber/text())[1]','VARCHAR(20)')           
  FROM @xml.nodes('/SavePurchasedTrip/TripTicketInfos/TripTicketInfo')AS TEMPTABLE(TripTicketInfo)  
  
  --Update Trip..Trip set tripStatusKey = @xml.nodes('/SavePurchasedTrip/TripStatusKey') WHERE tripKey=@tripId
  UPDATE T SET T.tripStatusKey = X.tripStatusKey FROM [dbo].[Trip] T 
		INNER JOIN (SELECT UpdateTrip.value('(TripStatusKey/text())[1]','int') AS tripStatusKey
					FROM @xml.nodes('/SavePurchasedTrip')AS TEMPTABLE(UpdateTrip))X ON T.tripKey = @tripId
    
 IF(SELECT COUNT(*) FROM TripTicketInfo WITH(NOLOCK)  
   WHERE tripKey = @tripId AND isExchanged = @isExchanged AND isVoided = @isVoided AND isRefunded = @isRefunded   
     AND oldTicketNumber = @oldTicketNumber) = 0  
 BEGIN   
  INSERT INTO TripTicketInfo (tripKey, recordLocator, isExchanged, isVoided, isRefunded, oldTicketNumber, newTicketNumber, createdDate, issuedDate,  
    currency, oldFare, newFare, addCollectFare, serviceCharge, residualFare, TotalFare, ExchangeFee, BaseFare, TaxFare)  
  SELECT @tripId,      
     TripTicketInfo.value('(recordLocator/text())[1]','VARCHAR(10)') AS recordLocator,  
     @isExchanged, @isVoided, @isRefunded, @oldTicketNumber,  
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
     TripTicketInfo.value('(TaxFare/text())[1]','float') AS TaxFare  
  FROM @xml.nodes('/SavePurchasedTrip/TripTicketInfos/TripTicketInfo')AS TEMPTABLE(TripTicketInfo)  
 END  
   
 ---------------Trip EMD Ticket Info-----------------  
 INSERT INTO TripEMDTicketInfo (tripKey, recordLocator, DocumentNumber, TotalFare, TotalBaseFare, TotalTaxFare, createdDate)  
  SELECT @tripId,      
     TripEMDTicketInfo.value('(recordLocator/text())[1]','VARCHAR(10)') AS recordLocator,  
     TripEMDTicketInfo.value('(DocumentNumber/text())[1]','VARCHAR(20)') AS DocumentNumber,  
     TripEMDTicketInfo.value('(TotalFare/text())[1]','float') AS TotalFare,  
     TripEMDTicketInfo.value('(BaseFare/text())[1]','float') AS BaseFare,  
     TripEMDTicketInfo.value('(TaxFare/text())[1]','float') AS TaxFare,  
     GETDATE()  
  FROM @xml.nodes('/SavePurchasedTrip/TripEMDTicketInfos/EMDTicketInfo')AS TEMPTABLE(TripEMDTicketInfo)  
  
	IF (SELECT 1 FROM @xml.nodes('/SavePurchasedTrip/redeemAuthNumber')AS TEMPTABLE(AuthNo)) > 0
	BEGIN
		  UPDATE T SET T.redeemAuthNumber = X.redeemAuthNumber FROM [dbo].[TripAirResponse] T 
		INNER JOIN (SELECT UpdateAir.value('(redeemAuthNumber/text())[1]','VARCHAR(20)') AS redeemAuthNumber,
						UpdateAir.value('(airResponseKey/text())[1]','VARCHAR(50)') AS airResponseKey
					FROM @xml.nodes('/SavePurchasedTrip')AS TEMPTABLE(UpdateAir))X ON T.airResponseKey = X.airResponseKey		
	END
	
 select @tripId  
 COMMIT TRANSACTION;  
 --print 'Commit'  
END TRY  
BEGIN CATCH  
 --SELECT     
 --       ERROR_NUMBER() AS ErrorNumber    
 --       ,ERROR_SEVERITY() AS ErrorSeverity    
 --       ,ERROR_STATE() AS ErrorState    
 --       ,ERROR_PROCEDURE() AS ErrorProcedure    
 --       ,ERROR_LINE() AS ErrorLine    
 --       ,ERROR_MESSAGE() AS ErrorMessage;  
 ROLLBACK TRANSACTION;  
 --print 'Rollback'  
   
END CATCH  
   
END
GO
