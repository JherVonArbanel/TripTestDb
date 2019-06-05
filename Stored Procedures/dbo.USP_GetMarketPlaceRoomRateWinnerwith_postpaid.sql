SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 3rd Oct 2014
-- Description:	This SP derives the winner GDS for Hotel room rate call and gets all the data for that GDS
-- Updated on 12th January 2015 - Fixed issue with tourico fare is not displaying with ean rate as base rate.
-- Updated on 5th June 2017 - Now with room rate winner we need post paid hotel of sabre as well. And sabre will not participate in room rate winner - market place.
-- =============================================  
--EXEC USP_GetMarketPlaceRoomRateWinner 'F1A3189C-2DCF-4EF3-900C-005EA83B2722'  
CREATE PROCEDURE [dbo].[USP_GetMarketPlaceRoomRateWinnerwith_postpaid]    
  --DECLARE   
  @hotelResponsekey UNIQUEIDENTIFIER    
 ,@isNightlyRobotCall BIT = 0  
 ,@price float = 99999999.99  
 ,@siteKey int   
 ,@showGovRate bit = 0  
 ,@UserKey int =0
 ,@CompanyKey int =0
 ,@UserGroupKey Int = 0  
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
  [atMerchant] [bit] NULL
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
   ,@pricelinePrice FLOAT = 0    
   ,@hotelbedsPrice FLOAT = 0    
   ,@operatingCostPercent FLOAT    
   ,@operatingCostValue FLOAT    
   ,@marketPlaceVariableId INT    
   ,@sabreCommissionPercent FLOAT    
   ,@hotelsComCommissionPercent FLOAT    
   ,@pricelineCommissionPercent FLOAT    
   ,@hotelbedsCommissionPercent FLOAT    
   ,@eanCommission FLOAT = 0    
   ,@touricoCommission FLOAT = 0    
   ,@sabreCommission FLOAT = 0    
   ,@pricelineCommission FLOAT = 0  
   ,@hotelbedsCommission FLOAT = 0  
   ,@hotelResponseDetailKeyTourico UNIQUEIDENTIFIER    
   ,@hotelResponseDetailKeyEan UNIQUEIDENTIFIER    
   ,@hotelResponseDetailKeySabre UNIQUEIDENTIFIER    
   ,@hotelResponseDetailKeyHotelBeds UNIQUEIDENTIFIER    
   ,@hotelResponseDetailKeyPriceline UNIQUEIDENTIFIER  
   ,@touricoNet FLOAT = 0    
   ,@hotelbedsNet FLOAT = 0    
   ,@pricelineNet FLOAT = 0    
   ,@winner VARCHAR(20)       
   ,@touricoActualMarkupPercent FLOAT    
   ,@displayPrice FLOAT = 0    
   ,@touricoBarCalculatedFromRoomRate FLOAT = 0    
   ,@touricoMarkupPercent FLOAT    
   ,@IsWinner BIT = 0    
   ,@isOperatingCostPercentHigher BIT = 0  
   ,@barRateWinner FLOAT = 0  
   ,@hotelsComTax FLOAT = 0  
   ,@pricelineTax FLOAT = 0  
   ,@hotelbedsTax FLOAT = 0  
   ,@sabreTax FLOAT = 0    
   ,@isCompanyMarketPlaceActive BIT = 0
   ,@atMerchant BIT =0
   ,@pricelineMerchantPrice FLOAT = 0   
   ,@pricelineMerchantTax FLOAT = 0   
   ,@hotelbedsMerchantPrice FLOAT = 0  
   ,@hotelbedsMerchantTax FLOAT = 0  
  
 --   DECLARE @RateDescriptionTable as Table   
 --(  
 --  rateType varchar(100)  
 --)  
 --DECLARE @rateDescriptionString as varchar(100)  
  
 --SET @rateDescriptionString ='%A A A%,%AAA%,%SENIOR%'  
  
 --IF (@showGovRate = 1)  
 --BEGIN  
 -- SET @rateDescriptionString ='%A A A%,%AAA%,%SENIOR%,%GOV%'  
 --END  
  
 --INSERT INTO @RateDescriptionTable  select * From ufn_CSVSplitString(@rateDescriptionString)   
     
 --Insert selected data from HotelResponseDetail based on hotelResponseKey    
 IF (@showGovRate = 1)  
 BEGIN  
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
  ,atMerchant  
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
  ,atMerchant  
  FROM HotelResponseDetail   
  WHERE hotelResponseKey = @hotelResponsekey    
  AND (rateDescription NOT LIKE ('%A A A%')     
  AND rateDescription NOT LIKE ('%AAA%')     
  AND rateDescription NOT LIKE ('%SENIOR%'))  
  AND hotelDailyPrice <= @price  
  END  
  ELSE  
  BEGIN  
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
  ,atMerchant    
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
  ,atMerchant 
  FROM HotelResponseDetail   
  WHERE hotelResponseKey = @hotelResponsekey    
  AND (rateDescription NOT LIKE ('%A A A%')     
  AND rateDescription NOT LIKE ('%AAA%')     
  AND rateDescription NOT LIKE ('%SENIOR%')  
  AND rateDescription NOT LIKE ('%GOV%'))     
  AND hotelDailyPrice <= @price  
  END  
  
  SELECT @isCompanyMarketPlaceActive = isCompanyMarketPlaceActive FROM Vault..Company WHERE COMPANYKEY = @CompanyKey
 
 --Set common marketplace values    
 
 IF @siteKey > 0  
 BEGIN  
 
  SELECT    
  @operatingCostPercent = ISNULL(OperatingCostPer, 0)    
  ,@operatingCostValue = ISNULL(OperatingCost, 0)    
  ,@marketPlaceVariableId = Id    
  FROM vault.dbo.MarketPlaceVariables    
  WHERE IsActive = 1  And SiteKey = @siteKey 
  and 1=CASE 
    WHEN @isCompanyMarketPlaceActive = 1 THEN 
        CASE WHEN CompanyId= @companykey  THEN 1 END
    WHEN companyId IS  NULL OR  companyId =0 THEN 1 END
  
 
 END  
 ELSE  
 BEGIN  
     SELECT    
  @operatingCostPercent = ISNULL(OperatingCostPer, 0)    
  ,@operatingCostValue = ISNULL(OperatingCost, 0)    
  ,@marketPlaceVariableId = Id    
  FROM vault.dbo.MarketPlaceVariables    
  WHERE IsActive = 1  
 END  

 print @marketPlaceVariableId
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
 @hotelsComCommissionPercent = ISNULL(BARMarkupPer, 0)    
 FROM @VtblMarketPlaceVariablesGDS    
 WHERE GDSId = 1     
  
 --SABRE marketplace values    
 SELECT     
 @sabreCommissionPercent = ISNULL(BARMarkupPer, 0)    
 FROM @VtblMarketPlaceVariablesGDS    
 WHERE GDSId = 4     
  
 --TOURICO marketplace values    
 SELECT     
 @touricoMarkupPercent = ISNULL(BARMarkupPer, 0)    
 FROM @VtblMarketPlaceVariablesGDS    
 WHERE GDSId = 5     

  SELECT     
 @pricelineCommissionPercent = ISNULL(BARMarkupPer, 0)    
 FROM @VtblMarketPlaceVariablesGDS    
 WHERE GDSId = 8  

  SELECT     
 @hotelbedsCommissionPercent = ISNULL(BARMarkupPer, 0)    
 FROM @VtblMarketPlaceVariablesGDS    
 WHERE GDSId = 6  
  
 --Get the lowest price for HotelsCom    
 SELECT TOP 1    
 @hotelsComPrice = ISNULL(hotelDailyPrice,0)  
 ,@hotelsComTax = ISNULL(hotelTaxRate, 0)    
 ,@hotelResponseDetailKeyEan = hotelResponseDetailKey       
 FROM #TmpHotelResponseDetail    
 WHERE supplierId = 'HotelsCom'    
 AND hotelResponseKey = @hotelResponsekey    
 ORDER BY hotelDailyPrice ASC   


  --Get the lowest price for HotelsCom    
 SELECT TOP 1    
 @pricelinePrice = ISNULL(touricoCalculatedBar,0)    
 ,@pricelineTax = ISNULL(hotelTaxRate, 0)    
 ,@hotelResponseDetailKeyPriceline = hotelResponseDetailKey   
 ,@pricelineNet = ISNULL(hotelDailyPrice, 0)         
 FROM #TmpHotelResponseDetail    
 WHERE supplierId = 'Priceline'    
 AND hotelResponseKey = @hotelResponsekey AND atMerchant=0
 ORDER BY hotelDailyPrice ASC   

 --IF @pricelinePrice = 0
 --BEGIN
  SELECT TOP 1    
	 @pricelineMerchantPrice = ISNULL(hotelDailyPrice,0)  
	 ,@pricelineMerchantTax = ISNULL(hotelTaxRate, 0)    
	 --,@hotelResponseDetailKeyPriceline = hotelResponseDetailKey   
	 FROM #TmpHotelResponseDetail    
	 WHERE supplierId = 'Priceline'    
	 AND hotelResponseKey = @hotelResponsekey AND atMerchant=1
	 ORDER BY hotelDailyPrice ASC 

	 print @pricelineMerchantPrice

	 IF(@pricelineMerchantPrice <>0)
	 BEGIN
		SET @pricelinePrice = @pricelineMerchantPrice
		SET @pricelineTax = @pricelineMerchantTax
	 END

	 print @pricelinePrice
	 print @pricelineNet

 --END


  SELECT TOP 1    
 @hotelbedsPrice =  ISNULL(touricoCalculatedBar,0)    
 ,@hotelbedsTax = ISNULL(hotelTaxRate, 0)    
 ,@hotelResponseDetailKeyHotelBeds = hotelResponseDetailKey
 ,@hotelbedsNet = ISNULL(touricoNetRate, 0)           
 FROM #TmpHotelResponseDetail    
 WHERE supplierId = 'Hotelbeds'    
 AND hotelResponseKey = @hotelResponsekey  AND atMerchant=0   
 ORDER BY hotelDailyPrice ASC   

   SELECT TOP 1    
	 @hotelbedsMerchantPrice = ISNULL(hotelDailyPrice,0)  
	 ,@hotelbedsMerchantTax = ISNULL(hotelTaxRate, 0)    
	 --,@hotelResponseDetailKeyPriceline = hotelResponseDetailKey   
	 FROM #TmpHotelResponseDetail    
	 WHERE supplierId = 'HotelBeds'    
	 AND hotelResponseKey = @hotelResponsekey AND atMerchant=1
	 ORDER BY hotelDailyPrice ASC 


	 IF(@hotelbedsMerchantPrice <>0)
	 BEGIN
		SET @hotelbedsPrice = @hotelbedsMerchantPrice
		SET @hotelbedsTax = @hotelbedsMerchantTax
	 END

	 print @pricelinePrice
	 print @pricelineNet
  
 --Get the lowest price for Tourico    
 SELECT TOP 1    
 @touricoPrice = ISNULL(touricoCalculatedBar,0)    
 ,@hotelResponseDetailKeyTourico = hotelResponseDetailKey    
 ,@touricoNet = ISNULL(touricoNetRate, 0)    
 ,@displayPrice = ISNULL(displayPrice, 0)    
 FROM #TmpHotelResponseDetail    
 WHERE supplierId = 'Tourico'    
 AND hotelResponseKey = @hotelResponsekey    
 ORDER BY hotelDailyPrice ASC    
  
 --Get the lowest price for Sabre    

 print '10'
 SELECT TOP 1    
 @sabrePrice = ISNULL(hotelDailyPrice,0)    
 ,@sabreTax = ISNULL(hotelTaxRate, 0)  
 ,@hotelResponseDetailKeySabre = hotelResponseDetailKey      
 FROM #TmpHotelResponseDetail    
 WHERE supplierId = 'Sabre'    
 AND hotelResponseKey = @hotelResponsekey    
 ORDER BY hotelDailyPrice ASC     
     print '11'



 
