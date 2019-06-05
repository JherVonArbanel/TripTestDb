SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  Jayant Guru    
-- Create date:    
-- Description: Get Hotel Deals  
-- =============================================    
--Exec USP_GetTripSavedDealHotelRadius  33771,1083,5,3,236,10,0.5,1,15,1.5,'107230','NEIGHBOURHOOD'  
--Exec USP_GetTripSavedDealHotelMinPrice_Marketplace 73198,1  
CREATE PROCEDURE [dbo].[USP_GetTripSavedDealHotelMinPrice]  
 -- Add the parameters for the stored procedure here  
 @HotelRequestKey int  
 ,@PkGroupId int  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
 --BEGIN TRY  
 Declare @isDefaultVal int = 0 --for TFS #19445  
 Declare @TblMinCurrentPrice As Table(PkId int identity(1,1),CurrentMinimumPrice float,HotelResponseKey Uniqueidentifier,IsUsed Bit Default(0)  
 ,FareCategory varchar(30),MinRate Float,Remarks Varchar(2000),HotelId Varchar(30))  
   
 Declare @TblMinCurrentPriceCache As Table(PkId int identity(1,1),CurrentMinimumPrice float,HotelResponseKey Uniqueidentifier,IsUsed Bit Default(0)  
 ,FareCategory varchar(30),MinRate Float,Remarks Varchar(2000),HotelId Varchar(30))  
   
 Declare @TblGroup As Table(TblGroupKey int identity(1,1),TripKey int,Rating float,RatingType varchar(16),ZipCode varchar(16)  
 ,IsInserted Bit Default(0),TripSavedKey UniqueIdentifier)  
   
 Declare @TblResponseKey As Table(ResponseKey UniqueIdentifier)  
 Declare @TblVendorDetails AS Table (VendorDetailsId int identity(1,1),VendorDetails Varchar(200),CreationDate Datetime,IsUsed bit Default(0))  
   
 Declare @insertCount int  
   ,@countToExecute int  
   ,@TK int  
   ,@BookedPrice Float  
   ,@CurrentMinimumPrice Float  
   ,@PkId int  
   ,@MinCurrentPriceCount int  
   ,@LoopCount int  
   ,@NoOfDays int  
   ,@Rating Float  
   ,@RatingType varchar(16)  
   ,@ZipCode varchar(16)  
   ,@ResponseKeyCount int  
   ,@HotelResponseKey uniqueidentifier = '00000000-0000-0000-0000-000000000000'  
   ,@TripSavedKey UniqueIdentifier  
   ,@checkInTime Datetime  
   ,@checkOutTime DateTime  
   ,@OriginalHotelResponseKey uniqueidentifier = '00000000-0000-0000-0000-000000000000'  
   ,@OriginalHotelID int  
   ,@NewHotelID int = 0  
   ,@StoreNewHotelID int  
   ,@MinimumPrice Float  
   ,@VendorDetailsCount int = 0  
   ,@IntervalDays int  
   ,@StoreIntervalDays int  
   ,@StoreHotelResponseKey uniqueidentifier  
   ,@IntervalNewHotelID int  
   ,@OriginalTotalPrice Float  
   ,@Latitude Float  
   ,@Longitude Float  
   ,@TblGroupKey Int  
   ,@HotelDailyPrice Float  
   ,@SupplierHotelID Varchar(10)  
   ,@StarRatingConsideration Float  
   ,@StarRatingStep1_1 Float  
   ,@StarRatingStep1_2 Float  
   ,@StarRatingStep2_1 Float  
   ,@PriceCap Float  
   ,@RepetitionInterval Float  
   ,@ThresholdPricePerDay Float  
   ,@NoOfRooms Int  
   ,@NeighbourhoodCount Int  
   ,@MilesIterationInitialize Int  
   ,@MilesIteration Int  
   ,@MilesIncrement Int  
   ,@RadiusInMiles Int = 0  
   ,@MilesStart Int  
   ,@MinRepetitionInterval Float  
   ,@VendorCountComparison Int  
   ,@DODIntervalCount Int  
   ,@TripSavedLowestDealResponseKey UniqueIdentifier = '00000000-0000-0000-0000-000000000000'  
   ,@ErrorMessage VARCHAR(4000)  
   ,@TripSavedLowestAdjustRating Float = 0  
   ,@UserKey INT  
   ,@TripFrom VARCHAR(3)  
   ,@TripTo VARCHAR(3)  
   ,@TripStartDate DATETIME  
   ,@TripEndDate DATETIME  
   ,@TripEndMonth INT  
   ,@TripEndYear INT     
   ,@RegionId INT  
   ,@RegionName VARCHAR(200)  
   ,@HotelRatingTMU FLOAT  
   ,@HotelName VARCHAR(200)  
   ,@TripRequestKey INT  
   ,@FromCountryCode VARCHAR(2)  
   ,@FromCountryName VARCHAR(128)  
   ,@FromStateCode VARCHAR(2)  
   ,@FromCityName VARCHAR(64)  
   ,@ToCountryCode VARCHAR(2)  
   ,@ToCountryName VARCHAR(128)  
   ,@ToStateCode VARCHAR(2)  
   ,@ToCityName VARCHAR(64)  
   ,@HotelChainCode VARCHAR(20)  
   ,@SupplierFamily VARCHAR(16)  
   ,@CurrentHotelsComId VARCHAR(10)  
   ,@CurrentSupplierFamily VARCHAR(16)  
   ,@CurrentSupplierId VARCHAR(10)  
   ,@touricoFloorMarginPercent FLOAT  
   ,@operatingCostPercent FLOAT  
   ,@operatingCostValue FLOAT  
   ,@marketPlaceVariablesId INT  
   ,@crowdDiscountPercent FLOAT  
   ,@strikeThroughPrice FLOAT  
   ,@hotelsComStripPrice FLOAT  
   ,@crowdSupplierFamily VARCHAR(20)          
   ,@isCrowd BIT = 0     
   
 Insert Into TmpHotelResponse(HotelResponseKey,HotelRequestKey,SupplierHotelKey,supplierId,minRate,minRateTax  
 ,HotelsComType,PreferenceOrder,CorporateCode,Rating,RatingType,ZipCode,FareCategory,HotelId,Latitude,Longitude  
 ,TouricoCostBasisRate,TouricoNetRate,TouricoCalculatedBarRate, AverageBaseRate)  
 Select Distinct HR.HotelResponseKey,HR.HotelRequestKey,HR.SupplierHotelKey,HR.supplierId,HR.minRate,HR.minRateTax  
 ,HR.HotelsComType,HR.PreferenceOrder,HR.CorporateCode,VW_SHR.Rating,VW_SHR.RatingType  
 ,VW_SHR.ZipCode,HR.corporateCode,VW_SHR.HotelId,VW_SHR.Latitude,VW_SHR.Longitude  
 ,HR.touricoCostBasisRate,HR.TouricoNetRate,HR.TouricoCalculatedBarRate, HR.averageBaseRate  
 From HotelResponse HR With (NoLock)   
 Inner Join vw_hotelDetailedResponseDeals VW_SHR With (NoLock)  
 On HR.hotelResponseKey = VW_SHR.hotelResponseKey  
 And ISNULL(VW_SHR.Rating,0) > 0  
 Where HR.hotelRequestKey = @HotelRequestKey  
 AND (HR.hotelId IS NOT NULL OR HR.hotelId <> 0)  
   
 SELECT   
 @marketPlaceVariablesId = Id  
 ,@operatingCostPercent = OperatingCostPer  
 ,@operatingCostValue = OperatingCost  
 ,@crowdDiscountPercent = CrowdDiscountPer   
 FROM vault.dbo.MarketPlaceVariables  
 WHERE IsActive = 1  
   
 --TOURICO VALUES(GDSID = 5)  
 SELECT   
 @touricoFloorMarginPercent = CrowdFloorMarkupPer   
 FROM vault.dbo.MarketPlaceVariablesGDS  
 WHERE GDSId = 5  
 AND MarketPlaceVariablesId = @marketPlaceVariablesId  
   
 /*Update touricoCalculatedBarRate, touricoNetRate & touricoCostBasisRate for those  
 hotels of HotelsCom which has its equivalent tourico rate  
 Update touricoCalculatedBarRate with HotelsCom Minrate as the display price should  
 be same across all GDS*/  
 UPDATE FHR  
 SET FHR.touricoCalculatedBarRate = FHR.minRate  
 ,FHR.touricoNetRate = THR.touricoNetRate  
 ,FHR.touricoCostBasisRate = THR.touricoCostBasisRate  
 FROM TmpHotelResponse FHR  
 INNER JOIN TmpHotelResponse THR  
 ON THR.hotelId = FHR.hotelId  
 AND THR.supplierId = 'Tourico'  
 WHERE FHR.supplierId = 'Hotelscom'  
   
 UPDATE THR  
 SET THR.TouricoCostBasisCrowdRate = dbo.udf_GetTouricoCostBasisForCrowd  
          (  
           THR.TouricoNetRate  
           ,@touricoFloorMarginPercent  
           ,@operatingCostPercent  
           ,@operatingCostValue  
          )  
 FROM TmpHotelResponse THR  
 INNER JOIN TmpHotelResponse FHR  
 ON FHR.HotelResponseKey = THR.HotelResponseKey  
 AND THR.HotelRequestKey = @HotelRequestKey  
   
 UPDATE THR  
 SET THR.RetailCrowdDiscountPrice = dbo.udf_RetailCrowdDiscountPrice  
            (  
           @crowdDiscountPercent  
           ,THR.minRate  
           ,THR.TouricoCalculatedBarRate            
            )  
 FROM TmpHotelResponse THR  
 INNER JOIN TmpHotelResponse FHR  
 ON FHR.HotelResponseKey = THR.HotelResponseKey  
 AND THR.HotelRequestKey = @HotelRequestKey  
   
 UPDATE THR  
 SET THR.minRate = dbo.udf_CrowdRate  
       (  
        THR.minRate  
        ,THR.TouricoCostBasisCrowdRate  
        ,THR.RetailCrowdDiscountPrice  
        ,0           
       )  
 ,THR.CrowdRate = dbo.udf_CrowdRate  
       (  
        THR.minRate  
        ,THR.TouricoCostBasisCrowdRate  
        ,THR.RetailCrowdDiscountPrice  
        ,1           
       )  
 FROM TmpHotelResponse THR  
 INNER JOIN TmpHotelResponse FHR  
 ON FHR.HotelResponseKey = THR.HotelResponseKey  
 AND THR.HotelRequestKey = @HotelRequestKey  
   
    
 Insert Into @TblGroup (TripKey,Rating,RatingType,ZipCode,TripSavedKey)   
 Select Distinct TripKey,Rating,RatingType,ZipCode,TripSavedKey   
 From HotelRequestTripSavedDeal With (NoLock) where PkGroupId = @PkGroupId  
           
 Select @ThresholdPricePerDay = ThresholdPricePerDay,@StarRatingConsideration = StarRatingConsideration  
 ,@StarRatingStep1_1 = StarRatingStep1_1,@StarRatingStep1_2 = StarRatingStep1_2,@StarRatingStep2_1 = StarRatingStep2_1  
 ,@PriceCap = PriceCap,@RepetitionInterval = RepetitionInterval,@MilesIteration = MilesIteration  
 ,@MilesIncrement = MilesIncrement, @MilesStart = MilesStart, @MinRepetitionInterval = MinRepetitionInterval  
 From DealsThresholdSettings With (NoLock) Where ComponentTypeKey = 4  
   
 Set @NoOfDays = (Select DATEDIFF(day, CONVERT(VARCHAR(10), checkInDate, 120), CONVERT(VARCHAR(10), checkOutDate, 120))   
     From HotelRequest With (NoLock) where hotelRequestKey = @HotelRequestKey)  
   
 Select Top 1 @checkInTime = CheckInDate, @checkOutTime = CheckOutDate From HotelRequestTripSavedDeal With (NoLock) Where PkGroupId = @PkGroupId  
   
 Set @countToExecute = (Select COUNT(*) from @TblGroup)  
   
 Set @insertCount = 1  
 WHILE (@insertCount <= @countToExecute)/*@insertCount <= @countToExecute*/  
  BEGIN  
   SET @isDefaultVal = 0  
   Set @StoreNewHotelID = 0     
            Set @NewHotelID = 0  
   Set @StoreIntervalDays = 0  
   Delete From @TblMinCurrentPrice  
   Delete From @TblVendorDetails  
   Delete From @TblMinCurrentPriceCache  
     
   Select Top 1 @TblGroupKey = TblGroupKey,@TripSavedKey = TripSavedKey,@TK = TripKey,@Rating = Rating  
   ,@RatingType = RatingType,@ZipCode = ZipCode From @TblGroup where IsInserted = 0  
     
   Select @BookedPrice = ISNULL(originalPerPersonDailyTotalHotel,0)  
       ,@OriginalTotalPrice = originalPerPersonPriceHotel  
       ,@HotelDailyPrice = ISNULL(dailyPriceHotel,0)  
   From TripDetails With (NoLock)  
   Where tripKey = @TK  
     
   /*The below code is commented as we are now picking  
   the original price from TripDetails Table.   
   However, we will be needing the hotelResponseKey from TripHotelResponse table,  
   so the query is written separately just below the commented code*/     
   --Select @BookedPrice = ISNULL(perPersonDailyTotal,0),@OriginalHotelResponseKey = hotelResponseKey  
   --,@OriginalTotalPrice = hotelTotalPrice,@HotelDailyPrice = ISNULL(hotelDailyPrice,0)  
   --From TripHotelResponse With (NoLock) Where tripGUIDKey =  @TripSavedKey  
     
   Select @OriginalHotelResponseKey = hotelResponseKey     
   From TripHotelResponse With (NoLock) Where tripGUIDKey =  @TripSavedKey   
     
   Select Top 1 @OriginalHotelID = HotelId  
   ,@SupplierHotelID = supplierHotelKey  
   ,@SupplierFamily = supplierId  
   From vw_TripHotelResponseDetails With (NoLock)   
   Where hotelResponseKey = @OriginalHotelResponseKey  
     
   IF(@SupplierFamily = 'HotelsCom')  
   BEGIN  
    SET @CurrentHotelsComId = @SupplierHotelID  
   END  
   ELSE  
   BEGIN  
    SET @CurrentHotelsComId = (SELECT SupplierHotelId FROM HotelContent.dbo.SupplierHotels1   
    WHERE HotelId = @OriginalHotelID AND SupplierFamily = 'HotelsCom')  
   END  
     
   Set @NoOfRooms = (Select Top 1 NoOfRooms from HotelRequestTripSavedDeal With (NoLock) Where TripKey = @TK)     
     
   IF(@Rating >= @StarRatingConsideration)/*@Rating >= 3*/  
   BEGIN  
    /*Neighbourhood Search*/  
    /*@MilesIteration Start*/  
    /*MilesIteration is now updated to 3 as we are starting with 9 miles. So the iteration would by thrice.   
    Ex: 9, 9+3 = 12, 12+3 = 15(Fifteen is the last radius). Setting 9 miles as the starting point instead of 3 miles(previously used)  
    is a temporary fix to get variation in deals.*/  
    Set @MilesIterationInitialize = 1  
    WHILE (@MilesIterationInitialize <= @MilesIteration)  
    BEGIN  
    /*initial miles is set as MilesStart i.e. 9 there after it is incremented by 3 (ex: 9, 9+3, 12+3)*/  
     SET @isDefaultVal = 0  
     SET @RadiusInMiles = @RadiusInMiles + @MilesIncrement--Miles incremented by 3  
       
     --print 'MilesIterationInitialize : ' + convert(varchar, @MilesIterationInitialize)  
     --print 'RadiusInMiles : ' + convert(varchar, @RadiusInMiles)  
       
     Insert Into @TblMinCurrentPriceCache(CurrentMinimumPrice,HotelResponseKey,FareCategory,MinRate,Remarks,HotelId)  
     Exec USP_GetTripSavedDealHotelRadius @HotelRequestKey,@OriginalHotelID,@RadiusInMiles,@Rating  
     ,@HotelDailyPrice,@ThresholdPricePerDay,@StarRatingStep1_1,@StarRatingStep1_2,@PriceCap,@StarRatingStep2_1,@SupplierHotelID,'NEIGHBOURHOOD'  
  
     If((Select COUNT(*) from @TblMinCurrentPriceCache) > 0)  
     Begin  
        
      /*Insert data to @TblMinCurrentPrice from @TblMinCurrentPriceCache.   
      The later table data is deleted as soon as the miles Iteration is complete for each miles  
      Data in @TblMinCurrentPrice is unique AND the data is deleted after each trip  
      The NOT IN condition is applied to insert unique data to @TblMinCurrentPrice table */  
      Insert Into @TblMinCurrentPrice(CurrentMinimumPrice,HotelResponseKey,FareCategory  
      ,MinRate,Remarks,HotelId)  
      Select CurrentMinimumPrice, HotelResponseKey, FareCategory, MinRate, Remarks, HotelId   
      From @TblMinCurrentPriceCache   
      WHERE HotelId NOT IN (SELECT HotelId From @TblMinCurrentPrice)  
        
      IF((Select COUNT(*) from @TblVendorDetails) = 0)  
      Begin  
       /*Last 5 days vendor details Data from TripSavedDeals is inserted into @TblVendorDetails  
       These data help in achieving the variation within 5 days*/  
       Insert Into @TblVendorDetails (VendorDetails,CreationDate)  
       Select Distinct vendorDetails, creationDate   
       From TripSavedDeals With (NoLock) Where componentType = 4   
       And (creationDate > (DATEADD(d,@MinRepetitionInterval,(Select MAX(creationDate)   
       From TripSavedDeals With (NoLock) Where componentType = 4))))   
       And vendorDetails <> '' And tripKey = @TK  
      End  
        
      /*The COUNT of @TblMinCurrentPriceCache is compared with Count of @TblVendorDetails data  
      to see if we have new hotels for DOD.  
      If the COUNT of @VendorCountComparison is greater than COUNT of @DODIntervalCount then we have new hotels  
      within 5 days for DOD*/  
      Set @VendorCountComparison = (Select COUNT(HotelId) from @TblMinCurrentPriceCache)  
      Set @DODIntervalCount = (Select COUNT(HotelId) From @TblMinCurrentPriceCache   
      Where HotelId IN (Select VendorDetails From @TblVendorDetails))  
        
      --print 'VendorCountComparison: ' + Convert(varchar(10),@VendorCountComparison) + ' ~~~DODIntervalCount: ' + Convert(varchar(10),@DODIntervalCount)  
        
      /*If the below condition is true then we have new hotels for DOD within 5 days.  
      If the condition is false we expand the radius by 3 miles and search for new hotel. The radius will increase  
      till we reach 15 miles*/  
      IF(@VendorCountComparison > @DODIntervalCount)  
      Begin  
       --INSERT INTO TripSavedDealLog (TripKey,Remarks)  
       --VALUES(@TK,'PASS: VARIATION CONDITION. RADIUS: ' + CONVERT(VARCHAR(5),@RadiusInMiles))  
       BREAK  
      End  
      --ELSE  
      --BEGIN  
      -- INSERT INTO TripSavedDealLog (TripKey,Remarks)  
      -- VALUES(@TK,'FAIL: VARIATION CONDITION. RADIUS: ' + CONVERT(VARCHAR(5),@RadiusInMiles))  
      --END  
        
     End  
            
     Delete From @TblMinCurrentPriceCache  
     SET  @MilesIterationInitialize += 1   
    END  
      
    Set @RadiusInMiles = 0  
    /*@MilesIteration End*/     
      
    /*DEFAULT CONDITION - If we don't find any hotels even after expanding the radius till 15 miles then we set   
    the original hotel as the DOD*/  
    If((Select COUNT(*) from @TblMinCurrentPrice) = 0)  
    Begin  
     --Set @Remarks = 'All Conditions Fail. Inserting the original hotel from current search. '  
     Insert Into @TblMinCurrentPrice (CurrentMinimumPrice,HotelResponseKey,FareCategory,MinRate,Remarks,HotelId)  
     Exec USP_GetTripSavedDealHotelRadius @HotelRequestKey,@OriginalHotelID,@RadiusInMiles,@Rating  
     ,@HotelDailyPrice,@ThresholdPricePerDay,@StarRatingStep1_1,@StarRatingStep1_2,@PriceCap,@StarRatingStep2_1,@SupplierHotelID,'DEFAULT'  
       
     SET @isDefaultVal = 1  
    End  
      
    /*END Neighbourhood Search*/  
      
    /*Start DON'T DELETE - The below commented code works for minimum price available. This is commented as suggested by Bijal*/  
    --If((Select COUNT(*) from @TblMinCurrentPrice) = 0)  
    --Begin  
    -- Set @MinimumPrice = (Select Distinct TOP 1 minRate from @TblHotelResponse  
    -- Where HotelId IN (Select HotelID from @NeighbourhoodHotelID)  
    -- And (Rating >= @Rating) Order By minRate Asc)  
       
    -- Insert Into @TblMinCurrentPrice (CurrentMinimumPrice,HotelResponseKey)  
    -- Select minRate,HotelResponseKey from @TblHotelResponse   
    -- Where HotelId IN (Select HotelID from @NeighbourhoodHotelID)  
    -- And minRate = @MinimumPrice  
    -- Set @Remarks = 'All Conditions Fail. Inserting the minimum price data found. '  
    --End  
    /*End DON'T DELETE - The commented code works for minimum price available. This is commented as suggested by Bijal*/  
         
    Set @MinCurrentPriceCount = (Select COUNT(*) from @TblMinCurrentPrice)  
      
      
    /*Logic for below looping: All the data inserted from the above applied radius rule is inserted in table @TblMinCurrentPrice.  
    From this table the below logic finds out the appropriate hotel for DOD applying the 5 days interval  
    Ex: Say the table(@TblMinCurrentPrice) have hotels H1, H2, H3, H4, H5 and today is the first day of DOD logic.  
    If user gets H1 as DOD today(say 1st Aug), On 2nd the DOD will be H2, 3rd Aug - H3, 4th Aug - H4, 5th Aug - H5  
    Then on 6th Aug the user should get H1 as the DOD and then the seires continues...*/  
    Set @LoopCount = 1  
    WHILE (@LoopCount <= @MinCurrentPriceCount) /*WHILE (@LoopCount <= @MinCurrentPriceCount)*/  
    BEGIN  
     Set @PkId = (Select Top 1 PkId from @TblMinCurrentPrice where IsUsed = 0)  
     Select @CurrentMinimumPrice = CurrentMinimumPrice,@HotelResponseKey = HotelResponseKey From @TblMinCurrentPrice Where PkId = @PkId  
       
     Select Top 1 @NewHotelID = HotelId  
     ,@CurrentSupplierFamily = supplierId  
     ,@CurrentSupplierId = supplierHotelKey   
     From vw_hotelDetailedResponseDeals   
     With (NoLock) Where hotelResponseKey = @HotelResponseKey  
       
     IF(@CurrentSupplierFamily = 'HotelsCom')  
     BEGIN  
      SET @CurrentHotelsComId = @CurrentSupplierId  
     END  
     ELSE  
     BEGIN  
      SET @CurrentHotelsComId = (SELECT SupplierHotelId FROM HotelContent.dbo.SupplierHotels1   
      WHERE HotelId = @NewHotelID AND SupplierFamily = 'HotelsCom')  
     END  
       
     If(@StoreNewHotelID <> @NewHotelID)  
     Begin  
      Set @StoreNewHotelID = @NewHotelID  
      Insert Into @TblVendorDetails (VendorDetails,CreationDate)  
      Select Distinct vendorDetails,creationDate From TripSavedDeals With (NoLock) Where componentType = 4   
      And (creationDate > (DATEADD(d,@MinRepetitionInterval,(Select MAX(creationDate) From TripSavedDeals With (NoLock) Where componentType = 4)))) And vendorDetails <> ''  
      And tripKey = @TK  
      Set @VendorDetailsCount = (Select COUNT(*) From @TblVendorDetails Where VendorDetails = @StoreNewHotelID)  
     End  
       
     If(@VendorDetailsCount > 0)  
     Begin  
      Set @IntervalDays = (Select Top 1 DATEDIFF(day, CONVERT(VARCHAR(10), CreationDate, 120), CONVERT(VARCHAR(10), GETDATE(), 120))   
      From @TblVendorDetails Where VendorDetails = @StoreNewHotelID Order by CreationDate Desc)  
        
      If(@IntervalDays > ISNULL(@StoreIntervalDays,0))  
      Begin  
       Set @StoreIntervalDays = @IntervalDays  
       Set @StoreHotelResponseKey = @HotelResponseKey  
       Set @IntervalNewHotelID = @NewHotelID  
      End  
     End  
       
     If(@LoopCount = @MinCurrentPriceCount And ISNULL(@StoreIntervalDays,0) <> 0)  
     Begin  
      Set @HotelResponseKey = @StoreHotelResponseKey  
      Set @NewHotelID = @IntervalNewHotelID  
     End  
            
     If(@VendorDetailsCount = 0 OR (@LoopCount = @MinCurrentPriceCount))  
     Begin  
        
      --#########START OF CROWD RATE CODE#########--  
      --This Code block was added on 20 Feb 2015.  
      SELECT @strikeThroughPrice = ISNULL(AverageBaseRate, 0)  
          ,@hotelsComStripPrice = ISNULL(minRate, 0)  
          ,@crowdSupplierFamily = ISNULL(supplierId, 'NOCROWD')  
      FROM TmpHotelResponse   
      WHERE HotelRequestKey = @HotelRequestKey  
      AND hotelId = @NewHotelID  
      AND hotelResponseKey <> @HotelResponseKey  
       
      IF(@strikeThroughPrice = 0 AND @crowdSupplierFamily = 'HotelsCom')  
      BEGIN          
       SET @strikeThroughPrice = @hotelsComStripPrice  
       SET @isCrowd = 1  
      END  
      ELSE IF(@strikeThroughPrice > 0 AND @crowdSupplierFamily = 'HotelsCom')    
      BEGIN  
       SET @isCrowd = 1  
      END  
      --#########END OF CROWD RATE CODE#########--  
        
      Insert Into TripSavedDeals (tripKey,responseKey,componentType,currentPerPersonPrice  
      ,originalPerPersonPrice,fareCategory,isAlternate  
      ,vendorDetails,originalTotalPrice,Remarks, currentListPagePrice, isCrowd)  
      Select Top 1 @TK,HotelResponseKey,4,Convert(Decimal(10,2),(MinRate*@NoOfDays)),@BookedPrice  
      ,Case When FareCategory <> '' Then 'SnapCode' Else 'Publish' End  
      ,Case When (@OriginalHotelID = @NewHotelID) Then 0 Else 1 End,@NewHotelID,(@OriginalTotalPrice) --*@NoOfRooms
      ,Remarks + ' ==> ' + CONVERT(Varchar,@HotelRequestKey) + ', ' + CONVERT(Varchar,@PkGroupId)  
      ,@strikeThroughPrice, @isCrowd  
      From @TblMinCurrentPrice Where HotelResponseKey = @HotelResponseKey  
        
      SET @strikeThroughPrice = 0  
      SET @isCrowd = 0  
      /*Update HotelRequestTripSavedDeal To keep track if a particular trip id was successful*/  
      Update HotelRequestTripSavedDeal Set IsSuccess = 1 Where TripKey = @TK  
        
      Insert Into @TblResponseKey (ResponseKey) Values (@HotelResponseKey)  
        
      SET @ResponseKeyCount = (SELECT COUNT(*) FROM TripHotelResponse With (NoLock) WHERE hotelResponseKey = @HotelResponseKey)  
       
      IF(@ResponseKeyCount = 0)/*@ResponseKeyCount*/  
      Begin     
       INSERT INTO TripHotelResponse(tripKey,hotelResponseKey,supplierHotelKey,supplierId,minRate,cityCode  
        ,checkInDate,checkOutDate,hotelDescription,minRateTax  
        ,hotelDailyPrice,SearchHotelPrice,preferenceOrder,contractCode)  
       SELECT TOP 1 0,hotelResponseKey,supplierHotelKey,supplierId,minRate,CityCode,  
        @checkInTime,@checkOutTime,HotelDescription,minRateTax,0,0,preferenceOrder,corporateCode  
       FROM [vw_hotelDetailedResponseDeals] With (NoLock) WHERE hotelResponseKey = @HotelResponseKey  
      End /*End @ResponseKeyCount*/  
        
      /*TMU DATA INSERTED IN TABLE TripDetails*/  
    BEGIN TRY  
       
     SELECT @TripRequestKey = tripRequestKey, @UserKey = userKey  
     FROM Trip WITH (NOLOCK) WHERE tripKey = @TK  
       
     SELECT @TripFrom = tripFrom1, @TripTo = tripTo1  
     ,@TripStartDate = tripFromDate1, @TripEndDate = tripToDate1  
     ,@TripEndMonth = DATEPART(MONTH,tripToDate1)  
     ,@TripEndYear = DATEPART(YEAR,tripToDate1)  
     FROM TripRequest WITH (NOLOCK)   
     WHERE tripRequestKey = @TripRequestKey  
       
     SELECT TOP 1 @FromCountryCode = AL.CountryCode   
     ,@FromCountryName = CL.CountryName  
     ,@FromStateCode = AL.StateCode  
     ,@FromCityName = AL.CityName  
     FROM AirportLookup AL WITH (NOLOCK)  
     LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)  
     ON CL.CountryCode = AL.CountryCode  
     WHERE AL.AirportCode = @TripFrom  
       
     SELECT TOP 1 @ToCountryCode = AL.CountryCode   
     ,@ToCountryName = CL.CountryName  
     ,@ToStateCode = AL.StateCode  
     ,@ToCityName = AL.CityName  
     FROM AirportLookup AL WITH (NOLOCK)  
     LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)  
     ON CL.CountryCode = AL.CountryCode  
     WHERE AL.AirportCode = @TripTo  
       
     --SELECT TOP 1 @UserKey = UserKey, @TripFrom = OriginalSearchToCity  
     --,@TripTo = OriginalSearchToCity, @TripStartDate = CheckInDate  
     --,@TripEndDate = CheckOutDate  
     --,@TripEndMonth = DATEPART(MONTH,CheckOutDate)  
     --,@TripEndYear = DATEPART(YEAR,CheckOutDate)  
     --,@CountryCode = CountryCode       --,@CountryName = CountryName  
     --,@StateCode = StateCode  
     --,@CityName = CityName  
     --FROM HotelRequestTripSavedDeal WHERE TripKey = @TK  
       
     --SELECT @HotelId = HotelId FROM TmpHotelResponse WITH (NOLOCK)   
     --WHERE HotelResponseKey = @HotelResponseKey  
       
     SELECT Top 1  @RegionId = RegionId FROM HotelContent.dbo.RegionHotelIDMapping WITH (NOLOCK)  
     WHERE HotelId = @NewHotelID  
       
     SELECT Top 1  @HotelName = HotelName, @HotelRatingTMU = Rating, @HotelChainCode = ChainCode   
     FROM HotelContent..Hotels WITH (NOLOCK) WHERE HotelId = @NewHotelID  
       
     SELECT Top 1  @RegionName = RegionName FROM HotelContent..ParentRegionList WITH (NOLOCK)  
     WHERE RegionID = @RegionId  
     AND RegionType = 'Neighborhood'  
     AND SubClass <> 'city'  
       
     IF(ISNULL(@HotelChainCode, '') = '')  
     BEGIN  
      SET @HotelChainCode = 'DefaultHotel'  
     END  
       
     IF((SELECT COUNT(tripKey) FROM TripDetails WHERE tripKey = @TK) = 0)  
     BEGIN  
      INSERT INTO TripDetails  
      (  
       tripKey  
       ,tripSavedKey  
       ,userKey  
       ,tripFrom  
       ,tripTo  
       ,tripStartDate  
       ,tripEndDate  
       ,tripEndMonth  
       ,tripEndYear  
       ,HotelRegionName  
       ,HotelRating  
       ,HotelName  
       ,fromCountryCode  
       ,fromCountryName  
       ,fromStateCode  
       ,fromCityName  
       ,toCountryCode  
       ,toCountryName  
       ,toStateCode  
       ,toCityName  
       ,HotelResponseKey         
       ,LatestHotelId         
       ,LatestHotelRegionId  
       ,LatestHotelChainCode  
       ,CurrentHotelsComId        
       --,originalPerPersonPriceHotel  
       --,originalTotalPriceHotel  
       --,originalPerPersonDailyTotalHotel  
       --,dailyPriceHotel  
      )  
      VALUES  
      (  
       @TK  
       ,@TripSavedKey  
       ,@UserKey  
       ,@TripFrom  
       ,@TripTo  
       ,@TripStartDate  
       ,@TripEndDate  
       ,@TripEndMonth  
       ,@TripEndYear  
       ,@RegionName  
       ,ISNULL(@HotelRatingTMU, 0)  
       ,@HotelName  
       ,@FromCountryCode  
       ,@FromCountryName  
       ,@FromStateCode  
       ,@FromCityName  
       ,@ToCountryCode  
       ,@ToCountryName  
       ,@ToStateCode  
       ,@ToCityName  
       ,@HotelResponseKey         
       ,@NewHotelID         
       ,@RegionId  
       ,@HotelChainCode  
       ,@CurrentHotelsComId        
       --,@OriginalTotalPrice --1 room price * no. of days  
       --,(@OriginalTotalPrice * @NoOfRooms)  
       --,@BookedPrice  
       --,@HotelDailyPrice  
      )  
     END  
     ELSE  
     BEGIN  
      UPDATE TripDetails SET  
       tripFrom = @TripFrom  
       ,tripTo = @TripTo  
       ,tripStartDate = @TripStartDate  
       ,tripEndDate = @TripEndDate  
       ,tripEndMonth = @TripEndMonth  
       ,tripEndYear = @TripEndYear  
       ,HotelRegionName = @RegionName  
       ,HotelRating = ISNULL(@HotelRatingTMU, 0)  
       ,HotelName = @HotelName  
       ,fromCountryCode = @FromCountryCode  
       ,fromCountryName = @FromCountryName  
       ,fromStateCode = @FromStateCode  
       ,fromCityName = @FromCityName  
       ,toCountryCode = @ToCountryCode  
       ,toCountryName = @ToCountryName  
       ,toStateCode = @ToStateCode  
       ,toCityName = @ToCityName  
       ,HotelResponseKey = @HotelResponseKey         
       ,LatestHotelId = @NewHotelID         
       ,LatestHotelRegionId = @RegionId  
       ,LatestHotelChainCode = @HotelChainCode  
       ,CurrentHotelsComId = @CurrentHotelsComId  
       ,lastUpdatedDate = GETDATE()  
      WHERE tripKey = @TK  
     END  
       
     IF(@isDefaultVal = 1)  
     BEGIN  
      UPDATE TripDetails SET  
      latestDealHotelPricePerPerson = 0 , latestDealHotelPriceTotal = 0,latestDealHotelSavingsPerPerson = 0,latestDealHotelSavingsTotal = 0  
      WHERE tripKey = @TK  
     END  
       
     END TRY  
     BEGIN CATCH       
     SET @ErrorMessage = ERROR_MESSAGE();  
     INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, ErrorMessage, Remarks, InitiatedFrom)   
     VALUES(@TK, @PkGroupId, 4, @ErrorMessage  
     ,'Error while inserting data in table TripDetails. stored procedure USP_GetTripSavedDealHotelMinPrice', 'TMU')  
     END CATCH  
    /*END: TMU DATA INSERTED IN TABLE TripDetails*/  
        
      BREAK  
        
     End --End @VendorDetailsCount = 0 OR (@LoopCount = @MinCurrentPriceCount  
       
     Delete @TblVendorDetails  
     Update @TblMinCurrentPrice Set IsUsed = 1 Where PkId = @PkId  
     SET  @LoopCount += 1  
    END /*END WHILE (@LoopCount <= @MinCurrentPriceCount)*/  
      
    /*TripSavedLowestDeal Insertion Logic*/  
      BEGIN TRY  
       Select Top 1 @TripSavedLowestDealResponseKey = ISNULL(HotelResponseKey, '00000000-0000-0000-0000-000000000000')  
       From TmpHotelResponse With (NoLock)   
       Where HotelRequestKey = @HotelRequestKey  
       And HotelResponseKey <> @HotelResponseKey  
       And HotelResponseKey <> @OriginalHotelResponseKey  
       And Rating = @Rating  
       Order By minRate Asc  
         
       /*If Original hotel rating not found*/  
       If(@TripSavedLowestDealResponseKey = '00000000-0000-0000-0000-000000000000')  
       Begin  
        If(@Rating = 5)  
        Begin  
         Select top 1 @TripSavedLowestDealResponseKey = ISNULL(HotelResponseKey, '00000000-0000-0000-0000-000000000000')  
         From TmpHotelResponse With (NoLock)   
         Where HotelRequestKey = @HotelRequestKey  
         And HotelResponseKey <> @HotelResponseKey  
         And HotelResponseKey <> @OriginalHotelResponseKey  
         And Rating Between 4 and @Rating  
         Order By minRate Asc  
        End  
        Else  
        Begin  
         Select top 1 @TripSavedLowestDealResponseKey = ISNULL(HotelResponseKey, '00000000-0000-0000-0000-000000000000')  
         From TmpHotelResponse With (NoLock)   
         Where HotelRequestKey = @HotelRequestKey  
         And HotelResponseKey <> @HotelResponseKey  
         And HotelResponseKey <> @OriginalHotelResponseKey  
         And Rating > @Rating  
         Order By minRate Asc, Rating Asc  
        End  
       End  
       /*END: If Original hotel rating not found*/  
         
       If(@TripSavedLowestDealResponseKey = '00000000-0000-0000-0000-000000000000')  
       Begin  
        INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, Remarks, InitiatedFrom)  
        Values (@TK, @PkGroupId, 4, 'No Lowest Hotel Deal Found', 'LowestDeal')   
       End  
       Else  
       Begin  
        Insert Into TripSavedLowestDeal (tripKey,responseKey,componentType,creationDate,isAlternate)  
        Values (@TK, @TripSavedLowestDealResponseKey, 4, GETDATE(), 1)  
          
        If((SELECT COUNT(*) FROM TripHotelResponse WHERE hotelResponseKey = @TripSavedLowestDealResponseKey) = 0)  
        Begin  
         --If((Select COUNT(*) From [vw_hotelDetailedResponseDeals] With (NoLock) WHERE hotelResponseKey = @TripSavedLowestDealResponseKey) = 0)  
         --Begin  
         -- INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, Remarks)  
         -- Values (@TK, @PkGroupId, 4, 'No data returned from view vw_hotelDetailedResponseDeals. Data cannot be inserted in TripHotelResponse table. ResponseKey  :  ' + CONVERT(Varchar(50), @TripSavedLowestDealResponseKey))   
         --End  
         --Else  
         --Begin  
          INSERT INTO TripHotelResponse(tripKey,hotelResponseKey,supplierHotelKey,supplierId,minRate,cityCode  
          ,checkInDate,checkOutDate,hotelDescription,minRateTax  
          ,hotelDailyPrice,SearchHotelPrice,preferenceOrder,contractCode)  
          SELECT TOP 1 0,hotelResponseKey,supplierHotelKey,supplierId,minRate,CityCode,  
          @checkInTime,@checkOutTime,HotelDescription,minRateTax,0,0,preferenceOrder,corporateCode  
          FROM [vw_hotelDetailedResponseDeals]   
          With (NoLock) WHERE hotelResponseKey = @TripSavedLowestDealResponseKey    
         --End  
        End  
       End  
      END TRY  
      BEGIN CATCH  
       SET @ErrorMessage = ERROR_MESSAGE();  
       INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, ErrorMessage, Remarks, InitiatedFrom)   
       VALUES(@TK, @PkGroupId, 4, @ErrorMessage  
       ,'Error while inserting data in table TripSavedLowestDeal. stored procedure USP_GetTripSavedDealHotelMinPrice', 'LowestDeal')  
      END CATCH  
     /*END: TripSavedLowestDeal Insertion Logic*/  
      
   END /*END @Rating >= 3*/  
     
   ELSE /*Hotel rating less than 3 star*/  
   BEGIN  
    Insert Into TripSavedDeals (tripKey,responseKey,componentType,currentPerPersonPrice,originalPerPersonPrice,fareCategory,isAlternate  
    ,vendorDetails,originalTotalPrice,currentTotalPrice,Remarks)  
    Select Top 1 @TK,@OriginalHotelResponseKey,4,@BookedPrice,@BookedPrice  
    ,'Publish',0,@OriginalHotelID,(@OriginalTotalPrice) -- * @NoOfRooms
    ,(@OriginalTotalPrice * @NoOfRooms) /*added by pradeep/vivek for TFS : 17513,18719,19499,19445,19415*/
    ,'Original hotel less than ' + CONVERT(Varchar,@StarRatingConsideration) + ' star. ==> ' + CONVERT(Varchar,@HotelRequestKey) + ', ' + CONVERT(Varchar,@PkGroupId)  
    --From TripHotelResponse With (NoLock) Where HotelResponseKey = @OriginalHotelResponseKey   
          
    /*Update HotelRequestTripSavedDeal To keep track if a particular trip id was successful*/  
    Update HotelRequestTripSavedDeal Set IsSuccess = 1 Where TripKey = @TK  
      
    /*TMU DATA INSERTED IN TABLE TripDetails*/  
    BEGIN TRY  
       
     SELECT @TripRequestKey = tripRequestKey, @UserKey = userKey  
     FROM Trip WITH (NOLOCK) WHERE tripKey = @TK  
       
     SELECT @TripFrom = tripFrom1, @TripTo = tripTo1  
     ,@TripStartDate = tripFromDate1, @TripEndDate = tripToDate1  
     ,@TripEndMonth = DATEPART(MONTH,tripToDate1)  
     ,@TripEndYear = DATEPART(YEAR,tripToDate1)  
     FROM TripRequest WITH (NOLOCK)   
     WHERE tripRequestKey = @TripRequestKey  
       
     SELECT TOP 1 @FromCountryCode = AL.CountryCode   
     ,@FromCountryName = CL.CountryName  
     ,@FromStateCode = AL.StateCode  
     ,@FromCityName = AL.CityName  
     FROM AirportLookup AL WITH (NOLOCK)  
     LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)  
     ON CL.CountryCode = AL.CountryCode  
     WHERE AL.AirportCode = @TripFrom  
       
     SELECT TOP 1 @ToCountryCode = AL.CountryCode   
     ,@ToCountryName = CL.CountryName  
     ,@ToStateCode = AL.StateCode  
     ,@ToCityName = AL.CityName  
     FROM AirportLookup AL WITH (NOLOCK)  
     LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)  
     ON CL.CountryCode = AL.CountryCode  
     WHERE AL.AirportCode = @TripTo  
       
     --SELECT @HotelId = HotelId FROM TmpHotelResponse WITH (NOLOCK)   
     --WHERE HotelResponseKey = @HotelResponseKey  
       
     SELECT Top 1  @RegionId = RegionId FROM HotelContent.dbo.RegionHotelIDMapping WITH (NOLOCK)  
     WHERE HotelId = @OriginalHotelID  
       
     SELECT Top 1  @HotelName = HotelName, @HotelRatingTMU = Rating, @HotelChainCode = ChainCode  
     FROM HotelContent..Hotels   
     WITH (NOLOCK) WHERE HotelId = @OriginalHotelID  
       
     SELECT Top 1  @RegionName = RegionName FROM HotelContent..ParentRegionList WITH (NOLOCK)  
     WHERE RegionID = @RegionId  
     AND RegionType = 'Neighborhood'  
     AND SubClass <> 'city'  
       
     IF(ISNULL(@HotelChainCode, '') = '')  
     BEGIN  
      SET @HotelChainCode = 'DefaultHotel'  
     END  
       
     IF((SELECT COUNT(tripKey) FROM TripDetails WHERE tripKey = @TK) = 0)  
     BEGIN  
      INSERT INTO TripDetails  
      (  
       tripKey  
       ,tripSavedKey  
       ,userKey  
       ,tripFrom  
       ,tripTo  
       ,tripStartDate  
       ,tripEndDate  
       ,tripEndMonth  
       ,tripEndYear  
       ,HotelRegionName  
       ,HotelRating  
       ,HotelName  
       ,fromCountryCode  
       ,fromCountryName  
       ,fromStateCode  
       ,fromCityName  
       ,toCountryCode  
       ,toCountryName  
       ,toStateCode  
       ,toCityName  
       ,HotelResponseKey         
       ,LatestHotelId         
       ,LatestHotelRegionId   
       ,latestDealHotelSavingsPerPerson  
       ,latestDealHotelSavingsTotal  
       ,latestDealHotelPricePerPerson  
       ,latestDealHotelPriceTotal  
       ,LatestDealHotelPricePerPersonPerDay  
       ,LatestHotelChainCode  
       ,CurrentHotelsComId  
      )  
      VALUES  
      (  
       @TK  
       ,@TripSavedKey  
       ,@UserKey  
       ,@TripFrom  
       ,@TripTo  
       ,@TripStartDate  
       ,@TripEndDate  
       ,@TripEndMonth  
       ,@TripEndYear  
       ,@RegionName  
       ,ISNULL(@HotelRatingTMU, 0)  
       ,@HotelName  
       ,@FromCountryCode  
       ,@FromCountryName  
       ,@FromStateCode  
       ,@FromCityName  
       ,@ToCountryCode  
       ,@ToCountryName  
       ,@ToStateCode  
       ,@ToCityName  
       ,@HotelResponseKey         
       ,@OriginalHotelID          
       ,@RegionId  
       ,0  
       ,0  
       ,@OriginalTotalPrice  
       ,(@OriginalTotalPrice * @NoOfRooms)  
       ,(@OriginalTotalPrice/@NoOfDays)  
       ,@HotelChainCode  
       ,@CurrentHotelsComId        
       --,@OriginalTotalPrice --1 room price * no. of days  
       --,(@OriginalTotalPrice * @NoOfRooms)  
       --,@BookedPrice  
       --,@HotelDailyPrice  
      )  
     END  
     ELSE  
     BEGIN  
      UPDATE TripDetails SET  
       tripFrom = @TripFrom  
       ,tripTo = @TripTo  
       ,tripStartDate = @TripStartDate  
       ,tripEndDate = @TripEndDate  
       ,tripEndMonth = @TripEndMonth  
       ,tripEndYear = @TripEndYear  
       ,HotelRegionName = @RegionName  
       ,HotelRating = ISNULL(@HotelRatingTMU, 0)  
       ,HotelName = @HotelName  
       ,fromCountryCode = @FromCountryCode  
       ,fromCountryName = @FromCountryName  
       ,fromStateCode = @FromStateCode  
       ,fromCityName = @FromCityName  
       ,toCountryCode = @ToCountryCode  
       ,toCountryName = @ToCountryName  
       ,toStateCode = @ToStateCode  
       ,toCityName = @ToCityName  
       ,HotelResponseKey = @HotelResponseKey  
       ,LatestHotelId = @OriginalHotelID         
       ,LatestHotelRegionId = @RegionId  
       ,latestDealHotelSavingsPerPerson = 0  
       ,latestDealHotelSavingsTotal = 0  
       ,latestDealHotelPricePerPerson = @OriginalTotalPrice  
       ,latestDealHotelPriceTotal = (@OriginalTotalPrice * @NoOfRooms)  
       ,LatestDealHotelPricePerPersonPerDay = (@OriginalTotalPrice/@NoOfDays)  
       ,LatestHotelChainCode = @HotelChainCode  
       ,CurrentHotelsComId = @CurrentHotelsComId  
       ,lastUpdatedDate = GETDATE()  
      WHERE tripKey = @TK  
     END  
     END TRY  
     BEGIN CATCH       
     SET @ErrorMessage = ERROR_MESSAGE();  
     INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, ErrorMessage, Remarks, InitiatedFrom)   
     VALUES(@TK, @PkGroupId, 4, @ErrorMessage  
     ,'Error while inserting data in table TripDetails. stored procedure USP_GetTripSavedDealHotelMinPrice', 'TMU')  
     END CATCH  
    /*END: TMU DATA INSERTED IN TABLE TripDetails*/  
      
    /*TripSavedLowestDeal Insertion Logic*/  
    BEGIN TRY  
     Insert Into TripSavedLowestDeal (tripKey,responseKey,componentType,creationDate,isAlternate)  
     Values (@TK,@OriginalHotelResponseKey,4,GETDATE(),0)  
    END TRY  
    BEGIN CATCH  
     SET @ErrorMessage = ERROR_MESSAGE();  
     INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, ErrorMessage, Remarks, InitiatedFrom)   
     VALUES(@TK, @PkGroupId, 4, @ErrorMessage  
     ,'Error while inserting data in table TripSavedLowestDeal. stored procedure USP_GetTripSavedDealHotelMinPrice', 'LowestDeal')   
    END CATCH  
    /*END: TripSavedLowestDeal Insertion Logic*/  
         
   END/*END Hotel rating less than 3 star*/  
     
   SET  @insertCount += 1  
   Update @TblGroup set IsInserted = 1 where TblGroupKey = @TblGroupKey  
     
  END /*END @insertCount <= @countToExecute*/  
    
  Delete From TmpHotelResponse Where HotelRequestKey = @HotelRequestKey  
    
  Select Distinct ResponseKey From @TblResponseKey  
    
  --END TRY  
  --BEGIN CATCH  
  -- SET @ErrorMessage = ERROR_MESSAGE();  
  -- --RAISERROR (@ErrorMessage, 16, 1);  
  -- INSERT INTO TripSavedDealLog (ErrorMessage, ErrorStack) Values ('Error in stored procedure USP_GetTripSavedDealHotelMinPrice. Group ID : ' + CONVERT(varchar,@PkGroupId) + '... Hotel Request Key : ' + CONVERT(VARCHAR, @HotelRequestKey), @ErrorMessage)
  
  --END CATCH;  
    
END  
GO
