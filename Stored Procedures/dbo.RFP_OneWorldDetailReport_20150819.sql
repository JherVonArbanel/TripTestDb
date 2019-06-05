SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
  
CREATE procedure [dbo].[RFP_OneWorldDetailReport_20150819]    
(    
 @userKey int,    
 @currency varchar(5),    
 @meetingCode int,    
 @airlineCode NVARCHAR(10),    
 @FOP NVARCHAR(50),    
 @countryCode NVARCHAR(10),    
 @fareType NVARCHAR(50),  
 @SiteKey int   
)    
AS        
Begin      

/* 
exec RFP_OneWorldDetailReport @userKey=701,@currency=N'USD',@meetingCode=592,@airlineCode=N'',@FOP=N'',@countryCode=N'',@faretype=N'',@siteKey=10
exec RFP_OneWorldDetailReport @userKey=701,@currency=N'EUR',@meetingCode=592,@airlineCode=N'',@FOP=N'',@countryCode=N'',@faretype=N'',@siteKey=10
exec RFP_OneWorldDetailReport @userKey=701,@currency=N'GBP',@meetingCode=592,@airlineCode=N'',@FOP=N'',@countryCode=N'',@faretype=N'',@siteKey=10
*/
 -- Declare new temp table for airlinecode
 DECLARE @tmpAirlineTable AS TABLE (AirlineCode VARCHAR(25))
        
 DECLARE @RollID int      
 SELECT @RollID = userRoles from vault.dbo.userprofile where userKey = @userKey       
      
 IF @RollID = 2048      
 BEGIN      
  -- Get user's Airline      
  SELECT Top 1 @airlineCode = UAir.AirlineCode FROM vault.dbo.[User] U        
  INNER JOIN vault.dbo.RFP_AirlineMapping UAir on UAir.AirlineCompanyKey = U.companyKey      
  WHERE U.userKey = @userKey      
 END      

  -- insert into temp table
  if (@AirlineCode = 'LA') -- if airlinecode is LA
  BEGIN  
	 insert into @tmpAirlineTable values('LA')
	 insert into @tmpAirlineTable values('JJ')
  end
  else -- other then LA airlines
  BEGIN
  insert into @tmpAirlineTable values(@AirlineCode)
  END
        
 Select trip.tripKey,CONVERT(DATE, trip.CreatedDate, 103) as bookedDate, CONVERT(DATE, trip.startDate, 103) as TravelDate,       
 DATEDIFF(DAY, Trip.CreatedDate, trip.startDate) as AdvBooked,      
 Tseg.airSegmentMarketingAirlineCode as Airline,       
 Case when Trip.isOnlineBooking = 1 then 'Online' else 'Offline' END as Source, 
 --(
	--Case when trip.tripStatusKey = 12 then  isnull(TTI.TotalFare,0) * (ExRate.ExchangeRate)
	--else isnull(TAR.actualAirPrice,0) * (ExRate.ExchangeRate) end 
 --) as tripTotalBaseCost      
 (
	Case when trip.tripStatusKey = 12 then  isnull(TTI.TotalFare,0) * (CASE WHEN TAR.CurrencyCodeKey = 'USD' THEN ExRate.ExchangeRate ELSE CASE WHEN (t.currencyCode = ExRate.currencyCode) THEN 1 ELSE ExRate.ExchangeRate / t.exchangeRateAmount END END)
	else isnull(TAR.actualAirPrice,0) * (CASE WHEN TAR.CurrencyCodeKey = 'USD' THEN ExRate.ExchangeRate ELSE CASE WHEN (t.currencyCode = ExRate.currencyCode) THEN 1 ELSE ExRate.ExchangeRate / t.exchangeRateAmount END END) end 
 ) as tripTotalBaseCost 
 from trip       
 --Inner Join TripRequest on TripRequest.tripRequestKey = Trip.tripRequestKey      
 Inner join Vault.dbo.Meeting M on Trip.meetingCodeKey = M.meetingCode and M.meetingCodeKey = @meetingCode      
 
 left join TripPassengerCreditCardInfo TripCard on Trip.tripKey = isnull(TripCard.TripKey,0) and TripCard.creditCardVendorCode is not null      
	AND TripCard.Active = 1 -- Added by Gopal to fetch trip created by using active credit card
 LEFT OUTER JOIN TripAirResponse TAR on TAR.tripGUIDKey = Trip.tripPurchasedKey and TAR.isDeleted = 0      
 LEFT OUTER JOIN (Select tripKey, totalFare From TripTicketInfo Where IsExchanged = 1) TTI on trip.tripKey = TTI.tripKey   
 --LEFT outer JOIN Get_Currency_ExchangeRate(@currency) ExRate on ExRate.FromCurrency = TAR.CurrencyCodeKey      
 LEFT OUTER JOIN 
 (
	SELECT C.currencyCode, E.exchangeRateAmount As ExchangeRate -- CAST(ROUND( E.exchangeRateAmount, 2) AS Decimal(18,2)) ExchangeRate
	FROM vault.dbo.ExchangeRate E 
		LEFT OUTER JOIN vault.dbo.Currency C ON e.currencyKey = c.currencyKey 
	WHERE exchangeRateDate = (SELECT  MAX(exchangeRateDate ) FROM vault.dbo.ExchangeRate)
 ) ExRate ON ExRate.currencyCode = @currency  
 LEFT OUTER JOIN 
 (
	SELECT C.currencyCode, E.exchangeRateAmount -- CAST(ROUND( E.exchangeRateAmount, 2) AS Decimal(18,2)) exchangeRateAmount 
	FROM vault.dbo.ExchangeRate E 
		LEFT OUTER JOIN vault.dbo.Currency C ON e.currencyKey = c.currencyKey 
	WHERE exchangeRateDate = (SELECT  MAX(exchangeRateDate ) FROM vault.dbo.ExchangeRate)
 ) t ON t.currencyCode = TAR.CurrencyCodeKey 
 --LEFT outer JOIN Get_Currency_ExchangeRate(TAR.CurrencyCodeKey) ExRateBooked on ExRateBooked.FromCurrency = TAR.CurrencyCodeKey 
 LEFT OUTER Join TripAirSegments Tseg on Tseg.tripAirSegmentKey =                   
               (select  MAX(tripAirSegmentKey) from TripAirSegments TAS      
               where TAR.airResponseKey = TAS.airResponseKey AND TAS.isDeleted =0 AND TAS.airLegNumber = 1)       