IF(@pricelinePrice > 0 AND @touricoPrice > 0 AND @hotelbedsPrice > 0)    
 BEGIN    
-- print '1'  
  IF((@pricelinePrice < @touricoPrice) OR  (@hotelbedsPrice < @touricoPrice))    
  BEGIN    
   --Calculate the commision for both. Use Hotels Com bar to calculate Tourico commission     
   IF(@pricelineNet > 0)
   BEGIN
		SET @pricelineCommission = dbo.udf_GetTouricoCommission(@pricelinePrice, @operatingCostPercent, @operatingCostValue, @pricelineNet)  ----net rate        
   END
   ELSE
   BEGIN
		SET @pricelineCommission = dbo.udf_GetMarketPlaceCommission(@pricelinePrice, @pricelineCommissionPercent)    --merchant rate
   END
   
   SET @touricoCommission = dbo.udf_GetTouricoCommission(@touricoPrice, @operatingCostPercent, @operatingCostValue, @touricoNet)    
   SET @hotelbedsCommission = dbo.udf_GetTouricoCommission(@hotelbedsPrice, @operatingCostPercent, @operatingCostValue, @hotelbedsNet)    
  
  IF(@pricelineCommission > @touricoCommission OR @pricelineCommission > @hotelbedsCommission)    
  BEGIN    
	  IF(@pricelineNet > 0)
	   BEGIN

		   IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
		  BEGIN    
		   SET @touricoMarkupPercent = @operatingCostPercent    
		   SET @isOperatingCostPercentHigher = 1    
		  END    
  
		  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
		  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
		   (    
			@touricoMarkupPercent    
			,@hotelbedsNet            
		   )    
  
		  IF(@isOperatingCostPercentHigher = 1)    
		  BEGIN    
		   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
		  END  

		  IF(@touricoBarCalculatedFromRoomRate > @pricelinePrice)  
		  BEGIN  
		   SET @barRateWinner = @touricoBarCalculatedFromRoomRate   
		  END  
		  ELSE  
		  BEGIN  
		   SET @barRateWinner = @pricelinePrice  
		  END

		  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		  @winner = 'Priceline'    
		  ,@hotelResponsekey = @hotelResponsekey    
		  ,@isNightlyRobotCall = @isNightlyRobotCall    
		   ,@hotelResponseDetailKey = @hotelResponseDetailKeyPriceline   
		   ,@showGovRate =  @showGovRate
		   ,@gdsPrice = @barRateWinner 
		   ,@touricoNet = @pricelineNet       
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
		   ,@atMerchant =0
		  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected  
	   END
	   ELSE
	   BEGIN
		   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		   @winner = 'Priceline'    
		   ,@hotelResponsekey = @hotelResponsekey    
		   ,@isNightlyRobotCall = @isNightlyRobotCall  
		   ,@showGovRate =  @showGovRate  
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
	   END
  END  
  ELSE IF(@hotelbedsCommission > @touricoCommission)
  BEGIN     
    IF(@hotelbedsNet > 0)
	BEGIN
	 IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
	  BEGIN    
	   SET @touricoMarkupPercent = @operatingCostPercent    
	   SET @isOperatingCostPercentHigher = 1    
	  END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
   (    
    @touricoMarkupPercent    
    ,@hotelbedsNet            
   )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END    

  print @touricoBarCalculatedFromRoomRate
  print @hotelbedsNet
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'HotelBeds'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@hotelResponseDetailKey = @hotelResponseDetailKeyHotelBeds    
   ,@showGovRate =  @showGovRate
   ,@gdsPrice = @touricoBarCalculatedFromRoomRate 
   ,@touricoNet = @hotelbedsNet       
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
   ,@atMerchant =0
   END
   ELSE
   BEGIN
   		   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		   @winner = 'HotelBeds'    
		   ,@hotelResponsekey = @hotelResponsekey    
		   ,@isNightlyRobotCall = @isNightlyRobotCall  
		   ,@showGovRate =  @showGovRate  
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
   END

  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
  END      
  ELSE    
  BEGIN     
   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
   @winner = 'Tourico'    
   ,@hotelResponsekey = @hotelResponsekey    
   ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
   ,@gdsPrice = @pricelinePrice    
   ,@touricoNet = @touricoNet    
   ,@totalTaxRate = @pricelineTax
   ,@showGovRate =  @showGovRate  
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  END      
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
  END    
  ELSE    
  --If Tourico Price is less than Hotels com Price    
  BEGIN      
   /*IF MARKUP PERCENT IS LOW OR ZERO THEN SET MARK UP PERCENT AS OPERATING PERCENT.    
   THIS WILL ALLOW TO ATLEAST TO RECOVER THE OPERATING COST*/    
   IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
   BEGIN    
    SET @touricoMarkupPercent = @operatingCostPercent    
    SET @isOperatingCostPercentHigher = 1    
   END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
    (    
     @touricoMarkupPercent    
     ,@touricoNet                  
    )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END   
  --If tourico bar rate is higher, then we have to atleast recover the operating cost of tourico   
  IF(@touricoBarCalculatedFromRoomRate > @pricelinePrice)  
  BEGIN  
   SET @barRateWinner = @touricoBarCalculatedFromRoomRate   
  END  
  ELSE  
  BEGIN  
   SET @barRateWinner = @pricelinePrice  
  END  
  --print 3454
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'Tourico'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
  ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
  ,@gdsPrice = @barRateWinner    
  ,@touricoNet = @touricoNet    
  ,@totalTaxRate = @pricelineTax   
   ,@showGovRate =  @showGovRate 
  ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
  END    
  --END: If Tourico Price is less than Priceline Price    
  
 END    
 --END: If Priceline and Tourico is available but Sabre is not available    
 --If only TOURICO is available    
 ELSE IF(@pricelinePrice > 0 AND @touricoPrice > 0 AND @hotelbedsPrice = 0)    
 BEGIN    
