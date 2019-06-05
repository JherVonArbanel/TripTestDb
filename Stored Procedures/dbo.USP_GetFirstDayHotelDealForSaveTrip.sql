SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 25th October 2013
-- Description:	Gets hotel deals for first day of save trip
-- =============================================
--EXEC USP_GetFirstDayHotelDealForSaveTrip 102484,3.5,0,2,'8DF33188-7C6C-40FD-AE2B-2EA5DA778148',205,0
CREATE PROCEDURE [dbo].[USP_GetFirstDayHotelDealForSaveTrip]
	@hotelRequestID INT
	,@starRating FLOAT
	,@regionID FLOAT
	,@fromPage INT
	,@hotelResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
	,@hotelGroupId INT = 0
	,@isSeo BIT = 0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	/*Variable declaration*/
	DECLARE @upgradedStarRating FLOAT
			,@regionLatitude FLOAT 
			,@regionLongitude FLOAT
			,@recommendedPrice FLOAT = 0
			,@lowestPrice FLOAT = 0
			,@recommendedHotelResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
			,@crowdHotelResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
			,@lowestHotelResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
			,@considerStarRating FLOAT = 0
			,@upgradedStarRatingUpto FLOAT = 0
			,@lowestDealStarRating FLOAT = 0
			,@countToExecute INT = 1
			,@totalDeals INT = 0
			,@hotelResponseId INT
			,@hotelId INT
			,@supplierFamily VARCHAR(20)
			,@hotelsComPromoRate FLOAT = 0
			,@gdsPromoRate FLOAT = 0
			,@hotelsComDailyPrice FLOAT = 0
			,@selectedHotelId INT
	/*END: Variable declaration*/
		    
	/*Temp table declaration*/
	CREATE TABLE #tmpHotelResponse 
	(
		RowNumber INT IDENTITY (1,1)
		,HotelResponsekey UNIQUEIDENTIFIER
		,hotelID VARCHAR(10)
		,minrate FLOAT
		,latitude FLOAT
		,longitude FLOAT
		,miles FLOAT
		,supplierFamily VARCHAR(20)
		,IsPromo BIT
		,PromoRate FLOAT 
	)
	/*END: Temp table declaration*/
	
	/*Variable table declaration*/
	DECLARE @hotelResponse AS TABLE 
	(
		ID INT identity (1,1)
		,HotelResponseKey  UNIQUEIDENTIFIER
		,DealType CHAR
		,IsAlternateOption BIT
		,hotelID VARCHAR(10)
		,IsCrowdRateAvailable BIT DEFAULT(0)
		,supplierFamily VARCHAR(20)
		,IsPromo BIT
		,PromoRate FLOAT		
		,isUpdated BIT DEFAULT(0)
	)
	
	DECLARE @tmpHotelResponse AS TABLE 
	(
		HotelResponseKey  UNIQUEIDENTIFIER
		,HotelSequence INT
		,hotelID VARCHAR(10)
		,supplierFamily VARCHAR(20)
		,IsPromo BIT
		,PromoRate FLOAT
		
	)
	/*END: Variable table declaration*/
	
	
	
	/*Setting star rating to default. Applicable for all pages*/
	IF (@starRating = 0 OR @starRating IS NULL)
	BEGIN
		SET @starRating = 3
	END
	ELSE IF(@starRating = 4)
	BEGIN
		SET @considerStarRating = 4.5
	END
	ELSE IF(@starRating = 4.5)
	BEGIN
		SET @starRating = 4
		SET @considerStarRating = 4.5
	END
	ELSE IF(@starRating = 3)
	BEGIN
		SET @considerStarRating = 3.5
	END
	ELSE IF(@starRating = 3.5)
	BEGIN
		SET @starRating = 3
		SET @considerStarRating = 3.5
	END
	ELSE IF(@starRating = 2)
	BEGIN
		SET @considerStarRating = 2.5
	END
	
	IF (@considerStarRating = 0)
	BEGIN
		SET @considerStarRating = @starRating
	END
		
	/*Setting region id to default. Applicable for all pages*/
	IF (@regionID = 0 OR @regionID IS NULL)
	BEGIN
		SET @regionID = 0
	END
		
	/*UNIQUIFIYING RESULTS*/
	INSERT INTO #tmpHotelResponse (HotelResponsekey, hotelID, minrate, latitude, longitude, supplierFamily, IsPromo, PromoRate)
	SELECT HR.hotelResponseKey, HR.hotelid, HR.minRate, HT.Latitude, HT.Longitude, HR.supplierId
	,HR.isPromoTrue, HR.averageBaseRate
	FROM HotelResponse HR  WITH (NOLOCK) 
	INNER JOIN HotelContent.dbo.Hotels HT WITH (NOLOCK) 
	ON HR.hotelId = HT.HotelId 
	
	WHERE hotelRequestKey = @hotelRequestID ORDER BY minrate
	
	--Deleting duplicate results from tourico/sabre/hotescom
	DELETE FROM #tmpHotelResponse WHERE RowNumber NOT IN 
	(SELECT MIN(RowNumber) ROWID  FROM #tmpHotelResponse GROUP BY hotelID)
	/*END - UNIQUIFIYING RESULTS*/
	
	--DELETE DUPLICATE HOTEL WHEN CALLED FROM SEO PAGE
	IF(@isSeo = 1)
	BEGIN
		DECLARE @seoHotelId INT
		SET @seoHotelId = (SELECT hotelID FROM #tmpHotelResponse WHERE HotelResponsekey = @hotelResponseKey)
		DELETE FROM #tmpHotelResponse WHERE hotelID = @seoHotelId --AND hotelResponseKey <> @hotelResponseKey
	END
	
	/*If user has selected region*/
	IF(@regionID > 0)
	BEGIN
	--print 'Region ID condition'
		--SELECT @regionLatitude = CenterLatitude, 
		--@regionLongitude = CenterLongitude   
		--FROM HotelContent.dbo.RegionCenterCoordinatesList 
		--WHERE regionId = @regionId
		
		--UPDATE #tmpHotelResponse 
		--SET miles = HotelContent.dbo.fnGetDistance(@regionLatitude, @regionLongitude, Latitude,  Longitude, 'Miles')
		
		/*For recomended deal. 'R' represents recomended deals*/
		IF(@fromPage = 1 OR @fromPage = 3)--Follow Deal and Get Deals page
		BEGIN
			
			INSERT INTO @tmpHotelResponse (HotelResponseKey, HotelSequence, hotelID, supplierFamily, IsPromo, PromoRate)
			SELECT HR.HotelResponsekey, CASE WHEN (ISNULL(CGM.HotelSequence,0) = 0) THEN 2 
			WHEN (ISNULL(CGM.HotelSequence,0) > 10) THEN 1 ELSE CGM.HotelSequence END  
			,HR.hotelID, HR.supplierFamily
			,HR.IsPromo, HR.PromoRate
			FROM #tmpHotelResponse HR         
			INNER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK) 
			ON HR.HotelId = HT.HotelId         
			INNER JOIN HotelContent.dbo.RegionHotelIDMapping HC WITH (NOLOCK)
			ON HR.HotelId = HC.HotelId
			INNER JOIN CMS.dbo.CustomHotelGroupMapping CGM WITH (NOLOCK)
			ON HT.HotelId = CGM.HotelId
			AND CGM.HotelGroupId = @hotelGroupId
			WHERE HC.RegionId = @regionId
			AND HT.Rating BETWEEN @starRating AND @considerStarRating
			
			--IF NO DATA FOUND THEN REMOVE HOTEL GROUP ID
			IF((SELECT COUNT(HotelResponseKey) FROM @tmpHotelResponse) = 0)
			BEGIN
				INSERT INTO @tmpHotelResponse (HotelResponseKey, HotelSequence, hotelID, supplierFamily, IsPromo, PromoRate)
				SELECT HR.HotelResponsekey, CASE WHEN (ISNULL(CGM.HotelSequence,0) = 0) THEN 2 
				WHEN (ISNULL(CGM.HotelSequence,0) > 10) THEN 1 ELSE CGM.HotelSequence END
				,HR.hotelID, HR.supplierFamily  
				,HR.IsPromo, HR.PromoRate
				FROM #tmpHotelResponse HR         
				INNER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK)
				ON HR.HotelId = HT.HotelId         
				INNER JOIN HotelContent.dbo.RegionHotelIDMapping HC WITH (NOLOCK)
				ON HR.HotelId = HC.HotelId
				INNER JOIN CMS.dbo.CustomHotelGroupMapping CGM WITH (NOLOCK)
				ON HT.HotelId = CGM.HotelId
				WHERE HC.RegionId = @regionId
				AND HT.Rating BETWEEN @starRating AND @considerStarRating		
			END
			
			INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
			SELECT TOP 1 hotelResponseKey, 'R', hotelID, supplierFamily
			,IsPromo, PromoRate
			FROM @tmpHotelResponse
			WHERE hotelSequence = (SELECT MAX(hotelSequence) FROM @tmpHotelResponse)
			AND HotelResponsekey <> @hotelResponseKey
			
			/*IF HOTEL NOT PRESENT IN CMS*/
			IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse) = 0)
			BEGIN
				INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
				SELECT TOP 1 HotelResponsekey, 'R', THR.hotelID, THR.supplierFamily
				,THR.IsPromo, THR.PromoRate
				FROM #tmpHotelResponse THR
				INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
				ON HTS.HotelId = THR.HotelId         
				INNER JOIN HotelContent.dbo.RegionHotelIDMapping RHC WITH (NOLOCK)
				ON HTS.HotelId = RHC.HotelId
				AND RHC.RegionId = @regionID
				AND HTS.Rating BETWEEN @starRating AND @considerStarRating
				AND THR.HotelResponsekey <> @hotelResponseKey
				ORDER BY THR.minrate ASC
			END
			/*END: IF HOTEL NOT PRESENT IN CMS*/
			
			/*IF HOTEL NOT FOUND IN SELECTED REGION*/
			IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse) = 0)
			BEGIN
				INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
				SELECT TOP 1 HotelResponsekey, 'R', THR.hotelID, THR.supplierFamily
				,THR.IsPromo, THR.PromoRate
				FROM #tmpHotelResponse THR
				INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
				ON HTS.HotelId = THR.HotelId         
				--INNER JOIN HotelContent.dbo.RegionHotelIDMapping RHC ON HTS.HotelId = RHC.HotelId
				AND HTS.Rating BETWEEN @starRating AND @considerStarRating
				AND THR.HotelResponsekey <> @hotelResponseKey
				ORDER BY THR.minrate ASC
			END
			/*END: IF HOTEL NOT FOUND IN SELECTED REGION*/
			
		END
		/*END - For recomended deal*/
		
		/*For lowest price deal. 'L' represents lowest deals*/
		IF(@fromPage = 2 OR @fromPage = 3)--Trip Summary and Get Deals page
		BEGIN
			INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
			SELECT TOP 1 HotelResponsekey, 'L', THR.hotelID, THR.supplierFamily
			,THR.IsPromo, THR.PromoRate
			FROM #tmpHotelResponse THR
			INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
			ON HTS.HotelId = THR.HotelId         
			INNER JOIN HotelContent.dbo.RegionHotelIDMapping RHC WITH (NOLOCK)
			ON HTS.HotelId = RHC.HotelId
			AND RHC.RegionId = @regionID
			AND HTS.Rating BETWEEN @starRating AND @considerStarRating
			AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
			AND THR.HotelResponsekey <> @hotelResponseKey
			ORDER BY THR.minrate ASC
			
			--If no hotels found then remove region id
			IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'L') = 0)
			BEGIN
				INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
				SELECT TOP 1 HotelResponsekey, 'L', THR.hotelID, THR.supplierFamily
				,THR.IsPromo, THR.PromoRate
				FROM #tmpHotelResponse THR
				INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
				ON HTS.HotelId = THR.HotelId
				AND HTS.Rating BETWEEN @starRating AND @considerStarRating
				AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
				AND THR.HotelResponsekey <> @hotelResponseKey
				ORDER BY THR.minrate ASC
			END
						
			/*IF ORIGINAL HOTEL RATING IS GREATER THAN 3 AND NO LOWEST DEAL FOUND
			THEN DECREASE THE HOTEL RATING BY 1 AND GET LOWEST HOTEL DEAL*/
			IF(@starRating > 3)
			BEGIN
				IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'L') = 0)
				BEGIN
					SET @lowestDealStarRating = (@starRating - 1) --DECREASING STAR RATING BY 1
					
					INSERT INTO @hotelResponse (HotelResponseKey, DealType, IsAlternateOption, hotelID, supplierFamily, IsPromo, PromoRate)
					SELECT TOP 1 HotelResponsekey, 'L', 1, THR.hotelID, THR.supplierFamily
					,THR.IsPromo, THR.PromoRate
					FROM #tmpHotelResponse THR
					INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
					ON HTS.HotelId = THR.HotelId
					AND HTS.Rating BETWEEN @lowestDealStarRating AND (@lowestDealStarRating + 0.5)
					ORDER BY THR.minrate ASC
				END
			END
			
		/*END - For lowest price deal*/
		
		/*IF THE PRICE OF RECOMMENDED HOTEL IS LESS THAN LOWEST PRICE HOTEL 
		THEN INTER EXCHANGE RECOMMENDED WITH LOWEST AND VICE-VERSA*/
		IF(@fromPage <> 2)
		BEGIN
			--IF LOWEST PRICE OPTION IS LESS THAN USER SELECTED STAR RATING THEN DONT INTER CHANGE DEAL
			IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'L' AND ISNULL(IsAlternateOption, 0) = 1) = 0)
			BEGIN
				SELECT @recommendedPrice = minrate, @recommendedHotelResponseKey = HotelResponsekey 
				FROM #tmpHotelResponse WHERE HotelResponsekey 
				= (SELECT HotelResponsekey FROM @hotelResponse WHERE DealType = 'R')
				
				SELECT @lowestPrice = minrate, @lowestHotelResponseKey = HotelResponsekey 
				FROM #tmpHotelResponse WHERE HotelResponsekey 
				= (SELECT HotelResponsekey FROM @hotelResponse WHERE DealType = 'L')
				
				IF(@lowestPrice > 0  AND @recommendedPrice > 0)
				BEGIN
					IF(@lowestPrice > @recommendedPrice)
					BEGIN
						UPDATE @hotelResponse SET DealType = 'R' WHERE HotelResponsekey = @lowestHotelResponseKey
						UPDATE @hotelResponse SET DealType = 'L' WHERE HotelResponsekey = @recommendedHotelResponseKey
					END
				END
			END
		END
		/*END: IF THE PRICE OF RECOMMENDED HOTEL IS LESS THAN LOWEST PRICE HOTEL 
		THEN INTER EXCHANGE RECOMMENDED WITH LOWEST AND VICE-VERSA*/
		
			/*For upgraded star rating. 'U' represents recomended deals*/
			--Setting Updated Star Rating
			IF(@starRating = 5)
				BEGIN
					SET @upgradedStarRating = 5
				END
			ELSE
				BEGIN
					IF(@starRating = 4.5 OR @starRating = 4)
					BEGIN
						SET @upgradedStarRating = 5
					END
					ELSE IF(@starRating = 3.5 OR @starRating = 3)
					BEGIN
						SET @upgradedStarRating = 4
						SET @upgradedStarRatingUpto = 4.5
					END
					ELSE IF(@starRating = 2.5 OR @starRating = 2)
					BEGIN
						SET @upgradedStarRating = 3
						SET @upgradedStarRatingUpto = 3.5
					END
				END
			--END: Setting Updated Star Rating
				
			/*UPGRADING OPTION BY INCREASING STAR RATING*/
			INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
			SELECT TOP 1 HotelResponsekey, 'U', THR.hotelID, THR.supplierFamily
			,THR.IsPromo, THR.PromoRate
			FROM #tmpHotelResponse THR
			INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
			ON HTS.HotelId = THR.HotelId         
			INNER JOIN HotelContent.dbo.RegionHotelIDMapping RHC WITH (NOLOCK)
			ON HTS.HotelId = RHC.HotelId
			AND RHC.RegionId = @regionID
			AND HTS.Rating = @upgradedStarRating
			AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
			AND THR.HotelResponsekey <> @hotelResponseKey
			ORDER BY THR.minrate ASC
			/*END: UPGRADING OPTION BY INCREASING STAR RATING*/
			
			IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'U') = 0)
			BEGIN --BEGIN 3
				/*ADD .5(@upgradedStarRatingUpto) STAR TO @upgradedStarRating TO GET DATA*/
				INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
				SELECT TOP 1 HotelResponsekey, 'U', THR.hotelID, THR.supplierFamily
				,THR.IsPromo, THR.PromoRate
				FROM #tmpHotelResponse THR
				INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
				ON HTS.HotelId = THR.HotelId         
				INNER JOIN HotelContent.dbo.RegionHotelIDMapping RHC WITH (NOLOCK)
				ON HTS.HotelId = RHC.HotelId
				AND RHC.RegionId = @regionID
				AND HTS.Rating BETWEEN @upgradedStarRating AND @upgradedStarRatingUpto
				AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
				AND THR.HotelResponsekey <> @hotelResponseKey
				ORDER BY THR.minrate ASC
				
				IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'U') = 0)
				BEGIN --BEGIN 2
					/*IF STILL NO HOTEL FOUND THEN REMOVE REGION ID AND CONSIDER UPGRADED STAR RATING*/
					INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
					SELECT TOP 1 HotelResponsekey, 'U', THR.hotelID, THR.supplierFamily
					,THR.IsPromo, THR.PromoRate
					FROM #tmpHotelResponse THR
					INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
					ON HTS.HotelId = THR.HotelId
					AND HTS.Rating BETWEEN @upgradedStarRating AND @upgradedStarRatingUpto
					AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
					AND THR.HotelResponsekey <> @hotelResponseKey
					ORDER BY THR.minrate ASC
					
					IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'U') = 0)
					BEGIN --BEGIN 1
						/*IF STILL NO HOTEL FOUND THEN CONSIDER THE ORIGINAL STAR RATING WITH REGION ID*/
						INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
						SELECT TOP 1 HotelResponsekey, 'U', THR.hotelID, THR.supplierFamily
						,THR.IsPromo, THR.PromoRate
						FROM #tmpHotelResponse THR
						INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
						ON HTS.HotelId = THR.HotelId         
						INNER JOIN HotelContent.dbo.RegionHotelIDMapping RHC WITH (NOLOCK)
						ON HTS.HotelId = RHC.HotelId
						AND RHC.RegionId = @regionID
						AND HTS.Rating BETWEEN @starRating AND @considerStarRating
						AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
						AND THR.HotelResponsekey <> @hotelResponseKey
						ORDER BY THR.minrate ASC
						
						IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'U') = 0)
						BEGIN --BEGIN 0
							/*IF STILL NO HOTEL FOUND THEN SET THE STAR RATING TO ORIGINAL AND REMOVE THE REGION ID*/
							INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
							SELECT TOP 1 HotelResponsekey, 'U', THR.hotelID, THR.supplierFamily
							,THR.IsPromo, THR.PromoRate
							FROM #tmpHotelResponse THR
							INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
							ON HTS.HotelId = THR.HotelId
							AND HTS.Rating BETWEEN @starRating AND @considerStarRating
							AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
							AND THR.HotelResponsekey <> @hotelResponseKey
							ORDER BY THR.minrate ASC
							
							/*IF NO UPGRADED DEAL FOUND AND ORIGINAL HOTEL RATING GREATER THAN 3 
							THEN DECREASE HOTEL RATING BY 1 
							AND GET THE BEST RATED HOTEL FROM CMS AS UPGRADED DEAL*/
							IF(@starRating > 3)
							BEGIN --BEGIN -2
								IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'U') = 0)
								BEGIN --BEGIN -1
									SET @lowestDealStarRating = (@starRating - 1) --DECREASING STAR RATING BY 1
									
									DELETE FROM @tmpHotelResponse
									
									--GET HOTELS WITHOUT HOTEL GROUP ID, JUST CONSIDER THE REGION
									INSERT INTO @tmpHotelResponse (HotelResponseKey, HotelSequence, hotelID, supplierFamily, IsPromo, PromoRate)
									SELECT HR.HotelResponsekey, CASE WHEN (ISNULL(CGM.HotelSequence,0) = 0) THEN 2 
									WHEN (ISNULL(CGM.HotelSequence,0) > 10) THEN 1 ELSE CGM.HotelSequence END  
									,HR.hotelID, HR.supplierFamily
									,HR.IsPromo, HR.PromoRate
									FROM #tmpHotelResponse HR         
									INNER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK)
									ON HR.HotelId = HT.HotelId         
									INNER JOIN HotelContent.dbo.RegionHotelIDMapping HC WITH (NOLOCK)
									ON HR.HotelId = HC.HotelId
									INNER JOIN CMS.dbo.CustomHotelGroupMapping CGM WITH (NOLOCK)
									ON HT.HotelId = CGM.HotelId
									WHERE HC.RegionId = @regionId
									AND HT.Rating BETWEEN @lowestDealStarRating AND (@lowestDealStarRating + 0.5)		
																		
									INSERT INTO @hotelResponse (HotelResponseKey, DealType, IsAlternateOption, hotelID, supplierFamily, IsPromo, PromoRate)
									SELECT TOP 1 hotelResponseKey, 'U', 1, hotelID, supplierFamily
									,IsPromo, PromoRate
									FROM @tmpHotelResponse
									WHERE hotelSequence = (SELECT MAX(hotelSequence) FROM @tmpHotelResponse)
									AND HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
								END --END: BEGIN -1
						   	END --END: BEGIN -2
						   	
						END --END: BEGIN 0
					END --END: BEGIN 1
				END --END: BEGIN 2
			END --END: BEGIN 3			
			/*END - For upgraded star rating*/		
		END
	END
	/*END: If user has selected region*/
	ELSE
	/*If user has NOT selected region*/
	BEGIN
		/*For recomended deal. 'R' represents recomended deals*/
		IF(@fromPage = 1 OR @fromPage = 3)--Follow Deal and Get Deals page
		BEGIN
			INSERT INTO @tmpHotelResponse (HotelResponseKey, HotelSequence, hotelID, supplierFamily, IsPromo, PromoRate)
			SELECT HR.HotelResponsekey, CASE WHEN (ISNULL(CGM.HotelSequence,0) = 0) THEN 2 
			WHEN (ISNULL(CGM.HotelSequence,0) > 10) THEN 1 ELSE CGM.HotelSequence END  
			,HR.hotelID, HR.supplierFamily
			,HR.IsPromo, HR.PromoRate
			FROM #tmpHotelResponse HR         
			INNER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK)
			ON HR.HotelId = HT.HotelId
			INNER JOIN CMS.dbo.CustomHotelGroupMapping CGM WITH (NOLOCK)
			ON HR.HotelId = CGM.HotelId
			AND CGM.HotelGroupId = @hotelGroupId
			AND HT.Rating BETWEEN @starRating AND @considerStarRating
			
			IF((SELECT COUNT(HotelResponseKey) FROM @tmpHotelResponse) = 0)
			BEGIN
				INSERT INTO @tmpHotelResponse (HotelResponseKey, HotelSequence, hotelID, supplierFamily, IsPromo, PromoRate)
				SELECT HR.HotelResponsekey, CASE WHEN (ISNULL(CGM.HotelSequence,0) = 0) THEN 2 
				WHEN (ISNULL(CGM.HotelSequence,0) > 10) THEN 1 ELSE CGM.HotelSequence END  
				,HR.hotelID, HR.supplierFamily
				,HR.IsPromo, HR.PromoRate
				FROM #tmpHotelResponse HR         
				INNER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK)
				ON HR.HotelId = HT.HotelId
				INNER JOIN CMS.dbo.CustomHotelGroupMapping CGM WITH (NOLOCK)
				ON HR.HotelId = CGM.HotelId
				AND HT.Rating BETWEEN @starRating AND @considerStarRating	
			END
			
			INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
			SELECT TOP 1 hotelResponseKey, 'R', hotelID, supplierFamily 
			,IsPromo, PromoRate
			FROM @tmpHotelResponse
			WHERE hotelSequence = (SELECT MAX(hotelSequence) FROM @tmpHotelResponse)
			AND HotelResponsekey <> @hotelResponseKey
			
			IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse) = 0)
			BEGIN
				INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
				SELECT TOP 1 HotelResponsekey, 'R', THR.hotelID, THR.supplierFamily
				,THR.IsPromo, THR.PromoRate
				FROM #tmpHotelResponse THR
				INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
				ON HTS.HotelId = THR.HotelId
				AND HTS.Rating BETWEEN @starRating AND @considerStarRating
				AND THR.HotelResponsekey <> @hotelResponseKey
				ORDER BY THR.minrate ASC
			END
			
		END
		/*END - For recomended deal*/
		
		/*For lowest price deal. 'L' represents recomended deals*/
		IF(@fromPage = 2 OR @fromPage = 3)--Trip Summary and Get Deals page
		BEGIN
			/*Setting selectedHotelId of Selected Response (Ashima)*/
			SET @selectedHotelId = (SELECT hotelId FROM HotelResponse where hotelResponseKey = @hotelResponseKey)
			IF(@selectedHotelId = 0 OR  @selectedHotelId IS NULL)
				BEGIN
					INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
					SELECT TOP 1 HotelResponsekey, 'L', THR.hotelID, THR.supplierFamily
					,THR.IsPromo, THR.PromoRate
					FROM #tmpHotelResponse THR
					INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
					ON HTS.HotelId = THR.HotelId
					AND HTS.Rating BETWEEN @starRating AND @considerStarRating
					AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
					AND THR.HotelResponsekey <> @hotelResponseKey
					ORDER BY THR.minrate ASC
				END
				ELSE BEGIN
					INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
					SELECT TOP 1 HotelResponsekey, 'L', THR.hotelID, THR.supplierFamily
					,THR.IsPromo, THR.PromoRate
					FROM #tmpHotelResponse THR
					INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
					ON HTS.HotelId = THR.HotelId
					AND HTS.Rating BETWEEN @starRating AND @considerStarRating
					AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
					AND THR.HotelResponsekey <> @hotelResponseKey
					AND THR.hotelID <> @selectedHotelId
					ORDER BY THR.minrate ASC
				END
			/*END :Setting selectedHotelId of Selected Response (Ashima) */
		END
		
		/*IF ORIGINAL HOTEL RATING IS GREATER THAN 3 AND NO LOWEST DEAL FOUND
			THEN DECREASE THE HOTEL RATING BY 1 AND GET LOWEST HOTEL DEAL*/
		IF(@starRating > 3)
		BEGIN
			IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'L') = 0)
			BEGIN
				SET @lowestDealStarRating = (@starRating - 1) --DECREASING STAR RATING BY 1
				
				INSERT INTO @hotelResponse (HotelResponseKey, DealType, IsAlternateOption, hotelID, supplierFamily, IsPromo, PromoRate)
				SELECT TOP 1 HotelResponsekey, 'L', 1, THR.hotelID, THR.supplierFamily
				,THR.IsPromo, THR.PromoRate
				FROM #tmpHotelResponse THR
				INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
				ON HTS.HotelId = THR.HotelId
				AND HTS.Rating BETWEEN @lowestDealStarRating AND (@lowestDealStarRating + 0.5)
				ORDER BY THR.minrate ASC	
			END
		END
		
		/*END - For lowest price deal*/
		
		/*IF THE PRICE OF RECOMMENDED HOTEL IS LESS THAN LOWEST PRICE HOTEL 
		THEN INTER EXCHANGE RECOMMENDED WITH LOWEST AND VICE-VERSA*/
		IF(@fromPage <> 2)
		BEGIN
			--IF LOWEST PRICE OPTION IS LESS THAN USER SELECTED STAR RATING THEN DONT INTER CHANGE DEAL
			IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'L' AND ISNULL(IsAlternateOption, 0) = 1) = 0)
			BEGIN
				SELECT @recommendedPrice = minrate, @recommendedHotelResponseKey = HotelResponsekey 
				FROM #tmpHotelResponse WHERE HotelResponsekey 
				= (SELECT HotelResponsekey FROM @hotelResponse WHERE DealType = 'R')
				
				SELECT @lowestPrice = minrate, @lowestHotelResponseKey = HotelResponsekey 
				FROM #tmpHotelResponse WHERE HotelResponsekey 
				= (SELECT HotelResponsekey FROM @hotelResponse WHERE DealType = 'L')
				
				IF(@lowestPrice > 0  AND @recommendedPrice > 0)
				BEGIN
					IF(@lowestPrice > @recommendedPrice)
					BEGIN
						UPDATE @hotelResponse SET DealType = 'R' WHERE HotelResponsekey = @lowestHotelResponseKey
						UPDATE @hotelResponse SET DealType = 'L' WHERE HotelResponsekey = @recommendedHotelResponseKey
					END
				END
			END
		END
		/*END: IF THE PRICE OF RECOMMENDED HOTEL IS LESS THAN LOWEST PRICE HOTEL 
		THEN INTER EXCHANGE RECOMMENDED WITH LOWEST AND VICE-VERSA*/
		
		/*For upgraded star rating. 'U' represents recomended deals*/
		IF(@fromPage = 2 OR @fromPage = 3)--Trip Summary and Get Deals page
		BEGIN
		--Upgrading Star Rating to .5 OR 1 
			IF(@starRating = 5)
			BEGIN
				SET @upgradedStarRating = 5
			END
			ELSE
			BEGIN
				IF(@starRating = 4.5 OR @starRating = 4)
				BEGIN
					SET @upgradedStarRating = 5
				END
				ELSE IF(@starRating = 3.5 OR @starRating = 3)
				BEGIN
					SET @upgradedStarRating = 4
					SET @upgradedStarRatingUpto = 4.5
				END
				ELSE IF(@starRating = 2.5 OR @starRating = 2)
				BEGIN
					SET @upgradedStarRating = 3
					SET @upgradedStarRatingUpto = 3.5
				END
			END
		--END: Upgrading Star Rating to .5 OR 1
					
			INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
			SELECT TOP 1 HotelResponsekey, 'U', THR.hotelID, THR.supplierFamily
			,THR.IsPromo, THR.PromoRate
			FROM #tmpHotelResponse THR
			INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
			ON HTS.HotelId = THR.HotelId
			AND HTS.Rating = @upgradedStarRating
			AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
			AND THR.HotelResponsekey <> @hotelResponseKey
			ORDER BY THR.minrate ASC
			
			IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'U') = 0)
			BEGIN --BEGIN 5
				/*ADD .5(@upgradedStarRatingUpto) STAR TO @upgradedStarRating TO GET DATA*/
				INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
				SELECT TOP 1 HotelResponsekey, 'U', THR.hotelID, THR.supplierFamily
				,THR.IsPromo, THR.PromoRate
				FROM #tmpHotelResponse THR
				INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
				ON HTS.HotelId = THR.HotelId
				AND HTS.Rating BETWEEN @upgradedStarRating AND @upgradedStarRatingUpto
				AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
				AND THR.HotelResponsekey <> @hotelResponseKey
				ORDER BY THR.minrate ASC
				
				/*if no data is available for above query then change 
				the star rating to original star rating*/
				IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'U') = 0)
				BEGIN --BEGIN 4
					INSERT INTO @hotelResponse (HotelResponseKey, DealType, hotelID, supplierFamily, IsPromo, PromoRate)
					SELECT TOP 1 HotelResponsekey, 'U', THR.hotelID, THR.supplierFamily
					,THR.IsPromo, THR.PromoRate
					FROM #tmpHotelResponse THR
					INNER JOIN HotelContent.dbo.Hotels AS HTS WITH (NOLOCK)
					ON HTS.HotelId = THR.HotelId
					AND HTS.Rating BETWEEN @starRating AND @considerStarRating
					AND THR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
					AND THR.HotelResponsekey <> @hotelResponseKey
					ORDER BY THR.minrate ASC
					
					/*IF NO UPGRADED DEAL FOUND AND ORIGINAL HOTEL RATING GREATER THAN 3 
					THEN DECREASE HOTEL RATING BY 1 
					AND GET THE BEST RATED HOTEL FROM CMS AS UPGRADED DEAL*/
					IF(@starRating > 3)
					BEGIN --BEGIN 7
						IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'U') = 0)
						BEGIN --BEGIN 6
							--print 'alternative'
							DELETE FROM @tmpHotelResponse
							SET @lowestDealStarRating = (@starRating - 1) --DECREASING STAR RATING BY 1
							
							INSERT INTO @tmpHotelResponse (HotelResponseKey, HotelSequence, hotelID, supplierFamily, IsPromo, PromoRate)
							SELECT HR.HotelResponsekey, CASE WHEN (ISNULL(CGM.HotelSequence,0) = 0) THEN 2 
							WHEN (ISNULL(CGM.HotelSequence,0) > 10) THEN 1 ELSE CGM.HotelSequence END  
							,HR.hotelID, HR.supplierFamily
							,HR.IsPromo, HR.PromoRate
							FROM #tmpHotelResponse HR         
							INNER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK)
							ON HR.HotelId = HT.HotelId
							INNER JOIN CMS.dbo.CustomHotelGroupMapping CGM WITH (NOLOCK)
							ON HR.HotelId = CGM.HotelId
							AND HT.Rating BETWEEN @lowestDealStarRating AND (@lowestDealStarRating + 0.5)
							
							INSERT INTO @hotelResponse (HotelResponseKey, DealType, IsAlternateOption, hotelID, supplierFamily, IsPromo, PromoRate)
							SELECT TOP 1 hotelResponseKey, 'R', 1, hotelID, supplierFamily 
							,IsPromo, PromoRate
							FROM @tmpHotelResponse
							WHERE hotelSequence = (SELECT MAX(hotelSequence) FROM @tmpHotelResponse)
							AND HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
							
							
							IF((SELECT COUNT(HotelResponseKey) FROM @hotelResponse WHERE DealType = 'U') = 0)
							BEGIN --BEGIN 8
								INSERT INTO @hotelResponse (HotelResponseKey, DealType, IsAlternateOption, hotelID, supplierFamily, IsPromo, PromoRate)
								SELECT HR.HotelResponsekey, 'U', 1, HR.hotelID, HR.supplierFamily
								,HR.IsPromo, HR.PromoRate
								FROM #tmpHotelResponse HR       
								INNER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK)
								ON HR.HotelId = HT.HotelId
								AND HT.Rating BETWEEN @lowestDealStarRating AND (@lowestDealStarRating + 0.5)
								AND HR.HotelResponsekey NOT IN (SELECT HotelResponsekey FROM @hotelResponse)
							END --END: BEGIN 8
							
						END --END: BEGIN 6
					END --END: BEGIN 7
				END --END: BEGIN 4
			END --END: BEGIN 5
			
		END
		/*END - For upgraded star rating*/		
	END
	/*END: If user has NOT selected region*/
	
	--select * from @hotelResponse
	
	--#########START OF CROWD RATE CODE#########--
	/*This Code block was added on 11 Feb 2015.
	This block checks if hotelResponse table has more than one record of same hotel for different GDS.*/
	SET @totalDeals = (SELECT COUNT(HotelResponseKey) FROM @hotelResponse)
	--Looping done to execute selected deals one by one
	WHILE(@countToExecute <= @totalDeals)
	BEGIN
		--Assign all the required values to variables
		SELECT TOP 1 @recommendedHotelResponseKey = HotelResponseKey
		,@hotelResponseId = ID
		,@hotelId = hotelID
		,@supplierFamily = supplierFamily
		,@gdsPromoRate = ISNULL(PromoRate, 0)
		FROM @hotelResponse WHERE isUpdated = 0
		
		--Check if we have a different response key other than the response key present in @hotelResponse table
		--If we have a key the assign to variable or assign default value
		--If we have a response key that means there is another record for the same hotel but with diff. GDS
		SELECT  @crowdHotelResponseKey = ISNULL(hotelResponseKey, '00000000-0000-0000-0000-000000000000')
		,@hotelsComPromoRate = ISNULL(averageBaseRate, 0)
		,@hotelsComDailyPrice = ISNULL(minRate, 0)
		FROM HotelResponse WITH (NOLOCK)
		WHERE hotelRequestKey = @hotelRequestID
		AND hotelId = @hotelId
		AND hotelResponseKey <> @recommendedHotelResponseKey	
		
		--PRINT '@crowdHotelResponseKey : ' + CONVERT(VARCHAR(100),@crowdHotelResponseKey)
		
		IF(@crowdHotelResponseKey <> '00000000-0000-0000-0000-000000000000')
		BEGIN
			--If supplier family is tourico then we need to just update isCrowdRateAvailable
			IF(@supplierFamily = 'Tourico')
			BEGIN
				IF(@hotelsComPromoRate > 0)				
				BEGIN
					--PRINT 'HOTELS COM PROMO -  WITH TOURICO'
					UPDATE @hotelResponse
					SET IsCrowdRateAvailable = 1
					,IsPromo = 1
					,PromoRate = @hotelsComPromoRate
					WHERE ID = @hotelResponseId
				END
				ELSE
				BEGIN
					--PRINT 'HOTELS COM DAILY PRICE - WITH TOURICO'
					UPDATE @hotelResponse
					SET IsCrowdRateAvailable = 1
					,PromoRate = @hotelsComDailyPrice					
					WHERE ID = @hotelResponseId	
				END
			END
			ELSE
			BEGIN
				--If supplier family is NOT tourico then we need to update isCrowdRateAvailable as well as hotelResponseKey
				--this is because we need only tourico response id for crowd rate calculation.
				IF(@hotelsComPromoRate > 0)
				BEGIN
					--PRINT 'HOTELS COM PROMO - WITH HOTELS COM'					
					UPDATE @hotelResponse
					SET IsCrowdRateAvailable = 1
					,HotelResponseKey = @crowdHotelResponseKey
					,IsPromo = 1
					,PromoRate = @hotelsComPromoRate
					WHERE ID = @hotelResponseId
				END
				ELSE
				BEGIN
					--PRINT 'HOTELS COM DAILY PRICE - WITH HOTELS COM'
					UPDATE @hotelResponse
					SET IsCrowdRateAvailable = 1
					,HotelResponseKey = @crowdHotelResponseKey
					,PromoRate = @hotelsComDailyPrice
					WHERE ID = @hotelResponseId
				END
			END
		END
		ELSE IF(@gdsPromoRate > 0)
		BEGIN
			--PRINT 'GDS PROMO'
			UPDATE @hotelResponse
			SET IsCrowdRateAvailable = 1			
			,IsPromo = 1
			WHERE ID = @hotelResponseId	
		END
		
		UPDATE @hotelResponse
		SET isUpdated = 1
		WHERE ID = @hotelResponseId
		
		SET @countToExecute += 1	
		 
	END
	--#########END OF CROWD RATE CODE#########--
	
	--DELETE FROM @hotelResponse WHERE DealType = 'U'
	--SELECT * FROM @hotelResponse
			
	SELECT DISTINCT
		VW.DealType
		,HR.hotelResponseKey, HR.supplierHotelKey, HR.hotelRequestKey, HR.supplierId, HR.minRate
		,HT.HotelName, HT.Rating, HT.RatingType, HT.ChainCode, HT.HotelId      
		,HT.Latitude, HT.Longitude, HT.Address1, HT.CityName, HT.StateCode, HT.CountryCode
		,HT.ZipCode, HT.PhoneNumber, HT.FaxNumber, ISNULL(HR.cityCode,HT.CityCode) AS cityCode
		,ISNULL(AH.Distance, 3) AS Distance
		,HQ.checkInDate, HQ.checkOutDate
		,REPLACE(HD.HotelDescription, '', '') AS HotelDescription
		,HC.ChainName
		,HR.minRateTax
		,ISNULL(HotelContent.dbo.HotelImages.SupplierImageURL, CHI.ImageURL) AS ImageURL
		,HR.preferenceOrder, HR.corporateCode,HT.richMediaUrl, ID
		,VW.IsCrowdRateAvailable
		,VW.IsPromo
		,VW.PromoRate
		--,RegionId = 0 --REMOVE THIS REGION ID WHEN UNCOMMENTING BELOW CODE(THIS IS HARD CODED VALUE)
		--"FOR TIME BEING REGION ID IS REMOVED AS WE DONT NEED IT"
		--,HM.RegionId
		,PR.RegionId
		,PR.RegionName
	FROM
		dbo.HotelResponse AS HR WITH (NOLOCK) 
		INNER JOIN @hotelResponse VW 
		ON VW.hotelResponseKey = HR.hotelResponseKey 
		INNER JOIN HotelContent.dbo.SupplierHotels1 AS SH WITH (NOLOCK)
		ON SH.SupplierHotelId = HR.supplierHotelKey 
		AND SH.SupplierFamily = HR.supplierId 
		INNER JOIN HotelContent.dbo.Hotels AS HT WITH (NOLOCK)
		ON SH.HotelId = HT.HotelId 
		LEFT OUTER JOIN HotelContent.dbo.HotelImages WITH (NOLOCK)
		ON HotelContent.dbo.HotelImages.HotelId = HT.HotelId 
		AND HotelContent.dbo.HotelImages.ImageType = 'Exterior' 
		LEFT OUTER JOIN HotelContent.dbo.AirportHotels AS AH WITH (NOLOCK)
		ON HT.HotelId = AH.HotelId 
		AND HT.CityCode = AH.AirportCode 
		LEFT OUTER JOIN dbo.HotelRequest AS HQ WITH (NOLOCK)
		ON HR.hotelRequestKey = HQ.hotelRequestKey 
		LEFT OUTER JOIN HotelContent.dbo.HotelDescriptions AS HD WITH (NOLOCK)
		ON SH.HotelId = HD.HotelId 
		LEFT OUTER JOIN HotelContent.dbo.HotelChains AS HC WITH (NOLOCK)
		ON HT.ChainCode = HC.ChainCode 
		LEFT OUTER JOIN CMS.dbo.CustomHotelImages AS CHI WITH (NOLOCK)
		ON CHI.HotelId = HT.HotelId 
		AND CHI.OrderId = 1 
		LEFT OUTER JOIN HotelContent.dbo.RegionHotelIDMapping RM 
		ON RM.HotelId = HT.HotelId 
		LEFT OUTER JOIN HotelContent.dbo.ParentRegionList PR  
		ON PR.RegionId = RM.RegionId  AND PR.RegionType='Neighborhood'
		--"FOR TIME BEING REGION ID IS REMOVED AS WE DONT NEED IT"
		--LEFT OUTER JOIN HotelContent..RegionHotelIDMapping HM ON HT.HotelId = HM.HotelId
        --WHERE SH.IsDeleted = 0
        
END
	DROP TABLE #tmpHotelResponse
GO
