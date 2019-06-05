SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
	EXEC [RFP_OneWorldReport_WithMoreDetail] @isOrganiser=0,@userKey=138,@currency=N'USD',@siteKey=7,@filterValue=N''
		,@filterStartDate=N'3/23/2016 5:05:52 AM',@filterEndDate=N'3/23/2017 5:05:52 AM'  -- OW24E16
*/

CREATE procedure [dbo].[RFP_OneWorldReport_WithMoreDetail]
(    
	--DECLARE	
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

/*
	SELECT @isOrganiser=0,@userKey=138,@currency=N'USD',@siteKey=7,@filterValue=N''
		,@filterStartDate=N'3/23/2016 5:05:52 AM',@filterEndDate=N'3/23/2017 5:05:52 AM'  -- OW24E16
*/

	-- Declare new temp table for airlinecode
	DECLARE @tmpAirlineTable AS TABLE (AirlineCode VARCHAR(25))
	DECLARE @RollID int, @AirlineCode NVARCHAR(10)  

	SELECT @RollID = userRoles from vault.dbo.userprofile where userKey = @userKey 

	IF @RollID = 2048 ---- Airline User  
	BEGIN  

		-- Get user's Airline  
		SELECT Top 1 @AirlineCode = UAir.AirlineCode 
		FROM vault.dbo.[User] U    
			INNER JOIN vault.dbo.RFP_AirlineMapping UAir on UAir.AirlineCompanyKey = U.companyKey  
		WHERE U.userKey = @userKey   

		-- insert into temp table
		IF (@AirlineCode = 'LA') -- if airlinecode is LA
		BEGIN  
			INSERT INTO @tmpAirlineTable values('LA'), ('JJ')
		END
		ELSE -- other then LA airlines
		BEGIN
			INSERT INTO @tmpAirlineTable values(@AirlineCode)
		END
--Print '1'
		-- Get user's Events   
		SELECT distinct M.meetingName as MeetingName, M.meetingCode, M.meetingCodeKey,  
			M.meetingAirportCd, M.meetingFromDate, M.meetingToDate, M.Status, E.EventKey,  
			SUM(case when (T.tripStatusKey in (2,12,3) ) then 1 else 0 end) as TotalBooking,     -- and Tseg.airSegmentMarketingAirlineCode = @AirlineCode --and Tseg.airSegmentMarketingAirlineCode = @AirlineCode
			ISNULL(SUM(CASE WHEN (T.tripStatusKey IN (2,12,3)) THEN (CASE WHEN T.tripstatuskey = 12 THEN TTI.TotalFare * ExRate.ExchangeRate  ELSE (TAR.actualAirPrice) * ExRate.ExchangeRate END) ELSE 0 END),0) AS TotalAmount  

, (SELECT STUFF((SELECT ', ' + REPLACE(RL1.RegionName, '&', 'And') + ' - ' + CONVERT(VARCHAR, ERM1.Attendence_Projection)  
		FROM Vault..RFP_EventRegionMapping ERM1
				INNER JOIN Vault..RFP_RegionLookup RL1 ON ERM1.RegionKey = RL1.RegionKey AND RL1.isActive = 1 AND ERM1.Attendence_Projection > 0
		WHERE ERM1.EventKey = E.EventKey FOR XML PATH ('')),1,1,'')) Regions
, SUM(ERM.Attendence_Projection) ExpectedAttendies 
	  
		FROM Vault..Meeting M   
			INNER JOIN Vault.dbo.RFP_Event E on E.MeetingKey = M.meetingCode  
			INNER JOIN Vault.dbo.RFP_EventAirlines RFPAir on RFPAir.EventKey =E.EventKey  
			INNER JOIN Vault..RFP_EventRegionMapping ERM ON E.EventKey = ERM.EventKey
			LEFT OUTER JOIN Trip T on M.meetingCode = T.meetingCodeKey  AND M.siteKey = T.siteKey  
			LEFT OUTER JOIN TripAirResponse TAR on TAR.tripGUIDKey = T.tripPurchasedKey and TAR.isDeleted = 0  
			LEFT OUTER JOIN (Select tripKey, totalFare From TripTicketInfo Where IsExchanged = 1) TTI on T.tripKey = TTI.tripKey 
			LEFT outer JOIN Get_Currency_ExchangeRate(@currency) ExRate on ExRate.FromCurrency = TAR.CurrencyCodeKey    
			LEFT OUTER JOIN TripAirSegments Tseg 
				ON Tseg.tripAirSegmentKey = (SELECT MAX(tripAirSegmentKey) FROM TripAirSegments TAS  
											WHERE TAR.airResponseKey = TAS.airResponseKey AND TAS.isDeleted = 0) 
		INNER JOIN @tmpAirlineTable tmp ON tmp.AirlineCode = Tseg.airSegmentMarketingAirlineCode 
		WHERE RFPAir.isParticipating = 1 AND RFPAir.AirlineKey in (select AirlineCode from @tmpAirlineTable)    -- only those events which include user's airline   
			AND (M.meetingName like '%' + @filterValue + '%' OR M.meetingCode LIKE '%' + @filterValue + '%' OR M.meetingCity LIKE '%' + @filterValue + '%' OR M.meetingAirportCd LIKE '%' + @filterValue + '%' )  
			AND M.createdBy = CASE WHEN @isOrganiser = 1 then @userKey else M.createdBy end  
			AND M.siteKey = @siteKey  AND E.SiteKey = @siteKey
			AND M.meetingFromDate BETWEEN @filterStartDate AND @filterEndDate AND M.Status='Confirmed'   
		GROUP BY M.meetingName, M.meetingCode, M.meetingCodeKey,    
			M.meetingAirportCd, M.meetingFromDate, M.meetingToDate, M.Status, E.EventKey  
	END  
	ELSE  
	BEGIN  
--PRINT '2'	
		SELECT distinct M.meetingName as MeetingName, M.meetingCode, M.meetingCodeKey,  
			M.meetingAirportCd, M.meetingFromDate, M.meetingToDate, M.Status, E.EventKey,  
			SUM(case when T.tripStatusKey in (2,12,3)  then 1 else 0 end) as TotalBooking,    
			ISNULL(SUM(case when T.tripStatusKey in (2,12,3) then (case when T.tripstatuskey = 12 then TTI.TotalFare * ExRate.ExchangeRate  else (TAR.actualAirPrice) * ExRate.ExchangeRate end) else 0 end),0) as TotalAmount  

, (SELECT STUFF((SELECT ', ' + REPLACE(RL1.RegionName, '&', 'And') + ' - ' + CONVERT(VARCHAR, ERM1.Attendence_Projection)  
		FROM Vault..RFP_EventRegionMapping ERM1
				INNER JOIN Vault..RFP_RegionLookup RL1 ON ERM1.RegionKey = RL1.RegionKey AND RL1.isActive = 1 AND ERM1.Attendence_Projection > 0
		WHERE ERM1.EventKey = E.EventKey FOR XML PATH ('')),1,1,'')) Regions
, SUM(ERM.Attendence_Projection) ExpectedAttendies 
	  
		FROM Vault..Meeting M   
			INNER JOIN Vault.dbo.RFP_Event E on E.MeetingKey = M.meetingCode  
			INNER JOIN Vault..RFP_EventRegionMapping ERM ON E.EventKey = ERM.EventKey 
			LEFT OUTER JOIN Trip T on M.meetingCode = T.meetingCodeKey  AND M.siteKey = T.siteKey  
			LEFT OUTER JOIN TripAirResponse TAR on TAR.tripGUIDKey = T.tripPurchasedKey and TAR.isDeleted = 0  
			LEFT OUTER JOIN (Select tripKey, totalFare From TripTicketInfo Where IsExchanged = 1) TTI on T.tripKey = TTI.tripKey 
			LEFT outer JOIN Get_Currency_ExchangeRate(@currency) ExRate on ExRate.FromCurrency = TAR.CurrencyCodeKey  
		WHERE (M.meetingName like '%' + @filterValue + '%' OR M.meetingCode LIKE '%' + @filterValue + '%' OR M.meetingCity LIKE '%' + @filterValue + '%' OR M.meetingAirportCd LIKE '%' + @filterValue + '%' )  
			AND M.createdBy = CASE WHEN @isOrganiser = 1 then @userKey else M.createdBy end  
			AND M.siteKey = @siteKey  AND E.SiteKey = @siteKey
			AND M.meetingFromDate BETWEEN @filterStartDate AND @filterEndDate AND M.Status='Confirmed'      
		GROUP BY M.meetingName, M.meetingCode, M.meetingCodeKey,    
			M.meetingAirportCd, M.meetingFromDate, M.meetingToDate, M.Status, E.EventKey  
	END 
END
GO
