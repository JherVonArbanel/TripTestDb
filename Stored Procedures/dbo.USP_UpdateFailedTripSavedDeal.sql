SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================  
-- Author:  Jayant Guru  
-- Create date: 18th Dec 2012  
-- Description: Update the failed saved trips with original data  
-- Updated By Manoj Kumar Naik
-- Description Updated implementation of Failed air Price to replace with original price Total & per person price fix.
-- =============================================  
--Exec USP_UpdateFailedTripSavedDeal 'CAR'  
  
CREATE PROCEDURE [dbo].[USP_UpdateFailedTripSavedDeal]  
   
 @ComponentType Varchar (10)  
   
AS  
BEGIN  
   
 SET NOCOUNT ON;  
   
 DECLARE @ErrorMessage VARCHAR(4000)  
   
 IF(@ComponentType = 'HOTEL')  
 BEGIN  
    
  Declare @TripKey Int  
    ,@OriginalHotelResponseKey UniqueIdentifier  
    ,@BookedPrice Float  
    ,@OriginalHotelID Int  
    ,@OriginalTotalPrice Float  
    ,@NoOfRooms Int  
    ,@Rating Float  
    ,@TripSavedKey UniqueIdentifier  
    ,@PkId int  
    ,@CountToExecute Int  
    ,@InsertCount Int  
    ,@TripRequestKeyHotel INT  
    ,@UserKeyHotel INT  
    ,@TripFromHotel VARCHAR(3)  
    ,@TripToHotel VARCHAR(3)  
    ,@TripStartDateHotel DATETIME  
    ,@TripEndDateHotel DATETIME  
    ,@TripEndMonthHotel INT  
    ,@TripEndYearHotel INT  
    ,@FromCountryCodeHotel VARCHAR(2)  
    ,@FromCountryNameHotel VARCHAR(128)  
    ,@FromStateCodeHotel VARCHAR(2)  
    ,@FromCityNameHotel VARCHAR(64)  
    ,@ToCountryCodeHotel VARCHAR(2)  
    ,@ToCountryNameHotel VARCHAR(128)  
    ,@ToStateCodeHotel VARCHAR(2)  
    ,@ToCityNameHotel VARCHAR(64)  
    ,@HotelName VARCHAR(150)  
    ,@RegionId INT  
    ,@RegionName VARCHAR(200)  
    ,@NoOfDays INT  
    ,@HotelChainCode VARCHAR(20)  
    ,@CurrentHotelsComId VARCHAR(10)  
    ,@SupplierHotelID Varchar(10)  
    ,@SupplierFamily VARCHAR(16)  
      
  Declare @TblTripSavedKey As Table  
  (  
   PkId int identity(1,1)  
   ,TripKey Int  
   ,TripSavedKey UniqueIdentifier  
   ,NoOfRooms Int  
   ,Rating Float  
   ,NoOfDays Int  
   ,IsUsed Bit Default(0)  
  )  
    
  Update HotelRequestTripSavedDeal Set IsSuccess = 0 Where TripKey   
  In (Select tripKey From TripSavedDeals Where responseDetailKey Is Null And componentType = 4   
  And CONVERT(varchar, creationDate, 103) = CONVERT(varchar, GETDATE(), 103)   
  And Remarks Not Like 'Original hotel less than%')  
    
  Delete From TripSavedDeals Where responseDetailKey Is Null And componentType = 4   
  And CONVERT(varchar, creationDate, 103) = CONVERT(varchar, GETDATE(), 103)   
  And Remarks Not Like 'Original hotel less than%'  
    
  Insert Into FailedTripSavedDeal (TripKey, ComponentType, TripSavedKey)  
  Select TripKey, 4, TripSavedKey From HotelRequestTripSavedDeal   
  Where IsSuccess = 0  
    
  Insert Into @TblTripSavedKey (TripKey, TripSavedKey, NoOfRooms, NoOfDays, Rating)  
  Select TripKey, TripSavedKey, NoOfRooms, NoOfDays, Rating From HotelRequestTripSavedDeal   
  Where IsSuccess = 0  
       
  Set @CountToExecute = (Select COUNT(TripKey) from @TblTripSavedKey)  
  Set @InsertCount = 1  
       
  WHILE (@InsertCount <= @CountToExecute)  
  BEGIN  
     
   Select Top 1   
    @PkId = PkId  
    ,@TripKey = TripKey  
    ,@TripSavedKey = TripSavedKey  
    ,@NoOfRooms = NoOfRooms  
    ,@Rating = Rating  
    ,@NoOfDays = NoOfDays  
   From @TblTripSavedKey   
   Where IsUsed = 0  
        
      /*Below code is commented as original price is picked from TripDetails Table*/        
   --Select @BookedPrice = ISNULL(perPersonDailyTotal,0)  
   -- ,@OriginalHotelResponseKey = hotelResponseKey  
   -- ,@OriginalTotalPrice = hotelTotalPrice  
   --From TripHotelResponse With (NoLock)   
   --Where tripGUIDKey =  @TripSavedKey  
     
   Select @OriginalHotelResponseKey = hotelResponseKey  
   From TripHotelResponse With (NoLock)   
   Where tripGUIDKey =  @TripSavedKey  
     
   Select @BookedPrice = ISNULL(originalPerPersonDailyTotalHotel,0)  
       ,@OriginalTotalPrice = originalPerPersonPriceHotel         
   From TripDetails With (NoLock)  
   Where tripKey = @TripKey  
     
   Select Top 1   
    @OriginalHotelID = HotelId  
    ,@HotelName = HotelName  
    ,@HotelChainCode = ChainCode  
    ,@SupplierHotelID = supplierHotelKey  
    ,@SupplierFamily = supplierId   
   From vw_TripHotelResponseDetails With (NoLock)   
   Where hotelResponseKey = @OriginalHotelResponseKey  
        
   Insert Into TripSavedDeals (tripKey,responseKey,componentType,currentPerPersonPrice,originalPerPersonPrice,fareCategory,isAlternate  
   ,vendorDetails,originalTotalPrice,currentTotalPrice,Remarks)  
   Values  
   (@TripKey,@OriginalHotelResponseKey,4,@BookedPrice,@BookedPrice  
   ,'Publish',0,@OriginalHotelID,(@OriginalTotalPrice),(@OriginalTotalPrice)  
   ,'Failed Trip Key. Original trip inserted')  
     
   /*TMU DATA INSERTED IN TABLE TripDetails*/  
    BEGIN TRY  
       
     SELECT @TripRequestKeyHotel = tripRequestKey, @UserKeyHotel = userKey  
     FROM Trip WITH (NOLOCK) WHERE tripKey = @TripKey  
       
     SELECT @TripFromHotel = tripFrom1, @TripToHotel = tripTo1  
     ,@TripStartDateHotel = tripFromDate1, @TripEndDateHotel = tripToDate1  
     ,@TripEndMonthHotel = DATEPART(MONTH,tripToDate1)  
     ,@TripEndYearHotel = DATEPART(YEAR,tripToDate1)  
     FROM TripRequest WITH (NOLOCK)   
     WHERE tripRequestKey = @TripRequestKeyHotel  
       
     SELECT TOP 1 @FromCountryCodeHotel = AL.CountryCode   
     ,@FromCountryNameHotel = CL.CountryName  
     ,@FromStateCodeHotel = AL.StateCode  
     ,@FromCityNameHotel = AL.CityName  
     FROM AirportLookup AL WITH (NOLOCK)  
     LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)  
     ON CL.CountryCode = AL.CountryCode  
     WHERE AL.AirportCode = @TripFromHotel  
       
     SELECT TOP 1 @ToCountryCodeHotel = AL.CountryCode   
     ,@ToCountryNameHotel = CL.CountryName  
     ,@ToStateCodeHotel = AL.StateCode  
     ,@ToCityNameHotel = AL.CityName  
     FROM AirportLookup AL WITH (NOLOCK)  
     LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)  
     ON CL.CountryCode = AL.CountryCode  
     WHERE AL.AirportCode = @TripToHotel  
            
     SELECT @RegionId = RegionId FROM HotelContent.dbo.RegionHotelIDMapping WITH (NOLOCK)  
     WHERE HotelId = @OriginalHotelID  
       
     SELECT @RegionName = RegionName FROM HotelContent..ParentRegionList WITH (NOLOCK)  
     WHERE RegionID = @RegionId  
     AND RegionType = 'Neighborhood'  
     AND SubClass <> 'city'  
       
     IF(ISNULL(@HotelChainCode, '') = '')  
     BEGIN  
      SET @HotelChainCode = 'DefaultHotel'  
     END  
       
     IF(@SupplierFamily = 'HotelsCom')  
     BEGIN  
      SET @CurrentHotelsComId = @SupplierHotelID  
     END  
     ELSE  
     BEGIN  
      SET @CurrentHotelsComId = (SELECT SupplierHotelId FROM HotelContent.dbo.SupplierHotels1   
      WHERE HotelId = @OriginalHotelID AND SupplierFamily = 'HotelsCom')  
     END  
       
     IF((SELECT COUNT(tripKey) FROM TripDetails WHERE tripKey = @TripKey) = 0)  
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
       --,originalPerPersonPriceHotel  
       --,originalTotalPriceHotel  
       ,latestDealHotelSavingsPerPerson  
       ,latestDealHotelSavingsTotal  
       ,latestDealHotelPricePerPerson  
       ,latestDealHotelPriceTotal  
       ,LatestDealHotelPricePerPersonPerDay         
       ,LatestHotelRegionId  
       ,LatestHotelChainCode  
       ,CurrentHotelsComId  
      )  
      VALUES  
      (  
       @TripKey  
       ,@TripSavedKey  
       ,@UserKeyHotel  
       ,@TripFromHotel  
       ,@TripToHotel  
       ,@TripStartDateHotel  
       ,@TripEndDateHotel  
       ,@TripEndMonthHotel  
       ,@TripEndYearHotel  
       ,@RegionName  
       ,ISNULL(@Rating, 0)  
       ,@HotelName  
       ,@FromCountryCodeHotel  
       ,@FromCountryNameHotel  
       ,@FromStateCodeHotel  
       ,@FromCityNameHotel  
       ,@ToCountryCodeHotel  
       ,@ToCountryNameHotel  
       ,@ToStateCodeHotel  
       ,@ToCityNameHotel  
       ,@OriginalHotelResponseKey  
       --,@OriginalTotalPrice  
       --,(@OriginalTotalPrice * @NoOfRooms)  
       ,0  
       ,0  
       ,@OriginalTotalPrice  
       ,(@OriginalTotalPrice * @NoOfRooms)  
       ,(@OriginalTotalPrice/@NoOfDays)         
       ,@RegionId  
       ,@HotelChainCode  
       ,@CurrentHotelsComId  
      )  
     END  
     ELSE  
     BEGIN  
      UPDATE TripDetails SET  
       tripFrom = @TripFromHotel  
       ,tripTo = @TripToHotel  
       ,tripStartDate = @TripStartDateHotel  
       ,tripEndDate = @TripEndDateHotel  
       ,tripEndMonth = @TripEndMonthHotel  
       ,tripEndYear = @TripEndYearHotel  
       ,HotelRegionName = @RegionName  
       ,HotelRating = ISNULL(@Rating, 0)  
       ,HotelName = @HotelName  
       ,fromCountryCode = @FromCountryCodeHotel  
       ,fromCountryName = @FromCountryNameHotel  
       ,fromStateCode = @FromStateCodeHotel  
       ,fromCityName = @FromCityNameHotel  
       ,toCountryCode = @ToCountryCodeHotel  
       ,toCountryName = @ToCountryNameHotel  
       ,toStateCode = @ToStateCodeHotel  
       ,toCityName = @ToCityNameHotel  
       ,HotelResponseKey = @OriginalHotelResponseKey  
       --,originalPerPersonPriceHotel = @OriginalTotalPrice  
       --,originalTotalPriceHotel = (@OriginalTotalPrice * @NoOfRooms)  
       ,latestDealHotelSavingsPerPerson = 0  
       ,latestDealHotelSavingsTotal = 0  
       ,latestDealHotelPricePerPerson = @OriginalTotalPrice  
       ,latestDealHotelPriceTotal = (@OriginalTotalPrice * @NoOfRooms)  
       ,LatestDealHotelPricePerPersonPerDay = (@OriginalTotalPrice/@NoOfDays)         
       ,LatestHotelRegionId = @RegionId  
       ,LatestHotelChainCode = @HotelChainCode  
       ,CurrentHotelsComId = @CurrentHotelsComId  
       ,lastUpdatedDate = GETDATE()  
      WHERE tripKey = @TripKey  
     END  
     END TRY  
     BEGIN CATCH       
     SET @ErrorMessage = ERROR_MESSAGE();  
     INSERT INTO TripSavedDealLog (TripKey, ComponentType, ErrorMessage, Remarks, InitiatedFrom)   
     VALUES(@TripKey, 2, @ErrorMessage  
     ,'Error while inserting failed trip in table TripDetails. stored procedure USP_UpdateFailedTripSavedDeal', 'TMU')  
     END CATCH  
    /*END: TMU DATA INSERTED IN TABLE TripDetails*/  
     
   Update HotelRequestTripSavedDeal Set IsSuccess = 1 Where TripKey = @TripKey         
   Update @TblTripSavedKey Set IsUsed = 1 Where PkId = @PkId  
   SET  @InsertCount += 1  
  END  
 END  
   
 ELSE IF(@ComponentType = 'AIR')  
 BEGIN  
    
  Declare @SearchAirTax Float  
    ,@SearchAirPrice Float  
    ,@AirTripKey Int  
    ,@AirTripSavedKey Uniqueidentifier  
    ,@AirCountToExecute Int  
    ,@AirInsertCount Int  
    ,@AirOriginalTotalPrice Float  
    ,@SearchAirPriceBreakupKey Int  
    ,@OriginalAirResponseKey Uniqueidentifier  
    ,@OriginalMarketingAirline Varchar(100)  
    ,@AirPkId Int  
    ,@AirBookedPerPersonPrice Float  
    ,@TripRequestKeyAir INT  
    ,@UserKeyAir INT  
    ,@TripFromAir VARCHAR(3)  
    ,@TripToAir VARCHAR(3)  
    ,@TripStartDateAir DATETIME  
    ,@TripEndDateAir DATETIME  
    ,@TripEndMonthAir INT  
    ,@TripEndYearAir INT  
    ,@FromCountryCodeAir VARCHAR(2)  
    ,@FromCountryNameAir VARCHAR(128)  
    ,@FromStateCodeAir VARCHAR(2)  
    ,@FromCityNameAir VARCHAR(64)  
    ,@ToCountryCodeAir VARCHAR(2)  
    ,@ToCountryNameAir VARCHAR(128)  
    ,@ToStateCodeAir VARCHAR(2)  
    ,@ToCityNameAir VARCHAR(64)  
    ,@AirRequestType VARCHAR(20)  
    ,@AirSegmentCabin VARCHAR(30)  
    ,@TMUMarketingAirlineCode VARCHAR(30)  
    ,@TMUMarketingAirlineName VARCHAR(64)  
    ,@isMultipleAirline BIT = 0  
    ,@singleAirlineCode VARCHAR(2)  
    ,@AirRequestTypeKey TINYINT  
    ,@NoOfAirStops TINYINT  
    ,@NoOfLeg1Stops TINYINT  
    ,@NoOfLeg2Stops TINYINT  
    
  Declare @TblAirFailedTripSavedKey As Table(PkId int identity(1,1),TripKey Int,TripSavedKey UniqueIdentifier,IsUsed Bit Default(0))  
    
  Insert Into FailedTripSavedDeal (TripKey, ComponentType, TripSavedKey)  
  Select TripKey, 1, TripSavedKey From AirRequestTripSavedDeal Where IsSuccess = 0  
    
  Insert Into @TblAirFailedTripSavedKey (TripKey, TripSavedKey)  
  Select TripKey, TripSavedKey From AirRequestTripSavedDeal Where IsSuccess = 0  
    
  Set @AirCountToExecute = (Select COUNT(*) from @TblAirFailedTripSavedKey)  
  Set @AirInsertCount = 1   
    
  WHILE (@AirInsertCount <= @AirCountToExecute)  
  BEGIN  
     
   Select Top 1 @AirPkId = PkId, @AirTripKey = TripKey, @AirTripSavedKey = TripSavedKey   
   From @TblAirFailedTripSavedKey Where IsUsed = 0  
     
   /*The below code is commented as we are now picking Original Total Price From TripDetails Table*/  
   --Select @SearchAirPrice =(( isnull(tripAdultBase,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildBase,0)*isnull(t.tripChildCount,0) )   
   --+ ( isnull(tripSeniorBase,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthBase,0)*isnull(t.tripYouthCount,0) )   
   --+ (isnull(tripInfantBase,0)*isnull(t.tripInfantCount,0) )  )  
   --,@SearchAirTax =(( isnull(tripAdulttax,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildtax,0)*isnull(t.tripChildCount,0) ) +   
   --( isnull(tripSeniortax,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthtax,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfanttax,0)*isnull(t.tripInfantCount,0) )  )  
   --from TripAirPrices TAP  With (NoLock)  
   --inner join TripAirResponse TR  With (NoLock) on TAP.tripAirPriceKey = TR.searchAirPriceBreakupKey   
   --inner join Trip T  With (NoLock) on TR.tripGUIDKey = @AirTripSavedKey  where t.tripKey = @AirTripKey  
        
   --SET @AirOriginalTotalPrice = (select convert(decimal (18,2), (@searchAirPrice + @searchAirTax)))  
   /*END: The below code is commented as we are now picking Original Total Price From TripDetails Table*/  
     
   SET @AirOriginalTotalPrice = (SELECT (searchAirPrice + searchAirTax) FROM TripAirResponse WHERE tripGuidKey in (SELECT tripSavedKey FROM TripDetails WHERE tripKey = @AirTripKey))  
     
   Select @SearchAirPriceBreakupKey = searchAirPriceBreakupKey,@OriginalAirResponseKey = airResponseKey  
   From TripAirResponse  With (NoLock) Where tripGUIDKey = @AirTripSavedKey  
     
   /*The below code is commented as we are now picking Original Per Person Price From TripDetails Table*/  
   /*Original booked price(From Adult and Senior one has to be mandatory)*/  
   --If((Select ISNULL(tripAdultBase,0) From TripAirPrices With (NoLock) Where tripAirPriceKey = @SearchAirPriceBreakupKey) <> 0)  
   --Begin  
   -- Set @AirBookedPerPersonPrice = (Select (tripAdultBase + tripAdultTax) from TripAirPrices  With (NoLock) Where tripAirPriceKey = @SearchAirPriceBreakupKey)  
   --End  
   --Else  
   --Begin  
   -- Set @AirBookedPerPersonPrice = (Select (tripSeniorBase + tripSeniorTax) from TripAirPrices  With (NoLock) Where tripAirPriceKey = @SearchAirPriceBreakupKey)  
   --End  
   /*END: The below code is commented as we are now picking Original Per Person Price From TripDetails Table*/  
     
   SET @AirBookedPerPersonPrice = (SELECT (tripAdultBase + tripAdultTax) FROM TripAirPrices WHERE tripAirPriceKey = @SearchAirPriceBreakupKey)  
     
   /*@OriginalMarketingAirline -> Flights of the original trip selected while watch trip. Needed for Alternative airline comparision*/  
   Select @OriginalMarketingAirline = STUFF((SELECT  ',' + airSegmentMarketingAirlineCode   
   From TripAirSegments  With (NoLock) Where airResponseKey = @OriginalAirResponseKey  Order By airSegmentDepartureDate Asc FOR XML PATH ('')),1,1,'')  
    
   Insert Into TripSavedDeals (tripKey,responseKey,componentType,currentPerPersonPrice,originalPerPersonPrice,fareCategory,isAlternate  
   ,vendorDetails,currentTotalPrice,originalTotalPrice,Remarks)  
   Values  
   (@AirTripKey,@OriginalAirResponseKey,1,@AirBookedPerPersonPrice,@AirBookedPerPersonPrice      
   ,'Publish',0,@OriginalMarketingAirline  
   ,@AirOriginalTotalPrice,@AirOriginalTotalPrice,'Failed Trip Key. Original trip inserted')  
     
   /*TMU DATA INSERTED IN TABLE TripDetails*/  
   BEGIN TRY  
   SELECT @TripRequestKeyAir = tripRequestKey, @UserKeyAir = userKey  
   FROM Trip WITH (NOLOCK) WHERE tripKey = @AirTripKey  
     
   SELECT @TripFromAir = tripFrom1, @TripToAir = tripTo1  
   ,@TripStartDateAir = tripFromDate1, @TripEndDateAir = tripToDate1  
   ,@TripEndMonthAir = DATEPART(MONTH,tripToDate1)  
   ,@TripEndYearAir = DATEPART(YEAR,tripToDate1)  
   FROM TripRequest WITH (NOLOCK) WHERE tripRequestKey = @TripRequestKeyAir  
     
   SELECT TOP 1 @FromCountryCodeAir = AL.CountryCode   
   ,@FromCountryNameAir = CL.CountryName  
   ,@FromStateCodeAir = AL.StateCode  
   ,@FromCityNameAir = AL.CityName  
   FROM AirportLookup AL WITH (NOLOCK)  
   LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)  
   ON CL.CountryCode = AL.CountryCode  
   WHERE AL.AirportCode = @TripFromAir  
     
   SELECT TOP 1 @ToCountryCodeAir = AL.CountryCode   
   ,@ToCountryNameAir = CL.CountryName  
   ,@ToStateCodeAir = AL.StateCode  
   ,@ToCityNameAir = AL.CityName  
   FROM AirportLookup AL WITH (NOLOCK)  
   LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)  
   ON CL.CountryCode = AL.CountryCode  
   WHERE AL.AirportCode = @TripToAir  
     
   SELECT TOP 1   
   @AirRequestTypeKey = AirRequestTypeKey  
   ,@AirRequestType = (CASE WHEN AirRequestTypeKey = 2 THEN 'RoundTrip' ELSE 'OneWay' END)  
   ,@AirSegmentCabin   
   = (CASE ClassLevel  
   WHEN 0 THEN 'Economy'  
   WHEN 1 THEN 'Economy'  
   WHEN 2 THEN 'Business'  
   WHEN 3 THEN 'First'  
   WHEN 4 THEN 'EconomyPremium'  
   END)  
   FROM AirRequestTripSavedDeal WITH (NOLOCK) WHERE TripKey = @AirTripKey  
     
   IF(@AirRequestTypeKey = 1) -- FOR ONE-WAY  
   BEGIN  
    SELECT @NoOfLeg1Stops = COUNT(airLegNumber)   
    FROM TripAirSegments      
    WHERE airResponseKey = @OriginalAirResponseKey  
      
    SET @NoOfAirStops = (@NoOfLeg1Stops - 1)  
   END  
   ELSE -- FOR ROUND-TRIP  
   BEGIN  
    SELECT @NoOfLeg1Stops = COUNT(airLegNumber)   
    FROM TripAirSegments      
    WHERE airResponseKey = @OriginalAirResponseKey  
    AND airLegNumber = 1  
      
    SELECT @NoOfLeg2Stops = COUNT(airLegNumber)   
    FROM TripAirSegments      
    WHERE airResponseKey = @OriginalAirResponseKey  
    AND airLegNumber = 2  
      
    IF(@NoOfLeg1Stops = 1 AND @NoOfLeg2Stops = 1)  
    BEGIN  
     SET @NoOfAirStops = 0  
    END  
    ELSE IF(@NoOfLeg1Stops > @NoOfLeg2Stops)  
    BEGIN  
     SET @NoOfAirStops = (@NoOfLeg1Stops - 1)  
    END  
    ELSE IF(@NoOfLeg2Stops > @NoOfLeg1Stops)  
    BEGIN  
     SET @NoOfAirStops = (@NoOfLeg2Stops - 1)  
    END  
    ELSE IF(@NoOfLeg1Stops = @NoOfLeg2Stops)  
    BEGIN  
     SET @NoOfAirStops = (@NoOfLeg1Stops - 1)  
    END  
      
   END  
     
   SET @isMultipleAirline = dbo.udf_ComapreMultipleAirlines(@OriginalMarketingAirline)  
   IF (@isMultipleAirline = 0)  
   BEGIN  
    SET @singleAirlineCode = SUBSTRING(@OriginalMarketingAirline, 1, 2)  
    SET @TMUMarketingAirlineCode = @singleAirlineCode  
    SET @TMUMarketingAirlineName = (SELECT ShortName FROM AirVendorLookup  WITH (NOLOCK) WHERE AirlineCode = @singleAirlineCode)  
   END  
   ELSE  
   BEGIN  
    SET @TMUMarketingAirlineCode = 'Multiple Airlines'  
    SET @TMUMarketingAirlineName = 'Multiple Airlines'  
   END  
     
   /*IF TRIP KEY IS NOT PRESENT IN TRIPDETAILS TABLE THEN INSERT OR ELSE UPDATE*/  
   IF((SELECT COUNT(tripKey) FROM TripDetails WHERE tripKey = @AirTripKey) = 0)  
   BEGIN  
    INSERT INTO TripDetails(tripKey,tripSavedKey,userKey,tripFrom,tripTo,tripStartDate  
    ,tripEndMonth,tripEndYear  
    ,latestDealAirSavingsPerPerson  
    ,latestDealAirSavingsTotal  
    ,latestDealAirPricePerPerson  
    ,latestDealAirPriceTotal  
    ,AirRequestTypeName  
    ,AirCabin  
    ,FromCountryCode  
    ,FromCountryName  
    ,FromStateCode  
    ,FromCityName  
    ,ToCountryCode  
    ,ToCountryName  
    ,ToStateCode  
    ,ToCityName  
    ,tripEndDate  
    ,LatestAirLineCode  
    ,LatestAirlineName  
    ,NumberOfCurrentAirStops  
    --,originalPerPersonPriceAir  
    --,originalTotalPriceAir  
    )  
    VALUES  
    (@AirTripKey,@AirTripSavedKey,@UserKeyAir,@TripFromAir,@TripToAir,@TripStartDateAir  
    ,@TripEndMonthAir,@TripEndYearAir  
    ,0  
    ,0  
    ,@AirBookedPerPersonPrice  
    ,@AirOriginalTotalPrice  
    ,@AirRequestType  
    ,@AirSegmentCabin  
    ,@FromCountryCodeAir  
    ,@FromCountryNameAir  
    ,@FromStateCodeAir  
    ,@FromCityNameAir  
    ,@ToCountryCodeAir  
    ,@ToCountryNameAir  
    ,@ToStateCodeAir  
    ,@ToCityNameAir  
    ,@TripEndDateAir  
    ,@TMUMarketingAirlineCode  
    ,@TMUMarketingAirlineName  
    ,@NoOfAirStops  
    --,@AirBookedPerPersonPrice  
    --,@AirOriginalTotalPrice  
    )  
   END  
   ELSE  
   BEGIN  
    UPDATE TripDetails SET   
    tripFrom = @TripFromAir  
    ,tripTo = @TripToAir  
    ,tripStartDate = @TripStartDateAir  
    ,tripEndDate = @TripEndDateAir  
    ,tripEndMonth = @TripEndMonthAir  
    ,tripEndYear = @TripEndYearAir  
    ,latestDealAirSavingsPerPerson = 0  
    ,latestDealAirSavingsTotal = 0  
    ,latestDealAirPricePerPerson = @AirBookedPerPersonPrice  
    ,latestDealAirPriceTotal = @AirOriginalTotalPrice  
    ,AirRequestTypeName = @AirRequestType  
    ,AirCabin = @AirSegmentCabin  
    ,FromCountryCode = @FromCountryCodeAir  
    ,FromCountryName = @FromCountryNameAir  
    ,FromStateCode = @FromStateCodeAir  
    ,FromCityName = @FromCityNameAir  
    ,ToCountryCode = @ToCountryCodeAir  
    ,ToCountryName = @ToCountryNameAir  
    ,ToStateCode = @ToStateCodeAir  
    ,ToCityName = @ToCityNameAir  
    ,LatestAirLineCode = @TMUMarketingAirlineCode  
    ,LatestAirlineName = @TMUMarketingAirlineName  
    ,NumberOfCurrentAirStops = @NoOfAirStops  
    --,originalPerPersonPriceAir = @AirBookedPerPersonPrice  
    --,originalTotalPriceAir = @AirOriginalTotalPrice  
    ,lastUpdatedDate = GETDATE()  
    WHERE tripKey = @AirTripKey  
   END  
     
   END TRY  
   BEGIN CATCH  
   SET @ErrorMessage = ERROR_MESSAGE();  
   INSERT INTO TripSavedDealLog (TripKey, ComponentType, ErrorMessage, Remarks, InitiatedFrom)   
   VALUES(@AirTripKey, 1, @ErrorMessage  
   ,'Error while inserting failed trip in table TripDetails. stored procedure USP_UpdateFailedTripSavedDeal', 'TMU')  
   END CATCH  
   /*END: TMU DATA INSERTED IN TABLE TripDetails*/  
     
   Update AirRequestTripSavedDeal Set IsSuccess = 1 Where TripKey = @AirTripKey  
   Update @TblAirFailedTripSavedKey Set IsUsed = 1 Where PkId = @AirPkId  
   SET  @AirInsertCount += 1  
  END   
 END  
   
 ELSE IF(@ComponentType = 'CAR')  
 BEGIN  
  Declare @CarTripKey Int  
    ,@CarCountToExecute Int  
    ,@CarInsertCount Int  
    ,@CarPkId Int  
    ,@CarTripSavedKey Uniqueidentifier  
    ,@CarVendorKey Varchar(10)  
    ,@CarOriginalTotalPrice Float  
    ,@CarResponseKey Uniqueidentifier  
    ,@OriginalCarPerPersonPrice Float  
    ,@TripRequestKeyCar INT  
    ,@UserKeyCar INT  
    ,@TripFromCar VARCHAR(3)  
    ,@TripToCar VARCHAR(3)  
    ,@TripStartDateCar DATETIME  
    ,@TripEndDateCar DATETIME  
    ,@FromCountryCodeCar VARCHAR(2)  
    ,@FromCountryNameCar VARCHAR(128)  
    ,@FromStateCodeCar VARCHAR(2)  
    ,@FromCityNameCar VARCHAR(64)  
    ,@ToCountryCodeCar VARCHAR(2)  
    ,@ToCountryNameCar VARCHAR(128)  
    ,@ToStateCodeCar VARCHAR(2)  
    ,@ToCityNameCar VARCHAR(64)  
    ,@TripEndMonthCar INT  
    ,@TripEndYearCar INT  
    ,@CarCategoryName VARCHAR(30)  
    ,@CarCategoryCodeForTMU CHAR  
    ,@NewCarVendorName VARCHAR(30)  
    
  Declare @TblCarFailedTripSavedKey As Table(PkId int identity(1,1),TripKey Int,TripSavedKey UniqueIdentifier  
  ,OriginalPerPersonPrice Float,IsUsed Bit Default(0))  
    
  Update CarRequestTripSavedDeal Set IsSuccess = 0 Where TripKey   
  In (Select tripKey From TripSavedDeals Where responseDetailKey Is Null And componentType = 2   
  And CONVERT(varchar, creationDate, 103) = CONVERT(varchar, GETDATE(), 103))  
    
  Delete From TripSavedDeals Where responseDetailKey Is Null And componentType = 2   
  And CONVERT(varchar, creationDate, 103) = CONVERT(varchar, GETDATE(), 103)  
    
  Insert Into FailedTripSavedDeal (TripKey, ComponentType, TripSavedKey)  
  Select TripKey, 2, TripSavedKey From CarRequestTripSavedDeal Where IsSuccess = 0  
    
  Insert Into @TblCarFailedTripSavedKey (TripKey, TripSavedKey, OriginalPerPersonPrice)  
  Select TripKey, TripSavedKey, ((MinRateTax/NoOfDays) + MinRate) From CarRequestTripSavedDeal Where IsSuccess = 0  
    
  Set @CarCountToExecute = (Select COUNT(*) from @TblCarFailedTripSavedKey)  
  Set @CarInsertCount = 1   
    
  WHILE (@CarInsertCount <= @CarCountToExecute)  
  BEGIN  
    
   Select Top 1 @CarPkId = PkId, @CarTripKey = TripKey, @CarTripSavedKey = TripSavedKey, @OriginalCarPerPersonPrice = OriginalPerPersonPrice   
   From @TblCarFailedTripSavedKey Where IsUsed = 0  
     
   Select @CarVendorKey = carVendorKey,@CarOriginalTotalPrice = ((minRate * NoOfDays) + minRateTax)  
   ,@CarResponseKey = carResponseKey From TripCarResponse With (NoLock) Where tripGUIDKey = @CarTripSavedKey   
            
   Insert Into TripSavedDeals (tripKey,responseKey,componentType,currentPerPersonPrice  
   ,originalPerPersonPrice,fareCategory,responseDetailKey  
   ,isAlternate,vendorDetails,currentTotalPrice,originalTotalPrice,Remarks)    
   Values  
   (@CarTripKey,@CarResponseKey,2,@OriginalCarPerPersonPrice, @OriginalCarPerPersonPrice  
   ,'Publish',@CarResponseKey,0,@CarVendorKey,@CarOriginalTotalPrice,@CarOriginalTotalPrice,'Failed Trip Key. Original trip inserted')  
     
   /*TMU DATA INSERTED IN TABLE TripDetails*/  
    BEGIN TRY  
     SELECT @TripRequestKeyCar = tripRequestKey, @UserKeyCar = userKey  
     FROM Trip WITH (NOLOCK) WHERE tripKey = @CarTripKey  
       
     SELECT @TripFromCar = tripFrom1, @TripToCar = tripTo1  
     ,@TripStartDateCar = tripFromDate1, @TripEndDateCar = tripToDate1  
     ,@TripEndMonthCar = DATEPART(MONTH,tripToDate1)  
     ,@TripEndYearCar = DATEPART(YEAR,tripToDate1)  
     FROM TripRequest WITH (NOLOCK) WHERE tripRequestKey = @TripRequestKeyCar  
       
     SELECT TOP 1 @FromCountryCodeCar = AL.CountryCode   
     ,@FromCountryNameCar = CL.CountryName  
     ,@FromStateCodeCar = AL.StateCode  
     ,@FromCityNameCar = AL.CityName  
     FROM AirportLookup AL WITH (NOLOCK)  
     LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)  
     ON CL.CountryCode = AL.CountryCode  
     WHERE AL.AirportCode = @TripFromCar  
       
     SELECT TOP 1 @ToCountryCodeCar = AL.CountryCode   
     ,@ToCountryNameCar = CL.CountryName  
     ,@ToStateCodeCar = AL.StateCode  
     ,@ToCityNameCar = AL.CityName  
     FROM AirportLookup AL WITH (NOLOCK)  
     LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)  
     ON CL.CountryCode = AL.CountryCode  
     WHERE AL.AirportCode = @TripToCar  
     
     SELECT TOP 1 @CarCategoryCodeForTMU = SUBSTRING (carCategoryCode, 1, 1)   
     FROM CarRequestTripSavedDeal WHERE TripKey = @CarTripKey  
       
     SET @CarCategoryName = (SELECT CarClass FROM CarPriorityByClass WITH (NOLOCK)   
     WHERE CarClassShortName = @CarCategoryCodeForTMU)  
       
     SELECT @NewCarVendorName = CarCompanyName   
     FROM CarContent.dbo.CarCompanies WITH (NOLOCK)  
     WHERE CarCompanyCode = @CarVendorKey  
       
     IF(ISNULL(@CarVendorKey, '') = '')  
     BEGIN  
      SET @NewCarVendorName = 'DefaultCar'  
      SET @CarVendorKey = 'DefaultCar'  
     END  
       
     IF((SELECT COUNT(tripKey) FROM TripDetails WHERE tripKey = @CarTripKey) = 0)  
     BEGIN  
      INSERT INTO TripDetails  
      (  
       tripKey  
       ,tripSavedKey  
       ,userKey  
       ,tripFrom  
       ,tripTo  
       ,tripStartDate  
       ,tripEndMonth  
       ,tripEndYear  
       ,latestDealCarSavingsPerPerson  
       ,latestDealCarSavingsTotal  
       ,latestDealCarPricePerPerson  
       ,latestDealCarPriceTotal  
       ,CarClass  
       ,CarVendorCode  
       ,fromCountryCode  
       ,fromCountryName  
       ,fromStateCode  
       ,fromCityName  
       ,toCountryCode  
       ,toCountryName  
       ,toStateCode  
       ,toCityName  
       ,tripEndDate  
       ,originalPerPersonPriceCar  
       ,originalTotalPriceCar  
       ,LatestCarVendorName  
      )  
      VALUES  
      (  
       @CarTripKey  
       ,@CarTripSavedKey  
       ,@UserKeyCar  
       ,@TripFromCar  
       ,@TripToCar  
       ,@TripStartDateCar  
       ,@TripEndMonthCar  
       ,@TripEndYearCar  
       ,0  
       ,0  
       ,@OriginalCarPerPersonPrice  
       ,@CarOriginalTotalPrice  
       ,@CarCategoryName  
       ,@CarVendorKey  
       ,@FromCountryCodeCar  
       ,@FromCountryNameCar  
       ,@FromStateCodeCar  
       ,@FromCityNameCar  
       ,@ToCountryCodeCar  
       ,@ToCountryNameCar  
       ,@ToStateCodeCar  
       ,@ToCityNameCar  
       ,@TripEndDateCar  
       ,@OriginalCarPerPersonPrice  
       ,@CarOriginalTotalPrice  
       ,@NewCarVendorName  
      )  
     END  
     ELSE  
     BEGIN  
      UPDATE TripDetails SET  
      tripFrom = @TripFromCar  
      ,tripTo = @TripToCar  
      ,tripStartDate = @TripStartDateCar  
      ,tripEndDate = @TripEndDateCar  
      ,tripEndMonth = @TripEndMonthCar  
      ,tripEndYear = @TripEndYearCar  
      ,latestDealCarSavingsPerPerson = 0  
      ,latestDealCarSavingsTotal = 0  
      ,latestDealCarPricePerPerson = @OriginalCarPerPersonPrice  
      ,latestDealCarPriceTotal = @CarOriginalTotalPrice  
      ,CarClass = @CarCategoryName  
      ,CarVendorCode = @CarVendorKey  
      ,fromCountryCode = @FromCountryCodeCar  
      ,fromCountryName = @FromCountryNameCar  
      ,fromStateCode = @FromStateCodeCar  
      ,fromCityName = @FromCityNameCar  
      ,toCountryCode = @ToCountryCodeCar  
      ,toCountryName = @ToCountryNameCar  
      ,toStateCode = @ToStateCodeCar  
      ,toCityName = @ToCityNameCar  
      ,originalPerPersonPriceCar = @OriginalCarPerPersonPrice  
      ,originalTotalPriceCar = @CarOriginalTotalPrice  
      ,LatestCarVendorName = @NewCarVendorName  
      ,lastUpdatedDate = GETDATE()  
      WHERE tripKey = @CarTripKey  
     END  
     END TRY  
     BEGIN CATCH       
     SET @ErrorMessage = ERROR_MESSAGE();  
     INSERT INTO TripSavedDealLog (TripKey, ComponentType, ErrorMessage, Remarks, InitiatedFrom)   
     VALUES(@CarTripKey, 2, @ErrorMessage  
     ,'Error while inserting failed trip in table TripDetails. stored procedure USP_UpdateFailedTripSavedDeal', 'TMU')  
     END CATCH  
    /*END: TMU DATA INSERTED IN TABLE TripDetails*/  
     
   Update CarRequestTripSavedDeal Set IsSuccess = 1 Where TripKey = @CarTripKey  
   Update @TblCarFailedTripSavedKey Set IsUsed = 1 Where PkId = @CarPkId  
   SET  @CarInsertCount += 1  
  END  
 END  
   
END  

GO
