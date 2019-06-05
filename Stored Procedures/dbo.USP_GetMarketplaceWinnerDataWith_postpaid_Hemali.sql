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
-- Updated by Manoj on 18-05-2018 : - Added showGovRate rule.       
/*#############-- VERY IMPORTANT INFORMATION --###################          
 THIS STORED PROCEDURE IS CALLED FROM USP_GetDealHotelDetailsByResponseID          
 AND USP_GetMarketPlaceRoomRateWinner. ANY CHANGES MADE IN THIS PROCEDURE WILL          
 AFFECT THE MENTIONED PROCEDURE. MAKE SURE BOTH THE PROCEDURE ARE WORKING FINE           
 AFTER MAKING ANY CHANGES HERE*/          
          
CREATE PROCEDURE [dbo].[USP_GetMarketplaceWinnerDataWith_postpaid_Hemali]            
             
 @winner VARCHAR(20)            
 ,@hotelResponsekey UNIQUEIDENTIFIER            
 ,@isNightlyRobotCall BIT = 0            
 ,@hotelResponseDetailKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'            
 ,@gdsPrice FLOAT = 0            
 ,@touricoNet FLOAT = 0            
 ,@touricoCalculatedBar FLOAT = 0            
 ,@environment VARCHAR(15) = 'D'            
 ,@totalTaxRate FLOAT = 0
 ,@showGovRate BIT =0   
 ,@UserKey int =0
 ,@CompanyKey int =0
 ,@UserGroupKey Int = 0  
AS            
BEGIN            
             
 SET NOCOUNT ON;            
               
 DECLARE @touricoActualMarkupPercent FLOAT = 0            
   ,@touricoTaxRate FLOAT = 0            
   ,@hotelTotalPrice FLOAT = 0       

