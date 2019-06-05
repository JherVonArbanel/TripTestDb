SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Exec [USP_UpdateTripSavedDealHotelDetails_Marketplace] '62ac5554-25e9-4466-9f8e-ccc112872f29', 'DEVELOPMENT'    
CREATE PROCEDURE [dbo].[USP_UpdateTripSavedDealHotelDetails]    
 -- Add the parameters for the stored procedure here    
 @HotelResponseKey UniqueIdentifier    
 ,@SiteEnvironment Varchar(20) = 'D'    
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
     
 --BEGIN TRY    
     
 Declare @MinimumPrice Float    
   ,@HotelResponseDetailKey UniqueIdentifier    
   ,@NoOfDays Int    
   ,@NoOfRooms Int    
   ,@TripKey Int    
   ,@HotelPolicy Varchar(2000)    
   ,@CheckInInstruction Varchar(2000)    
   ,@BookedPerPersonPrice Float    
   ,@touricoActualMarkupPercent FLOAT    
   ,@hotelTaxRate FLOAT    
     
 Declare @TblTripKey As Table(Tripkey Int, TripSavedKey UniqueIdentifier    
 ,latestDealHotelSavingsPerPerson FLOAT    
 ,latestDealHotelSavingsTotal FLOAT)    
     
 DECLARE @TblHotelResponseDetail AS TABLE    
 (     
  hotelTotalPrice FLOAT    
  ,hotelResponseDetailKey UNIQUEIDENTIFIER    
  ,touricoActualMarkupPercent FLOAT    
 )    
     
 INSERT INTO @TblHotelResponseDetail    
 EXEC USP_GetDealHotelDetailsByResponseID     
 @hotelResponseKey = @HotelResponseKey    
 ,@isNightlyRobotCall = 1    
 ,@environment = @SiteEnvironment    
     
 --PRODUCTION/DEVELOPMENT FOR GURANTEE CODE 'D' IS TAKEN CARE IN USP_GetDealHotelDetailsByResponseID SP     
 Select @MinimumPrice = hotelTotalPrice    
 ,@HotelResponseDetailKey = hotelResponseDetailKey    
 ,@touricoActualMarkupPercent = ISNULL(touricoActualMarkupPercent, 0)    
 From @TblHotelResponseDetail    
     
 If((@MinimumPrice IS NULL OR @MinimumPrice = '') OR (@HotelResponseDetailKey IS NULL))    
 Begin    
       
  Declare @TripKeys Varchar(2000)    
      
  Insert Into @TblTripKey (Tripkey)    
  Select tripKey from TripSavedDeals With (NoLock) where responseKey = @HotelResponseKey      
      
  Select @TripKeys = STUFF((SELECT ',' + CONVERT(Varchar, Tripkey) FROM @TblTripKey FOR XML PATH(''), TYPE).value('.[1]', 'nvarchar(max)'), 1, 1, '') FROM @TblTripKey AS x--STUFF((SELECT  ',' + CONVERT(Varchar, Tripkey) From @TblTripKey  FOR XML PATH ('')),1,1,'')    
      
  Update HotelRequestTripSavedDeal Set IsSuccess = 0 Where TripKey In (Select Tripkey from @TblTripKey)    
      
  Insert Into TripSavedDealLog (ComponentType, Remarks) Values (4, 'MinimumPrice OR HotelResponseDetailKey is null. HotelResponseKey : ' + CONVERT(Varchar(100), @HotelResponseKey) + ' ==>> TripKeys :' + ISNULL(@TripKeys,''))    
      
  Delete From TripSavedDeals Where responseKey = @HotelResponseKey     
  --Delete From TripDetails Where HotelResponseKey = @HotelResponseKey    
 End    
 Else    
 Begin    
      
  Select Top 1 @HotelPolicy = hotelPolicy, @CheckInInstruction = checkInInstruction From HotelDescription With (NoLock)     
  Where hotelResponseKey = @HotelResponseKey Order By hotelPolicy Desc    
       
  Set @NoOfDays = (Select Top 1 DATEDIFF(day, CONVERT(VARCHAR(10), checkInDate, 120), CONVERT(VARCHAR(10), checkOutDate, 120))     
  From TripHotelResponse With (NoLock) Where hotelResponseKey = @HotelResponseKey)    
      
  Set @TripKey = (Select Top 1 tripKey From TripSavedDeals With (Nolock) Where responseKey = @HotelResponseKey)    
  Set @NoOfRooms = (Select noOfRooms From Trip With (NoLock) Where tripKey = @TripKey and tripStatusKey <> 17)    
       
  UPDATE T  SET  supplierHotelKey = HD.supplierHotelKey, supplierId = HD.supplierId, hotelTotalPrice = HD.hotelTotalPrice     
  ,hotelDailyPrice = HD.hotelDailyPrice, hotelTaxRate = HD.hotelTaxRate, hotelRatePlanCode = HD.hotelRatePlanCode     
  ,rateDescription = HD.rateDescription,guaranteeCode = hd.guaranteeCode, hotelDescription = CASE WHEN HD.roomDescription     
  IS NULL OR HD.roomDescription = '' THEN HD.hotelDescription ELSE HD.roomDescription END, SupplierType = HD.hotelsComSupplierType    
  ,salesTaxAndHotelOccupancyTax = HD.salesTaxAndHotelOccupancyTax,originalHotelTotalPrice = HD.originalHotelTotalPrice    
  ,cancellationPolicy = HD.CancellationPolicy, roomDescriptionShort = CASE WHEN HD.roomDescriptionShort IS NULL OR HD.roomDescriptionShort = ''    
  THEN HD.hotelDescription ELSE HD.roomDescriptionShort END    
  ,hotelRoomTypeCode = HD.hotelRoomTypeCode    
  ,MarketplaceMarginPercent = @touricoActualMarkupPercent    
  From TripHotelResponse T     
  Inner Join  HotelResponseDetail HD ON t.hotelResponseKey = HD.hotelResponseKey      
  AND HD.hotelResponseDetailKey = @HotelResponseDetailKey    
      
  Update TripSavedDeals Set currentPerPersonPrice = Convert(Decimal(10,2),((@MinimumPrice/@NoOfDays))),responseDetailKey = @HotelResponseDetailKey    
  ,currentTotalPrice = (@MinimumPrice)-- * @NoOfRooms)    
  Where responseKey = @HotelResponseKey    
      
  /*TMU DATA INSERTED IN TABLE TripDetails*/    
  Insert Into @TblTripKey     
  (    
   Tripkey    
   ,TripSavedKey    
   ,latestDealHotelSavingsPerPerson    
   ,latestDealHotelSavingsTotal    
  )    
  Select     
   tripKey    
   ,tripSavedKey    
   ,(originalPerPersonPriceHotel - @MinimumPrice)    
   ,(originalTotalPriceHotel - (@MinimumPrice))   -- * @NoOfRooms  
  From TripDetails With (NoLock) where HotelResponseKey = @HotelResponseKey    
      
  /*The below code is commented as we are picking the original price from TripDetails table*/    
  --UPDATE TK SET      
  --TK.latestDealHotelSavingsPerPerson = ISNULL((TH.hotelTotalPrice - @MinimumPrice),0)    
  --,TK.OriginalTotalPrice = (TH.hotelTotalPrice * @NoOfRooms)    
  --FROM @TblTripKey TK    
  --INNER JOIN TripHotelResponse TH WITH (NOLOCK)    
  --ON TH.tripGUIDKey = TK.TripSavedKey    
  /*END: The below code is commented as we are picking the original price from TripDetails table*/    
      
  SET @hotelTaxRate = (SELECT THR.hotelTaxRate     
                  FROM TripHotelResponse THR     
                  Inner Join  HotelResponseDetail HD ON THR.hotelResponseKey = HD.hotelResponseKey      
      AND HD.hotelResponseDetailKey = @HotelResponseDetailKey)    