-- print '1'  
  IF((@pricelinePrice < @touricoPrice))    
  BEGIN    
   --Calculate the commision for both. Use Priceline Com bar to calculate Tourico commission     
      IF(@pricelineNet > 0)
   BEGIN
		SET @pricelineCommission = dbo.udf_GetTouricoCommission(@pricelinePrice, @operatingCostPercent, @operatingCostValue, @pricelineNet)  ----net rate        
   END
   ELSE
   BEGIN
		SET @pricelineCommission = dbo.udf_GetMarketPlaceCommission(@pricelinePrice, @pricelineCommissionPercent)    --merchant rate
   END  
   SET @touricoCommission = dbo.udf_GetTouricoCommission(@pricelinePrice, @operatingCostPercent, @operatingCostValue, @touricoNet)    
  
  IF(@pricelineCommission > @touricoCommission)    
  BEGIN    
 IF(@pricelineNet > 0)
	   BEGIN

		   IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
		  BEGIN    
		   SET @touricoMarkupPercent = @operatingCostPercent    
		   SET @isOperatingCostPercentHigher = 1    
		  END    
  
		  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
		  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
		   (    
			@touricoMarkupPercent    
			,@hotelbedsNet            
		   )    
  
		  IF(@isOperatingCostPercentHigher = 1)    
		  BEGIN    
		   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
		  END  

		  IF(@touricoBarCalculatedFromRoomRate > @pricelinePrice)  
		  BEGIN  
		   SET @barRateWinner = @touricoBarCalculatedFromRoomRate   
		  END  
		  ELSE  
		  BEGIN  
		   SET @barRateWinner = @pricelinePrice  
		  END

		  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		  @winner = 'Priceline'    
		  ,@hotelResponsekey = @hotelResponsekey    
		  ,@isNightlyRobotCall = @isNightlyRobotCall    
		   ,@hotelResponseDetailKey = @hotelResponseDetailKeyPriceline   
		   ,@showGovRate =  @showGovRate
		   ,@gdsPrice = @barRateWinner 
		   ,@touricoNet = @pricelineNet       
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
		   ,@atMerchant =0
		  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected  
	   END
	   ELSE
	   BEGIN
		   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		   @winner = 'Priceline'    
		   ,@hotelResponsekey = @hotelResponsekey    
		   ,@isNightlyRobotCall = @isNightlyRobotCall  
		   ,@showGovRate =  @showGovRate  
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
	   END
  END       
  ELSE    
  BEGIN     
   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
   @winner = 'Tourico'    
   ,@hotelResponsekey = @hotelResponsekey    
   ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
   ,@gdsPrice = @hotelsComPrice    
   ,@touricoNet = @touricoNet    
   ,@totalTaxRate = @pricelineTax
   ,@showGovRate =  @showGovRate  
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  END      
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
  END    
  ELSE    
  --If Tourico Price is less than Hotels com Price    
  BEGIN      
   /*IF MARKUP PERCENT IS LOW OR ZERO THEN SET MARK UP PERCENT AS OPERATING PERCENT.    
   THIS WILL ALLOW TO ATLEAST TO RECOVER THE OPERATING COST*/    
   IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
   BEGIN    
    SET @touricoMarkupPercent = @operatingCostPercent    
    SET @isOperatingCostPercentHigher = 1    
   END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
    (    
     @touricoMarkupPercent    
     ,@touricoNet                  
    )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END   
  --If tourico bar rate is higher, then we have to atleast recover the operating cost of tourico   
  IF(@touricoBarCalculatedFromRoomRate > @pricelinePrice)  
  BEGIN  
   SET @barRateWinner = @touricoBarCalculatedFromRoomRate   
  END  
  ELSE  
  BEGIN  
   SET @barRateWinner = @pricelinePrice  
  END  
  --print 3454
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'Tourico'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
  ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
  ,@gdsPrice = @barRateWinner    
  ,@touricoNet = @touricoNet    
  ,@totalTaxRate = @pricelineTax   
   ,@showGovRate =  @showGovRate 
  ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
  END    
  --END: If Tourico Price is less than Priceline Price    
  
 END   
  ELSE IF(@pricelinePrice = 0 AND @touricoPrice > 0 AND @hotelbedsPrice > 0)    
 BEGIN    