CREATE TABLE #FinalHotelResponseDetail(
	[hotelResponseDetailKey] [uniqueidentifier] NOT NULL,
	[hotelResponseKey] [uniqueidentifier] NOT NULL,
	[hotelDailyPrice] [float] NOT NULL,
	[hotelDescription] [varchar](500) NULL,
	[supplierId] [varchar](50) NOT NULL,
	[hotelRatePlanCode] [varchar](50) NULL,
	[hotelRoomTypeCode] [varchar](50) NULL,
	[hotelTotalPrice] [float] NULL,
	[hotelPriceType] [int] NULL,
	[hotelTaxRate] [float] NULL,
	[rateDescription] [varchar](1000) NULL,
	[guaranteeCode] [nchar](10) NULL,
	[CancellationPolicy] [nvarchar](4000) NULL,
	[hotelsComSupplierType] [nchar](10) NULL,
	[roomDescriptionShort] [varchar](1000) NULL,
	[roomDescription] [varchar](2000) NULL,
	[roomAmenities] [nvarchar](2000) NULL,
	[isNonRefundable] [bit] NULL,
	[supplierHotelKey] [varchar](50) NULL,
	[originalHotelDailyPrice] [float] NULL,
	[originalHotelTotalPrice] [float] NULL,
	[yieldManagementValueKey] [int] NULL,
	[originalHotelTaxRate] [float] NULL,
	[hotelTaxPercentage] [float] NULL,
	[salesTaxAndHotelOccupancyTax] [float] NULL,
	[marketPlacePreferenceOrder] [int] NULL,
	[depositAmount] [float] NULL,
	[valueAdds] [nvarchar](1000) NULL,
	[beforeCancellationDate] [varchar](500) NULL,
	[resortFee] [varchar](2000) NULL,
	[IsPromoTrue] [bit] NULL,
	[PromoDescription] [varchar](300) NULL,
	[AverageBaseRate] [float] NULL,
	[PromoId] [varchar](20) NULL,
	[touricoCalculationBarRate] [float] NULL,
	[touricoNetRate] [float] NULL,
	[displayPrice] [float] NULL,
	[numberOfNights] [int] NULL,
	[crowdPrice] [float] NULL,
	[MarketplaceMarginPercent] [float] NULL,
	[TouricoTaxRate] [float] NULL,
	[roomImages] [varchar](2000) NULL,
	[contractCode] [varchar](20) NULL,
	[nightlyRates] [varchar](max) NULL,
	[NoofRooms] [int] NULL,
	[IsGovtRate] [bit] NULL,
	[IsCompanyContractApplied][bit] NULL,
	TouricoActualMarkupPercent float,
	[ReasonCode] NVARCHAR(10) DEFAULT 'NONE'
   )


 --If the winner is not Tourico then simply select data from table            
 IF(@winner <> 'Tourico')            
 BEGIN            
  IF(@isNightlyRobotCall = 0)            
  BEGIN    
	  INSERT INTO #FinalHotelResponseDetail
   SELECT *            
   ,TouricoActualMarkupPercent = @touricoActualMarkupPercent, 'NONE' AS ReasonCode
   FROM HotelResponseDetail WITH (NOLOCK)            
   WHERE supplierId in (@winner, 'Sabre','HotelsCom')            
   AND hotelResponseKey = @hotelResponsekey            
   AND (rateDescription NOT LIKE ('%A A A%')             
   AND rateDescription NOT LIKE ('%AAA%')             
   AND rateDescription NOT LIKE ('%SENIOR%')             
   AND rateDescription not like CASE WHEN @showGovRate=0 then ('%GOV%') else '' end
   --AND rateDescription NOT LIKE case when @showGovRate=0 then ('%GOV%') end
   
   )            
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
    WHERE supplierId in (@winner, 'Sabre','HotelsCom')            
    AND hotelResponseKey = @hotelResponsekey            
    AND (rateDescription NOT LIKE ('%A A A%')             
    AND rateDescription NOT LIKE ('%AAA%')             
    AND rateDescription NOT LIKE ('%SENIOR%') 
	AND rateDescription not like CASE WHEN @showGovRate=0 then ('%GOV%') else '' end           
      -- AND rateDescription NOT LIKE case when @showGovRate=0 then ('%GOV%') end
	)            
    ORDER BY hotelTotalPrice ASC            
   END            
   ELSE            
   BEGIN            
    SELECT TOP 1             
    hotelTotalPrice            
    ,hotelResponseDetailKey            
    ,TouricoActualMarkupPercent = @touricoActualMarkupPercent              
    FROM HotelResponseDetail WITH (NOLOCK)            
    WHERE supplierId in (@winner,'Sabre','HotelsCom')            
    AND hotelResponseKey = @hotelResponsekey            
    AND (rateDescription NOT LIKE ('%A A A%')             
    AND rateDescription NOT LIKE ('%AAA%')             
    AND rateDescription NOT LIKE ('%SENIOR%')  
	AND rateDescription not like CASE WHEN @showGovRate=0 then ('%GOV%') else '' end   
      -- AND rateDescription NOT LIKE case when @showGovRate=0 then ('%GOV%') end
	)            
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
              
    
--print 'tourico net'      
--print @touricoNet    
--print 'gdsPrice'    
--print @gdsPrice    
  --Update hotelDailyPrice by actualMarkupPercent          

  select 1
      
  UPDATE THD            
  SET THD.hotelDailyPrice = dbo.udf_GetTouricoMarkupValue            
          (            
         SHD.touricoNetRate            
         ,@touricoActualMarkupPercent                     
          )            
  FROM #TmpHotelResponseDetail THD            
  INNER JOIN #TmpHotelResponseDetail SHD            
  ON SHD.hotelResponseDetailKey = THD.hotelResponseDetailKey            
   
   select 2           
          
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
  ,HRD.hotelTaxRate = @touricoTaxRate  
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

