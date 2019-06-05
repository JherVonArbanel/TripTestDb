SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 29th Sep 2014
-- Description:	This SP derives the winner GDS for Hotel room rate call and gets all the data for that GDS
-- =============================================

--EXEC USP_GetMarketPlaceRoomRateWinner '434E38E4-1B55-4033-AB05-F096258ADFB8'
CREATE PROCEDURE [dbo].[USP_GetMarketPlaceRoomRateWinner_2]
	
	@hotelResponsekey UNIQUEIDENTIFIER
	
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
		[touricoCalculatedBar] [float] NULL
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
			,@IsWinner BIT = 0
	
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
		--If Sabre price is higher than HotelsCom price then ignore Sabre
		IF(@sabrePrice > @hotelsComPrice)
		BEGIN
			
			SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)
			SET @touricoCommission = dbo.udf_GetTouricoCommission(@hotelsComPrice, @operatingCostPercent, @operatingCostValue, @touricoNet)
			
			IF(@eanCommission > @touricoCommission)
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
				DELETE FROM #TmpHotelResponseDetail
				WHERE supplierId <> 'Tourico'
				
				SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
												  (
														@touricoNet
														,@hotelsComPrice
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
				SET hotelDailyPrice = @hotelsComPrice
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
		--END: If Sabre price is higher than HotelsCom price then ignore Sabre
		--If Sabre price is LESS than HotelsCom price then ignore HotelsCom
		ELSE IF(@hotelsComPrice > @sabrePrice)
		BEGIN
			SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)
			SET @touricoCommission = dbo.udf_GetTouricoCommission(@sabrePrice, @operatingCostPercent, @operatingCostValue, @touricoNet)
			
			IF(@sabreCommission > @touricoCommission)
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
			ELSE
			BEGIN				
				DELETE FROM #TmpHotelResponseDetail
				WHERE supplierId <> 'Tourico'
				
				SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
												  (
														@touricoNet
														,@sabrePrice
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
				SET hotelDailyPrice = @sabrePrice
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
		--END: If Sabre price is LESS than HotelsCom price then ignore HotelsCom
		--If Sabre price and HotelsCom price are same
		ELSE IF(@sabrePrice = @hotelsComPrice)
		BEGIN
			SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)
			SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)
			SET @touricoCommission = dbo.udf_GetTouricoCommission(@hotelsComPrice, @operatingCostPercent, @operatingCostValue, @touricoNet)
			
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
			ELSE
			BEGIN
				DELETE FROM #TmpHotelResponseDetail
				WHERE supplierId <> 'Tourico'
				
				SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
												  (
														@touricoNet
														,@hotelsComPrice
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
				SET hotelDailyPrice = @hotelsComPrice
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
						
		END
		--END: If Sabre price and HotelsCom price are same
		
		Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected
		
    END
    --END: If we get results for all 3 GDS
    --If EAN and Sabre Price is available AND Tourico price is not available
    ELSE IF(@sabrePrice > 0 AND @hotelsComPrice > 0 AND @touricoPrice = 0)
    BEGIN
		IF(@hotelsComPrice < @sabrePrice)
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
		Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected
    END
    --END: If EAN and Sabre Price is available AND Tourico price is not available
    --If Sabre and Tourico is availble but EAN is not available
    ELSE IF(@sabrePrice > 0 AND @touricoPrice > 0 AND @hotelsComPrice = 0)
    BEGIN
		IF(@sabrePrice < @touricoPrice)
		BEGIN
			SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)
			SET @touricoCommission = dbo.udf_GetTouricoCommission(@sabrePrice, @operatingCostPercent, @operatingCostValue, @touricoNet)
			
			IF(@sabreCommission > @touricoCommission)
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
			ELSE
			BEGIN
				DELETE FROM #TmpHotelResponseDetail
				WHERE supplierId <> 'Tourico'
				
				SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
												  (
														@touricoNet
														,@hotelsComPrice
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
				SET hotelDailyPrice = @hotelsComPrice
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
			
			Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected
		END
    END
    --END: If Sabre and Tourico is availble but EAN is not available
    --If EAN and Tourico is availble but Sabre is not available
    ELSE IF(@hotelsComPrice > 0 AND @touricoPrice > 0 AND @sabrePrice = 0)
    BEGIN		
		SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)
		SET @touricoCommission = dbo.udf_GetTouricoCommission(@hotelsComPrice, @operatingCostPercent, @operatingCostValue, @touricoNet)
		
		IF(@eanCommission > @touricoCommission)
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
			
			DELETE FROM #TmpHotelResponseDetail
			WHERE supplierId <> 'Tourico'
			
			SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
												  (
														@touricoNet
														,@hotelsComPrice
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
			SET hotelDailyPrice = @hotelsComPrice
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
		
		Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected	
    END
    --END: If EAN and Tourico is availble but Sabre is not available
    --If only TOURICO is available
    ELSE IF(@touricoPrice > 0 AND @sabrePrice = 0 AND @hotelsComPrice = 0)
    BEGIN
		DELETE FROM #TmpHotelResponseDetail
		WHERE supplierId <> 'Tourico'
		
		SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar
												(
													@touricoMarkupPercent
													,@touricoNet	
												)
		
		SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent
												  (
														@touricoNet
														,@touricoBarCalculatedFromRoomRate
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
		SET hotelDailyPrice = @touricoCalculatedBar
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
		
		Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected
    END
    --END: If only TOURICO is available
    --If only SABRE is available
    ELSE IF(@sabrePrice > 0 AND @touricoPrice = 0 AND @hotelsComPrice = 0)
    BEGIN
		SELECT * FROM HotelResponseDetail
		WHERE supplierId = 'Sabre'
		AND hotelResponseKey = @hotelResponsekey
		AND (rateDescription NOT LIKE ('%A A A%') 
		AND rateDescription NOT LIKE ('%AAA%') 
		AND rateDescription NOT LIKE ('%SENIOR%') 
		AND rateDescription NOT LIKE ('%GOV%'))
		ORDER BY hotelDailyPrice ASC
		
		Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected
    END
    --END: If only SABRE is available
    --If only HOTELSCOM is available
    ELSE IF(@hotelsComPrice > 0 AND @sabrePrice = 0 AND @touricoPrice = 0)
    BEGIN
		SELECT * FROM HotelResponseDetail
		WHERE supplierId = 'Hotelscom'
		AND hotelResponseKey = @hotelResponsekey
		AND (rateDescription NOT LIKE ('%A A A%') 
		AND rateDescription NOT LIKE ('%AAA%') 
		AND rateDescription NOT LIKE ('%SENIOR%') 
		AND rateDescription NOT LIKE ('%GOV%'))
		ORDER BY hotelDailyPrice ASC	
		
		Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected
    END
    --END: If only HOTELSCOM is available
    
   -- --Get marketplace calculated values to show on hoteldetails page 
   IF(@IsWinner =1)
   Begin
    Select	isnull(@hotelsComPrice ,0) as  EANBar,isnull(@touricoNet ,0) as  TouricoNet,isnull(@sabrePrice ,0) as  SabreBar
			,isnull(@touricoCalculatedBar ,0) as  TouricoCalculatedBar,isnull(@eanCommission ,0) as  EANCommission
			,isnull(@touricoCommission ,0) as  TouricoCommission,isnull(@sabreCommission ,0) as  SabreCommission,isnull(@touricoActualMarkupPercent ,0) as  TouricoActualMarkupPercent
	End			
END

DROP TABLE #TmpHotelResponseDetail
GO
