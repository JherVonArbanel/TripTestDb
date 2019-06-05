SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
-- =============================================    
-- Author:  Jayant Guru    
-- Create date: 3rd Oct 2014    
-- Description: It will Update and get marketplace GDS winner data    
-- =============================================    
-- Updated by Manoj on 21-09-2015 : - Removed the check for taxRate is greater than 0 for updating touricoTaxRate.  
/*#############-- VERY IMPORTANT INFORMATION --###################    
 THIS STORED PROCEDURE IS CALLED FROM USP_GetDealHotelDetailsByResponseID    
 AND USP_GetMarketPlaceRoomRateWinner. ANY CHANGES MADE IN THIS PROCEDURE WILL    
 AFFECT THE MENTIONED PROCEDURE. MAKE SURE BOTH THE PROCEDURE ARE WORKING FINE     
 AFTER MAKING ANY CHANGES HERE*/    
    
/*Tourico tax rate is originally captured */

CREATE PROCEDURE [dbo].[USP_GetMarketplaceWinnerData]    
     
 @winner VARCHAR(20)    
 ,@hotelResponsekey UNIQUEIDENTIFIER    
 ,@isNightlyRobotCall BIT = 0    
 ,@hotelResponseDetailKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'    
 ,@gdsPrice FLOAT = 0    
 ,@touricoNet FLOAT = 0    
 ,@touricoCalculatedBar FLOAT = 0    
 ,@environment VARCHAR(15) = 'D'    
 ,@totalTaxRate FLOAT = 0    