-- print '1'  
  IF((@pricelinePrice < @touricoPrice))    
  BEGIN    
   --Calculate the commision for both. Use Hotels Com bar to calculate Tourico commission     
   SET @hotelbedsCommission = dbo.udf_GetTouricoCommission(@hotelbedsPrice, @operatingCostPercent, @operatingCostValue, @hotelbedsNet)    
   SET @touricoCommission = dbo.udf_GetTouricoCommission(@pricelinePrice, @operatingCostPercent, @operatingCostValue, @touricoNet)    
  
  IF(@hotelbedsCommission > @touricoCommission)    
  BEGIN    
    IF(@hotelbedsNet > 0)
	BEGIN
	 IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
	  BEGIN    
	   SET @touricoMarkupPercent = @operatingCostPercent    
	   SET @isOperatingCostPercentHigher = 1    
	  END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
   (    
    @touricoMarkupPercent    
    ,@hotelbedsNet            
   )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END    

  print @touricoBarCalculatedFromRoomRate
  print @hotelbedsNet
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'HotelBeds'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@hotelResponseDetailKey = @hotelResponseDetailKeyHotelBeds    
   ,@showGovRate =  @showGovRate
   ,@gdsPrice = @touricoBarCalculatedFromRoomRate 
   ,@touricoNet = @hotelbedsNet       
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
   ,@atMerchant =0
   END
   ELSE
   BEGIN
   		   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		   @winner = 'HotelBeds'    
		   ,@hotelResponsekey = @hotelResponsekey    
		   ,@isNightlyRobotCall = @isNightlyRobotCall  
		   ,@showGovRate =  @showGovRate  
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
   END
   Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
  END       
  ELSE    
  BEGIN     
   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
   @winner = 'Tourico'    
   ,@hotelResponsekey = @hotelResponsekey    
   ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
   ,@gdsPrice = @hotelsComPrice    
   ,@touricoNet = @touricoNet    
   ,@totalTaxRate = @pricelineTax
   ,@showGovRate =  @showGovRate  
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  END      
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
  END    
  ELSE    
  --If Tourico Price is less than Hotels com Price    
  BEGIN      
   /*IF MARKUP PERCENT IS LOW OR ZERO THEN SET MARK UP PERCENT AS OPERATING PERCENT.    
   THIS WILL ALLOW TO ATLEAST TO RECOVER THE OPERATING COST*/    
   IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
   BEGIN    
    SET @touricoMarkupPercent = @operatingCostPercent    
    SET @isOperatingCostPercentHigher = 1    
   END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
    (    
     @touricoMarkupPercent    
     ,@touricoNet                  
    )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END   
  --If tourico bar rate is higher, then we have to atleast recover the operating cost of tourico   
  IF(@touricoBarCalculatedFromRoomRate > @pricelinePrice)  
  BEGIN  
   SET @barRateWinner = @touricoBarCalculatedFromRoomRate   
  END  
  ELSE  
  BEGIN  
   SET @barRateWinner = @pricelinePrice  
  END  
  --print 3454
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'Tourico'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
  ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
  ,@gdsPrice = @barRateWinner    
  ,@touricoNet = @touricoNet    
  ,@totalTaxRate = @pricelineTax   
   ,@showGovRate =  @showGovRate 
  ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
  END    
  --END: If Tourico Price is less than Priceline Price    
  
 END   
   ELSE IF(@pricelinePrice > 0 AND @touricoPrice = 0 AND @hotelbedsPrice > 0)    
 BEGIN    
 print '95'  
  IF((@pricelinePrice < @hotelbedsPrice))    
  BEGIN    

   --Calculate the commision for both. Use Priceline bar to calculate Tourico commission     
      IF(@pricelineNet > 0)
   BEGIN
		SET @pricelineCommission = dbo.udf_GetTouricoCommission(@pricelinePrice, @operatingCostPercent, @operatingCostValue, @pricelineNet)  ----net rate        
   END
   ELSE
   BEGIN
		SET @pricelineCommission = dbo.udf_GetMarketPlaceCommission(@pricelinePrice, @pricelineCommissionPercent)    --merchant rate
   END
   SET @hotelbedsCommission = dbo.udf_GetTouricoCommission(@hotelbedsPrice, @operatingCostPercent, @operatingCostValue, @touricoNet)    

  IF(@hotelbedsCommission > @pricelineCommission)    
  BEGIN    
   print '96'
    IF(@hotelbedsNet > 0)
	BEGIN
	 IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
	  BEGIN    
	   SET @touricoMarkupPercent = @operatingCostPercent    
	   SET @isOperatingCostPercentHigher = 1    
	  END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
   (    
    @touricoMarkupPercent    
    ,@hotelbedsNet            
   )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END    

  print @touricoBarCalculatedFromRoomRate
  print @hotelbedsNet
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'HotelBeds'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@hotelResponseDetailKey = @hotelResponseDetailKeyHotelBeds    
   ,@showGovRate =  @showGovRate
   ,@gdsPrice = @touricoBarCalculatedFromRoomRate 
   ,@touricoNet = @hotelbedsNet       
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
   ,@atMerchant =0
   END
   ELSE
   BEGIN
   		   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		   @winner = 'HotelBeds'    
		   ,@hotelResponsekey = @hotelResponsekey    
		   ,@isNightlyRobotCall = @isNightlyRobotCall  
		   ,@showGovRate =  @showGovRate  
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
   END
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
  END       
  ELSE    
  BEGIN    
   print '97'
 IF(@pricelineNet > 0)
	   BEGIN

		   IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
		  BEGIN    
		   SET @touricoMarkupPercent = @operatingCostPercent    
		   SET @isOperatingCostPercentHigher = 1    
		  END    
  
		  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
		  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
		   (    
			@touricoMarkupPercent    
			,@hotelbedsNet            
		   )    
  
		  IF(@isOperatingCostPercentHigher = 1)    
		  BEGIN    
		   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
		  END  

		  IF(@touricoBarCalculatedFromRoomRate > @pricelinePrice)  
		  BEGIN  
		   SET @barRateWinner = @touricoBarCalculatedFromRoomRate   
		  END  
		  ELSE  
		  BEGIN  
		   SET @barRateWinner = @pricelinePrice  
		  END

		  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		  @winner = 'Priceline'    
		  ,@hotelResponsekey = @hotelResponsekey    
		  ,@isNightlyRobotCall = @isNightlyRobotCall    
		   ,@hotelResponseDetailKey = @hotelResponseDetailKeyPriceline   
		   ,@showGovRate =  @showGovRate
		   ,@gdsPrice = @barRateWinner 
		   ,@touricoNet = @pricelineNet       
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
		   ,@atMerchant =0
		  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected  
	   END
	   ELSE
	   BEGIN
		   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		   @winner = 'Priceline'    
		   ,@hotelResponsekey = @hotelResponsekey    
		   ,@isNightlyRobotCall = @isNightlyRobotCall  
		   ,@showGovRate =  @showGovRate  
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
	   END
  END      
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
  END    
  ELSE
   BEGIN
     IF(@hotelbedsNet > 0)
	BEGIN
	 IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
	  BEGIN    
	   SET @touricoMarkupPercent = @operatingCostPercent    
	   SET @isOperatingCostPercentHigher = 1    
	  END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
   (    
    @touricoMarkupPercent    
    ,@hotelbedsNet            
   )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END    

  print @touricoBarCalculatedFromRoomRate
  print @hotelbedsNet
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'HotelBeds'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@hotelResponseDetailKey = @hotelResponseDetailKeyHotelBeds    
   ,@showGovRate =  @showGovRate
   ,@gdsPrice = @touricoBarCalculatedFromRoomRate 
   ,@touricoNet = @hotelbedsNet       
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
   ,@atMerchant =0
   END
   ELSE
   BEGIN
   		   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		   @winner = 'HotelBeds'    
		   ,@hotelResponsekey = @hotelResponsekey    
		   ,@isNightlyRobotCall = @isNightlyRobotCall  
		   ,@showGovRate =  @showGovRate  
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
   END
   Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
   END
  
 END   
