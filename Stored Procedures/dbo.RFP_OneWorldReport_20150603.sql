SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE procedure [dbo].[RFP_OneWorldReport_20150603]
(    
 @isOrganiser bit,  
 @userKey int,  
 @currency varchar(5),  
 @siteKey int,  
 @filterValue NVARCHAR(50),  
 @filterStartDate NVARCHAR(50),  
 @filterEndDate NVARCHAR(50)  
)    
AS    
BEGIN    
  
  -- Declare new temp table for airlinecode
  DECLARE @tmpAirlineTable AS TABLE (AirlineCode VARCHAR(25))
  
 DECLARE @RollID int, @AirlineCode NVARCHAR(10)  
 SELECT @RollID = userRoles from vault.dbo.userprofile where userKey = @userKey   
  
 IF @RollID = 2048 ---- Airline User  
 BEGIN  
  -- Get user's Airline  
  SELECT Top 1 @AirlineCode = UAir.AirlineCode FROM vault.dbo.[User] U    
  INNER JOIN vault.dbo.RFP_AirlineMapping UAir on UAir.AirlineCompanyKey = U.companyKey  
  WHERE U.userKey = @userKey   
  
  
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
  
   
  -- Get user's Events   
  SELECT distinct M.meetingName as MeetingName, M.meetingCode, M.meetingCodeKey,  
  M.meetingAirportCd, M.meetingFromDate, M.meetingToDate, M.Status, E.EventKey,  
  SUM(case when (T.tripStatusKey in (2,12,3) ) then 1 else 0 end) as TotalBooking,     -- and Tseg.airSegmentMarketingAirlineCode = @AirlineCode --and Tseg.airSegmentMarketingAirlineCode = @AirlineCode
  ISNULL(SUM(case when (T.tripStatusKey in (2,12,3) ) then (case when T.tripstatuskey = 12 then TTI.TotalFare * ExRate.ExchangeRate  else (TAR.actualAirPrice) * ExRate.ExchangeRate end) else 0 end),0) as TotalAmount  
  FROM Vault..Meeting M   
  INNER JOIN Vault.dbo.RFP_Event E on E.MeetingKey = M.meetingCode  
  INNER JOIN Vault.dbo.RFP_EventAirlines RFPAir on RFPAir.EventKey =E.EventKey  
  LEFT OUTER JOIN Trip T on M.meetingCode = T.meetingCodeKey  AND M.siteKey = T.siteKey  
  LEFT OUTER JOIN TripAirResponse TAR on TAR.tripGUIDKey = T.tripPurchasedKey and TAR.isDeleted = 0  
  LEFT OUTER JOIN (Select tripKey, totalFare From TripTicketInfo Where IsExchanged = 1) TTI on T.tripKey = TTI.tripKey 
  LEFT outer JOIN Get_Currency_ExchangeRate(@currency) ExRate on ExRate.FromCurrency = TAR.CurrencyCodeKey    
  LEFT OUTER Join TripAirSegments Tseg on Tseg.tripAirSegmentKey =               
                (select  MAX(tripAirSegmentKey) from TripAirSegments TAS  
                where TAR.airResponseKey = TAS.airResponseKey AND TAS.isDeleted = 0)  
  INNER Join @tmpAirlineTable tmp on tmp.AirlineCode = Tseg.airSegmentMarketingAirlineCode 
  WHERE RFPAir.isParticipating = 1 AND RFPAir.AirlineKey in (select AirlineCode from @tmpAirlineTable)    -- only those events which include user's airline   
  AND (M.meetingName like '%' + @filterValue + '%' OR M.meetingCode LIKE '%' + @filterValue + '%' OR M.meetingCity LIKE '%' + @filterValue + '%' OR M.meetingAirportCd LIKE '%' + @filterValue + '%' )  
  AND M.createdBy = CASE WHEN @isOrganiser = 1 then @userKey else M.createdBy end  
  AND M.siteKey = @siteKey  AND E.SiteKey = @siteKey
  AND M.meetingFromDate BETWEEN @filterStartDate AND @filterEndDate    
  GROUP BY M.meetingName, M.meetingCode, M.meetingCodeKey,    
  M.meetingAirportCd, M.meetingFromDate, M.meetingToDate, M.Status, E.EventKey  
 END  
 ELSE  
 BEGIN  
  SELECT distinct M.meetingName as MeetingName, M.meetingCode, M.meetingCodeKey,  
  M.meetingAirportCd, M.meetingFromDate, M.meetingToDate, M.Status, E.EventKey,  
  SUM(case when T.tripStatusKey in (2,12,3)  then 1 else 0 end) as TotalBooking,    
  ISNULL(SUM(case when T.tripStatusKey in (2,12,3) then (case when T.tripstatuskey = 12 then TTI.TotalFare * ExRate.ExchangeRate  else (TAR.actualAirPrice) * ExRate.ExchangeRate end) else 0 end),0) as TotalAmount  
  FROM Vault..Meeting M   
  INNER JOIN Vault.dbo.RFP_Event E on E.MeetingKey = M.meetingCode  
  LEFT OUTER JOIN Trip T on M.meetingCode = T.meetingCodeKey  AND M.siteKey = T.siteKey  
  LEFT OUTER JOIN TripAirResponse TAR on TAR.tripGUIDKey = T.tripPurchasedKey and TAR.isDeleted = 0  
  LEFT OUTER JOIN (Select tripKey, totalFare From TripTicketInfo Where IsExchanged = 1) TTI on T.tripKey = TTI.tripKey 
  LEFT outer JOIN Get_Currency_ExchangeRate(@currency) ExRate on ExRate.FromCurrency = TAR.CurrencyCodeKey  
     WHERE (M.meetingName like '%' + @filterValue + '%' OR M.meetingCode LIKE '%' + @filterValue + '%' OR M.meetingCity LIKE '%' + @filterValue + '%' OR M.meetingAirportCd LIKE '%' + @filterValue + '%' )  
  AND M.createdBy = CASE WHEN @isOrganiser = 1 then @userKey else M.createdBy end  
  AND M.siteKey = @siteKey  AND E.SiteKey = @siteKey
  AND M.meetingFromDate BETWEEN @filterStartDate AND @filterEndDate    
  GROUP BY M.meetingName, M.meetingCode, M.meetingCodeKey,    
  M.meetingAirportCd, M.meetingFromDate, M.meetingToDate, M.Status, E.EventKey  
 END 
END  
  
GO
