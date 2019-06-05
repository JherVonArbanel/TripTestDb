SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 29th June 2012
-- Description:	Gets 3 minimum fare
-- =============================================
--Exec USP_GetNightlyCarMinPrice 8248,1
CREATE PROCEDURE [dbo].[USP_GetNightlyCarMinPrice]
	-- Add the parameters for the stored procedure here
	@CarRequestKey int
	,@PkGroupId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Declare @TblCarResponse As Table ([carResponseKey] uniqueidentifier,[carRequestKey] int,[carVendorKey] varchar(50)
	,[supplierId] varchar(50),[carCategoryCode] varchar(50),[carLocationCode] varchar(50),[carLocationCategoryCode] varchar(50)
	,[minRate] float,[minRateTax] float,[DailyRate] float,[TotalChargeAmt] float,[NoOfDays] int,[RateQualifier] varchar(25)
	,[ReferenceType] varchar(10),[ReferenceDateTime] varchar(20),[ReferenceId] varchar(50),[MileageAllowance] varchar(10)
	,[RatePlan] varchar(10),IsUsed Bit Default(0))
	
	Declare @TblCarResponseDetail As Table ([carResponseDetailKey] uniqueidentifier,[carResponseKey] uniqueidentifier
	,[carVendorKey] varchar(50),[supplierId] varchar(50),[carCategoryCode] varchar(50),[carLocationCode] varchar(50)
	,[carLocationCategoryCode] varchar(50),[minRate] float,[minRateTax] float,[totalPrice] float,[NoOfDays] int,[RateQualifier] varchar(25)
	,[ReferenceType] varchar(10),[ReferenceDateTime] varchar(20),[ReferenceId] varchar(50),[MileageAllowance] varchar(10)
	,[RatePlan] varchar(10),[GuaranteeCode] varchar(20),[SellGuaranteeReq] bit,FareCategory varchar(30))
	
	Declare @TblMinCurrentPrice as Table(PkId int identity(1,1),CurrentMinimumPrice float,IsUsed Bit Default(0))
	
	Declare @TblGroup as Table(TripKey int,TripSavedKey UniqueIdentifier,ActualCarPrice Float,ActualCarTax Float,IsInserted Bit Default(0))
	
	Insert Into @TblCarResponse(carResponseKey,carRequestKey,carVendorKey,supplierId,carCategoryCode,carLocationCode
	,carLocationCategoryCode,minRate,minRateTax,DailyRate,TotalChargeAmt,NoOfDays,RateQualifier,ReferenceType
	,ReferenceDateTime,ReferenceId,MileageAllowance,RatePlan)
	Select carResponseKey,carRequestKey,carVendorKey,supplierId,carCategoryCode,carLocationCode
	,carLocationCategoryCode,minRate,minRateTax,DailyRate,TotalChargeAmt,NoOfDays,RateQualifier,ReferenceType
	,ReferenceDateTime,ReferenceId,MileageAllowance,RatePlan
	From CarResponse Where carRequestKey = @CarRequestKey
	
	Insert Into @TblCarResponseDetail(carResponseDetailKey,carResponseKey,carVendorKey,supplierId,carCategoryCode
	,carLocationCode,carLocationCategoryCode,minRate,minRateTax,totalPrice,NoOfDays,RateQualifier,ReferenceType,ReferenceDateTime
	,ReferenceId,MileageAllowance,RatePlan,GuaranteeCode,SellGuaranteeReq,FareCategory)
	Select carResponseDetailKey,carResponseKey,carVendorKey,supplierId,carCategoryCode
	,carLocationCode,carLocationCategoryCode,minRate,minRateTax,((minRate*NoOfDays) + minRateTax),NoOfDays,RateQualifier,ReferenceType,ReferenceDateTime
	,ReferenceId,MileageAllowance,RatePlan,GuaranteeCode,SellGuaranteeReq,contractCode
	From CarResponseDetail Where carResponseKey in (Select carResponseKey from @TblCarResponse)
		
	Insert into @TblGroup (TripKey,TripSavedKey,ActualCarPrice,ActualCarTax) 
	Select TripKey,TripSavedKey,ActualCarPrice,ActualCarTax From CarRequestNightly where PkGroupId = @PkGroupId
	
	Declare @insertCount int
			,@countToExecute int
			,@TK int
			,@BookedPrice Float
			,@CurrentMinimumPrice Float
			,@PkId int
			,@MinCurrentPriceCount int
			,@LoopCount int
			,@TripSavedKey UniqueIdentifier
			
	Set @insertCount = 1
	Set @countToExecute = (Select COUNT(*) from @TblGroup)
		
	WHILE (@insertCount <= @countToExecute)
		BEGIN
			Set @TripSavedKey = (Select Top 1 TripSavedKey from @TblGroup where IsInserted = 0)
			Set @LoopCount = 1
			Select @TK = TripKey, @BookedPrice = (actualCarPrice + actualCarTax) from @TblGroup where TripSavedKey = @TripSavedKey
			
			Insert Into @TblMinCurrentPrice (CurrentMinimumPrice)	
			Select Distinct TOP 3  ((minRate*NoOfDays) + minRateTax) from @TblCarResponseDetail
			Order By ((minRate*NoOfDays) + minRateTax) Asc
			
			Set @MinCurrentPriceCount = (Select COUNT(*) from @TblMinCurrentPrice)
			
			WHILE (@LoopCount <= @MinCurrentPriceCount)
			BEGIN
				Set @PkId = (Select Top 1 PkId from @TblMinCurrentPrice where IsUsed = 0)
				Set @CurrentMinimumPrice = (Select CurrentMinimumPrice From @TblMinCurrentPrice Where PkId = @PkId)
				
				Insert Into NightlyDealProcess (tripKey,responseKey,componentType,currentPrice,originalPrice,fareCategory,responseDetailKey)
				Select @TK,CarResponseKey,'Car',Convert(Decimal(10,2),@CurrentMinimumPrice),@BookedPrice
				,Case When FareCategory <> '' Then 'SnapCode' Else 'Publish' End,carResponseDetailKey
				From @TblCarResponseDetail Where totalPrice = @CurrentMinimumPrice
				
				Update @TblMinCurrentPrice Set IsUsed = 1 Where PkId = @PkId
				SET  @LoopCount += 1
			END
			
			Delete From @TblMinCurrentPrice
			Update @TblGroup set IsInserted = 1 where TripSavedKey = @TripSavedKey
			SET  @insertCount += 1
			
		END
END
GO
