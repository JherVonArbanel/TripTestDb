SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 3rd Oct 2014
-- Description:	WILL RETURN CROWD DETAILS RATE
-- =============================================
--EXEC USP_GetDealHotelDetailsByResponseID 'B7D9F1A5-CECB-418C-9AFA-A97EEACF5BFC', 1

/*#######-- VERY IMPORTANT INFORMATION --####################################
THIS STORED PROCEDURE IS USED IN LIST PAGE CROWD PRICE DETAILS CALL
AND HOTEL NIGHTLY ROBOT. ANY CHANGES MADE HERE WILL AFFECT BOTH THE
PROCESS. MAKE SURE BOTH THINGS ARE WORKING PROPERLY AFTER MAKING ANY CHANGE
##################################################################*/

CREATE PROCEDURE [dbo].[USP_GetDealHotelDetailsByResponseID] 
	
	@hotelResponseKey UNIQUEIDENTIFIER
	,@isNightlyRobotCall BIT = 0
	,@environment VARCHAR(20) = 'D'
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
	DECLARE @sabrePrice FLOAT = 0
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
		,originalHotelDailyPrice
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
	FROM vault.dbo.MarketPlaceVariablesGDS WITH (NOLOCK)
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
	IF(@isNightlyRobotCall = 0)
	BEGIN
	SELECT TOP 1
		@touricoPrice = ISNULL(touricoCalculatedBar,0)
		,@hotelResponseDetailKeyTourico = hotelResponseDetailKey
		,@touricoNet = touricoNetRate
		,@touricoCalculatedBar = touricoCalculatedBar
		,@displayPrice = displayPrice
		,@crowdPrice = ISNULL(crowdPrice, 0)
		FROM #TmpHotelResponseDetail
		WHERE supplierId = 'Tourico'
		AND hotelResponseKey = @hotelResponsekey
		ORDER BY hotelDailyPrice ASC
	END
	ELSE
	BEGIN
		SELECT TOP 1
		@touricoPrice = ISNULL(touricoCalculatedBar,0)
		,@hotelResponseDetailKeyTourico = hotelResponseDetailKey
		,@touricoNet = touricoNetRate
		,@touricoCalculatedBar = touricoCalculatedBar
		,@displayPrice = displayPrice		
		FROM #TmpHotelResponseDetail
		WHERE supplierId = 'Tourico'
		AND hotelResponseKey = @hotelResponsekey
		ORDER BY hotelDailyPrice ASC
		
		SELECT @crowdPrice = ISNULL(CrowdRate, 0)
		FROM TmpHotelResponse
		WHERE HotelResponseKey = @hotelResponsekey
		
	END
	
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
				EXEC USP_GetMarketplaceWinnerData
					 @winner = 'Tourico'
					 ,@hotelResponsekey = @hotelResponsekey
					 ,@isNightlyRobotCall = @isNightlyRobotCall
					 ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico
					 ,@gdsPrice = @crowdPrice
					 ,@touricoNet = @touricoNet
					 ,@environment = @environment				   
			END
			--END: If crowd price(derived from tourico price) is the lowest
			--WHEN CROWD PRICE IS NOT THE LOWEST PRICE
			ELSE
			BEGIN
				/*Commission code is commented because sometimes the display price becomes more than crowd price*/				
				--SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)
				--SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)
				
				--IF(@eanCommission > @sabreCommission)
				--BEGIN
				--	EXEC USP_GetMarketplaceWinnerData
				--		 'Hotelscom'
				--		 ,@hotelResponsekey
				--		 ,@isNightlyRobotCall
				--END
				--ELSE
				--BEGIN
				--	EXEC USP_GetMarketplaceWinnerData
				--		 'Sabre'
				--		 ,@hotelResponsekey
				--		 ,@isNightlyRobotCall
				--END
				
				IF(@sabrePrice > @hotelsComPrice)
				BEGIN
					EXEC USP_GetMarketplaceWinnerData
						 @winner = 'Hotelscom'
						 ,@hotelResponsekey = @hotelResponsekey
						 ,@isNightlyRobotCall = @isNightlyRobotCall
						 ,@environment = @environment
				END
				ELSE
				BEGIN
					EXEC USP_GetMarketplaceWinnerData
						 @winner = 'Sabre'
						 ,@hotelResponsekey = @hotelResponsekey
						 ,@isNightlyRobotCall = @isNightlyRobotCall
						 ,@environment = @environment
				END
				
			END
			--END: WHEN CROWD PRICE IS NOT THE LOWEST PRICE
		END
		--END: If we have a tourico crowd price
		--If we dont have tourico crowd price
		ELSE
		BEGIN
			--Calculate the Tourico cost basis for crowd
			SET @touricoCostBasisForCrowd = dbo.udf_GetTouricoCostBasisForCrowd
											(
												@touricoNet
												,@touricoFloorMarkupPercent
												,@operatingCostPercent
												,@operatingCostValue
											)
			--Get the commission for all 3 GDS								
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
				EXEC USP_GetMarketplaceWinnerData
					 @winner = @winner
					 ,@hotelResponsekey = @hotelResponsekey
					 ,@isNightlyRobotCall = @isNightlyRobotCall
					 ,@environment = @environment
			END
			--END: If the winner is other than tourico
			--If the winner is tourico
			ELSE
			BEGIN
				EXEC USP_GetMarketplaceWinnerData
					 @winner = 'Tourico'
					 ,@hotelResponsekey = @hotelResponsekey
					 ,@isNightlyRobotCall = @isNightlyRobotCall
					 ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico
					 ,@gdsPrice = @touricoCostBasisForCrowd
					 ,@touricoNet = @touricoNet
					 ,@environment = @environment
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
				EXEC USP_GetMarketplaceWinnerData
					 @winner = 'Tourico'
					 ,@hotelResponsekey = @hotelResponsekey
					 ,@isNightlyRobotCall = @isNightlyRobotCall
					 ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico
					 ,@gdsPrice = @crowdPrice
					 ,@touricoNet = @touricoNet	
					 ,@environment = @environment				   
			END
			--END: If crowd price(derived from tourico price) is the lowest
			--WHEN CROWD PRICE IS NOT THE LOWEST PRICE
			ELSE
			BEGIN
				EXEC USP_GetMarketplaceWinnerData
					 @winner = 'Hotelscom'
					 ,@hotelResponsekey = @hotelResponsekey
					 ,@isNightlyRobotCall = @isNightlyRobotCall
					 ,@environment = @environment
			END
			--END: WHEN CROWD PRICE IS NOT THE LOWEST PRICE
		END
		--END: If we have a tourico crowd price	
		--If we dont have tourico crowd price
		ELSE
		BEGIN
			EXEC USP_GetMarketplaceWinnerData
					 @winner = 'Hotelscom'
					 ,@hotelResponsekey = @hotelResponsekey
					 ,@isNightlyRobotCall = @isNightlyRobotCall
					 ,@environment = @environment
		END
		--END: If we dont have tourico crowd price
	END
	--END: If SABRE price is not available
	--IF HOTELS COM PRICE IS NOT AVAILABLE
	ELSE IF(@touricoPrice > 0 AND @sabrePrice > 0 AND @hotelsComPrice = 0 )
	BEGIN
		--If we have a tourico crowd price
		IF(@crowdPrice > 0)
		BEGIN
			--If crowd price(derived from tourico price) is the lowest
			IF(@crowdPrice < @sabrePrice)
			BEGIN
				EXEC USP_GetMarketplaceWinnerData
					 @winner = 'Tourico'
					 ,@hotelResponsekey = @hotelResponsekey
					 ,@isNightlyRobotCall = @isNightlyRobotCall
					 ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico
					 ,@gdsPrice = @crowdPrice
					 ,@touricoNet = @touricoNet					   
					 ,@environment = @environment
			END
			--END: If crowd price(derived from tourico price) is the lowest
			--WHEN CROWD PRICE IS NOT THE LOWEST PRICE
			ELSE
			BEGIN
				EXEC USP_GetMarketplaceWinnerData
					 @winner = 'Sabre'
					 ,@hotelResponsekey = @hotelResponsekey
					 ,@isNightlyRobotCall = @isNightlyRobotCall
					 ,@environment = @environment
			END
			--END: WHEN CROWD PRICE IS NOT THE LOWEST PRICE
		END
		--END: If we have a tourico crowd price
		--If we dont have tourico crowd price
		ELSE
		BEGIN
			EXEC USP_GetMarketplaceWinnerData
				 @winner = 'Sabre'
				 ,@hotelResponsekey = @hotelResponsekey
				 ,@isNightlyRobotCall = @isNightlyRobotCall
				 ,@environment = @environment
		END	
		--END: If we dont have tourico crowd price
	END
    --END: IF HOTELS COM PRICE IS NOT AVAILABLE
    --IF TOURICO PRICE IS NOT AVAILABLE
    ELSE IF(@sabrePrice > 0 AND @hotelsComPrice > 0 AND @touricoPrice = 0)
    BEGIN
		--Commented as we are taking the price not based on commission
		--Calculate the commission
		--SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)
		--SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)
		
		--IF(@eanCommission > @sabreCommission)
		--BEGIN
		--	EXEC USP_GetMarketplaceWinnerData
		--		 'Hotelscom'
		--		 ,@hotelResponsekey
		--		 ,@isNightlyRobotCall
		--END
		--ELSE
		--BEGIN
		--	EXEC USP_GetMarketplaceWinnerData
		--		 'Sabre'
		--		 ,@hotelResponsekey
		--		 ,@isNightlyRobotCall
		--END
		
		IF(@hotelsComPrice < @sabrePrice)
		BEGIN
			EXEC USP_GetMarketplaceWinnerData
				 @winner = 'Hotelscom'
				 ,@hotelResponsekey = @hotelResponsekey
				 ,@isNightlyRobotCall = @isNightlyRobotCall
				 ,@environment = @environment
		END
		ELSE
		BEGIN
			EXEC USP_GetMarketplaceWinnerData
				 @winner = 'Sabre'
				 ,@hotelResponsekey = @hotelResponsekey
				 ,@isNightlyRobotCall = @isNightlyRobotCall
				 ,@environment = @environment
		END
			
    END
    --END: IF TOURICO PRICE IS NOT AVAILABLE
    --If only hotels com is available
    ELSE IF(@hotelsComPrice > 0 AND @touricoPrice = 0 AND @sabrePrice = 0)
    BEGIN
		EXEC USP_GetMarketplaceWinnerData
			 @winner = 'Hotelscom'
			 ,@hotelResponsekey = @hotelResponsekey
			 ,@isNightlyRobotCall = @isNightlyRobotCall
			 ,@environment = @environment
    END
    --END: If only hotels com is available
    --If only tourico is available
    ELSE IF(@touricoPrice > 0 AND @sabrePrice = 0 AND @hotelsComPrice = 0)
    BEGIN
		--If crowd price is available
		IF(@crowdPrice > 0)		
		BEGIN
			EXEC USP_GetMarketplaceWinnerData
				 @winner = 'Tourico'
				 ,@hotelResponsekey = @hotelResponsekey
				 ,@isNightlyRobotCall = @isNightlyRobotCall
				 ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico
				 ,@gdsPrice = @crowdPrice
				 ,@touricoNet = @touricoNet					   
				 ,@environment = @environment
		END
		--END: If crowd price is available
		--If crowd price is NOT available
		ELSE
		BEGIN
			--Calculate Tourico cost basis for crowd and use it as the crowd price
			SET @touricoCostBasisForCrowd = dbo.udf_GetTouricoCostBasisForCrowd
											(
												@touricoNet
												,@touricoFloorMarkupPercent
												,@operatingCostPercent
												,@operatingCostValue
											)
			
			EXEC USP_GetMarketplaceWinnerData
				 @winner = 'Tourico'
				 ,@hotelResponsekey = @hotelResponsekey
				 ,@isNightlyRobotCall = @isNightlyRobotCall
				 ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico
				 ,@gdsPrice = @touricoCostBasisForCrowd
				 ,@touricoNet = @touricoNet
				 ,@environment = @environment
		END
		--END: If crowd price is NOT available
    END
    --END: If only tourico is available
    --If only Sabre is available
    ELSE IF(@sabrePrice > 0 AND @hotelsComPrice = 0 AND @touricoPrice = 0)
    BEGIN
		EXEC USP_GetMarketplaceWinnerData
			 @winner = 'Sabre'
			 ,@hotelResponsekey = @hotelResponsekey
			 ,@isNightlyRobotCall = @isNightlyRobotCall
			 ,@environment = @environment
    END
    --END: If only Sabre is available
    
    -- --Get marketplace calculated values to show on hoteldetails page 
    IF(@isNightlyRobotCall = 0)
    BEGIN
		DECLARE @sumOfCalculatedValue FLOAT
		SET @sumOfCalculatedValue = ISNULL(@hotelsComPrice ,0) + ISNULL(@touricoNet ,0) + ISNULL(@sabrePrice ,0) 
		+ ISNULL(@touricoCalculatedBar ,0) + ISNULL(@eanCommission ,0) + ISNULL(@touricoCommission ,0) 
		+ ISNULL(@sabreCommission ,0) + ISNULL(@touricoActualMarkupPercent ,0) + ISNULL(@crowdPrice,0)
		+ ISNULL(@touricoCostBasisForCrowd,0)
		IF(@sumOfCalculatedValue > 0)
		BEGIN		
			SELECT	isnull(@hotelsComPrice ,0) as  EANBar,isnull(@touricoNet ,0) as  TouricoNet,isnull(@sabrePrice ,0) as  SabreBar
			,isnull(@touricoCalculatedBar ,0) as  TouricoCalculatedBar,isnull(@eanCommission ,0) as  EANCommission
			,isnull(@touricoCommission ,0) as  TouricoCommission,isnull(@sabreCommission ,0) as  SabreCommission,isnull(@touricoActualMarkupPercent ,0) as  TouricoActualMarkupPercent
			,CrowdPrice = @crowdPrice, TouricoFloor = @touricoCostBasisForCrowd
		END
	END
    
END
DROP TABLE #TmpHotelResponseDetail
GO