ELSE IF(@touricoPrice > 0 AND @pricelinePrice = 0 AND @hotelbedsPrice = 0)    
 BEGIN     
  /*IF MARKUP PERCENT IS LOW OR ZERO THEN SET MARK UP PERCENT AS OPERATING PERCENT.    
  THIS WILL ALLOW TO ATLEAST TO RECOVER THE OPERATING COST*/    
  IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
  BEGIN    
   SET @touricoMarkupPercent = @operatingCostPercent    
   SET @isOperatingCostPercentHigher = 1    
  END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
   (    
    @touricoMarkupPercent    
    ,@touricoNet            
   )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END    
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'Tourico'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
  ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
  ,@gdsPrice = @touricoBarCalculatedFromRoomRate    
  ,@touricoNet = @touricoNet    
  ,@touricoCalculatedBar = @touricoPrice    
   ,@showGovRate =  @showGovRate
  ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    

  END    
 ELSE IF(@pricelinePrice > 0 AND @touricoPrice = 0 AND @hotelbedsPrice = 0)    
 BEGIN    
 print 'p3'  
 IF(@pricelineNet > 0)
	   BEGIN

		   IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
		  BEGIN    
		   SET @touricoMarkupPercent = @operatingCostPercent    
		   SET @isOperatingCostPercentHigher = 1    
		  END    
  
		  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
		  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
		   (    
			@touricoMarkupPercent    
			,@hotelbedsNet            
		   )    
  
		  IF(@isOperatingCostPercentHigher = 1)    
		  BEGIN    
		   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
		  END  

		  IF(@touricoBarCalculatedFromRoomRate > @pricelinePrice)  
		  BEGIN  
		   SET @barRateWinner = @touricoBarCalculatedFromRoomRate   
		  END  
		  ELSE  
		  BEGIN  
		   SET @barRateWinner = @pricelinePrice  
		  END
		  print @pricelinePrice
		  print @barRateWinner


		  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		  @winner = 'Priceline'    
		  ,@hotelResponsekey = @hotelResponsekey    
		  ,@isNightlyRobotCall = @isNightlyRobotCall    
		   ,@hotelResponseDetailKey = @hotelResponseDetailKeyPriceline   
		   ,@showGovRate =  @showGovRate
		   ,@gdsPrice = @barRateWinner 
		   ,@touricoNet = @pricelineNet       
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
		   ,@atMerchant =0
		  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected  
	   END
	   ELSE
	   BEGIN
		   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		   @winner = 'Priceline'    
		   ,@hotelResponsekey = @hotelResponsekey    
		   ,@isNightlyRobotCall = @isNightlyRobotCall  
		   ,@showGovRate =  @showGovRate  
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
	   END
 END    
 ELSE IF(@hotelbedsPrice > 0 AND @touricoPrice = 0 AND @pricelinePrice = 0)    
 BEGIN    
 print 'p9'  

     IF(@hotelbedsNet > 0)
	BEGIN
	 IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
	  BEGIN    
	   SET @touricoMarkupPercent = @operatingCostPercent    
	   SET @isOperatingCostPercentHigher = 1    
	  END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
   (    
    @touricoMarkupPercent    
    ,@hotelbedsNet            
   )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END    

  print @touricoBarCalculatedFromRoomRate
  print @hotelbedsNet
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'HotelBeds'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@hotelResponseDetailKey = @hotelResponseDetailKeyHotelBeds    
   ,@showGovRate =  @showGovRate
   ,@gdsPrice = @touricoBarCalculatedFromRoomRate 
   ,@touricoNet = @hotelbedsNet       
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
   ,@atMerchant =0
   END
   ELSE
   BEGIN
   		   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		   @winner = 'HotelBeds'    
		   ,@hotelResponsekey = @hotelResponsekey    
		   ,@isNightlyRobotCall = @isNightlyRobotCall  
		   ,@showGovRate =  @showGovRate  
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
   END
     Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
 END    
 ELSE IF(@hotelsComPrice > 0 AND @touricoPrice > 0)    
 BEGIN    