left join AirportLookup  airport on airport.AirportCode = Tseg.airSegmentArrivalAirport
 WHERE tripStatusKey in (2,12,3)     
 AND M.siteKey = @SiteKey and Trip.siteKey = @SiteKey    
 --AND ISNULL(Tseg.airSegmentMarketingAirlineCode,'') = case when (@airlineCode = '' OR @airlineCode = null) then ISNULL(Tseg.airSegmentMarketingAirlineCode,'') else @airlineCode end     
 
AND ISNULL(Tseg.airSegmentMarketingAirlineCode,'') IN (select (case when (AirlineCode = '' OR AirlineCode = null) then ISNULL(Tseg.airSegmentMarketingAirlineCode,'') else AirlineCode end) from @tmpAirlineTable)
  
 AND ISNULL(TripCard.creditCardVendorCode,'') = case when (@FOP = '' OR @FOP = null) then ISNULL(TripCard.creditCardVendorCode,'') else @FOP end    
   
 AND ISNULL(airport.CountryCode,'') = case when (@countryCode = '' OR @countryCode = null) then ISNULL(airport.CountryCode,'') else @countryCode end      
 AND ISNULL(Tseg.airsegmentcabin,'') = case when (@fareType = '' OR @fareType = null) then ISNULL(Tseg.airsegmentcabin,'') else @fareType end            
 ORDER BY CONVERT(DATE, trip.CreatedDate, 103) DESC      
End     
    
GO
