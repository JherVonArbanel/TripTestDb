SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[usp_AddTripTicketInfoForHistory]
@Pnr varchar(50),
@TripHistoryKey uniqueidentifier
AS


Insert into TripTicketInfo(

tripKey,
recordLocator,
isExchanged,
isVoided,
isRefunded,
oldTicketNumber,
newTicketNumber,
createdDate,
issuedDate,
currency,
oldFare,
newFare,
addCollectFare,
serviceCharge,
residualFare,
TotalFare,
ExchangeFee,
TripHistoryKey,
Basefare,
TaxFare) 


Select
0 as tripKey,
recordLocator,
isExchanged,
isVoided,
isRefunded,
oldTicketNumber,
newTicketNumber,
createdDate,
issuedDate,
currency,
oldFare,
newFare,
addCollectFare,
serviceCharge,
residualFare,
TotalFare,
ExchangeFee,
@TripHistoryKey,
BaseFare,
TaxFare
From TripTicketInfo 
Where recordLocator = @pnr and TripHistoryKey is null
GO
