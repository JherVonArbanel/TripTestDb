SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 22nd Jan 2013
-- Description:	Back up and delete data from Trip tables
-- =============================================
-- EXEC USP_TripSavedDealsDeleteOldData
 CREATE PROCEDURE [dbo].[USP_TripSavedDealsDeleteOldData] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @TmpTripSavedDeals AS TABLE (TripSavedDealKey INT,tripKey INT,responseKey UNIQUEIDENTIFIER
	,componentType INT,currentPerPersonPrice FLOAT
	,originalPerPersonPrice FLOAT,fareCategory VARCHAR(50),responseDetailKey UNIQUEIDENTIFIER
	,creationDate DATETIME,dealSentDate DATETIME,processedDate DATETIME,isAlternate BIT
	,vendorDetails VARCHAR(200),currentTotalPrice FLOAT,originalTotalPrice FLOAT,Remarks VARCHAR(3000)
	,currentListPagePrice FLOAT, isCrowd BIT)
	
	DECLARE @AirResponseKey AS TABLE (AirResponseKey UNIQUEIDENTIFIER)
	DECLARE @Trip AS TABLE (TripKey INT)
	
	INSERT INTO @Trip
	SELECT TripKey FROM Trip WHERE SiteKey = 5 AND CreatedDate < DATEADD(d,-8,Getdate()) 
	
	/*Truncate temporary hotel response table*/
	TRUNCATE TABLE TmpHotelResponse
	
	INSERT INTO @TmpTripSavedDeals
	SELECT TS.* FROM TripSavedDeals TS Inner Join @Trip T On T.tripKey=TS.TripKey 
	
	INSERT INTO @TmpTripSavedDeals (responseKey)
	SELECT responseKey FROM TripSavedLowestDeal WHERE creationDate < DATEADD(d,-2,Getdate())
		
	/*##########################AIR DATA BACKUP AND DELETE##########################*/	
	INSERT INTO @AirResponseKey
	SELECT TAR.airResponseKey FROM @TmpTripSavedDeals TSD 
	INNER JOIN TripAirResponse TAR ON TSD.responseKey = TAR.airResponseKey 
	AND TAR.tripGUIDKey IS NULL AND (TAR.tripKey IS NULL OR TAR.tripKey = 0)
	
	/*~~~~~~~~~~~~~~~~~~~~~~~TripAirSegments~~~~~~~~~~~~~~~~~~~~~~~*/	
	--EXEC USP_CompareAndAlterTableSturcture 'TripAirSegments', 'TripAirSegmentsHistory'
	
	INSERT INTO TripAirSegmentsHistory
	SELECT * FROM TripAirSegments WHERE airResponseKey 
	IN (SELECT AirResponseKey FROM @AirResponseKey)
	
	DELETE FROM TripAirSegments WHERE airResponseKey 
	IN (SELECT AirResponseKey FROM @AirResponseKey)
	/*~~~~~~~~~~~~~~~~~~~~~~~TripAirSegments~~~~~~~~~~~~~~~~~~~~~~~*/
	
	/*~~~~~~~~~~~~~~~~~~~~~~~TripAirLegs~~~~~~~~~~~~~~~~~~~~~~~*/	
	--EXEC USP_CompareAndAlterTableSturcture 'TripAirLegs', 'TripAirLegsHistory'
	
	INSERT INTO TripAirLegsHistory
	SELECT * FROM TripAirLegs WHERE airResponseKey 
	IN (SELECT AirResponseKey FROM @AirResponseKey)
	
	DELETE FROM TripAirLegs WHERE airResponseKey 
	IN (SELECT AirResponseKey FROM @AirResponseKey)
	/*~~~~~~~~~~~~~~~~~~~~~~~TripAirLegs~~~~~~~~~~~~~~~~~~~~~~~*/
	
	/*~~~~~~~~~~~~~~~~~~~~~~~TripAirPrices~~~~~~~~~~~~~~~~~~~~~~~*/
	--EXEC USP_CompareAndAlterTableSturcture 'TripAirPrices', 'TripAirPricesHistory'
	
	INSERT INTO TripAirPricesHistory
	SELECT * FROM TripAirPrices WHERE tripAirPriceKey 
	IN (SELECT searchAirPriceBreakupKey FROM TripAirResponse WHERE airResponseKey 
	IN (SELECT AirResponseKey FROM @AirResponseKey))
	
	DELETE FROM TripAirPrices WHERE tripAirPriceKey 
	IN (SELECT searchAirPriceBreakupKey FROM TripAirResponse WHERE airResponseKey 
	IN (SELECT AirResponseKey FROM @AirResponseKey))
	/*~~~~~~~~~~~~~~~~~~~~~~~TripAirPrices~~~~~~~~~~~~~~~~~~~~~~~*/
	
	/*~~~~~~~~~~~~~~~~~~~~~~~TripAirResponse~~~~~~~~~~~~~~~~~~~~~~~*/
	--EXEC USP_CompareAndAlterTableSturcture 'TripAirResponse', 'TripAirResponseHistory'
	
	INSERT INTO TripAirResponseHistory
	SELECT * FROM TripAirResponse WHERE airResponseKey 
	IN (SELECT AirResponseKey FROM @AirResponseKey)
	
	DELETE FROM TripAirResponse WHERE airResponseKey 
	IN (SELECT AirResponseKey FROM @AirResponseKey)
	/*~~~~~~~~~~~~~~~~~~~~~~~TripAirResponse~~~~~~~~~~~~~~~~~~~~~~~*/
	
	/*##########################CAR DATA BACKUP AND DELETE##########################*/
	--EXEC USP_CompareAndAlterTableSturcture 'TripCarResponse', 'TripCarResponseHistory'
	
	INSERT INTO TripCarResponseHistory
	SELECT * FROM TripCarResponse WHERE carResponseKey 
	IN (SELECT TCR.carResponseKey FROM @TmpTripSavedDeals TSD 
	INNER JOIN TripCarResponse TCR ON TSD.responseKey = TCR.carResponseKey 
	AND TCR.tripGUIDKey IS NULL AND (TCR.tripKey IS NULL OR TCR.tripKey = 0))
	
	DELETE FROM TripCarResponse WHERE carResponseKey 
	IN (SELECT TCR.carResponseKey FROM @TmpTripSavedDeals TSD 
	INNER JOIN TripCarResponse TCR ON TSD.responseKey = TCR.carResponseKey 
	AND TCR.tripGUIDKey IS NULL AND (TCR.tripKey IS NULL OR TCR.tripKey = 0))
	
	/*##########################HOTEL DATA BACKUP AND DELETE##########################*/
	--EXEC USP_CompareAndAlterTableSturcture 'TripHotelResponse', 'TripHotelResponseHistory'
	
	INSERT INTO TripHotelResponseHistory
	SELECT * FROM TripHotelResponse WHERE hotelResponseKey 
	IN (SELECT THR.hotelResponseKey FROM @TmpTripSavedDeals TSD 
	INNER JOIN TripHotelResponse THR ON TSD.responseKey = THR.hotelResponseKey 
	AND THR.tripGUIDKey IS NULL AND (THR.tripKey IS NULL OR THR.tripKey = 0))
	
	DELETE FROM TripHotelResponse WHERE hotelResponseKey 
	IN (SELECT THR.hotelResponseKey FROM @TmpTripSavedDeals TSD 
	INNER JOIN TripHotelResponse THR ON TSD.responseKey = THR.hotelResponseKey 
	AND THR.tripGUIDKey IS NULL AND (THR.tripKey IS NULL OR THR.tripKey = 0))
	
	/*##########################TRIP SAVED DEALS DATA BACKUP AND DELETE##########################*/
	--EXEC USP_CompareAndAlterTableSturcture 'TripSavedDeals', 'TripSavedDealsHistory'
	
	INSERT INTO TripSavedDealsHistory 
	SELECT * FROM @TmpTripSavedDeals 
	WHERE TripSavedDealKey IS NOT NULL
	
	DELETE FROM TripSavedDeals 
	WHERE TripSavedDealKey IN (SELECT TripSavedDealKey FROM @TmpTripSavedDeals)
	
	DELETE FROM TripSavedLowestDeal
	WHERE responseKey IN (SELECT responseKey FROM @TmpTripSavedDeals)
	
	/*##########################TripDetails DATA BACKUP. NO DELETE OPERATION APPLICABLE HERE##########################*/
	--EXEC USP_CompareAndAlterTableSturcture 'TripDetails', 'TripDetailsHistory'
	
	INSERT INTO TripDetailsHistory
	SELECT * FROM TripDetails

	DELETE FROM TripDetails WHERE TripKey IN (SELECT TripKey FROm @Trip) 
	DELETE FROM Trip WHERE TripKey IN (SELECT TripKey FROm @Trip) 
	DELETE FROM TimeLine WHERE TripKey IN (SELECT TripKey FROm @Trip) 

	
END
GO
