SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--Exec [USP_UpdateTripSavedDealHotelDetails] '1191DE30-21AE-4BE4-86A0-750F8AB9F470', 'DEVELOPMENT'
CREATE PROCEDURE [dbo].[USP_UpdateTripSavedDealHotelDetails_2]
	-- Add the parameters for the stored procedure here
	@HotelResponseKey UniqueIdentifier
	,@SiteEnvironment Varchar(20)
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
	
	Declare @TblTripKey As Table(Tripkey Int, TripSavedKey UniqueIdentifier
	,latestDealHotelSavingsPerPerson FLOAT
	,latestDealHotelSavingsTotal FLOAT)
	
	If(@SiteEnvironment = 'PRODUCTION')
	Begin
		Select Top 1 @MinimumPrice = hotelTotalPrice, @HotelResponseDetailKey = hotelResponseDetailKey 
		From HotelResponseDetail With (NoLock) Where hotelResponseKey = @HotelResponseKey 
		And (rateDescription Not Like ('%A A A%') 
		And rateDescription Not Like ('%AAA%') 
		And rateDescription Not Like ('%SENIOR%') 
		And rateDescription Not Like ('%GOV%'))
		Order By hotelTotalPrice Asc
	End
	Else
	Begin
		Select Top 1 @MinimumPrice = hotelTotalPrice, @HotelResponseDetailKey = hotelResponseDetailKey 
		From HotelResponseDetail With (NoLock) Where hotelResponseKey = @HotelResponseKey 
		And (rateDescription Not Like ('%A A A%') 
		AND rateDescription Not Like ('%AAA%') 
		AND rateDescription Not Like ('%SENIOR%') 
		AND rateDescription Not Like ('%GOV%')) 
		And ISNULL(guaranteeCode,'') <> 'D'
		Order By hotelTotalPrice Asc
	End
	
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
			,(originalTotalPriceHotel - (@MinimumPrice * @NoOfRooms))
		From TripDetails With (NoLock) where HotelResponseKey = @HotelResponseKey
		
		/*The below code is commented as we are picking the original price from TripDetails table*/
		--UPDATE TK SET		
		--TK.latestDealHotelSavingsPerPerson = ISNULL((TH.hotelTotalPrice - @MinimumPrice),0)
		--,TK.OriginalTotalPrice = (TH.hotelTotalPrice * @NoOfRooms)
		--FROM @TblTripKey TK
		--INNER JOIN TripHotelResponse TH WITH (NOLOCK)
		--ON TH.tripGUIDKey = TK.TripSavedKey
		/*END: The below code is commented as we are picking the original price from TripDetails table*/
		
		UPDATE TD SET
		TD.latestDealHotelSavingsPerPerson = Convert(Decimal(10,2),TK.latestDealHotelSavingsPerPerson)
		,TD.latestDealHotelSavingsTotal = Convert(Decimal(10,2),(TK.latestDealHotelSavingsTotal))
		,TD.latestDealHotelPricePerPerson = Convert(Decimal(10,2),(@MinimumPrice))
		,TD.latestDealHotelPriceTotal = Convert(Decimal(10,2),(@MinimumPrice * @NoOfRooms))
		,TD.LatestDealHotelPricePerPersonPerDay = Convert(Decimal(10,2),((@MinimumPrice/@NoOfDays)))
		FROM TripDetails TD
		INNER JOIN @TblTripKey TK
		ON TK.Tripkey = TD.tripKey
		WHERE TD.HotelResponseKey = @HotelResponseKey		
		/*END: TMU DATA INSERTED IN TABLE TripDetails*/
		
		/*Original Code where currentPerPersonPrice is divided by 2*/
		--Update TripSavedDeals Set currentPerPersonPrice = Convert(Decimal(10,2),(((@MinimumPrice/2)/@NoOfDays))),responseDetailKey = @HotelResponseDetailKey
		--,currentTotalPrice = (@MinimumPrice * @NoOfRooms)
		--Where responseKey = @HotelResponseKey
		
	End
	
	--END TRY
	--BEGIN CATCH
	--	DECLARE @ErrorMessage NVARCHAR(4000);
	--		SET @ErrorMessage = ERROR_MESSAGE();
	--		--RAISERROR (@ErrorMessage, 16, 1);
	--		INSERT INTO TripSavedDealLog (ErrorMessage, ErrorStack) Values ('Error in stored procedure USP_UpdateTripSavedDealHotelDetails. Hotel Response Key: ' + CONVERT(varchar,@HotelResponseKey) + '... Site Environment : ' + @SiteEnvironment, @ErrorMessage)
	--END CATCH;
END
GO