DECLARE @isTourico INT
SET @isTourico = (SELECT TOP 1 CASE WHEN HRD.supplierId='Tourico' THEN 1 ELSE 0 END  FROM Trip..HotelResponseDetail HRD WHERE hotelResponseKey =@HotelResponseKey)


--added this @isTourico by pradeep/vivek for tourico hotell.
/*added by pradeep/vivek for TFS : 17513,18719,19499,19445,19415*/
--when we have tourco hote as recommended, then minimum price do not include taxrate and noofdays.
--which was causing and issue on multiple page on carryon websit i.e trips, alerts, myaccount etc...pages...
-- so to avoid this, we are again maually calculating price for all latest column in Tripdetails table.
IF(@isTourico = 1)
BEGIN

	SET @hotelTaxRate  = (SELECT TOP 1 CASE WHEN HRD.supplierId='Tourico' THEN HRD.TouricoTaxRate ELSE @hotelTaxRate END  FROM Trip..HotelResponseDetail HRD WHERE hotelResponseKey =@HotelResponseKey )
	DECLARE @minimumTotalPriceforTourico FLOAT
	SET @minimumTotalPriceforTourico = Convert(Decimal(10,2),((@MinimumPrice * @NoOfRooms) + @hotelTaxRate * @NoOfRooms )) 

	Declare @TblTripKeyforTourico As Table(Tripkey Int, TripSavedKey UniqueIdentifier    
	,latestDealHotelSavingsPerPerson FLOAT    
	,latestDealHotelSavingsTotal FLOAT)  
  
	Insert Into @TblTripKeyforTourico( Tripkey,TripSavedKey,latestDealHotelSavingsPerPerson,latestDealHotelSavingsTotal)    
	Select tripKey ,tripSavedKey ,(originalPerPersonPriceHotel - @minimumTotalPriceforTourico) ,(originalTotalPriceHotel - @minimumTotalPriceforTourico)  
	From TripDetails With (NoLock) where HotelResponseKey = @HotelResponseKey 


	UPDATE TD SET    
	  TD.latestDealHotelSavingsPerPerson = Convert(Decimal(10,2),TK.latestDealHotelSavingsPerPerson)  
	  ,TD.latestDealHotelSavingsTotal = Convert(Decimal(10,2),(TK.latestDealHotelSavingsTotal)) 
	  ,TD.latestDealHotelPricePerPerson = Convert(Decimal(10,2),(@MinimumPrice))
	  ,TD.latestDealHotelPriceTotal = @minimumTotalPriceforTourico   --changed by pradeep/vivek 
	  ,TD.LatestDealHotelPricePerPersonPerDay = Convert(Decimal(10,2),((@MinimumPrice/@NoOfDays )))    
	  FROM TripDetails TD    
	  INNER JOIN @TblTripKeyforTourico TK    
	  ON TK.Tripkey = TD.tripKey    
	  WHERE TD.HotelResponseKey = @HotelResponseKey     
