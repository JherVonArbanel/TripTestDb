SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 1st Oct 2014
-- Description:	WILL RETURN CROWD DETAILS RATE
-- =============================================
--EXEC USP_GetDealHotelDetailsByResponseID 'A59EBC73-939A-49DD-9423-7792C9C49343'
CREATE PROCEDURE [dbo].[USP_GetDealHotelDetailsByResponseID_2] 
	
	@hotelResponseKey UNIQUEIDENTIFIER
AS
BEGIN	
	SET NOCOUNT ON;
	
	--Declare temporary table for hotelResponseDetailData
	CREATE TABLE #TmpHotelResponseDetail
	(
		[hotelResponseDetailKey] [uniqueidentifier] NOT NULL,
		[hotelResponseKey] [uniqueidentifier] NOT NULL,
		[hotelDailyPrice] [float] NOT NULL,
		[numberOfNights] [int] NULL,
		[supplierId] [varchar](20) NOT NULL,		
		[hotelTotalPrice] [float] NULL,		
		[hotelTaxRate] [float] NULL,
		[touricoNetRate] [float] NULL,
		[displayPrice] [float] NULL,
		[touricoCalculatedBar] [float] NULL,
		[crowdPrice] [float] NULL
	)
	
	--Declare variable table for storing marketplace GDS values
	DECLARE @VtblMarketPlaceVariablesGDS AS TABLE
	(
		[MarketPlaceVariablesId] [int] NOT NULL,
		[GDSId] [int] NOT NULL,
		[IsFeedOn] [bit] NULL,
		[IsNetRateFeed] [bit] NULL,
		[BARMarkupPer] [float] NULL,
		[BARMarkup] [float] NULL,
		[CrowdFloorMarkupPer] [float] NULL
	)
	
	--Variable Declaration
	DECLARE @gdsResponseCount INT = 0
			,@sabrePrice FLOAT = 0
			,@touricoPrice FLOAT = 0
			,@hotelsComPrice FLOAT = 0
			,@operatingCostPercent FLOAT
			,@operatingCostValue FLOAT
			,@marketPlaceVariableId INT
			,@sabreCommissionPercent INT
			,@hotelsComCommissionPercent FLOAT
			,@eanCommission FLOAT = 0
			,@touricoCommission FLOAT = 0
			,@sabreCommission FLOAT = 0
			,@hotelResponseDetailKeyTourico UNIQUEIDENTIFIER
			,@hotelResponseDetailKeyEan UNIQUEIDENTIFIER
			,@hotelResponseDetailKeySabre UNIQUEIDENTIFIER
			,@touricoNet FLOAT = 0
			,@winner VARCHAR(20)
			,@touricoCalculatedBar FLOAT = 0
			,@touricoActualMarkupPercent FLOAT
			,@displayPrice FLOAT = 0
			,@touricoBarCalculatedFromRoomRate FLOAT = 0
			,@touricoMarkupPercent FLOAT
			,@crowdPrice FLOAT = 0
			,@touricoCostBasisForCrowd FLOAT = 0
			,@touricoFloorMarkupPercent FLOAT = 0
	
	--Insert selected data from HotelResponseDetail based on hotelResponseKey
	INSERT INTO #TmpHotelResponseDetail
	(
		hotelResponseDetailKey
		,hotelResponseKey
		,hotelDailyPrice
		,numberOfNights
		,supplierId	
		,hotelTotalPrice
		,hotelTaxRate
		,touricoNetRate
		,displayPrice
		,touricoCalculatedBar
		,crowdPrice
	)
	SELECT 
		hotelResponseDetailKey
		,hotelResponseKey
		,hotelDailyPrice
		,numberOfNights
		,supplierId	
		,hotelTotalPrice
		,hotelTaxRate
		,touricoNetRate
		,displayPrice
		,touricoCalculationBarRate
		,crowdPrice
	FROM HotelResponseDetail
	WHERE hotelResponseKey = @hotelResponsekey
	AND (rateDescription NOT LIKE ('%A A A%') 
	AND rateDescription NOT LIKE ('%AAA%') 
	AND rateDescription NOT LIKE ('%SENIOR%') 
	AND rateDescription NOT LIKE ('%GOV%'))	
	
	--Set common marketplace values
	SELECT
	@operatingCostPercent = OperatingCostPer
	,@operatingCostValue = OperatingCost
	,@marketPlaceVariableId = Id
	FROM vault.dbo.MarketPlaceVariables
	WHERE IsActive = 1
	
	--Insert individual GDS values
	INSERT INTO @VtblMarketPlaceVariablesGDS
	(
		[MarketPlaceVariablesId]
		,[GDSId] 
		,[IsFeedOn]
		,[IsNetRateFeed]
		,[BARMarkupPer]
		,[BARMarkup] 
		,[CrowdFloorMarkupPer] 
	)
	SELECT
		[MarketPlaceVariablesId]
		,[GDSId] 
		,[IsFeedOn]
		,[IsNetRateFeed]
		,[BARMarkupPer]
		,[BARMarkup] 
		,[CrowdFloorMarkupPer] 
	FROM vault.dbo.MarketPlaceVariablesGDS
	WHERE MarketPlaceVariablesId = @marketPlaceVariableId
	
	--EAN marketplace values
	SELECT 
	@hotelsComCommissionPercent = BARMarkupPer
	FROM @VtblMarketPlaceVariablesGDS
	WHERE GDSId = 1	
	
	--SABRE marketplace values
	SELECT 
	@sabreCommissionPercent = BARMarkupPer
	FROM @VtblMarketPlaceVariablesGDS
	WHERE GDSId = 4	
	
	--TOURICO marketplace values
	SELECT 
	@touricoMarkupPercent = BARMarkupPer
	,@touricoFloorMarkupPercent = CrowdFloorMarkupPer
	FROM @VtblMarketPlaceVariablesGDS
	WHERE GDSId = 5	
	
	--Get the lowest price for HotelsCom
	SELECT TOP 1
		@hotelsComPrice = ISNULL(hotelDailyPrice,0)
		,@hotelResponseDetailKeyEan = hotelResponseDetailKey		
		FROM #TmpHotelResponseDetail
		WHERE supplierId = 'HotelsCom'
		AND hotelResponseKey = @hotelResponsekey
		ORDER BY hotelDailyPrice ASC
	
	--Get the lowest price for Tourico
	SELECT TOP 1
		@touricoPrice = ISNULL(hotelDailyPrice,0)
		,@hotelResponseDetailKeyTourico = hotelResponseDetailKey
		,@touricoNet = touricoNetRate
		,@touricoCalculatedBar = touricoCalculatedBar
		,@displayPrice = displayPrice
		,@crowdPrice = ISNULL(crowdPrice, 0)
		FROM #TmpHotelResponseDetail
		WHERE supplierId = 'Tourico'
		AND hotelResponseKey = @hotelResponsekey
		ORDER BY hotelDailyPrice ASC
	
	--Get the lowest price for Sabre
	SELECT TOP 1
		@sabrePrice = ISNULL(hotelDailyPrice,0)
		,@hotelResponseDetailKeySabre = hotelResponseDetailKey		
		FROM #TmpHotelResponseDetail
		WHERE supplierId = 'Sabre'
		AND hotelResponseKey = @hotelResponsekey
		ORDER BY hotelDailyPrice ASC
	
	--If we get results for all 3 GDS
	IF(@sabrePrice > 0 AND @touricoPrice > 0 AND @hotelsComPrice > 0)
	BEGIN
		--If we have a tourico crowd price
		IF(@crowdPrice > 0)
		BEGIN
			--If crowd price(derived from tourico price) is the lowest
			IF((@crowdPrice < @sabrePrice) AND (@crowdPrice < @hotelsComPrice))
			BEGIN
				DELETE FROM #TmpHotelResponseDetail
				WHERE supplierId <> 'Tourico'
				SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
												  (
														@touricoNet
														,@crowdPrice
												   )
				UPDATE THD
				SET THD.hotelDailyPrice = dbo.udf_GetTouricoMarkupValue
									  (
										SHD.touricoNetRate
										,@touricoActualMarkupPercent										
									  )
				FROM #TmpHotelResponseDetail THD
				INNER JOIN #TmpHotelResponseDetail SHD
				ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
							
				UPDATE #TmpHotelResponseDetail
				SET hotelDailyPrice = @crowdPrice
				WHERE hotelResponseDetailKey = @hotelResponseDetailKeyTourico
				
				UPDATE THD
				SET THD.hotelTotalPrice = dbo.udf_GetTouricoHotelTotalPrice
										  (
											SHD.hotelDailyPrice
											,SHD.numberOfNights
											,SHD.hotelTaxRate 
										  )
				FROM #TmpHotelResponseDetail THD
				INNER JOIN #TmpHotelResponseDetail SHD
				ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
				
				UPDATE HRD
				SET HRD.hotelDailyPrice = THD.hotelDailyPrice
				,HRD.hotelTotalPrice = THD.hotelTotalPrice
				FROM HotelResponseDetail HRD
				INNER JOIN #TmpHotelResponseDetail THD
				ON THD.hotelResponseDetailKey = HRD.hotelResponseDetailKey
				
				SELECT * FROM HotelResponseDetail
				WHERE supplierId = 'Tourico'
				AND hotelResponseKey = @hotelResponsekey
				AND (rateDescription NOT LIKE ('%A A A%') 
				AND rateDescription NOT LIKE ('%AAA%') 
				AND rateDescription NOT LIKE ('%SENIOR%') 
				AND rateDescription NOT LIKE ('%GOV%'))
				ORDER BY hotelDailyPrice ASC									   
			END
			--END: If crowd price(derived from tourico price) is the lowest
			--WHEN CROWD PRICE IS NOT THE LOWEST PRICE
			ELSE
			BEGIN				
				SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)
				SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)
				
				IF(@eanCommission > @sabreCommission)
				BEGIN
					SELECT * FROM HotelResponseDetail
					WHERE supplierId = 'Hotelscom'
					AND hotelResponseKey = @hotelResponsekey
					AND (rateDescription NOT LIKE ('%A A A%') 
					AND rateDescription NOT LIKE ('%AAA%') 
					AND rateDescription NOT LIKE ('%SENIOR%') 
					AND rateDescription NOT LIKE ('%GOV%'))
					ORDER BY hotelDailyPrice ASC
				END
				ELSE
				BEGIN
					SELECT * FROM HotelResponseDetail
					WHERE supplierId = 'Sabre'
					AND hotelResponseKey = @hotelResponsekey
					AND (rateDescription NOT LIKE ('%A A A%') 
					AND rateDescription NOT LIKE ('%AAA%') 
					AND rateDescription NOT LIKE ('%SENIOR%') 
					AND rateDescription NOT LIKE ('%GOV%'))
					ORDER BY hotelDailyPrice ASC
				END
				
			END
			--END: WHEN CROWD PRICE IS NOT THE LOWEST PRICE
		END
		--END: If we have a tourico crowd price
		--If we dont have tourico crowd price
		ELSE
		BEGIN
			SET @touricoCostBasisForCrowd = dbo.udf_GetTouricoCostBasisForCrowd
											(
												@touricoNet
												,@touricoFloorMarkupPercent
												,@operatingCostPercent
												,@operatingCostValue
											)
											
			SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)
			SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)
			SET @touricoCommission = dbo.udf_GetTouricoCommission(@touricoCostBasisForCrowd, @operatingCostPercent, @operatingCostValue, @touricoNet)	
			
			--Use case to decide the winner based on commission
			SET @winner =  
			CASE WHEN @sabreCommission > @eanCommission 
				 AND @sabreCommission > @touricoCommission 
				 THEN 'Sabre'
				 WHEN @eanCommission > @sabreCommission
				 AND @eanCommission > @touricoCommission
				 THEN 'Hotelscom'
				 WHEN @touricoCommission > @sabreCommission
				 AND @touricoCommission > @eanCommission
				 THEN 'Tourico'
				 ELSE 'Hotelscom'
			END
			--END: Use case to decide the winner based on commission
			
			--If the winner is other than tourico
			IF(@winner <> 'Tourico')
			BEGIN
				SELECT * FROM HotelResponseDetail
				WHERE supplierId = @winner
				AND hotelResponseKey = @hotelResponsekey
				AND (rateDescription NOT LIKE ('%A A A%') 
				AND rateDescription NOT LIKE ('%AAA%') 
				AND rateDescription NOT LIKE ('%SENIOR%') 
				AND rateDescription NOT LIKE ('%GOV%'))
				ORDER BY hotelDailyPrice ASC
			END
			--END: If the winner is other than tourico
			--If the winner is tourico
			ELSE
			BEGIN
				DELETE FROM #TmpHotelResponseDetail
				WHERE supplierId <> 'Tourico'
				
				SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
												  (
														@touricoNet
														,@touricoCostBasisForCrowd
												   )
				
				UPDATE THD
				SET THD.hotelDailyPrice = dbo.udf_GetTouricoMarkupValue
									  (
										SHD.touricoNetRate
										,@touricoActualMarkupPercent										
									  )
				FROM #TmpHotelResponseDetail THD
				INNER JOIN #TmpHotelResponseDetail SHD
				ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
							
				UPDATE #TmpHotelResponseDetail
				SET hotelDailyPrice = @touricoCostBasisForCrowd
				WHERE hotelResponseDetailKey = @hotelResponseDetailKeyTourico
				
				UPDATE THD
				SET THD.hotelTotalPrice = dbo.udf_GetTouricoHotelTotalPrice
										  (
											SHD.hotelDailyPrice
											,SHD.numberOfNights
											,SHD.hotelTaxRate 
										  )
				FROM #TmpHotelResponseDetail THD
				INNER JOIN #TmpHotelResponseDetail SHD
				ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
				
				UPDATE HRD
				SET HRD.hotelDailyPrice = THD.hotelDailyPrice
				,HRD.hotelTotalPrice = THD.hotelTotalPrice
				FROM HotelResponseDetail HRD
				INNER JOIN #TmpHotelResponseDetail THD
				ON THD.hotelResponseDetailKey = HRD.hotelResponseDetailKey
				
				SELECT * FROM HotelResponseDetail
				WHERE supplierId = @winner
				AND hotelResponseKey = @hotelResponsekey
				AND (rateDescription NOT LIKE ('%A A A%') 
				AND rateDescription NOT LIKE ('%AAA%') 
				AND rateDescription NOT LIKE ('%SENIOR%') 
				AND rateDescription NOT LIKE ('%GOV%'))
				ORDER BY hotelDailyPrice ASC	
			END
			--END: If the winner is tourico
			
		END
		--END: If we dont have tourico crowd price
	END
	--END: If we get results for all 3 GDS
	--If SABRE price is not available
	ELSE IF(@hotelsComPrice > 0 AND @touricoPrice > 0 AND @sabrePrice = 0)
	BEGIN
		--If we have a tourico crowd price
		IF(@crowdPrice > 0)
		BEGIN
			--If crowd price(derived from tourico price) is the lowest
			IF(@crowdPrice < @hotelsComPrice)
			BEGIN
				DELETE FROM #TmpHotelResponseDetail
				WHERE supplierId <> 'Tourico'
				
				SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
												  (
														@touricoNet
														,@crowdPrice
												   )
				UPDATE THD
				SET THD.hotelDailyPrice = dbo.udf_GetTouricoMarkupValue
										  (
											SHD.touricoNetRate
											,@touricoActualMarkupPercent										
										  )
				FROM #TmpHotelResponseDetail THD
				INNER JOIN #TmpHotelResponseDetail SHD
				ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
							
				UPDATE #TmpHotelResponseDetail
				SET hotelDailyPrice = @crowdPrice
				WHERE hotelResponseDetailKey = @hotelResponseDetailKeyTourico
				
				UPDATE THD
				SET THD.hotelTotalPrice = dbo.udf_GetTouricoHotelTotalPrice
										  (
											SHD.hotelDailyPrice
											,SHD.numberOfNights
											,SHD.hotelTaxRate 
										  )
				FROM #TmpHotelResponseDetail THD
				INNER JOIN #TmpHotelResponseDetail SHD
				ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
				
				UPDATE HRD
				SET HRD.hotelDailyPrice = THD.hotelDailyPrice
				,HRD.hotelTotalPrice = THD.hotelTotalPrice
				FROM HotelResponseDetail HRD
				INNER JOIN #TmpHotelResponseDetail THD
				ON THD.hotelResponseDetailKey = HRD.hotelResponseDetailKey
				
				SELECT * FROM HotelResponseDetail
				WHERE supplierId = 'Tourico'
				AND hotelResponseKey = @hotelResponsekey
				AND (rateDescription NOT LIKE ('%A A A%') 
				AND rateDescription NOT LIKE ('%AAA%') 
				AND rateDescription NOT LIKE ('%SENIOR%') 
				AND rateDescription NOT LIKE ('%GOV%'))
				ORDER BY hotelDailyPrice ASC									   
			END
			--END: If crowd price(derived from tourico price) is the lowest
			--WHEN CROWD PRICE IS NOT THE LOWEST PRICE
			ELSE
			BEGIN
				SELECT * FROM HotelResponseDetail
				WHERE supplierId = 'Hotelscom'
				AND hotelResponseKey = @hotelResponsekey
				AND (rateDescription NOT LIKE ('%A A A%') 
				AND rateDescription NOT LIKE ('%AAA%') 
				AND rateDescription NOT LIKE ('%SENIOR%') 
				AND rateDescription NOT LIKE ('%GOV%'))
				ORDER BY hotelDailyPrice ASC
			END
			--END: WHEN CROWD PRICE IS NOT THE LOWEST PRICE
		END
		--END: If we have a tourico crowd price	
		--If we dont have tourico crowd price
		ELSE
		BEGIN
			SELECT * FROM HotelResponseDetail
			WHERE supplierId = 'Hotelscom'
			AND hotelResponseKey = @hotelResponsekey
			AND (rateDescription NOT LIKE ('%A A A%') 
			AND rateDescription NOT LIKE ('%AAA%') 
			AND rateDescription NOT LIKE ('%SENIOR%') 
			AND rateDescription NOT LIKE ('%GOV%'))
			ORDER BY hotelDailyPrice ASC
		END
		--END: If we dont have tourico crowd price
	END
	--END: If hotels com price is not available
	--IF HOTELS COM PRICE IS NOT AVAILABLE
	ELSE IF(@touricoPrice > 0 AND @sabrePrice > 0 AND @hotelsComPrice = 0 )
	BEGIN
		--If we have a tourico crowd price
		IF(@crowdPrice > 0)
		BEGIN
			--If crowd price(derived from tourico price) is the lowest
			IF(@crowdPrice < @sabrePrice)
			BEGIN
				DELETE FROM #TmpHotelResponseDetail
				WHERE supplierId <> 'Tourico'
				
				SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
												  (
														@touricoNet
														,@crowdPrice
												   )
				UPDATE THD
				SET THD.hotelDailyPrice = dbo.udf_GetTouricoMarkupValue
									  (
										SHD.touricoNetRate
										,@touricoActualMarkupPercent										
									  )
				FROM #TmpHotelResponseDetail THD
				INNER JOIN #TmpHotelResponseDetail SHD
				ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
							
				UPDATE #TmpHotelResponseDetail
				SET hotelDailyPrice = @crowdPrice
				WHERE hotelResponseDetailKey = @hotelResponseDetailKeyTourico
				
				UPDATE THD
				SET THD.hotelTotalPrice = dbo.udf_GetTouricoHotelTotalPrice
										  (
											SHD.hotelDailyPrice
											,SHD.numberOfNights
											,SHD.hotelTaxRate 
										  )
				FROM #TmpHotelResponseDetail THD
				INNER JOIN #TmpHotelResponseDetail SHD
				ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
				
				UPDATE HRD
				SET HRD.hotelDailyPrice = THD.hotelDailyPrice
				,HRD.hotelTotalPrice = THD.hotelTotalPrice
				FROM HotelResponseDetail HRD
				INNER JOIN #TmpHotelResponseDetail THD
				ON THD.hotelResponseDetailKey = HRD.hotelResponseDetailKey
				
				SELECT * FROM HotelResponseDetail
				WHERE supplierId = 'Tourico'
				AND hotelResponseKey = @hotelResponsekey
				AND (rateDescription NOT LIKE ('%A A A%') 
				AND rateDescription NOT LIKE ('%AAA%') 
				AND rateDescription NOT LIKE ('%SENIOR%') 
				AND rateDescription NOT LIKE ('%GOV%'))
				ORDER BY hotelDailyPrice ASC									   
			END
			--END: If crowd price(derived from tourico price) is the lowest
			--WHEN CROWD PRICE IS NOT THE LOWEST PRICE
			ELSE
			BEGIN
				SELECT * FROM HotelResponseDetail
				WHERE supplierId = 'Sabre'
				AND hotelResponseKey = @hotelResponsekey
				AND (rateDescription NOT LIKE ('%A A A%') 
				AND rateDescription NOT LIKE ('%AAA%') 
				AND rateDescription NOT LIKE ('%SENIOR%') 
				AND rateDescription NOT LIKE ('%GOV%'))
				ORDER BY hotelDailyPrice ASC
			END
			--END: WHEN CROWD PRICE IS NOT THE LOWEST PRICE
		END
		--END: If we have a tourico crowd price
		--If we dont have tourico crowd price
		ELSE
		BEGIN
			SELECT * FROM HotelResponseDetail
			WHERE supplierId = 'Sabre'
			AND hotelResponseKey = @hotelResponsekey
			AND (rateDescription NOT LIKE ('%A A A%') 
			AND rateDescription NOT LIKE ('%AAA%') 
			AND rateDescription NOT LIKE ('%SENIOR%') 
			AND rateDescription NOT LIKE ('%GOV%'))
			ORDER BY hotelDailyPrice ASC
		END	
		--END: If we dont have tourico crowd price
	END
    --END: IF HOTELS COM PRICE IS NOT AVAILABLE
    --IF TOURICO PRICE IS NOT AVAILABLE
    ELSE IF(@sabrePrice > 0 AND @hotelsComPrice > 0 AND @touricoPrice = 0)
    BEGIN
		SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)
		SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)
		
		IF(@eanCommission > @sabreCommission)
		BEGIN
			SELECT * FROM HotelResponseDetail
			WHERE supplierId = 'Hotelscom'
			AND hotelResponseKey = @hotelResponsekey
			AND (rateDescription NOT LIKE ('%A A A%') 
			AND rateDescription NOT LIKE ('%AAA%') 
			AND rateDescription NOT LIKE ('%SENIOR%') 
			AND rateDescription NOT LIKE ('%GOV%'))
			ORDER BY hotelDailyPrice ASC
		END
		ELSE
		BEGIN
			SELECT * FROM HotelResponseDetail
			WHERE supplierId = 'Sabre'
			AND hotelResponseKey = @hotelResponsekey
			AND (rateDescription NOT LIKE ('%A A A%') 
			AND rateDescription NOT LIKE ('%AAA%') 
			AND rateDescription NOT LIKE ('%SENIOR%') 
			AND rateDescription NOT LIKE ('%GOV%'))
			ORDER BY hotelDailyPrice ASC
		END	
    END
    --END: IF TOURICO PRICE IS NOT AVAILABLE
    --If only hotels com is available
    ELSE IF(@hotelsComPrice > 0 AND @touricoPrice = 0 AND @sabrePrice = 0)
    BEGIN
		SELECT * FROM HotelResponseDetail
		WHERE supplierId = 'Hotelscom'
		AND hotelResponseKey = @hotelResponsekey
		AND (rateDescription NOT LIKE ('%A A A%') 
		AND rateDescription NOT LIKE ('%AAA%') 
		AND rateDescription NOT LIKE ('%SENIOR%') 
		AND rateDescription NOT LIKE ('%GOV%'))
		ORDER BY hotelDailyPrice ASC
    END
    --END: If only hotels com is available
    --If only tourico is available
    ELSE IF(@sabrePrice = 0 AND @hotelsComPrice = 0 AND @touricoPrice > 0)
    BEGIN
		IF(@crowdPrice > 0)
		BEGIN
			DELETE FROM #TmpHotelResponseDetail
			WHERE supplierId <> 'Tourico'
			
			SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
											  (
													@touricoNet
													,@crowdPrice
											   )
			UPDATE THD
			SET THD.hotelDailyPrice = dbo.udf_GetTouricoMarkupValue
								  (
									SHD.touricoNetRate
									,@touricoActualMarkupPercent										
								  )
			FROM #TmpHotelResponseDetail THD
			INNER JOIN #TmpHotelResponseDetail SHD
			ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
						
			UPDATE #TmpHotelResponseDetail
			SET hotelDailyPrice = @crowdPrice
			WHERE hotelResponseDetailKey = @hotelResponseDetailKeyTourico
			
			UPDATE THD
			SET THD.hotelTotalPrice = dbo.udf_GetTouricoHotelTotalPrice
									  (
										SHD.hotelDailyPrice
										,SHD.numberOfNights
										,SHD.hotelTaxRate 
									  )
			FROM #TmpHotelResponseDetail THD
			INNER JOIN #TmpHotelResponseDetail SHD
			ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
			
			UPDATE HRD
			SET HRD.hotelDailyPrice = THD.hotelDailyPrice
			,HRD.hotelTotalPrice = THD.hotelTotalPrice
			FROM HotelResponseDetail HRD
			INNER JOIN #TmpHotelResponseDetail THD
			ON THD.hotelResponseDetailKey = HRD.hotelResponseDetailKey
			
			SELECT * FROM HotelResponseDetail
			WHERE supplierId = 'Tourico'
			AND hotelResponseKey = @hotelResponsekey
			AND (rateDescription NOT LIKE ('%A A A%') 
			AND rateDescription NOT LIKE ('%AAA%') 
			AND rateDescription NOT LIKE ('%SENIOR%') 
			AND rateDescription NOT LIKE ('%GOV%'))
			ORDER BY hotelDailyPrice ASC									   
		END
		ELSE
		BEGIN
			DELETE FROM #TmpHotelResponseDetail
			WHERE supplierId <> 'Tourico'
			
			SET @touricoCostBasisForCrowd = dbo.udf_GetTouricoCostBasisForCrowd
											(
												@touricoNet
												,@touricoFloorMarkupPercent
												,@operatingCostPercent
												,@operatingCostValue
											)
			
			SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
											  (
													@touricoNet
													,@touricoCostBasisForCrowd
											   )
			UPDATE THD
			SET THD.hotelDailyPrice = dbo.udf_GetTouricoMarkupValue
								  (
									SHD.touricoNetRate
									,@touricoActualMarkupPercent										
								  )
			FROM #TmpHotelResponseDetail THD
			INNER JOIN #TmpHotelResponseDetail SHD
			ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
						
			UPDATE #TmpHotelResponseDetail
			SET hotelDailyPrice = @touricoCostBasisForCrowd
			WHERE hotelResponseDetailKey = @hotelResponseDetailKeyTourico
			
			UPDATE THD
			SET THD.hotelTotalPrice = dbo.udf_GetTouricoHotelTotalPrice
									  (
										SHD.hotelDailyPrice
										,SHD.numberOfNights
										,SHD.hotelTaxRate 
									  )
			FROM #TmpHotelResponseDetail THD
			INNER JOIN #TmpHotelResponseDetail SHD
			ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey
			
			UPDATE HRD
			SET HRD.hotelDailyPrice = THD.hotelDailyPrice
			,HRD.hotelTotalPrice = THD.hotelTotalPrice
			FROM HotelResponseDetail HRD
			INNER JOIN #TmpHotelResponseDetail THD
			ON THD.hotelResponseDetailKey = HRD.hotelResponseDetailKey
			
			SELECT * FROM HotelResponseDetail
			WHERE supplierId = 'Tourico'
			AND hotelResponseKey = @hotelResponsekey
			AND (rateDescription NOT LIKE ('%A A A%') 
			AND rateDescription NOT LIKE ('%AAA%') 
			AND rateDescription NOT LIKE ('%SENIOR%') 
			AND rateDescription NOT LIKE ('%GOV%'))
			ORDER BY hotelDailyPrice ASC
		END
    END
    --END: If only tourico is available
    --If only Sabre is available
    ELSE IF(@sabrePrice > 0 AND @hotelsComPrice = 0 AND @touricoPrice = 0)
    BEGIN
		SELECT * FROM HotelResponseDetail
		WHERE supplierId = 'Sabre'
		AND hotelResponseKey = @hotelResponsekey
		AND (rateDescription NOT LIKE ('%A A A%') 
		AND rateDescription NOT LIKE ('%AAA%') 
		AND rateDescription NOT LIKE ('%SENIOR%') 
		AND rateDescription NOT LIKE ('%GOV%'))
		ORDER BY hotelDailyPrice ASC
    END
    --END: If only Sabre is available
    
    -- --Get marketplace calculated values to show on hoteldetails page 
   --IF(@IsWinner =1)
   --Begin
    Select	isnull(@hotelsComPrice ,0) as  EANBar,isnull(@touricoNet ,0) as  TouricoNet,isnull(@sabrePrice ,0) as  SabreBar
			,isnull(@touricoCalculatedBar ,0) as  TouricoCalculatedBar,isnull(@eanCommission ,0) as  EANCommission
			,isnull(@touricoCommission ,0) as  TouricoCommission,isnull(@sabreCommission ,0) as  SabreCommission,isnull(@touricoActualMarkupPercent ,0) as  TouricoActualMarkupPercent
			,CrowdPrice = @crowdPrice, TouricoFloor = @touricoCostBasisForCrowd
	--End
    
END
DROP TABLE #TmpHotelResponseDetail
GO
