SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 7th Jan 2014
-- Description:	Compare AirRequestTripSavedDeal/HotelRequestTripSavedDeal/CarRequestTripSavedDeal 
-- with TripDetails table and find the tripKey's which are not present in TripDetails table
-- and insert those trips with original price
-- =============================================
--EXEC USP_UpdateTripDetailsWithMissingTripKeys 1
CREATE PROCEDURE [dbo].[USP_UpdateTripDetailsWithMissingTripKeys] 
	
	@componentType INT
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	Declare @MissingTripCount INT = 0
	--AIR
	IF (@componentType = 1) --FOR AIR
	BEGIN --BEGIN 3
		
		DECLARE @MissingAirTrips AS TABLE 
		(
			TripKey INT
			,UserKey INT
			,TripSavedKey UNIQUEIDENTIFIER
			,SearchAirPriceBreakupKey INT
			,OriginalPerPersonPrice FLOAT
			,SearchAirPrice FLOAT
			,SearchAirTax FLOAT
			,CrowdId INT
		)
		
		INSERT INTO @MissingAirTrips (TripKey)
		SELECT TripKey FROM AirRequestTripSavedDeal
		EXCEPT
		SELECT TripKey FROM TripDetails	
		
		SET @MissingTripCount = (SELECT COUNT(TripKey) FROM @MissingAirTrips)
		
		INSERT INTO TripSavedDealLog(ComponentType, Remarks, InitiatedFrom)
		VALUES
		(1, 'Total Number Of Missing Trips For Air Reprice : ' + CONVERT(VARCHAR, @MissingTripCount), 'RepriceAirComponent')
		
		IF(@MissingTripCount > 0)
		BEGIN --BEGIN 4
			
			DECLARE @SearchAirPriceBreakupKey INT
					,@SearchAirPrice FLOAT
					,@SearchAirTax FLOAT
			
			UPDATE MT 
			SET MT.TripSavedKey = AR.TripSavedKey
			,MT.UserKey = AR.UserKey
			FROM  @MissingAirTrips MT 
			INNER JOIN AirRequestTripSavedDeal AR 
			ON AR.TripKey = MT.TripKey
			
			UPDATE MT
			SET MT.searchAirPriceBreakupKey = TR.searchAirPriceBreakupKey
			FROM  @MissingAirTrips MT 
			INNER JOIN TripAirResponse TR 
			ON TR.tripGUIDKey = MT.TripSavedKey
			
			UPDATE MT
			SET MT.OriginalPerPersonPrice = CASE WHEN 
			(ISNULL(tripAdultBase,0) > 0) THEN (TR.tripAdultBase + TR.tripAdultTax)
			ELSE (TR.tripSeniorBase + TR.tripSeniorTax) END
			FROM  @MissingAirTrips MT 
			INNER JOIN TripAirPrices TR 
			ON TR.tripAirPriceKey = MT.SearchAirPriceBreakupKey
			
		    UPDATE MT
		    SET MT.SearchAirPrice = ((ISNULL(TAP.tripAdultBase,0) * ISNULL(T.tripAdultsCount,0)) 
		    + (ISNULL(TAP.tripChildBase,0) * ISNULL(T.tripChildCount,0))
		    + (ISNULL(TAP.tripSeniorBase,0) * ISNULL(T.tripSeniorsCount,0)) 
		    + (ISNULL(TAP.tripYouthBase,0) * ISNULL(T.tripYouthCount,0)) 
		    + (ISNULL(TAP.tripInfantBase,0) * ISNULL(T.tripInfantCount,0)))
		    
		    ,MT.SearchAirTax = ((ISNULL(TAP.tripAdultTax,0) * isnull(T.tripAdultsCount,0)) 
		    + (ISNULL(TAP.tripChildTax,0) * ISNULL(t.tripChildCount,0)) 
		    + (ISNULL(TAP.tripSeniorTax,0) * ISNULL(T.tripSeniorsCount,0)) 
		    + (ISNULL(TAP.tripYouthTax,0) * ISNULL(t.tripYouthCount,0)) 
		    + (ISNULL(TAP.tripInfantTax,0) * ISNULL(t.tripInfantCount,0)))
		    
		    FROM @MissingAirTrips MT
		    INNER JOIN TripAirPrices TAP
		    ON TAP.tripAirPriceKey = MT.SearchAirPriceBreakupKey
		    INNER JOIN Trip T
		    ON MT.TripSavedKey = T.tripSavedKey
		    		    
		    UPDATE MT
		    SET MT.CrowdId = ISNULL(TS.CrowdId,0)
		    FROM @MissingAirTrips MT 
		    INNER JOIN TripSaved TS
		    ON TS.tripSavedKey = MT.TripSavedKey
		    
		    INSERT INTO TripDetails
		    (
				tripKey
				,tripSavedKey
				,userKey
				,originalPerPersonPriceAir
				,originalTotalPriceAir
				,CrowdId
		    )
		    SELECT
				TripKey
				,TripSavedKey
				,UserKey
				,OriginalPerPersonPrice
				,(SearchAirPrice + SearchAirTax)
				,CrowdId
		    FROM @MissingAirTrips
  		
		END --END: BEGIN 4
		
		--UPDATE TRIP ORIGINAL DETAILS
		
		DECLARE @MissingDetailsAirTrips AS TABLE 
		(
			TripKey INT
			,UserKey INT
			,TripSavedKey UNIQUEIDENTIFIER
			,SearchAirPriceBreakupKey INT
			,OriginalPerPersonPrice FLOAT
			,SearchAirPrice FLOAT
			,SearchAirTax FLOAT
			,CrowdId INT
		)
		
		INSERT INTO @MissingDetailsAirTrips (TripKey)
		SELECT tripKey FROM TripDetails
		WHERE tripKey IN
		(
			SELECT tripKey FROM AirRequestTripSavedDeal
		)
		AND (ISNULL(originalPerPersonPriceAir,0) = 0 OR ISNULL(originalTotalPriceAir,0) = 0)
		
		SET @MissingTripCount = (SELECT COUNT(TripKey) FROM @MissingDetailsAirTrips)
		
		IF(@MissingTripCount > 0)
		BEGIN -- BEGIN 10			
			UPDATE MT 
			SET MT.TripSavedKey = AR.TripSavedKey
			,MT.UserKey = AR.UserKey
			FROM  @MissingDetailsAirTrips MT 
			INNER JOIN AirRequestTripSavedDeal AR 
			ON AR.TripKey = MT.TripKey
			
			UPDATE MT
			SET MT.searchAirPriceBreakupKey = TR.searchAirPriceBreakupKey
			FROM  @MissingDetailsAirTrips MT 
			INNER JOIN TripAirResponse TR 
			ON TR.tripGUIDKey = MT.TripSavedKey
			
			UPDATE MT
			SET MT.OriginalPerPersonPrice = CASE WHEN 
			(ISNULL(tripAdultBase,0) > 0) THEN (TR.tripAdultBase + TR.tripAdultTax)
			ELSE (TR.tripSeniorBase + TR.tripSeniorTax) END
			FROM  @MissingDetailsAirTrips MT 
			INNER JOIN TripAirPrices TR 
			ON TR.tripAirPriceKey = MT.SearchAirPriceBreakupKey
			
		    UPDATE MT
		    SET MT.SearchAirPrice = ((ISNULL(TAP.tripAdultBase,0) * ISNULL(T.tripAdultsCount,0)) 
		    + (ISNULL(TAP.tripChildBase,0) * ISNULL(T.tripChildCount,0))
		    + (ISNULL(TAP.tripSeniorBase,0) * ISNULL(T.tripSeniorsCount,0)) 
		    + (ISNULL(TAP.tripYouthBase,0) * ISNULL(T.tripYouthCount,0)) 
		    + (ISNULL(TAP.tripInfantBase,0) * ISNULL(T.tripInfantCount,0)))
		    
		    ,MT.SearchAirTax = ((ISNULL(TAP.tripAdultTax,0) * isnull(T.tripAdultsCount,0)) 
		    + (ISNULL(TAP.tripChildTax,0) * ISNULL(t.tripChildCount,0)) 
		    + (ISNULL(TAP.tripSeniorTax,0) * ISNULL(T.tripSeniorsCount,0)) 
		    + (ISNULL(TAP.tripYouthTax,0) * ISNULL(t.tripYouthCount,0)) 
		    + (ISNULL(TAP.tripInfantTax,0) * ISNULL(t.tripInfantCount,0)))
		    
		    FROM @MissingDetailsAirTrips MT
		    INNER JOIN TripAirPrices TAP
		    ON TAP.tripAirPriceKey = MT.SearchAirPriceBreakupKey
		    INNER JOIN Trip T
		    ON MT.TripSavedKey = T.tripSavedKey
		    
		    UPDATE MT
		    SET MT.CrowdId = ISNULL(TS.CrowdId,0)
		    FROM @MissingDetailsAirTrips MT 
		    INNER JOIN TripSaved TS
		    ON TS.tripSavedKey = MT.TripSavedKey
		   			   		    
		    UPDATE TD
			SET TD.originalPerPersonPriceAir = MT.OriginalPerPersonPrice
			,TD.originalTotalPriceAir = (MT.SearchAirPrice + MT.SearchAirTax)
			,TD.CrowdId = MT.CrowdId
			FROM  TripDetails TD 
			INNER JOIN @MissingDetailsAirTrips MT 
			ON MT.TripKey = TD.tripKey		    
		END -- END: BEGIN 10
		
	END --END: BEGIN 3
	--HOTEL
	ELSE IF (@componentType = 4) --FOR HOTEL
	BEGIN --BEGIN 2
		
		DECLARE @MissingHotelTrips AS TABLE 
		(
			TripKey INT
			,UserKey INT
			,NoOfRooms INT
			,TripSavedKey UNIQUEIDENTIFIER
			,originalPerPersonPriceHotel FLOAT
			,originalTotalPriceHotel FLOAT
			,originalPerPersonDailyTotalHotel FLOAT
			,dailyPriceHotel FLOAT
			,NoOfDays INT
			,CrowdId INT
		)
		
		INSERT INTO @MissingHotelTrips (TripKey)
		SELECT TripKey FROM HotelRequestTripSavedDeal
		EXCEPT
		SELECT TripKey FROM TripDetails
		
		SET @MissingTripCount = (SELECT COUNT(TripKey) FROM @MissingHotelTrips)
		
		INSERT INTO TripSavedDealLog(ComponentType, Remarks, InitiatedFrom)
		VALUES
		(4, 'Total Number Of Missing Trips For Hotel Reprice : ' + CONVERT(VARCHAR, @MissingTripCount)
		,'RepriceHotelComponent')
		
		IF(@MissingTripCount > 0)
		BEGIN --BEGIN 1
			UPDATE MT 
			SET MT.TripSavedKey = HR.TripSavedKey
			,MT.UserKey = HR.UserKey
			,MT.NoOfRooms = HR.NoOfRooms
			,MT.NoOfDays = HR.NoOfDays
			FROM  @MissingHotelTrips MT 
			INNER JOIN HotelRequestTripSavedDeal HR 
			ON HR.TripKey = MT.TripKey
			
			UPDATE MT
			SET MT.dailyPriceHotel = THR.hotelDailyPrice
			,MT.originalPerPersonDailyTotalHotel = THR.perPersonDailyTotal
			,MT.originalPerPersonPriceHotel = THR.hotelTotalPrice
			,MT.originalTotalPriceHotel = (THR.hotelTotalPrice * MT.NoOfRooms)
			FROM @MissingHotelTrips MT
			INNER JOIN TripHotelResponse THR
			ON THR.tripGUIDKey = MT.TripSavedKey
			
			UPDATE MT
			SET MT.CrowdId = TS.CrowdId
			FROM @MissingHotelTrips MT
			INNER JOIN TripSaved TS
			ON TS.tripSavedKey = MT.TripSavedKey
								    
		    INSERT INTO TripDetails
		    (
				tripKey
				,tripSavedKey
				,userKey
				,originalPerPersonPriceHotel
				,originalTotalPriceHotel
				,originalPerPersonDailyTotalHotel
				,dailyPriceHotel
				,NoOfHotelRooms
				,HotelNoOfDays
				,CrowdId
		    )
		    SELECT
				TripKey
				,TripSavedKey
				,UserKey
				,originalPerPersonPriceHotel
				,originalTotalPriceHotel
				,originalPerPersonDailyTotalHotel
				,dailyPriceHotel
				,NoOfRooms
				,NoOfDays
				,CrowdId
		    FROM @MissingHotelTrips
		END --END: BEGIN 1
		
		--HOTEL ROOM UPDATE
	DECLARE @MissingHotelRooms AS TABLE
	(
		TripKey INT	
	)
	
	INSERT INTO @MissingHotelRooms
	SELECT tripKey
	FROM TripDetails WHERE tripKey in
	(
		SELECT TripKey FROM HotelRequestTripSavedDeal
	)
	AND (NoOfHotelRooms IS NULL OR NoOfHotelRooms = 0)
    
    UPDATE TD
	SET TD.NoOfHotelRooms = HR.NoOfRooms
	FROM TripDetails TD
	INNER JOIN HotelRequestTripSavedDeal HR
	ON HR.TripKey = TD.tripKey
	WHERE TD.tripKey IN
	(SELECT TripKey FROM @MissingHotelRooms)
		
		--ORIGINAL PRICE UPDATE
		DECLARE @MissingHotelDetailsTrips AS TABLE 
		(
			TripKey INT
			,UserKey INT
			,NoOfRooms INT
			,TripSavedKey UNIQUEIDENTIFIER
			,originalPerPersonPriceHotel FLOAT
			,originalTotalPriceHotel FLOAT
			,originalPerPersonDailyTotalHotel FLOAT
			,dailyPriceHotel FLOAT
			,CrowdId INT
		)
		
		INSERT INTO @MissingHotelDetailsTrips (TripKey)
		SELECT tripKey FROM TripDetails
		WHERE tripKey IN
		(
			SELECT tripKey FROM HotelRequestTripSavedDeal
		)
		AND (ISNULL(originalPerPersonPriceHotel,0) = 0 OR ISNULL(originalTotalPriceHotel,0) = 0)
		
		SET @MissingTripCount = (SELECT COUNT(TripKey) FROM @MissingHotelDetailsTrips)
		
		IF(@MissingTripCount > 0)
		BEGIN --BEGIN 1
			UPDATE MT 
			SET MT.TripSavedKey = HR.TripSavedKey
			,MT.UserKey = HR.UserKey
			,MT.NoOfRooms = HR.NoOfRooms
			FROM  @MissingHotelDetailsTrips MT 
			INNER JOIN HotelRequestTripSavedDeal HR 
			ON HR.TripKey = MT.TripKey
			
			UPDATE MT
			SET MT.dailyPriceHotel = THR.hotelDailyPrice
			,MT.originalPerPersonDailyTotalHotel = THR.perPersonDailyTotal
			,MT.originalPerPersonPriceHotel = THR.hotelTotalPrice
			,MT.originalTotalPriceHotel = (THR.hotelTotalPrice * MT.NoOfRooms)
			FROM @MissingHotelDetailsTrips MT
			INNER JOIN TripHotelResponse THR
			ON THR.tripGUIDKey = MT.TripSavedKey
			
			UPDATE MT
			SET MT.CrowdId = TS.CrowdId
			FROM @MissingHotelDetailsTrips MT
			INNER JOIN TripSaved TS
			ON TS.tripSavedKey = MT.TripSavedKey
					    
		    UPDATE TD
			SET TD.originalPerPersonPriceHotel = MHT.originalPerPersonPriceHotel
			,TD.originalTotalPriceHotel = MHT.originalTotalPriceHotel
			,TD.originalPerPersonDailyTotalHotel = MHT.originalPerPersonDailyTotalHotel
			,TD.dailyPriceHotel = MHT.dailyPriceHotel
			,TD.CrowdId = MHT.CrowdId
			FROM  TripDetails TD 
			INNER JOIN @MissingHotelDetailsTrips MHT 
			ON MHT.TripKey = TD.tripKey  
		    
		END 
		
		--NO OF DAYS UPDATE
		DECLARE @MissingHotelNoOfDays AS TABLE
		(
			TripKey INT	
		)
	
		INSERT INTO @MissingHotelNoOfDays
		SELECT tripKey
		FROM TripDetails WHERE tripKey in
		(
			SELECT TripKey FROM HotelRequestTripSavedDeal
		)
		AND (HotelNoOfDays IS NULL OR HotelNoOfDays = 0)
	    
	    SET @MissingTripCount = (SELECT COUNT(TripKey) FROM @MissingHotelNoOfDays)
	    
	    IF(@MissingTripCount > 0)
	    BEGIN
			UPDATE TD
			SET TD.HotelNoOfDays = HR.NoOfDays
			FROM TripDetails TD
			INNER JOIN HotelRequestTripSavedDeal HR
			ON HR.TripKey = TD.tripKey
			WHERE TD.tripKey IN
			(SELECT TripKey FROM @MissingHotelNoOfDays)
		END
		
	END --END: BEGIN 2
    
END
GO