-- print '1'  
  IF(@hotelsComPrice < @touricoPrice)    
  BEGIN    
   --Calculate the commision for both. Use Hotels Com bar to calculate Tourico commission     
   SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)    
   SET @touricoCommission = dbo.udf_GetTouricoCommission(@hotelsComPrice, @operatingCostPercent, @operatingCostValue, @touricoNet)    
  
  IF(@eanCommission > @touricoCommission)    
  BEGIN    
   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
   @winner = 'Hotelscom'    
   ,@hotelResponsekey = @hotelResponsekey    
   ,@isNightlyRobotCall = @isNightlyRobotCall  
   ,@showGovRate =  @showGovRate  
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  END    
  ELSE    
  BEGIN     
   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
   @winner = 'Tourico'    
   ,@hotelResponsekey = @hotelResponsekey    
   ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
   ,@gdsPrice = @hotelsComPrice    
   ,@touricoNet = @touricoNet    
   ,@totalTaxRate = @hotelsComTax
   ,@showGovRate =  @showGovRate  
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  END      
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
  END    
  ELSE    
  --If Tourico Price is less than Hotels com Price    
  BEGIN      
   /*IF MARKUP PERCENT IS LOW OR ZERO THEN SET MARK UP PERCENT AS OPERATING PERCENT.    
   THIS WILL ALLOW TO ATLEAST TO RECOVER THE OPERATING COST*/    
   IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
   BEGIN    
    SET @touricoMarkupPercent = @operatingCostPercent    
    SET @isOperatingCostPercentHigher = 1    
   END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
    (    
     @touricoMarkupPercent    
     ,@touricoNet                  
    )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END   
  --If tourico bar rate is higher, then we have to atleast recover the operating cost of tourico   
  IF(@touricoBarCalculatedFromRoomRate > @hotelsComPrice)  
  BEGIN  
   SET @barRateWinner = @touricoBarCalculatedFromRoomRate   
  END  
  ELSE  
  BEGIN  
   SET @barRateWinner = @hotelsComPrice  
  END  
  --print 3454
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'Tourico'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
  ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
  ,@gdsPrice = @barRateWinner    
  ,@touricoNet = @touricoNet    
  ,@totalTaxRate = @hotelsComTax   
   ,@showGovRate =  @showGovRate 
  ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
  END    
  --END: If Tourico Price is less than Hotels com Price    
  
 END    
 --END: If EAN and Tourico is availble but Sabre is not available    
 --If only TOURICO is available    
 ELSE IF(@touricoPrice > 0 AND @hotelsComPrice = 0)    
 BEGIN    
 print '2'  
  /*IF MARKUP PERCENT IS LOW OR ZERO THEN SET MARK UP PERCENT AS OPERATING PERCENT.    
  THIS WILL ALLOW TO ATLEAST TO RECOVER THE OPERATING COST*/    
  IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
  BEGIN    
   SET @touricoMarkupPercent = @operatingCostPercent    
   SET @isOperatingCostPercentHigher = 1    
  END    
  
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
   (    
    @touricoMarkupPercent    
    ,@touricoNet            
   )    
  
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END    
  print 34545
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'Tourico'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
  ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
  ,@gdsPrice = @touricoBarCalculatedFromRoomRate    
  ,@touricoNet = @touricoNet    
  ,@touricoCalculatedBar = @touricoPrice    
   ,@showGovRate =  @showGovRate
  ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    

  print 7865
  END    
   
 --END: If only TOURICO is available    
 --If only SABRE is available    
 ELSE IF(@sabrePrice > 0 AND @touricoPrice = 0 AND @hotelsComPrice = 0 AND @pricelinePrice =0)    
 BEGIN    
 --print '3'  
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'Sabre'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@showGovRate =  @showGovRate
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
  
 END    
 --END: If only SABRE is available    
 --If only HOTELSCOM is available    
 ELSE IF(@hotelsComPrice > 0 AND @touricoPrice = 0)    
 BEGIN    
 --print '4'  
  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
  @winner = 'Hotelscom'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@showGovRate =  @showGovRate
   ,@UserKey = @UserKey
   ,@CompanyKey = @CompanyKey
   ,@UserGroupKey = @UserGroupKey
   ,@maxPrice=@price
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
 END    
 ELSE  
   BEGIN  
   -- print 7989
	--print @showGovRate
 IF(@pricelineNet > 0)
	   BEGIN

		   IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
		  BEGIN    
		   SET @touricoMarkupPercent = @operatingCostPercent    
		   SET @isOperatingCostPercentHigher = 1    
		  END    
  
		  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
		  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
		   (    
			@touricoMarkupPercent    
			,@hotelbedsNet            
		   )    
  
		  IF(@isOperatingCostPercentHigher = 1)    
		  BEGIN    
		   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
		  END  

		  IF(@touricoBarCalculatedFromRoomRate > @pricelinePrice)  
		  BEGIN  
		   SET @barRateWinner = @touricoBarCalculatedFromRoomRate   
		  END  
		  ELSE  
		  BEGIN  
		   SET @barRateWinner = @pricelinePrice  
		  END

		  EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		  @winner = 'Priceline'    
		  ,@hotelResponsekey = @hotelResponsekey    
		  ,@isNightlyRobotCall = @isNightlyRobotCall    
		   ,@hotelResponseDetailKey = @hotelResponseDetailKeyPriceline   
		   ,@showGovRate =  @showGovRate
		   ,@gdsPrice = @barRateWinner 
		   ,@touricoNet = @pricelineNet       
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
		   ,@atMerchant =0
		  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected  
	   END
	   ELSE
	   BEGIN
		   EXEC USP_GetMarketplaceWinnerDataWith_postpaid     
		   @winner = 'Priceline'    
		   ,@hotelResponsekey = @hotelResponsekey    
		   ,@isNightlyRobotCall = @isNightlyRobotCall  
		   ,@showGovRate =  @showGovRate  
		   ,@UserKey = @UserKey
		   ,@CompanyKey = @CompanyKey
		   ,@UserGroupKey = @UserGroupKey
		   ,@maxPrice=@price
	   END
   Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
    
   END  
    --END: If only HOTELSCOM is available    
        
   -- --Get marketplace calculated values to show on hoteldetails page    
   IF(@isNightlyRobotCall = 0)    
   BEGIN    
    IF(@IsWinner =1)    
    BEGIN    
  SELECT isnull(@hotelsComPrice ,0) as  EANBar,isnull(@touricoNet ,0) as  TouricoNet,isnull(@sabrePrice ,0) as  SabreBar    
    ,isnull(@touricoPrice ,0) as  TouricoCalculatedBar,isnull(@eanCommission ,0) as  EANCommission    
    ,isnull(@touricoCommission ,0) as  TouricoCommission,isnull(@sabreCommission ,0) as  SabreCommission,
	isnull(@touricoActualMarkupPercent ,0) as  TouricoActualMarkupPercent,isnull(@hotelbedsNet ,0) as  HotelBedsNet,
	isnull(@hotelbedsCommission,0) as HotelBedsCommission,
	isnull(@pricelineCommission,0) as PricelineCommission
  END    
 END       
END    
  
  
DROP TABLE #TmpHotelResponseDetail    
 


GO