AS    
BEGIN    
     
 SET NOCOUNT ON;    
     
 DECLARE @touricoActualMarkupPercent FLOAT = 0    
   ,@touricoTaxRate FLOAT = 0    
   ,@hotelTotalPrice FLOAT = 0    
     
 --If the winner is not Tourico then simply select data from table    
 IF(@winner <> 'Tourico')    
 BEGIN    
  IF(@isNightlyRobotCall = 0)    
  BEGIN       
   SELECT *    
   ,TouricoActualMarkupPercent = @touricoActualMarkupPercent    
   FROM HotelResponseDetail WITH (NOLOCK)    
   WHERE supplierId = @winner    
   AND hotelResponseKey = @hotelResponsekey    
   AND (rateDescription NOT LIKE ('%A A A%')     
   AND rateDescription NOT LIKE ('%AAA%')     
   AND rateDescription NOT LIKE ('%SENIOR%')     
   AND rateDescription NOT LIKE ('%GOV%'))    
   ORDER BY hotelDailyPrice ASC       
  END    
  --THIS IS EXCLUSIVELY FOR NIGHTLY ROBOT    
  ELSE      
  BEGIN    
   IF(@environment = 'PRODUCTION')    
   BEGIN    
    SELECT TOP 1     
    hotelTotalPrice    
    ,hotelResponseDetailKey    
    ,TouricoActualMarkupPercent = @touricoActualMarkupPercent      
    FROM HotelResponseDetail WITH (NOLOCK)    
    WHERE supplierId = @winner    
    AND hotelResponseKey = @hotelResponsekey    
    AND (rateDescription NOT LIKE ('%A A A%')     
    AND rateDescription NOT LIKE ('%AAA%')     
    AND rateDescription NOT LIKE ('%SENIOR%')     
    AND rateDescription NOT LIKE ('%GOV%'))    
    ORDER BY hotelTotalPrice ASC    
   END    
   ELSE    
   BEGIN    
    SELECT TOP 1     
    hotelTotalPrice    
    ,hotelResponseDetailKey    
    ,TouricoActualMarkupPercent = @touricoActualMarkupPercent      
    FROM HotelResponseDetail WITH (NOLOCK)    
    WHERE supplierId = @winner    
    AND hotelResponseKey = @hotelResponsekey    
    AND (rateDescription NOT LIKE ('%A A A%')     
    AND rateDescription NOT LIKE ('%AAA%')     
    AND rateDescription NOT LIKE ('%SENIOR%')     
    AND rateDescription NOT LIKE ('%GOV%'))    
    And ISNULL(guaranteeCode,'') <> 'D'    
    ORDER BY hotelTotalPrice ASC     
   END    
  END    
 END    
 --END: If the winner is not Tourico then simply select data from table    
 --If winner is TOURICO    
 ELSE    
 BEGIN    
  --Delete data which doesn't belong to TOURICO    
  DELETE FROM #TmpHotelResponseDetail    
  WHERE supplierId <> @winner    
      
  --Find markup percent to be applied form 2nd room onwards    
  SET @touricoActualMarkupPercent = dbo.udf_GetActualTouricoMarkupPercent    
            (    
            @touricoNet    
            ,@gdsPrice    
             )    
			 print 'fetching price'
			 print @gdsPrice
      print @touricoActualMarkupPercent 
  --Update hotelDailyPrice by actualMarkupPercent    
  UPDATE THD    
  SET THD.hotelDailyPrice = dbo.udf_GetTouricoMarkupValue    
          (    
         SHD.touricoNetRate
         ,@touricoActualMarkupPercent              
          )    
  FROM #TmpHotelResponseDetail THD    
  INNER JOIN #TmpHotelResponseDetail SHD    
  ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey    
      
  --APPLICABLE IN CASE OF ONLY TOURICO    
  IF(@touricoCalculatedBar > 0)    
  BEGIN    
   SET @gdsPrice = @touricoCalculatedBar     
  END    
      
  --The minimum price displayed in details page should be updated by hotelsCom/Tourico/Sabre minimum price      
  --IF(ISNULL(@totalTaxRate, 0) = false)    
  --BEGIN    
   SELECT @touricoTaxRate = ISNULL(TouricoTaxRate, 0), @hotelTotalPrice = hotelTotalPrice FROM HotelResponseDetail WHERE hotelResponseDetailKey = @hotelResponseDetailKey    
   IF(@touricoTaxRate = 0)    
   BEGIN    
    SELECT @touricoTaxRate = hotelTaxRate     
    ,@hotelTotalPrice = hotelTotalPrice    
    FROM #TmpHotelResponseDetail     
    WHERE hotelResponseDetailKey = @hotelResponseDetailKey    
        
    --Subtract the tourico tax rate from total price, then add the hotelscom tax to total price    
    SET @hotelTotalPrice = @hotelTotalPrice - @touricoTaxRate    
    SET @hotelTotalPrice = @hotelTotalPrice + @totalTaxRate    
        
    UPDATE #TmpHotelResponseDetail    
    SET hotelDailyPrice = @gdsPrice   
    ,hotelTaxRate = @totalTaxRate    
    ,hotelTotalPrice = @hotelTotalPrice      
    WHERE hotelResponseDetailKey = @hotelResponseDetailKey    
   END    
  --END    
  --ELSE    
  --BEGIN    
  -- UPDATE #TmpHotelResponseDetail    
  -- SET hotelDailyPrice = @gdsPrice       
  -- WHERE hotelResponseDetailKey = @hotelResponseDetailKey    
  --END    
      
  /*Update hotelTotalPrice based on number of nights, hotelTaxRate    
  and hotelDailyPrice(this price is updated in the above query. so we need to update     
  hotelTotalPrice based on new hotelDailyPrice)*/    
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
      
  --Update HotelResponseDetail with new price values    
  UPDATE HRD    
  SET HRD.hotelDailyPrice = THD.hotelDailyPrice 
  ,HRD.hotelTotalPrice = THD.hotelTotalPrice    
  ,HRD.hotelTaxRate = @touricoTaxRate--THD.hotelTaxRate    
  ,HRD.TouricoTaxRate = @touricoTaxRate    
  FROM HotelResponseDetail HRD    
  INNER JOIN #TmpHotelResponseDetail THD    
  ON THD.hotelResponseDetailKey = HRD.hotelResponseDetailKey    
      
  IF(@isNightlyRobotCall = 0)    
  BEGIN       
   UPDATE HotelResponseDetail    
   SET MarketplaceMarginPercent = @touricoActualMarkupPercent    
   WHERE hotelResponseKey = @hotelResponsekey    
   AND supplierId = @winner    
       
   SELECT *    
   FROM HotelResponseDetail WITH (NOLOCK)    
   WHERE supplierId = @winner    
   AND hotelResponseKey = @hotelResponsekey    
   AND (rateDescription NOT LIKE ('%A A A%')     
   AND rateDescription NOT LIKE ('%AAA%')     
   AND rateDescription NOT LIKE ('%SENIOR%')     
   AND rateDescription NOT LIKE ('%GOV%'))    
   ORDER BY hotelDailyPrice ASC    
  END    
  --THIS IS EXCLUSIVELY FOR NIGHTLY ROBOT    
  ELSE    
  BEGIN    
   IF(@environment = 'PRODUCTION')    
   BEGIN    
    SELECT TOP 1 
    hotelTotalPrice      
   -- Case when hotelTaxRate = 0 then  originalHotelTotalPrice else hotelTotalPrice end  as [hotelTotalPrice] --added for FS 15867
    ,hotelResponseDetailKey    
    ,TouricoActualMarkupPercent = @touricoActualMarkupPercent      
    FROM HotelResponseDetail WITH (NOLOCK)    
    WHERE supplierId = @winner    
    AND hotelResponseKey = @hotelResponsekey    
    AND (rateDescription NOT LIKE ('%A A A%')     
    AND rateDescription NOT LIKE ('%AAA%')     
    AND rateDescription NOT LIKE ('%SENIOR%')     
    AND rateDescription NOT LIKE ('%GOV%'))    
    ORDER BY hotelTotalPrice ASC    
   END    
   ELSE    
   BEGIN    
    SELECT TOP 1     
    hotelTotalPrice    
    --Case when hotelTaxRate = 0 then  originalHotelTotalPrice else hotelTotalPrice end  as [hotelTotalPrice] --added for FS 15867
    ,hotelResponseDetailKey    
    ,TouricoActualMarkupPercent = @touricoActualMarkupPercent      
    FROM HotelResponseDetail WITH (NOLOCK)    
    WHERE supplierId = @winner    
    AND hotelResponseKey = @hotelResponsekey    
    AND (rateDescription NOT LIKE ('%A A A%')     
    AND rateDescription NOT LIKE ('%AAA%')     
    AND rateDescription NOT LIKE ('%SENIOR%')     
    AND rateDescription NOT LIKE ('%GOV%'))    
    And ISNULL(guaranteeCode,'') <> 'D'    
    ORDER BY hotelTotalPrice ASC     
   END    
  END    
 END    
 --END: If winner is TOURICO     
        
END    
GO
