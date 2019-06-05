SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Jayant Guru  
-- Create date: 3rd Oct 2014  
-- Description: This SP derives the winner GDS for Hotel room rate call and gets all the data for that GDS  
-- Updated on 12th January 2015 - Fixed issue with tourico fare is not displaying with ean rate as base rate.  
-- Updated on 5th June 2017 - Now with room rate winner we need post paid hotel of sabre as well. And sabre will not participate in room rate winner - market place.  
-- =============================================    
--EXEC USP_GetMarketPlaceRoomRateWinner 'F1A3189C-2DCF-4EF3-900C-005EA83B2722'    
CREATE PROCEDURE [dbo].[USP_GetMarketPlaceRoomRateWinner_backup]    
     
  @hotelResponsekey UNIQUEIDENTIFIER    
 ,@isNightlyRobotCall BIT = 0  
 ,@price float = 9999999.99  
 ,@siteKey int = 0  
     
AS    
BEGIN    
 SET NOCOUNT ON;    
     print '1'
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
   ,@touricoActualMarkupPercent FLOAT    
   ,@displayPrice FLOAT = 0    
   ,@touricoBarCalculatedFromRoomRate FLOAT = 0    
   ,@touricoMarkupPercent FLOAT    
   ,@IsWinner BIT = 0    
   ,@isOperatingCostPercentHigher BIT = 0  
   ,@barRateWinner FLOAT = 0  
   ,@hotelsComTax FLOAT = 0  
   ,@sabreTax FLOAT = 0    
     
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
  ,originalHotelDailyPrice    
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
  AND hotelDailyPrice <= @price  
  print '2'
 --Set common marketplace values    
 IF @siteKey > 0  
 BEGIN  
  SELECT    
  @operatingCostPercent = ISNULL(OperatingCostPer, 0)    
  ,@operatingCostValue = ISNULL(OperatingCost, 0)    
  ,@marketPlaceVariableId = Id    
  FROM vault.dbo.MarketPlaceVariables    
  WHERE IsActive = 1  And SiteKey = @siteKey  
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
   print '3'
  
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
  
  print '4'
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
  print '6'
 --Get the lowest price for HotelsCom    
 SELECT TOP 1    
 @hotelsComPrice = ISNULL(hotelDailyPrice,0)  
 ,@hotelsComTax = ISNULL(hotelTaxRate, 0)    
 ,@hotelResponseDetailKeyEan = hotelResponseDetailKey       
 FROM #TmpHotelResponseDetail    
 WHERE supplierId = 'HotelsCom'    
 AND hotelResponseKey = @hotelResponsekey    
 ORDER BY hotelDailyPrice ASC   
   print '7'
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
  print '8'
 --Get the lowest price for Sabre    
 SELECT TOP 1    
 @sabrePrice = ISNULL(hotelDailyPrice,0)    
 ,@sabreTax = ISNULL(hotelTaxRate, 0)  
 ,@hotelResponseDetailKeySabre = hotelResponseDetailKey      
 FROM #TmpHotelResponseDetail    
 WHERE supplierId = 'Sabre'    
 AND hotelResponseKey = @hotelResponsekey    
 ORDER BY hotelDailyPrice ASC     
    print '8.1'  
  --If we get results for all 3 GDS    
  --print 'sabre price ' + Convert(varchar, @sabrePrice)  
  --print 'ean price ' + Convert(varchar, @hotelsComPrice)  
  --print 'tourico price ' + Convert(varchar, @touricoPrice)  
 --IF(@sabrePrice > 0 AND @touricoPrice > 0 AND @hotelsComPrice > 0)    
 --BEGIN     
 ----If Sabre price is higher than HotelsCom price then ignore Sabre    
 --IF(@sabrePrice > @hotelsComPrice)    
 --BEGIN    
  
 -- SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)    
 -- SET @touricoCommission = dbo.udf_GetTouricoCommission(@hotelsComPrice, @operatingCostPercent, @operatingCostValue, @touricoNet)    
  
 -- --When HotelsCom commission is higher    
 -- IF(@eanCommission > @touricoCommission)    
 -- BEGIN    
 --  EXEC USP_GetMarketplaceWinnerData     
 --  @winner = 'Hotelscom'    
 --  ,@hotelResponsekey = @hotelResponsekey    
 --  ,@isNightlyRobotCall = @isNightlyRobotCall    
 -- END    
 -- --When Tourico commission is higher    
 -- ELSE       
 -- BEGIN    
 --  EXEC USP_GetMarketplaceWinnerData     
 --  @winner = 'Tourico'    
 --  ,@hotelResponsekey = @hotelResponsekey    
 --  ,@isNightlyRobotCall = @isNightlyRobotCall    
 --  ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
 --  ,@gdsPrice = @hotelsComPrice    
 --  ,@touricoNet = @touricoNet  
 --  ,@totalTaxRate = @hotelsComTax    
 -- END     
  
 --END    
 ----END: If Sabre price is higher than HotelsCom price then ignore Sabre    
 ----If Sabre price is LESS than HotelsCom price then ignore HotelsCom    
 --ELSE IF(@hotelsComPrice > @sabrePrice)    
 --BEGIN    
 -- SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)   
 -- SET @touricoCommission = dbo.udf_GetTouricoCommission(@sabrePrice, @operatingCostPercent, @operatingCostValue, @touricoNet)    
  
 ----When Sabre commission is higher    
 --IF(@sabreCommission > @touricoCommission)    
 --BEGIN    
 -- EXEC USP_GetMarketplaceWinnerData     
 -- @winner = 'Sabre'    
 -- ,@hotelResponsekey = @hotelResponsekey    
 -- ,@isNightlyRobotCall = @isNightlyRobotCall    
 --END    
 ----When Tourico commission is higher    
 --ELSE    
 --BEGIN        
 -- EXEC USP_GetMarketplaceWinnerData     
 -- @winner = 'Tourico'    
 -- ,@hotelResponsekey = @hotelResponsekey    
 -- ,@isNightlyRobotCall = @isNightlyRobotCall    
 -- ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
 -- ,@gdsPrice = @hotelsComPrice    
 -- ,@touricoNet = @touricoNet  
 -- ,@totalTaxRate = @hotelsComTax         
 --END       
 --END    
 ----END: If Sabre price is LESS than HotelsCom price then ignore HotelsCom    
 ----If Sabre price and HotelsCom price are same    
 --ELSE IF(@sabrePrice = @hotelsComPrice)    
 --BEGIN    
 -- --Calculate commission for all 3 GDS. In case of Tourico Commission use hotels com minimum bar rate    
 -- SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)    
 -- SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)    
 -- SET @touricoCommission = dbo.udf_GetTouricoCommission(@hotelsComPrice, @operatingCostPercent, @operatingCostValue, @touricoNet)    
 -- --print 'sabre ' + Convert(varchar, @sabreCommission)  
 -- --print 'ean ' + Convert(varchar, @eanCommission)  
 -- SET @winner =      
 -- CASE WHEN @sabreCommission > @eanCommission     
 -- AND @sabreCommission > @touricoCommission     
 -- THEN 'Sabre'    
 -- WHEN @eanCommission > @sabreCommission    
 -- AND @eanCommission > @touricoCommission    
 -- THEN 'Hotelscom'    
 -- WHEN @touricoCommission > @sabreCommission    
 -- AND @touricoCommission > @eanCommission    
 -- THEN 'Tourico'    
 -- ELSE 'Hotelscom'    
 -- END    
  
 ----Winner other than Tourico    
 --IF(@winner <> 'Tourico')    
 --BEGIN    
 -- EXEC USP_GetMarketplaceWinnerData     
 -- @winner = @winner    
 -- ,@hotelResponsekey = @hotelResponsekey    
 -- ,@isNightlyRobotCall = @isNightlyRobotCall    
 --END    
   
 --ELSE IF  (@touricoPrice > 0 AND @sabrePrice =0 AND @hotelsComPrice =0)  
 --BEGIN    
 -- EXEC USP_GetMarketplaceWinnerData     
 -- @winner = @winner    
 -- ,@hotelResponsekey = @hotelResponsekey    
 -- ,@isNightlyRobotCall = @isNightlyRobotCall    
 -- ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
 -- ,@gdsPrice = @hotelsComPrice    
 -- ,@touricoNet = @touricoNet  
 -- --,@totalTaxRate = @touricoTaxRate    
 --END    
   
 ----When tourico is the winner    
 --ELSE    
 --BEGIN    
 -- EXEC USP_GetMarketplaceWinnerData     
 -- @winner = @winner    
 -- ,@hotelResponsekey = @hotelResponsekey    
 -- ,@isNightlyRobotCall = @isNightlyRobotCall    
 -- ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
 -- ,@gdsPrice = @hotelsComPrice    
 -- ,@touricoNet = @touricoNet  
 -- ,@totalTaxRate = @hotelsComTax    
 --END    
  
 --END    
 ----END: If Sabre price and HotelsCom price are same    
  
 --Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
  
 --END    
 ----END: If we get results for all 3 GDS    
 ----If EAN and Sabre Price is available AND Tourico price is not available    
 --ELSE IF(@sabrePrice > 0 AND @hotelsComPrice > 0 AND @touricoPrice = 0)    
 --BEGIN    
 -- --In this case commission is not calculated but the winner is decided using the lowest bar rate    
 -- SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)    
 -- SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)   
  
 -- --IF(@hotelsComPrice < @sabrePrice)    
 -- IF(@eanCommission > @sabreCommission)  
 -- BEGIN    
 --  EXEC USP_GetMarketplaceWinnerData     
 --  @winner = 'Hotelscom'    
 --  ,@hotelResponsekey = @hotelResponsekey    
 --  ,@isNightlyRobotCall = @isNightlyRobotCall    
 -- END    
 -- ELSE    
 -- BEGIN    
 --     if(@hotelsComPrice < @sabrePrice)  
 --     BEGIN   
 --       EXEC USP_GetMarketplaceWinnerData     
 --    @winner = 'Hotelscom'    
 --    ,@hotelResponsekey = @hotelResponsekey    
 --   ,@isNightlyRobotCall = @isNightlyRobotCall    
 --     END  
 --     ELSE  
 --     BEGIN  
 --   EXEC USP_GetMarketplaceWinnerData     
 --   @winner = 'Sabre'    
 --   ,@hotelResponsekey = @hotelResponsekey    
 --   ,@isNightlyRobotCall = @isNightlyRobotCall    
 --  END  
 -- END    
 -- Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
 --END    
 ----END: If EAN and Sabre Price is available AND Tourico price is not available    
 ----If Sabre and Tourico is availble but EAN is not available    
 --ELSE IF(@sabrePrice > 0 AND @touricoPrice > 0 AND @hotelsComPrice = 0)    
 --BEGIN    
 -- IF(@sabrePrice < @touricoPrice)    
 -- BEGIN         
 --  --Calculate the commision for both. Use Sabre bar to calculate Tourico commission    
 --  SET @sabreCommission = dbo.udf_GetMarketPlaceCommission(@sabrePrice, @sabreCommissionPercent)    
 --  SET @touricoCommission = dbo.udf_GetTouricoCommission(@sabrePrice, @operatingCostPercent, @operatingCostValue, @touricoNet)    
  
 -- IF(@sabreCommission > @touricoCommission)    
 -- BEGIN    
 --  EXEC USP_GetMarketplaceWinnerData     
 --  @winner = 'Sabre'    
 --  ,@hotelResponsekey = @hotelResponsekey    
 --  ,@isNightlyRobotCall = @isNightlyRobotCall    
 -- END    
 -- ELSE    
 -- BEGIN       
 --  EXEC USP_GetMarketplaceWinnerData     
 --  @winner = 'Tourico'    
 --  ,@hotelResponsekey = @hotelResponsekey    
 --  ,@isNightlyRobotCall = @isNightlyRobotCall    
 --  ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
 --  ,@gdsPrice = @touricoPrice    
 --  ,@touricoNet = @touricoNet     
 -- END    
  
 -- Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
 -- END    
 -- ELSE    
 -- --If Tourico Price is less than Sabre Price    
 -- BEGIN    
 -- --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
 -- SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
 --  (    
 --   @touricoMarkupPercent    
 --   ,@touricoNet                 
 --  )    
 -- EXEC USP_GetMarketplaceWinnerData     
 -- @winner = 'Tourico'    
 -- ,@hotelResponsekey = @hotelResponsekey    
 -- ,@isNightlyRobotCall = @isNightlyRobotCall    
 -- ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
 -- ,@gdsPrice = @touricoBarCalculatedFromRoomRate    
 -- ,@touricoNet = @touricoNet    
 -- ,@touricoCalculatedBar = @touricoPrice    
  
 -- Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
 -- END    
 -- --END: If Tourico Price is less than Sabre Price    
 --END    
 --END: If Sabre and Tourico is availble but EAN is not available    
 --If EAN and Tourico is availble but Sabre is not available    
 IF(@hotelsComPrice > 0 AND @touricoPrice > 0)    
 BEGIN    
     print '8.2' 
  IF(@hotelsComPrice < @touricoPrice)    
  BEGIN    
   --Calculate the commision for both. Use Hotels Com bar to calculate Tourico commission     
   SET @eanCommission = dbo.udf_GetMarketPlaceCommission(@hotelsComPrice, @hotelsComCommissionPercent)    
   SET @touricoCommission = dbo.udf_GetTouricoCommission(@hotelsComPrice, @operatingCostPercent, @operatingCostValue, @touricoNet)    
   print '9'
  IF(@eanCommission > @touricoCommission)    
  BEGIN    
   EXEC USP_GetMarketplaceWinnerData     
   @winner = 'Hotelscom'    
   ,@hotelResponsekey = @hotelResponsekey    
   ,@isNightlyRobotCall = @isNightlyRobotCall     
  END    
  ELSE    
  BEGIN     
   EXEC USP_GetMarketplaceWinnerData     
   @winner = 'Tourico'    
   ,@hotelResponsekey = @hotelResponsekey    
   ,@isNightlyRobotCall = @isNightlyRobotCall    
   ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
   ,@gdsPrice = @hotelsComPrice    
   ,@touricoNet = @touricoNet    
   ,@totalTaxRate = @hotelsComTax  
   print '10'
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
   print '11'
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
  
  EXEC USP_GetMarketplaceWinnerData     
  @winner = 'Tourico'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
  ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
  ,@gdsPrice = @barRateWinner    
  ,@touricoNet = @touricoNet    
  ,@totalTaxRate = @hotelsComTax    
  
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected     
  END    
  --END: If Tourico Price is less than Hotels com Price    
  
 END    
 --END: If EAN and Tourico is availble but Sabre is not available    
 --If only TOURICO is available    
 ELSE IF(@touricoPrice > 0 AND @hotelsComPrice = 0)    
 BEGIN    
  print '8.3' 
  /*IF MARKUP PERCENT IS LOW OR ZERO THEN SET MARK UP PERCENT AS OPERATING PERCENT.    
  THIS WILL ALLOW TO ATLEAST TO RECOVER THE OPERATING COST*/    
  IF(ISNULL(@operatingCostPercent, 0) > ISNULL(@touricoMarkupPercent, 0))    
  BEGIN    
   SET @touricoMarkupPercent = @operatingCostPercent    
   SET @isOperatingCostPercentHigher = 1    
  END    
   print '8.4' 
  --Calculate Tourico bar based on Tourico Net and Tourico Markup percent    
  SET @touricoBarCalculatedFromRoomRate = dbo.udf_GetTouricoBar    
   (    
    @touricoMarkupPercent    
    ,@touricoNet                 
   )    
   print 'tourico markup'
  print @touricoMarkupPercent
  print 'tourico net' 
  print @touricoNet
  IF(@isOperatingCostPercentHigher = 1)    
  BEGIN    
   SET @touricoBarCalculatedFromRoomRate = @touricoBarCalculatedFromRoomRate + @operatingCostValue    
  END    
   print '8.5' 
   print @touricoBarCalculatedFromRoomRate
  EXEC USP_GetMarketplaceWinnerData     
  @winner = 'Tourico'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
  ,@hotelResponseDetailKey = @hotelResponseDetailKeyTourico    
  ,@gdsPrice = @touricoBarCalculatedFromRoomRate    
  ,@touricoNet = @touricoNet    
  ,@touricoCalculatedBar = @touricoPrice    
   print '8.6' 
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
 END    
 --END: If only TOURICO is available    
 --If only SABRE is available    
 ELSE IF(@sabrePrice > 0 AND @touricoPrice = 0 AND @hotelsComPrice = 0)    
 BEGIN    
  EXEC USP_GetMarketplaceWinnerData     
  @winner = 'Sabre'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
  
  Set @IsWinner = 1 -- This will be used to get calculated values only if any winner has been selected    
 END    
 --END: If only SABRE is available    
 --If only HOTELSCOM is available    
 ELSE IF(@hotelsComPrice > 0 AND @touricoPrice = 0)    
 BEGIN    
  EXEC USP_GetMarketplaceWinnerData     
  @winner = 'Hotelscom'    
  ,@hotelResponsekey = @hotelResponsekey    
  ,@isNightlyRobotCall = @isNightlyRobotCall    
  
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
    ,isnull(@touricoCommission ,0) as  TouricoCommission,isnull(@sabreCommission ,0) as  SabreCommission,isnull(@touricoActualMarkupPercent ,0) as  TouricoActualMarkupPercent    
  END    
 END       
END    
    
DROP TABLE #TmpHotelResponseDetail  
GO