;WITH CTE AS(               
SELECT 
 * ,row_number() over(Partition by hotelRatePlanCode order by hotelRatePlanCode) RN            
   FROM HotelResponseDetail WITH (NOLOCK)            
   WHERE supplierId in (@winner, 'Sabre','HotelsCom')    
   AND hotelResponseKey = @hotelResponsekey            
   AND (rateDescription NOT LIKE ('%A A A%')             
   AND rateDescription NOT LIKE ('%AAA%')             
   AND rateDescription NOT LIKE ('%SENIOR%')
   AND rateDescription not like CASE WHEN @showGovRate=0 then ('%GOV%') else '' end             
      --AND rateDescription NOT LIKE case when @showGovRate=0 then ('%GOV%') end
   )            
) 
 insert into #FinalHotelResponseDetail
 select *,'NONE' AS ReasonCode from CTE where RN=1  
   ORDER BY hotelDailyPrice ASC           
  END            
  --THIS IS EXCLUSIVELY FOR NIGHTLY ROBOT            
  ELSE            
  BEGIN            
   IF(@environment = 'PRODUCTION')            
   BEGIN            
    ;WITH CTE AS(               
SELECT  TOP 1         
    hotelTotalPrice              
   -- Case when hotelTaxRate = 0 then  originalHotelTotalPrice else hotelTotalPrice end  as [hotelTotalPrice] --added for FS 15867        
    ,hotelResponseDetailKey            
    ,TouricoActualMarkupPercent = @touricoActualMarkupPercent ,row_number() over(Partition by hotelRatePlanCode order by hotelRatePlanCode) RN            
	             
    FROM HotelResponseDetail WITH (NOLOCK)            
    WHERE supplierId in(@winner,'Sabre','HotelsCom')      
    AND hotelResponseKey = @hotelResponsekey            
    AND (rateDescription NOT LIKE ('%A A A%')             
    AND rateDescription NOT LIKE ('%AAA%')             
    AND rateDescription NOT LIKE ('%SENIOR%')  
	AND rateDescription not like CASE WHEN @showGovRate=0 then ('%GOV%') else '' end           
      -- AND rateDescription NOT LIKE case when @showGovRate=0 then ('%GOV%') end
	)    
	) 
 select * from CTE where RN=1          
    ORDER BY hotelTotalPrice ASC            
   END            
   ELSE            
   BEGIN   
   ;WITH CTE AS(          
    SELECT TOP 1             
    hotelTotalPrice            
    --Case when hotelTaxRate = 0 then  originalHotelTotalPrice else hotelTotalPrice end  as [hotelTotalPrice] --added for FS 15867        
    ,hotelResponseDetailKey            
    ,TouricoActualMarkupPercent = @touricoActualMarkupPercent,row_number() over(Partition by hotelRatePlanCode order by hotelRatePlanCode) RN                      
    FROM HotelResponseDetail WITH (NOLOCK)            
    WHERE supplierId in(@winner,'Sabre','HotelsCom')            
    AND hotelResponseKey = @hotelResponsekey            
    AND (rateDescription NOT LIKE ('%A A A%')             
    AND rateDescription NOT LIKE ('%AAA%')             
    AND rateDescription NOT LIKE ('%SENIOR%')  
	AND rateDescription not like CASE WHEN @showGovRate=0 then ('%GOV%') else '' end           
       --AND rateDescription NOT LIKE case when @showGovRate=0 then ('%GOV%') end
	)            
    And ISNULL(guaranteeCode,'') <> 'D' )
	 select * from CTE where RN=1           
    ORDER BY hotelTotalPrice ASC             
   END            
  END            
 END            
 --END: If winner is TOURICO  
 
  IF(@isNightlyRobotCall = 0) 
  BEGIN
        -- Policy Implementation Start
		DECLARE @IsPolicyApplicable BIT= 0,@siteKey INT= 0, @TripType VARCHAR(50) , @tripTypeKey INT, @hotelRequestKey INT,@isInternationalTrip BIT=0,
				@MaxFareTotal FLOAT,	  @IsHideFare BIT=0,@HighFareTotal FLOAT,	@IsHighFareTotal BIT=0,@LowFareThreshold FLOAT,@IsLowFareThreshold BIT=0,@IsApplyGSA BIT= 0,
				@CityID INT= 0,@CheckInDate DATETIME, @CheckoutDate DATETIME
		SELECT @hotelRequestKey = hotelRequestKey FROM HotelResponse WHERE hotelResponseKey =  @hotelResponsekey
		SELECT @tripTypeKey = tripTypeKey FROM trip..TripRequest WHERE tripRequestKey =  (SELECT TripRequestkey FROM Trip..TripRequest_hotel WHERE hotelRequestKey = @hotelRequestKey)
		SELECT @TripType =  tripTypeName FROM TripTypeLookup WHERE tripTypeKey = @tripTypeKey
		SELECT @isInternationalTrip = IsInternationalTrip FROM trip..HotelRequest WHERE hotelRequestkey = @hotelRequestKey
		SELECT @CityID = CityID,@CheckInDate = checkinDate,@CheckoutDate = CheckoutDate FROM  HotelRequest WHERE hotelRequestKey =  @hotelRequestKey

		IF (@UserKey <> 0)
			BEGIN
			   SELECT @siteKey = siteKey FROM Vault..[User] WHERE userkey = @UserKey
			END

		IF (@siteKey <> 0)
		BEGIN
			SELECT @IsPolicyApplicable = ISNULL(data.value('(/Site/UI/IsPolicyApplicable/node())[1]', 'BIT'),0)
			FROM	Vault..SiteConfiguration 
			WHERE siteKey = @SiteKey
		END
		IF (@IsPolicyApplicable=1)
		BEGIN
			DECLARE @tblHotelPolicy as Table      
			(      
				policyDetailKey int,      
				policyKey int,    
				LowFareThresholdHotel FLOAT,
				IsLowFareThresholdHotel BIT,
				IsNotifyLowFareThresholdHotel BIT,
				IsApproveLowFareThresholdHotel BIT,
				LowFareThresholdHotelIntl FLOAT, 
				IsLowFareThresholdHotelIntl BIT,
				IsNotifyLowFareThresholdHotelIntl BIT,
				IsApproveLowFareThresholdHotelIntl BIT,
				MaxFareTotalHotel FLOAT, 
				IsMaxFareTotalHotel BIT,
				MaxFareTotalHotelIntl FLOAT, 
				IsMaxFareTotalHotelIntl BIT,
				HighFareTolHotelIntl FLOAT,
				IsHighFareTolHotelIntl BIT,
				IsNotifyHighFareTolHotelIntl BIT,
				IsApproveHighFareTolHotelIntl BIT,
				HighFareTolHotel FLOAT,
				IsHighFareTolHotel BIT,
				IsNotifyHighFareTolHotel BIT,
				IsApproveHighFareTolHotel BIT,
				IsApprovalRequiredHotel BIT,
				IsApproveApprovalHotel BIT,
				IsNotifyApprovalHotel BIT,
				IsApplyGSA BIT
			)  

			INSERT INTO @tblHotelPolicy(policyDetailKey, policyKey,
									LowFareThresholdHotel,IsLowFareThresholdHotel,
									LowFareThresholdHotelIntl,IsLowFareThresholdHotelIntl,
									MaxFareTotalHotel,IsMaxFareTotalHotel,
									MaxFareTotalHotelIntl,IsMaxFareTotalHotelIntl,
									HighFareTolHotelIntl,IsHighFareTolHotelIntl,
									HighFareTolHotel,IsHighFareTolHotel,IsApplyGSA) 
			SELECT		 			HotelPolicyDetailkey, policykey,
									LowFareThreshold, isLowFareThreshold,
									LowFareThresholdInternational, IsLowFareThresholdInternational,
									HotelSpendingCap, IsHotelSpendingCap,
									InternationalMaxFareTol, IsInternationalMaxFareTol,
									InternationalHighFareTol, IsInternationalHighFareTol,
									DomesticHighFareTol,IsDomesticHighFareTol,IsApplyGSA
									FROM vault.dbo.[udf_GetPolicyDetailsForHotel] (@UserKey, @CompanyKey, @TripType,@UserGroupKey)

			IF (@isInternationalTrip = 0)
				   SELECT TOP 1 @MaxFareTotal = MaxFareTotalHotel, @IsHideFare = IsMaxFareTotalHotel,  @HighFareTotal = HighFareTolHotel,@IsHighFareTotal = IsHighFareTolHotel,@LowFareThreshold = LowFareThresholdHotel, @IsLowFareThreshold = IsLowFareThresholdHotel, @IsApplyGSA = IsApplyGSA FROM @tblHotelPolicy
				ELSE
				   SELECT TOP 1 @MaxFareTotal = MaxFareTotalHotelIntl, @IsHideFare = IsMaxFareTotalHotelIntl,@HighFareTotal = HighFareTolHotelIntl,@IsHighFareTotal = IsHighFareTolHotelIntl,@LowFareThreshold = LowFareThresholdHotelIntl, @IsLowFareThreshold = IsLowFareThresholdHotelIntl,@IsApplyGSA = IsApplyGSA FROM @tblHotelPolicy          

			IF ((@MaxFareTotal != 0) and (@IsHideFare = 1))
			BEGIN
				DELETE FROM #FinalHotelResponseDetail 
				WHERE hotelResponseDetailKey IN  (SELECT A.hotelResponseDetailKey from #FinalHotelResponseDetail A WHERE ROUND(ISNULL(A.hotelDailyPrice,0),2) > ROUND(@MaxFareTotal,2))
			END
 
			IF (@HighFareTotal != 0 AND @IsHighFareTotal = 1)
			BEGIN
			IF (@MaxFareTotal !=0)
			BEGIN
				UPDATE #FinalHotelResponseDetail 
				SET ReasonCode = 'High' 
				WHERE hotelResponseDetailKey IN (SELECT A.hotelResponseDetailKey 
											FROM #FinalHotelResponseDetail A 
											WHERE ROUND(A.hotelDailyPrice,2) > ROUND(@HighFareTotal,2)
											AND ROUND(A.hotelDailyPrice,2) <=  ROUND(@MaxFareTotal,2))
			END
			ELSE
			BEGIN
				UPDATE #FinalHotelResponseDetail 
				SET ReasonCode  = 'High' 
				WHERE hotelResponseDetailKey IN (SELECT A.hotelResponseDetailKey 
											FROM #FinalHotelResponseDetail A 
											WHERE ROUND(A.hotelDailyPrice,2) > ROUND(@HighFareTotal,2))
			END
		END

		IF (( @IsLowFareThreshold =1) AND (@LowFareThreshold > 0))
		BEGIN
			DECLARE @LowestPrice FLOAT=0
			SELECT @LowestPrice =  MIN(minRate) FROM HotelResponse WHERE HotelRequestKey = @hotelRequestKey -- need to check
			
			if (@HighFareTotal != 0) 
			BEGIN
				UPDATE #FinalHotelResponseDetail 
				SET ReasonCode  = 'OOP' 
				WHERE hotelResponseDetailKey IN (SELECT A.hotelResponseDetailKey 
											FROM #FinalHotelResponseDetail A 
											WHERE ROUND(A.hotelDailyPrice,2) > ROUND((@LowestPrice + @LowFareThreshold),2)
											AND ROUND(A.hotelDailyPrice,2) <= ROUND(@HighFareTotal,2))
			END
			ELSE
			BEGIN
				UPDATE #FinalHotelResponseDetail 
				SET ReasonCode = 'OOP' 
				WHERE #FinalHotelResponseDetail IN (SELECT A.hotelResponseDetailKey 
											FROM #FinalHotelResponseDetail A 
											WHERE ROUND(A.hotelDailyPrice,2) > ROUND((@LowestPrice + @LowFareThreshold),2))
			END
		END

		--PER DIEM
		IF (@CityID<> 0 AND @CheckInDate IS NOT NULL AND @CheckoutDate IS NOT NULL)
		BEGIN
			DECLARE @LodgingRate INT = 0
			SELECT @LodgingRate = LodgingRate FROM vault..udf_GetPerDiemByCityID(@CityID, @CheckInDate, @CheckoutDate)
			IF (@LodgingRate <> 0)
			BEGIN
				IF (@IsApplyGSA = 1)
				BEGIN
					UPDATE #FinalHotelResponseDetail 
					SET ReasonCode = 'PerDiem' 
					WHERE hotelResponseDetailKey IN (SELECT A.hotelResponseDetailKey 
												FROM #FinalHotelResponseDetail A 
												WHERE ROUND(A.hotelDailyPrice,2) > @LodgingRate)
			
				END
			END
		END
	END
    SELECT * from #FinalHotelResponseDetail
  END           
                
END 
GO
