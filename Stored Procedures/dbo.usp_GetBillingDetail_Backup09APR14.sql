SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Steve Edgerton
-- Create date: 9/1/2011
-- Description:	Get detail transaction data for billing
-- Modified:	7/9/2013 - SLE
--				Added logic for Star Alliance billing report 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBillingDetail_Backup09APR14] 
( 
@fromDate nvarchar(20), 
@toDate nvarchar(20),
@siteKey int
)
AS
BEGIN
	
	DECLARE @debug int
	SET @debug = 0

	DECLARE @tripKey int
	DECLARE @airLegNumber int
	DECLARE @airSegmentDepartureAirport varchar(50)
	DECLARE @airSegmentArrivalAirport varchar(50)
	DECLARE @ticketNumber varchar(50)
	DECLARE @tickets varchar(100)
	DECLARE @miniItin varchar(100)


	-- siteKey = 1 = Star Alliance
	-- siteKey = 7 = oneworld
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- AJA 11/26/2012 - added logic to handle conversion of unexpected date formats
	--                 can not trust that dates will come in as properly formated string
	SET @fromDate = convert(varchar, convert(datetime, @fromDate), 111) + ' 00:00:00'
	SET @toDate = convert(varchar, convert(datetime, @toDate), 111) + ' 23:59:59' 
	
	-- SET @fromDate = @fromDate + ' 00:00:01'
	-- SET @toDate = @toDate + ' 23:59:59' 
	
	---------------------------------
	/* CREATE AND LOAD TRIP TABLES */
	---------------------------------
	-- Temp table to hold AIR transaction information
	CREATE TABLE #TripAir         
		(        
		tripKey int,
		recordLocator varchar(50), 
		startDate datetime, 
		endDate datetime, 
		CreatedDate datetime, 
		miniItin varchar(100),
		tickets varchar(100),
		tripStatusKey int, 
		actualAirPrice float,
		actualAirTax float, 
		CurrencyCodeKey nvarchar(10), 
		tripStatusName varchar(50), 
		meetingCodeKey nvarchar(30), 
        emailAddress nvarchar(100), 
        IsCheck nvarchar(10)
		)

	
	INSERT #TripAir 
		( tripKey, recordLocator, startDate, endDate, CreatedDate, miniItin, tickets,  tripStatusKey, actualAirPrice, actualAirTax, CurrencyCodeKey, tripStatusName, meetingCodeKey, emailAddress, IsCheck)
	
	SELECT	   DISTINCT dbo.Trip.tripKey, dbo.Trip.recordLocator, dbo.Trip.startDate, dbo.Trip.endDate, dbo.Trip.CreatedDate,'','', dbo.Trip.tripStatusKey, dbo.TripAirResponse.actualAirPrice,
			   dbo.TripAirResponse.actualAirTax, dbo.TripAirResponse.CurrencyCodeKey, dbo.TripStatusLookup.tripStatusName, trip.meetingCodeKey, dbo.TripPassengerInfo.PassengerEmailID, dbo.TripPassengerUDIDInfo.PassengerUDIDValue
	FROM       dbo.Trip  INNER JOIN
                      dbo.TripAirResponse ON dbo.Trip.tripKey = dbo.TripAirResponse.tripKey INNER JOIN
                      dbo.TripStatusLookup ON dbo.Trip.tripStatusKey = dbo.TripStatusLookup.tripStatusKey INNER JOIN
                      dbo.TripPassengerInfo ON dbo.Trip.tripKey = dbo.TripPassengerInfo.tripKey  left outer JOIN
                      dbo.TripPassengerUDIDInfo ON ((dbo.Trip.tripKey = dbo.TripPassengerUDIDInfo.tripKey) AND CompanyUDIDNumber = 20) 
    WHERE (dbo.Trip.CreatedDate BETWEEN @fromDate AND @toDate) AND siteKey = @siteKey


	-- SELECT * From #TripAir
	-- Temp table to hold AIR segment information
	CREATE TABLE #TripSegments         
		(        
		tripKey int,
		airLegNumber int, 
		airSegmentDepartureAirport varchar(50), 
		airSegmentArrivalAirport varchar(50), 
		ticketNumber varchar(50)
		)

	
	INSERT #TripSegments 
		( tripKey, airLegNumber, airSegmentDepartureAirport, airSegmentArrivalAirport, ticketNumber)
	
	SELECT     dbo.TripAirLegs.tripKey, dbo.TripAirSegments.airLegNumber, dbo.TripAirSegments.airSegmentDepartureAirport, 
                      dbo.TripAirSegments.airSegmentArrivalAirport, dbo.TripAirSegments.ticketNumber
	FROM         dbo.TripAirLegs INNER JOIN
                      dbo.TripAirSegments ON dbo.TripAirLegs.tripAirLegsKey = dbo.TripAirSegments.tripAirLegsKey AND 
                      dbo.TripAirLegs.tripAirLegsKey = dbo.TripAirSegments.tripAirLegsKey AND dbo.TripAirLegs.tripAirLegsKey = dbo.TripAirSegments.tripAirLegsKey
	WHERE (dbo.TripAirLegs.tripKey IN ( SELECT tripKey FROM #TripAir ))
	ORDER BY dbo.TripAirLegs.tripKey, dbo.TripAirLegs.airLegNumber, dbo.TripAirSegments.airSegmentDepartureDate
	
	-- SELECT * from #TripSegments
	
	
	DECLARE @saveTicket varchar(20) = ''
	DECLARE @ticketStr varchar(100) = '' 
	DECLARE @firstLeg tinyint
	DECLARE @firstSegment tinyint
	DECLARE @curTripKey int
	DECLARE @curAirLegNumber int
	DECLARE @saveArrivalAirport varchar(50)
	
	DECLARE @MyCursor CURSOR 

	SET @MyCursor = CURSOR FAST_FORWARD 
	FOR 
		SELECT tripKey, airLegNumber, airSegmentDepartureAirport, airSegmentArrivalAirport, ticketNumber
		FROM #TripSegments
		
	OPEN @MyCursor 
	FETCH NEXT FROM @MyCursor 
	INTO @tripKey, @airLegNumber, @airSegmentDepartureAirport, @airSegmentArrivalAirport, @ticketNumber
		 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		SET @firstLeg = 1
		SET @curTripKey = @tripKey
	
		WHILE ((@tripKey = @curTripKey) AND (@@FETCH_STATUS = 0))
		BEGIN
			
			SET @firstSegment = 1
			SET @curAirLegNumber = @airLegNumber
			
			WHILE ((@airLegNumber = @curAirLegNumber) AND (@tripKey = @curTripKey) AND (@@FETCH_STATUS = 0))
			BEGIN
			
				IF (@firstLeg = 1) SET @miniItin = @airSegmentDepartureAirport + '-'
				ELSE IF (@firstSegment = 1) SET @miniItin = @miniItin + @airSegmentDepartureAirport + '-'
								
				-- hold arrival airport to close leg
				SET @saveArrivalAirport = @airSegmentArrivalAirport
				
				-- build ticket string
				IF (SUBSTRING(LTRIM(@ticketNumber),1,13) <> @saveTicket)
				BEGIN
					SET @saveTicket = SUBSTRING(LTRIM(@ticketNumber),1,13)
					SET @ticketStr = @ticketStr + @saveTicket + '  '
				END
				
				SET @firstLeg = 0
				SET @firstSegment = 0
				
				FETCH NEXT FROM @MyCursor 
				INTO @tripKey, @airLegNumber, @airSegmentDepartureAirport, @airSegmentArrivalAirport, @ticketNumber
				
			END	
				
			SET @miniItin = @miniItin + @saveArrivalAirport + '-'
		
		END
	
		-- UPDATE TRIP RECORD
		UPDATE #TripAir
		SET miniItin = @miniItin, tickets = @ticketStr
		WHERE tripKey = @curTripKey
		
		SET @miniItin = ''
		SET @ticketStr = ''
		
	END 

	CLOSE @MyCursor 
	DEALLOCATE @MyCursor 
	
	select * from #TripAir
	ORDER by meetingCodeKey, emailAddress
	
	CLEANUP:	
	-------------------------------	
	-- Clean up temp tables
	-------------------------------	
	drop table #TripAir
	drop table #TripSegments
	
END




GO
