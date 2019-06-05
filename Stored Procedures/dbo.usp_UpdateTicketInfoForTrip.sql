SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
CREATE PROCEDURE [dbo].[usp_UpdateTicketInfoForTrip]       
 -- Add the parameters for the stored procedure here      
 @xml XML,@tripId int      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
  
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
    
print '1'

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
     TripTicketInfo.value('(TaxFare/text())[1]','float') AS TaxFare  
  FROM @xml.nodes('/SavePurchasedTrip/TripTicketInfos/TripTicketInfo')AS TEMPTABLE(TripTicketInfo) 

 BEGIN   
  INSERT INTO TripTicketInfo (tripKey, recordLocator, isExchanged, isVoided, isRefunded, oldTicketNumber, newTicketNumber, createdDate, issuedDate,  
    currency, oldFare, newFare, addCollectFare, serviceCharge, residualFare, TotalFare, ExchangeFee, BaseFare, TaxFare)  
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
     TripTicketInfo.value('(TaxFare/text())[1]','float') AS TaxFare  
  FROM @xml.nodes('/SavePurchasedTrip/TripTicketInfos/TripTicketInfo')AS TEMPTABLE(TripTicketInfo)  
 END  
   
   print '2'
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

     print '3'
   
       
     
END TRY      
BEGIN CATCH      
   
END CATCH      
       
END 
GO