END
ELSE 
BEGIN
	UPDATE TD SET    
  TD.latestDealHotelSavingsPerPerson = Convert(Decimal(10,2),TK.latestDealHotelSavingsPerPerson)  
  ,TD.latestDealHotelSavingsTotal = Convert(Decimal(10,2),(TK.latestDealHotelSavingsTotal)) -- removed @hotelTaxRate again for TFS 15867    
  ,TD.latestDealHotelPricePerPerson = Convert(Decimal(10,2),(((@MinimumPrice - @hotelTaxRate)/@NoOfDays)))    
  ,TD.latestDealHotelPriceTotal = Convert(Decimal(10,2),((@MinimumPrice * @NoOfRooms) ))  -- adding *@NoOfRooms and adding @hotelTaxRate again for TFS 15867   
  ,TD.LatestDealHotelPricePerPersonPerDay = Convert(Decimal(10,2),((@MinimumPrice/@NoOfDays)))    
  FROM TripDetails TD    
  INNER JOIN @TblTripKey TK    
  ON TK.Tripkey = TD.tripKey    
  WHERE TD.HotelResponseKey = @HotelResponseKey    
  /*END: TMU DATA INSERTED IN TABLE TripDetails*/    
      
 
END

   
  /*END: TMU DATA INSERTED IN TABLE TripDetails*/    
      
  /*Original Code where currentPerPersonPrice is divided by 2*/    
  --Update TripSavedDeals Set currentPerPersonPrice = Convert(Decimal(10,2),(((@MinimumPrice/2)/@NoOfDays))),responseDetailKey = @HotelResponseDetailKey    
  --,currentTotalPrice = (@MinimumPrice * @NoOfRooms)    
  --Where responseKey = @HotelResponseKey    
      
 End    
     
 --END TRY    
 --BEGIN CATCH    
 -- DECLARE @ErrorMessage NVARCHAR(4000);    
 --  SET @ErrorMessage = ERROR_MESSAGE();    
 --  --RAISERROR (@ErrorMessage, 16, 1);    
 --  INSERT INTO TripSavedDealLog (ErrorMessage, ErrorStack) Values ('Error in stored procedure USP_UpdateTripSavedDealHotelDetails. Hotel Response Key: ' + CONVERT(varchar,@HotelResponseKey) + '... Site Environment : ' + @SiteEnvironment, @ErrorMessage) 
  
   
 --END CATCH;    
END    
GO
