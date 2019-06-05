SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
-- =============================================  
-- Author:  Jayant Guru  
-- Create date: 29th June 2012  
-- Description: Gets 3 minimum fare  
-- =============================================  
--Exec USP_GetTripSavedDealCarMinPrice 132250, 128
CREATE PROCEDURE [dbo].[USP_GetTripSavedDealCarMinPrice]  
 -- Add the parameters for the stored procedure here  
 @CarRequestKey int  
 ,@PkGroupId int  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
   Declare @isDefaultVal int = 0 --for TFS #19445
   
 Declare @TblCarResponse As Table ([carResponseKey] uniqueidentifier,[carRequestKey] int,[carVendorKey] varchar(50)  
 ,[supplierId] varchar(50),[carCategoryCode] varchar(50),[carLocationCode] varchar(50),[carLocationCategoryCode] varchar(50)  
 ,[minRate] float,[minRateTax] float,[DailyRate] float,[TotalChargeAmt] float,[NoOfDays] int,[RateQualifier] varchar(25)  
 ,[ReferenceType] varchar(10),[ReferenceDateTime] varchar(20),[ReferenceId] varchar(50),[MileageAllowance] varchar(10)  
 ,[RatePlan] varchar(10),IsUsed Bit Default(0))  
   
 Declare @TblCarResponseDetail As Table ([carResponseDetailKey] uniqueidentifier,[carResponseKey] uniqueidentifier  
 ,[carVendorKey] varchar(50),[supplierId] varchar(50),[carCategoryCode] varchar(50),[carLocationCode] varchar(50)  
 ,[carLocationCategoryCode] varchar(50),[minRate] float,[minRateTax] float,[totalPrice] float,[NoOfDays] int,[RateQualifier] varchar(25)  
 ,[ReferenceType] varchar(10),[ReferenceDateTime] varchar(20),[ReferenceId] varchar(50),[MileageAllowance] varchar(10)  
 ,[RatePlan] varchar(10),[GuaranteeCode] varchar(20),[SellGuaranteeReq] bit,FareCategory varchar(30),PerDayPrice Float)  
   
 Declare @TblMinCurrentPrice as Table(PkId int identity(1,1),CurrentMinimumPrice float,CarResponseDetailKey Uniqueidentifier
 ,CarResponseKey Uniqueidentifier,CarVendorKey Varchar(10),IsUsed Bit Default(0),TotalPrice Float)
 
 Declare @TblMinThreshHoldPrice as Table(PkId int identity(1,1),CurrentMinimumPrice float,CarResponseDetailKey Uniqueidentifier
 ,CarResponseKey Uniqueidentifier,CarVendorKey Varchar(10),IsUsed Bit Default(0),TotalPrice Float)  
   
 Declare @TblGroup as Table(TblGroupKey int identity(1,1),TripKey int,TripSavedKey UniqueIdentifier,ActualCarPrice Float
 ,ActualCarTax Float,IsInserted Bit Default(0),MinRate Float,MinRateTax Float,NoOfDays Int)  
 Declare @TblVendorDetails AS Table (VendorDetailsId int identity(1,1),VendorDetails Varchar(200),CreationDate Datetime,IsUsed bit Default(0))
 
 Declare @TblCarResponseDetailKey as Table(CarResponseDetailKey UniqueIdentifier)
   
 Insert Into @TblCarResponse(carResponseKey,carRequestKey,carVendorKey,supplierId,carCategoryCode,carLocationCode  
 ,carLocationCategoryCode,minRate,minRateTax,DailyRate,TotalChargeAmt,NoOfDays,RateQualifier,ReferenceType  
 ,ReferenceDateTime,ReferenceId,MileageAllowance,RatePlan)  
 Select carResponseKey,carRequestKey,carVendorKey,supplierId,carCategoryCode,carLocationCode  
 ,carLocationCategoryCode,minRate,minRateTax,DailyRate,TotalChargeAmt,NoOfDays,RateQualifier,ReferenceType  
 ,ReferenceDateTime,ReferenceId,MileageAllowance,RatePlan  
 From CarResponse With (NoLock) Where carRequestKey = @CarRequestKey  
  
 Insert Into @TblCarResponseDetail(carResponseDetailKey,carResponseKey,carVendorKey,supplierId,carCategoryCode  
 ,carLocationCode,carLocationCategoryCode,minRate,minRateTax,totalPrice,NoOfDays,RateQualifier,ReferenceType,ReferenceDateTime  
 ,ReferenceId,MileageAllowance,RatePlan,GuaranteeCode,SellGuaranteeReq,FareCategory,PerDayPrice)  
 Select carResponseDetailKey,carResponseKey,carVendorKey,supplierId,carCategoryCode  
 ,carLocationCode,carLocationCategoryCode,minRate,minRateTax,((minRate*NoOfDays) + minRateTax),NoOfDays,RateQualifier,ReferenceType,ReferenceDateTime  
 ,ReferenceId,MileageAllowance,RatePlan,GuaranteeCode,SellGuaranteeReq,contractCode,(minRate + (minRateTax/NoOfDays))
 From CarResponseDetail With (NoLock) Where carResponseKey in (Select carResponseKey from @TblCarResponse)  
 
 UPDATE TD SET carLocationCode = C.carLocationCode, carLocationCategoryCode = c.carLocationCategoryCode  
 FROM @TblCarResponseDetail TD inner join CarResponse C On TD.carResponseKey = C.carResponseKey 
 Where c.carResponseKey in (Select carResponseKey From @TblCarResponse)  
  
 Insert into @TblGroup (TripKey,TripSavedKey,ActualCarPrice,ActualCarTax,MinRate,MinRateTax,NoOfDays)   
 Select TripKey,TripSavedKey,ActualCarPrice,ActualCarTax,MinRate,MinRateTax,NoOfDays From CarRequestTripSavedDeal where PkGroupId = @PkGroupId  
   
 Declare @insertCount int  
   ,@countToExecute int  
   ,@TK int
   ,@CurrentMinimumPrice Float  
   ,@PkId int  
   ,@MinCurrentPriceCount int  
   ,@LoopCount int  
   ,@TripSavedKey UniqueIdentifier
   ,@ResponseKeyCount int
   ,@CarResponseDetailKey uniqueidentifier = '00000000-0000-0000-0000-000000000000'
   ,@CarResponseKey uniqueidentifier
   ,@ActualCarPrice Float
   ,@ActualCarTax Float
   ,@PickUpDate Datetime
   ,@DropOutDate Datetime
   ,@CarVendorKey Varchar(10)
   ,@NewCarVendorKey Varchar(10)
   ,@StoreNewCarVendorKey Varchar(10)
   ,@IntervalNewCarVendorKey Varchar(10)
   ,@NoOfDays Int
   ,@MinimumPrice Float
   ,@VendorDetailsCount int
   ,@IntervalDays int
   ,@StoreIntervalDays int
   ,@StoreCarResponseDetailKey uniqueidentifier
   ,@TblGroupKey Int
   ,@TotalPrice Float
   ,@OriginalTotalPrice Float
   ,@OriginalPerPersonPrice Float
   ,@CarCategoryCode Varchar(5)
   ,@Remarks Varchar(3000)
   ,@ThresholdPricePerDay Float
   ,@RepetitionInterval Float
   ,@TripSavedLowestDealResponseKey uniqueidentifier = '00000000-0000-0000-0000-000000000000'
   ,@OriginalCarResponseKey uniqueidentifier = '00000000-0000-0000-0000-000000000000'
   ,@UserKey INT
   ,@TripFrom VARCHAR(3)
   ,@TripTo VARCHAR(3)
   ,@TripStartDate DATETIME
   ,@TripEndDate DATETIME
   ,@TripEndMonth INT
   ,@TripEndYear INT
   ,@CurrentPerPersonPrice FLOAT
   ,@CurrentTotalPrice FLOAT
   ,@FromCountryCode VARCHAR(2)
   ,@FromCountryName VARCHAR(128)
   ,@FromStateCode VARCHAR(2)
   ,@FromCityName VARCHAR(64)
   ,@ToCountryCode VARCHAR(2)
   ,@ToCountryName VARCHAR(128)
   ,@ToStateCode VARCHAR(2)
   ,@ToCityName VARCHAR(64)
   ,@ErrorMessage VARCHAR(4000)
   ,@CarCategoryCodeForTMU CHAR
   ,@CarCategoryName VARCHAR(30)
   ,@TripRequestKey INT
   ,@NewCarVendorName VARCHAR(30)
   ,@CrowdId INT
   
    
 Select @ThresholdPricePerDay = ThresholdPricePerDay, @RepetitionInterval = RepetitionInterval From DealsThresholdSettings With (NoLock) Where ComponentTypeKey = 2 
   
 Set @insertCount = 1  
 Set @countToExecute = (Select COUNT(*) from @TblGroup)  
    
 WHILE (@insertCount <= @countToExecute)  
  BEGIN  
   SET @isDefaultVal = 0
   Set @StoreNewCarVendorKey = ''   
   Set @NewCarVendorKey = '' 
   Set @StoreIntervalDays = 0
   Delete From @TblMinThreshHoldPrice	
   --Set @TripSavedKey = (Select Top 1 TripSavedKey from @TblGroup where IsInserted = 0)  
   Set @LoopCount = 1  
   Select Top 1 @TblGroupKey = TblGroupKey,@TK = TripKey,@TripSavedKey = TripSavedKey,@OriginalPerPersonPrice = ((MinRateTax/NoOfDays) + MinRate) from @TblGroup where IsInserted = 0  
   Select @PickUpDate = pickUpDate,@DropOutDate = dropOutDate,@CarVendorKey = carVendorKey,@OriginalTotalPrice = ((minRate * NoOfDays) + minRateTax)
		  ,@NoOfDays = NoOfDays,@CarCategoryCode = carCategoryCode, @OriginalCarResponseKey = carResponseKey
   From TripCarResponse With (NoLock) Where tripGUIDKey = @TripSavedKey 
   
   Insert Into @TblMinThreshHoldPrice (CurrentMinimumPrice,CarResponseDetailKey,CarResponseKey,CarVendorKey,TotalPrice)   
   Select PerDayPrice,carResponseDetailKey,carResponseKey,carVendorKey,totalPrice From @TblCarResponseDetail 
   Where carCategoryCode IN (Select CarClass From CarPriority Where CarPrioritySequence >= (Select CarPrioritySequence Where CarClass = @CarCategoryCode))
   And ((@OriginalPerPersonPrice - PerDayPrice) >= (@ThresholdPricePerDay))
   
   If((Select COUNT(*) From @TblMinThreshHoldPrice) > 0)
   Begin
	   Insert Into @TblMinCurrentPrice (CurrentMinimumPrice,CarResponseDetailKey,CarResponseKey,CarVendorKey,TotalPrice)
	   Select CurrentMinimumPrice,CarResponseDetailKey,CarResponseKey,CarVendorKey,TotalPrice From @TblMinThreshHoldPrice
	   Order By CurrentMinimumPrice Asc
	   Set @Remarks = 'Thresh Hold Success. The price difference per day is greater than 10$'
   End
   Else
   Begin
	   --@MinimumPrice -> Least minimum price of current search
	   Set @MinimumPrice = (Select Distinct TOP 1  totalPrice from @TblCarResponseDetail Where carCategoryCode 
	   In (Select CarClass From CarPriority Where CarPrioritySequence >= (Select CarPrioritySequence Where CarClass = @CarCategoryCode)) 
	   Order By totalPrice Asc)
    	
	   Insert Into @TblMinCurrentPrice (CurrentMinimumPrice,CarResponseDetailKey,CarResponseKey,CarVendorKey,TotalPrice)   
	   Select PerDayPrice,carResponseDetailKey,carResponseKey,carVendorKey,totalPrice From @TblCarResponseDetail Where totalPrice = @MinimumPrice 
	   And carCategoryCode IN (Select CarClass From CarPriority Where CarPrioritySequence >= (Select CarPrioritySequence Where CarClass = @CarCategoryCode))
	   Set @Remarks = 'Thresh Hold Fails. The price difference per day may be less than 10$ OR it can be negative'
   End
   
   If((Select COUNT(*) From @TblMinCurrentPrice) = 0)
   Begin
	   Set @MinimumPrice = (Select Distinct TOP 1  totalPrice from @TblCarResponseDetail 
	   Where carCategoryCode = (Select carCategoryCode from CarRequestTripSavedDeal Where TripKey = @TK) Order By totalPrice Asc)	
	   
	   Insert Into @TblMinCurrentPrice (CurrentMinimumPrice,CarResponseDetailKey,CarResponseKey,CarVendorKey,TotalPrice)   
	   Select PerDayPrice,carResponseDetailKey,carResponseKey,carVendorKey,totalPrice From @TblCarResponseDetail 
	   Where  carCategoryCode = (Select carCategoryCode from CarRequestTripSavedDeal Where TripKey = @TK)
	   And totalPrice = @MinimumPrice
	   Set @Remarks = 'All Condition Fail. Executing default condition. '
	   
	   SET @isDefaultVal = 1
	   
   End
      
   Set @MinCurrentPriceCount = (Select COUNT(*) from @TblMinCurrentPrice)  
     
	   WHILE (@LoopCount <= @MinCurrentPriceCount)  
		   BEGIN  
				Set @PkId = (Select Top 1 PkId from @TblMinCurrentPrice where IsUsed = 0)  
				--Set @CurrentMinimumPrice = (Select CurrentMinimumPrice From @TblMinCurrentPrice Where PkId = @PkId)
				Select @CurrentMinimumPrice = CurrentMinimumPrice,@CarResponseDetailKey = carResponseDetailKey
				,@CarResponseKey = carResponseKey,@NewCarVendorKey = carVendorKey,@TotalPrice = TotalPrice
				From @TblMinCurrentPrice Where PkId = @PkId
				
				If(@StoreNewCarVendorKey <> @NewCarVendorKey)
				Begin
					Set @StoreNewCarVendorKey = @NewCarVendorKey
					Insert Into @TblVendorDetails (VendorDetails,CreationDate)
					Select Distinct vendorDetails,creationDate From TripSavedDeals With (NoLock) Where componentType = 2 
					And (creationDate > (DATEADD(d,@RepetitionInterval,(Select MAX(creationDate) From TripSavedDeals With (NoLock) Where componentType = 2)))) And vendorDetails <> ''
					And tripKey = @TK
					Set @VendorDetailsCount = (Select COUNT(*) From @TblVendorDetails Where VendorDetails = @StoreNewCarVendorKey)
				End
				
				If(@VendorDetailsCount > 0)
				Begin
					--@IntervalDays is the difference between the @StoreNewMarketingAirline and current date. 
					--The @IntervalDays is always stored in variable "@StoreIntervalDays" whenever it is greater then previous @IntervalDays
					Set @IntervalDays = (Select Top 1 DATEDIFF(day, CONVERT(VARCHAR(10), CreationDate, 120), CONVERT(VARCHAR(10), GETDATE(), 120)) 
					From @TblVendorDetails Where VendorDetails = @StoreNewCarVendorKey Order by CreationDate Desc)
					
					If(@IntervalDays > ISNULL(@StoreIntervalDays,0))
					Begin
						Set @StoreIntervalDays = @IntervalDays
						Set @StoreCarResponseDetailKey = @CarResponseDetailKey
						Set @IntervalNewCarVendorKey = @NewCarVendorKey
					End
				End
	 
	 --if any of the condition above doesnt match then @CarResponseDetailKey is assigned the value of @StoreCarResponseDetailKey
	 --@StoreCarResponseDetailKey is the key whose @IntervalDays is maximum
	 If(@LoopCount = @MinCurrentPriceCount And ISNULL(@StoreIntervalDays,0) <> 0)
	 Begin
		Set @CarResponseDetailKey = @StoreCarResponseDetailKey
		Set @NewCarVendorKey = @IntervalNewCarVendorKey
	 End
	 --Executing To insert data in TripSavedDeals
     If(@VendorDetailsCount = 0 OR (@LoopCount = @MinCurrentPriceCount))	
     Begin
				--If((@OriginalPerPersonPrice - @CurrentMinimumPrice) >= 10)
				--Begin
				/* In the below insert query carResponseDetailKey is inserted in responseKey as the carCategoryCode(ECAR,DCAR..) might differ for each
				carResponseDetailKey */
				Insert Into TripSavedDeals (tripKey,responseKey,componentType,currentPerPersonPrice,originalPerPersonPrice
				,fareCategory,responseDetailKey
				,isAlternate,vendorDetails,currentTotalPrice,originalTotalPrice,Remarks)  
				Select @TK,carResponseDetailKey,2,Convert(Decimal(10,2),PerDayPrice),CONVERT(Decimal(10,2), @OriginalPerPersonPrice)
				,Case When FareCategory <> '' Then 'SnapCode' Else 'Publish' End,carResponseDetailKey
				,Case When (@CarVendorKey = carVendorKey) Then 0 Else 1 End
				,@NewCarVendorKey,Convert(Decimal(10,2),totalPrice),@OriginalTotalPrice,@Remarks + ' ==> ' + CONVERT(Varchar,@CarRequestKey) + ', ' + CONVERT(Varchar,@PkGroupId)
				From @TblCarResponseDetail Where carResponseDetailKey = @CarResponseDetailKey --Select @SCOPE_IDENTITY = SCOPE_IDENTITY()
			    
			    /*CarResponseDetailKey required for car rules*/
			    Insert Into @TblCarResponseDetailKey(CarResponseDetailKey) Values (@CarResponseDetailKey)
			    
			    /*Update CarRequestTripSavedDeal To keep track if a particular trip id was successful*/
				Update CarRequestTripSavedDeal Set IsSuccess = 1 Where TripKey = @TK
			    
			    /*In the below query carResponseKey is compared with @CarResponseDetailKey And @CarResponseDetailKey is inserted in carResponseKey.
			    This is done as the carCategoryCode(ECAR,DCAR..) might differ for each carResponseDetailKey*/
				SET @ResponseKeyCount = (SELECT COUNT(*) FROM TripCarResponse With (NoLock) WHERE carResponseKey = @CarResponseDetailKey)
				IF(@ResponseKeyCount < 1)
				BEGIN
					INSERT INTO TripCarResponse(carResponseKey,tripKey,carVendorKey,supplierId,carCategoryCode,carLocationCode,carLocationCategoryCode
					,minRate,minRateTax,TotalChargeAmt,NoOfDays,SearchCarPrice,searchCarTax,actualCarPrice,actualCarTax,pickUpDate
					,dropOutDate,isExpenseAdded,contractCode)
					Select @CarResponseDetailKey,0,carVendorKey,supplierId,carCategoryCode,carLocationCode,carLocationCategoryCode
					,minRate,minRateTax,0,NoOfDays,(minRate*NoOfDays),minRateTax,(minRate*NoOfDays),minRateTax
					,@PickUpDate,@DropOutDate,0,FareCategory from @TblCarResponseDetail where carResponseDetailKey = @CarResponseDetailKey
				END	
				--End
				
				/*TMU DATA INSERTED IN TABLE TripDetails*/
				BEGIN TRY
					SELECT @TripRequestKey = tripRequestKey, @UserKey = userKey
					FROM Trip WITH (NOLOCK) WHERE tripKey = @TK
					
					SELECT @TripFrom = tripFrom1, @TripTo = tripTo1
					,@TripStartDate = tripFromDate1, @TripEndDate = tripToDate1
					,@TripEndMonth = DATEPART(MONTH,tripToDate1)
					,@TripEndYear = DATEPART(YEAR,tripToDate1)
					FROM TripRequest WITH (NOLOCK) WHERE tripRequestKey = @TripRequestKey
					
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
					
					--SELECT TOP 1 @UserKey = UserKey, @TripFrom = PickupCityCode
					--,@TripTo = DropOffCityCode, @TripStartDate = PickupDate
					--,@TripEndDate = DropOffDate
					--,@TripEndMonth = DATEPART(MONTH,DropOffDate)
					--,@TripEndYear = DATEPART(YEAR,DropOffDate)
					--,@FromCountryCode = FromCountryCode
					--,@FromCountryName = FromCountryName
					--,@FromStateCode = FromStateCode
					--,@FromCityName = FromCityName
					--,@ToCountryCode = ToCountryCode
					--,@ToCountryName = ToCountryName
					--,@ToStateCode = ToStateCode
					--,@ToCityName = ToCityName
					--FROM CarRequestTripSavedDeal WHERE TripKey = @TK
			
					SELECT @CurrentPerPersonPrice  = CONVERT(DECIMAL(10,2),PerDayPrice)
					,@CurrentTotalPrice = CONVERT(DECIMAL(10,2),totalPrice)
					,@CarCategoryCodeForTMU = SUBSTRING (carCategoryCode, 1, 1)
					,@ActualCarTax = CONVERT(DECIMAL(10,2), minRateTax)
					,@NoOfDays = NoOfDays
					FROM @TblCarResponseDetail WHERE carResponseDetailKey = @CarResponseDetailKey
					
					SET @CarCategoryName = (SELECT CarClass FROM CarPriorityByClass WITH (NOLOCK) 
					WHERE CarClassShortName = @CarCategoryCodeForTMU)
										
					SELECT @NewCarVendorName = CarCompanyName 
					FROM CarContent.dbo.CarCompanies WITH (NOLOCK)
					WHERE CarCompanyCode = @NewCarVendorKey 
					
					IF(ISNULL(@NewCarVendorKey, '') = '')
					BEGIN
						SET @NewCarVendorName = 'DefaultCar'
						SET @NewCarVendorKey = 'DefaultCar'
					END
					
					SET @CrowdId = (SELECT CrowdId FROM TripSaved
					WHERE tripSavedKey = @TripSavedKey)
					
					IF((SELECT COUNT(tripKey) FROM TripDetails WHERE tripKey = @TK) = 0)
					BEGIN
						INSERT INTO TripDetails(tripKey,tripSavedKey,userKey
						,tripFrom,tripTo,tripStartDate,tripEndMonth
						,tripEndYear,latestDealCarSavingsPerPerson
						,latestDealCarSavingsTotal,latestDealCarPricePerPerson
						,latestDealCarPriceTotal,CarClass,CarVendorCode
						,fromCountryCode,fromCountryName
						,fromStateCode,fromCityName,toCountryCode
						,toCountryName,toStateCode,toCityName,tripEndDate
						,originalPerPersonPriceCar,originalTotalPriceCar
						,LatestCarVendorName,CrowdId)
						VALUES
						(@TK,@TripSavedKey,@UserKey,@TripFrom,@TripTo,@TripStartDate
						,@TripEndMonth,@TripEndYear, CONVERT(DECIMAL(10,2),(@OriginalPerPersonPrice - @CurrentPerPersonPrice))
						,CONVERT(DECIMAL(10,2),(@originalTotalPrice - @CurrentTotalPrice))
						,CONVERT(DECIMAL(10,2),(@CurrentPerPersonPrice - ((@ActualCarTax)/@NoOfDays)))
						,CONVERT(DECIMAL(10,2),@CurrentTotalPrice)
						,@CarCategoryName, @NewCarVendorKey, @FromCountryCode, @FromCountryName
						,@FromStateCode, @FromCityName, @ToCountryCode, @ToCountryName
						,@ToStateCode, @ToCityName, @TripEndDate
						,@OriginalPerPersonPrice, @OriginalTotalPrice
						,@NewCarVendorName,@CrowdId)
					END
					ELSE
					BEGIN
						--print convert(varchar,@originalTotalPrice)
						--print convert(varchar,@CurrentTotalPrice)
						
						DECLARE @PriceDiff INT = CONVERT(DECIMAL(10,2),(@originalTotalPrice - @CurrentTotalPrice))
						IF @PriceDiff > 0
						BEGIN
						SET @isDefaultVal = 0
						END
						
						
						UPDATE TripDetails SET
						tripFrom = @TripFrom
						,tripTo = @TripTo
						,tripStartDate = @TripStartDate
						,tripEndDate = @TripEndDate
						,tripEndMonth = @TripEndMonth
						,tripEndYear = @TripEndYear
						,latestDealCarSavingsPerPerson = CONVERT(DECIMAL(10,2),(@OriginalPerPersonPrice - @CurrentPerPersonPrice))
						,latestDealCarSavingsTotal = CONVERT(DECIMAL(10,2),(@originalTotalPrice - @CurrentTotalPrice))
						,latestDealCarPricePerPerson = CONVERT(DECIMAL(10,2),(@CurrentPerPersonPrice - ((@ActualCarTax)/@NoOfDays)))
						,latestDealCarPriceTotal = CONVERT(DECIMAL(10,2),@CurrentTotalPrice)
						,CarClass = @CarCategoryName
						,CarVendorCode = @NewCarVendorKey
						,fromCountryCode = @FromCountryCode
						,fromCountryName = @FromCountryName
						,fromStateCode = @FromStateCode
						,fromCityName = @FromCityName
						,toCountryCode = @ToCountryCode
						,toCountryName = @ToCountryName
						,toStateCode = @ToStateCode
						,toCityName = @ToCityName
						,originalPerPersonPriceCar = @OriginalPerPersonPrice
						,originalTotalPriceCar = @OriginalTotalPrice
						,LatestCarVendorName = @NewCarVendorName
						,lastUpdatedDate = GETDATE()
						WHERE tripKey = @TK
					END
					
					IF(@isDefaultVal = 1)
					BEGIN
						UPDATE TripDetails SET
						latestDealCarSavingsPerPerson = 0
						,latestDealCarSavingsTotal = 0
						,latestDealCarPricePerPerson = 0
						,latestDealCarPriceTotal = 0
						WHERE tripKey = @TK
						
					END
					
				 END TRY
				 BEGIN CATCH					
					SET @ErrorMessage = ERROR_MESSAGE();
					INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, ErrorMessage, Remarks, InitiatedFrom) 
					VALUES(@TK, @PkGroupId, 2, @ErrorMessage
					,'Error while inserting data in table TripDetails. stored procedure USP_GetTripSavedDealCarMinPrice', 'TMU')
				 END CATCH
				/*END: TMU DATA INSERTED IN TABLE TripDetails*/
				
		BREAK	   
		End	
		Delete @TblVendorDetails  
		Update @TblMinCurrentPrice Set IsUsed = 1 Where PkId = @PkId  
		SET  @LoopCount += 1  
   END   
   
		/*For Inserting Data In TripSavedLowestDeal*/
		BEGIN TRY
			Select Top 1 @TripSavedLowestDealResponseKey = ISNULL(carResponseDetailKey, '00000000-0000-0000-0000-000000000000') 
			From @TblCarResponseDetail 
			Where carResponseDetailKey <> @CarResponseDetailKey
			And carResponseDetailKey <> @OriginalCarResponseKey
			And carCategoryCode = @CarCategoryCode
			Order By totalPrice Asc
			
			If(@TripSavedLowestDealResponseKey = '00000000-0000-0000-0000-000000000000')
			Begin
				Select Top 1 @TripSavedLowestDealResponseKey = ISNULL(carResponseDetailKey, '00000000-0000-0000-0000-000000000000') 
				From @TblCarResponseDetail 
				Where carResponseDetailKey <> @CarResponseDetailKey
				And carResponseDetailKey <> @OriginalCarResponseKey
				Order By totalPrice Asc
			End
			
			If(@TripSavedLowestDealResponseKey = '00000000-0000-0000-0000-000000000000')
			Begin
				INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, Remarks, InitiatedFrom)
				Values (@TK, @PkGroupId, 2, 'No Lowest Car Deal Found', 'LowestDeal')	
			End
			Else
			Begin
				Insert Into TripSavedLowestDeal (tripKey,responseKey,componentType,responseDetailKey,creationDate,isAlternate)
				Values (@TK,@TripSavedLowestDealResponseKey,2,@TripSavedLowestDealResponseKey,GETDATE(),1)
				
				IF((Select COUNT(*) From TripCarResponse Where carResponseKey = @TripSavedLowestDealResponseKey) = 0)
				BEGIN
					INSERT INTO TripCarResponse(carResponseKey,tripKey,carVendorKey,supplierId,carCategoryCode,carLocationCode,carLocationCategoryCode
					,minRate,minRateTax,TotalChargeAmt,NoOfDays,SearchCarPrice,searchCarTax,actualCarPrice,actualCarTax,pickUpDate
					,dropOutDate,isExpenseAdded,contractCode)
					Select Top 1 @TripSavedLowestDealResponseKey,0,carVendorKey,supplierId,carCategoryCode,carLocationCode,carLocationCategoryCode
					,minRate,minRateTax,0,NoOfDays,(minRate*NoOfDays),minRateTax,(minRate*NoOfDays),minRateTax
					,@PickUpDate,@DropOutDate,0,FareCategory from @TblCarResponseDetail where carResponseDetailKey = @TripSavedLowestDealResponseKey
				END
			End
		END TRY
		BEGIN CATCH
			SET @ErrorMessage = ERROR_MESSAGE();
			INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, ErrorMessage, Remarks, InitiatedFrom) 
			VALUES(@TK, @PkGroupId, 2, @ErrorMessage
			,'Error while inserting data in table TripSavedLowestDeal. stored procedure USP_GetTripSavedDealCarMinPrice', 'LowestDeal')
		END CATCH
		/*END: For Inserting Data In TripSavedLowestDeal*/
   
   Delete From @TblMinCurrentPrice  
   Update @TblGroup set IsInserted = 1 where TblGroupKey = @TblGroupKey
   SET  @insertCount += 1  
     
  END
 
 Select Distinct CarResponseDetailKey From @TblCarResponseDetailKey
    
END
GO
