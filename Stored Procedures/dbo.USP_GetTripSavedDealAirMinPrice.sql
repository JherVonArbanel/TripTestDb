SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- =============================================    
-- Author:  Jayant Guru    
-- Create date: 24th May 2012    
-- Description: Compares the lowest price for the current date with the booked date and insert the data in table    
-- =============================================    
--Exec [USP_GetTripSavedDealAirMinPrice] 103874,5,'US,AA,UA,DL'
    
     
CREATE PROCEDURE [dbo].[USP_GetTripSavedDealAirMinPrice]    
 -- Add the parameters for the stored procedure here    
 @AirSubRequestKey INT    
 ,@PkGroupId INT
 ,@ExcludedAirlines Varchar(100)    
     
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;        
     
     Declare @isDefaultVal int = 0 --for TFS #19445
	 Declare @TblGroup as table    
	 (     
	  TblGroupKey int identity(1,1),PkId int, PkGroupId int, TripRequestKey int, TripKey int, AirRequestKey int,AirRequestTypeKey int,BookedPrice Float,PassengerEmailID varchar(100)    
	  ,AirResponseKey1 Varchar(100),CurrentPrice1 Float,AirResponseKey2 Varchar(100),CurrentPrice2 Float,AirResponseKey3 Varchar(100),CurrentPrice3 Float    
	  ,IsInserted smallint Default(0),TripSavedKey UniqueIdentifier,DepartureDateTimeLeg1 Datetime    
	 )    
	 Declare @TblAirResponse As Table     
	 (    
	  airResponseKey uniqueidentifier,airSubRequestKey int,airPriceBase float,airPriceTax float,airPriceBaseSenior float    
	  ,airPriceTaxSenior float,airPriceBaseChildren float,airPriceTaxChildren float,airPriceBaseInfant float,airPriceTaxInfant float    
	  ,airPriceBaseDisplay float,airPriceTaxDisplay float,airPriceBaseTotal float,airPriceTaxTotal float    
	  ,airPriceBaseYouth float,airPriceTaxYouth float,fareCategory varchar(30) ,total float,DepartureDateTimeLeg1 Datetime
	 )    
	     
	 Declare @TblMinCurrentPrice as Table(PkId int identity(1,1),CurrentMinimumPrice float,AirResponseKey Uniqueidentifier,IsUsed Bit Default(0),SegmentFlight Varchar(150))
	 Declare @TblMinThreshHoldPriceHourly as Table(PkId int identity(1,1),CurrentMinimumPrice float,AirResponseKey Uniqueidentifier,IsUsed Bit Default(0),SegmentFlight Varchar(150))
	 Declare @TblMinThreshHoldPriceDaily as Table(PkId int identity(1,1),CurrentMinimumPrice float,AirResponseKey Uniqueidentifier,IsUsed Bit Default(0),SegmentFlight Varchar(150))
	 Declare @TblMinVariation as Table(PkId int identity(1,1),CurrentMinimumPrice float,AirResponseKey Uniqueidentifier,IsUsed Bit Default(0),SegmentFlight Varchar(150))
	 Declare @TblVendorDetails AS Table (VendorDetailsId int identity(1,1),VendorDetails Varchar(200),CreationDate Datetime,IsUsed bit Default(0))
	 Declare @TblAirline AS Table (Airlines Varchar(200))
	 Declare @AirReprice As Table (Category Varchar(15), AirResponseKey Uniqueidentifier, TripAirResponseKey Int, TripAirPriceKey Int)
	 
          
	 Insert Into @TblAirResponse(airResponseKey,airSubRequestKey,airPriceBaseDisplay,airPriceTaxDisplay,fareCategory,total,airPriceBaseTotal,airPriceTaxTotal)    
	 Select airResponseKey,airSubRequestKey,airPriceBaseDisplay,airPriceTaxDisplay,contractCode,(airPriceBaseDisplay+airPriceTaxDisplay) as total
	 ,airPriceBaseTotal,airPriceTaxTotal
	 From AirResponse With (NoLock) Where airSubRequestKey = @AirSubRequestKey order by total asc
	 
	 /*Excluding - Please do not book NK - Spirit Airlines & WN - Southwest Airlines*/
	 Delete From @TblAirResponse Where airResponseKey IN (	 
	 Select Distinct airResponseKey From AirSegments With (NoLock) Where airResponseKey IN (Select airResponseKey From @TblAirResponse) 
	 And airSegmentOperatingAirlineCode IN (SELECT * FROM vault.dbo.ufn_CSVToTable (@ExcludedAirlines))
	 OR airSegmentMarketingAirlineCode IN (SELECT * FROM vault.dbo.ufn_CSVToTable (@ExcludedAirlines)))
	 	 	 
     UPDATE AR
     SET AR.DepartureDateTimeLeg1 = (SELECT MIN(airSegmentDepartureDate)
     FROM AirSegments AS SG  With (NoLock)
     WHERE SG.airResponseKey = AR.airResponseKey)
	 FROM @TblAirResponse AS AR
     
	 Insert into @TblGroup(PkId,PkGroupId,TripRequestKey,TripKey,AirRequestKey,AirRequestTypeKey,TripSavedKey,DepartureDateTimeLeg1)    
	 Select PkId,PkGroupId,TripRequestKey,TripKey,AirRequestKey,AirRequestTypeKey,TripSavedKey,DepartureDateTimeLeg1 from AirRequestTripSavedDeal With (NoLock) where PkGroupId = @PkGroupId    
     
    Declare @insertCount int    
    ,@countToExecute int    
    ,@TK int    
    ,@TripSavedKey UniqueIdentifier    
    ,@BookedPrice Float    
    ,@CurrentMinimumPrice Float    
    ,@PkId int    
    ,@MinCurrentPriceCount int    
    ,@LoopCount int    
    ,@ResponseKeyCount int
    ,@AirResponseKey uniqueidentifier
    ,@StoreAirResponseKey uniqueidentifier
    ,@ContractCode Varchar(50)
    ,@IsRefundable Bit
    ,@ValidatingCarrier Varchar(3)
    ,@TripAirPriceKey Int
    ,@Category Varchar(15)
    ,@TripAirResponseKey int
    ,@OriginalAirResponseKey uniqueidentifier
    ,@OriginalMarketingAirline Varchar(150)
    ,@NewMarketingAirline Varchar(150)
    ,@StoreNewMarketingAirline Varchar(150)
    ,@IntervalNewMarketingAirline Varchar(150)
    ,@MinimumPrice Float
    ,@VendorDetailsCount Int
    ,@IntervalDays Int
    ,@StoreIntervalDays Int
    ,@SearchAirPriceBreakupKey Int
    ,@originalTotalPrice Float
    ,@TblGroupKey Int
    ,@SearchAirTax Float
    ,@SearchAirPrice Float
    ,@DepartureDateTimeLeg1 DateTime
    ,@ThreshHoldPriceCount Int
    ,@ComparisonCount Int
    ,@DistinctThreshHoldPriceCount Int
    ,@Remarks Varchar(3000) = ''
    ,@CheckCondition Bit = 0
    ,@RepetitionInterval Float
    ,@ThresholdPriceHourly Float
    ,@ThresholdPricePerDay Float
    ,@UserKey INT
    ,@TripFrom VARCHAR(3)
    ,@TripTo VARCHAR(3)
    ,@TripStartDate DATETIME
    ,@TripEndDate DATETIME
    ,@TripEndMonth INT
    ,@TripEndYear INT
    ,@CurrentPerPersonPrice FLOAT
    ,@CurrentTotalPrice FLOAT
    ,@AirRequestType VARCHAR(20)
    ,@AirSegmentCabin VARCHAR(20)
    ,@FromCountryCode VARCHAR(2)
	,@FromCountryName VARCHAR(128)
	,@FromStateCode VARCHAR(2)
	,@FromCityName VARCHAR(64)
	,@ToCountryCode VARCHAR(2)
	,@ToCountryName VARCHAR(128)
	,@ToStateCode VARCHAR(2)
	,@ToCityName VARCHAR(64)
	,@TripRequestKey INT
	,@TMUMarketingAirlineCode VARCHAR(30)
	,@TMUMarketingAirlineName VARCHAR(64)
	,@isMultipleAirline BIT = 0
    ,@singleAirlineCode VARCHAR(2)
    ,@AirRequestTypeKey TINYINT
    ,@NoOfAirStops TINYINT
    ,@NoOfLeg1Stops TINYINT
    ,@NoOfLeg2Stops TINYINT
    
  Select @ThresholdPriceHourly = ThresholdPriceHourly, @ThresholdPricePerDay = ThresholdPricePerDay, @RepetitionInterval = RepetitionInterval 
  From DealsThresholdSettings With (NoLock) Where ComponentTypeKey = 1
  
  Set @insertCount = 1    
  Set @countToExecute = (Select COUNT(*) from @TblGroup)    
  
  /*@countToExecute -> Total number of trips/tripKey in a particular group having same trip*/
  WHILE (@insertCount <= @countToExecute)    
   BEGIN    
    
    SET @isDefaultVal = 0
    Set @StoreNewMarketingAirline = ''   
    Set @NewMarketingAirline = '' 
    Set @StoreIntervalDays = 0
    
    Delete From @TblMinThreshHoldPriceHourly
    Delete From @TblMinThreshHoldPriceDaily
    Delete From @TblMinVariation
    
    Select Top 1 @TK = TripKey,@TblGroupKey = TblGroupKey,@TripSavedKey = TripSavedKey
    ,@DepartureDateTimeLeg1 = DepartureDateTimeLeg1 from @TblGroup where IsInserted = 0
    
    /*The below code is commented as we are now picking Original Total Price From TripDetails Table*/
  --Select @SearchAirPrice =(( isnull(tripAdultBase,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildBase,0)*isnull(t.tripChildCount,0) ) 
  --+ ( isnull(tripSeniorBase,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthBase,0)*isnull(t.tripYouthCount,0) ) 
  --+ (isnull(tripInfantBase,0)*isnull(t.tripInfantCount,0) )  )
  --,@SearchAirTax =(( isnull(tripAdulttax,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildtax,0)*isnull(t.tripChildCount,0) ) + 
  --( isnull(tripSeniortax,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthtax,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfanttax,0)*isnull(t.tripInfantCount,0) )  )
  --from TripAirPrices TAP  With (NoLock)
  --inner join TripAirResponse TR  With (NoLock) on TAP.tripAirPriceKey = TR.searchAirPriceBreakupKey 
  --inner join Trip T  With (NoLock) on TR.tripGUIDKey = @TripSavedKey  where t.tripKey = @TK  and T.tripStatusKey <> 17 
    
  --SET @originalTotalPrice = (select convert(decimal (18,2), (@searchAirPrice + @searchAirTax)))
	/*END: The below code is commented as we are now picking Original Total Price From TripDetails Table*/
    
    Select @SearchAirPriceBreakupKey = searchAirPriceBreakupKey,@OriginalAirResponseKey = airResponseKey
    From TripAirResponse  With (NoLock) Where tripGUIDKey = @TripSavedKey
    
    /*Select @SearchAirPriceBreakupKey = searchAirPriceBreakupKey,@OriginalAirResponseKey = airResponseKey
    ,@originalTotalPrice = (searchAirPrice + searchAirPrice) 
    From TripAirResponse Where tripGUIDKey = @TripSavedKey*/
    
    /*The below code is commented as we are now picking Original Per Person Price From TripDetails Table*/
    /*Original booked price(From Adult and Senior one has to be mandatory)*/
  --If((Select ISNULL(tripAdultBase,0) From TripAirPrices With (NoLock) Where tripAirPriceKey = @SearchAirPriceBreakupKey) <> 0)
  --Begin
		--Set @BookedPrice = (Select (tripAdultBase + tripAdultTax) from TripAirPrices  With (NoLock) Where tripAirPriceKey = @SearchAirPriceBreakupKey)
  --End
  --Else
  --Begin
		--Set @BookedPrice = (Select (tripSeniorBase + tripSeniorTax) from TripAirPrices  With (NoLock) Where tripAirPriceKey = @SearchAirPriceBreakupKey)
  --End
	/*END: The below code is commented as we are now picking Original Per Person Price From TripDetails Table*/
    
    Select @BookedPrice = originalPerPersonPriceAir 
    ,@originalTotalPrice = originalTotalPriceAir
	From TripDetails Where tripKey = @TK
    
    /*@OriginalMarketingAirline -> Flights of the original trip selected while watch trip. Needed for Alternative airline comparision*/
    Select @OriginalMarketingAirline = STUFF((SELECT  ',' + airSegmentMarketingAirlineCode 
    From TripAirSegments  With (NoLock) Where airResponseKey = @OriginalAirResponseKey  Order By airSegmentDepartureDate Asc FOR XML PATH ('')),1,1,'')
    
    /*Checking for +/-2 hours*/
    /*For +2 hours*/
    Insert Into @TblMinThreshHoldPriceHourly(CurrentMinimumPrice,AirResponseKey)
    Select (airPriceBaseDisplay + airPriceTaxDisplay) As MinPrice,airResponseKey from @TblAirResponse
    Where DATEDIFF(HOUR, @DepartureDateTimeLeg1, DepartureDateTimeLeg1) between 0 And 2
    And (@BookedPrice - (airPriceBaseDisplay + airPriceTaxDisplay) 
    >= (@ThresholdPriceHourly))
    /*For -2 hours*/    
    Insert Into @TblMinThreshHoldPriceHourly(CurrentMinimumPrice,AirResponseKey)
    Select (airPriceBaseDisplay + airPriceTaxDisplay) As MinPrice,airResponseKey from @TblAirResponse
    Where DATEDIFF(HOUR, @DepartureDateTimeLeg1, DepartureDateTimeLeg1) between -2 And 0
    And (@BookedPrice - (airPriceBaseDisplay + airPriceTaxDisplay) 
    >= (@ThresholdPriceHourly))
    /*End Checking for +/-2 hours*/
    
    Set @ThreshHoldPriceCount = (Select COUNT(*) From @TblMinThreshHoldPriceHourly)
    
    If(@ThreshHoldPriceCount > 0)
    Begin
		/*Updating segment flights for Variation comparison*/
		UPDATE PH SET PH.SegmentFlight = (
		STUFF((SELECT  ',' + airSegmentMarketingAirlineCode 
		From AirSegments SG  With (NoLock) Where SG.airResponseKey = PH.AirResponseKey Order By airSegmentDepartureDate Asc FOR XML PATH ('')),1,1,'')
		) FROM @TblMinThreshHoldPriceHourly AS PH
		/*End Updating segment flights for Variation comparison*/
		
		Set @ComparisonCount = (Select COUNT(*) From (Select Distinct vendorDetails From TripSavedDeals  With (NoLock) Where componentType = 1 
			And (creationDate > (DATEADD(d,@RepetitionInterval,(Select MAX(creationDate) From TripSavedDeals With (NoLock) Where componentType = 1)))) And vendorDetails <> ''
			And tripKey = @TK And vendorDetails in (Select Distinct SegmentFlight From @TblMinThreshHoldPriceHourly)) AS TblCount)
			
		Set @DistinctThreshHoldPriceCount = (Select COUNT(*) From (Select Distinct SegmentFlight From @TblMinThreshHoldPriceHourly) As TblSeg)
		
		/*Comparing the variation within +/-2 hours*/
		If(@ComparisonCount < @DistinctThreshHoldPriceCount)
		Begin
			Insert Into @TblMinCurrentPrice (CurrentMinimumPrice,AirResponseKey,SegmentFlight)
			Select CurrentMinimumPrice,AirResponseKey,SegmentFlight From @TblMinThreshHoldPriceHourly
			Set @Remarks = '+/-2 hrs pass. Variation available to insert. The price difference is >= 15$. '
		End
		Else
		Begin
			Insert Into @TblMinVariation(CurrentMinimumPrice,AirResponseKey,SegmentFlight)
			Select CurrentMinimumPrice,AirResponseKey,SegmentFlight From @TblMinThreshHoldPriceHourly
			
			Insert Into @TblAirline(Airlines)
			Select Distinct vendorDetails From TripSavedDeals Where componentType = 1 
			And (creationDate > (DATEADD(d,@RepetitionInterval,(Select MAX(creationDate) From TripSavedDeals With (NoLock) Where componentType = 1)))) And vendorDetails <> ''
			And tripKey = @TK
			
			Set @CheckCondition = 1
			Set @Remarks = '+/-2 hrs pass. Variation NOT available to insert. '
		End
    End
    
    /*When +/-2 hour condition pass but variation not available to insert. 
    Condition greater than +/-2 hours*/
    If(@CheckCondition = 1)
    Begin
		Set @CheckCondition = 0
		Insert Into @TblMinThreshHoldPriceDaily(CurrentMinimumPrice,AirResponseKey)
		Select (airPriceBaseDisplay + airPriceTaxDisplay),airResponseKey from @TblAirResponse
		Where (@BookedPrice - (airPriceBaseDisplay + airPriceTaxDisplay) 
		>= (@ThresholdPricePerDay))
		
		Set @ThreshHoldPriceCount = (Select COUNT(*) From @TblMinThreshHoldPriceDaily)
		
		/*Checking if flight available for greater than +/-2 hours*/
		If(@ThreshHoldPriceCount > 0)
		Begin
			/*Updating segment flights for Variation comparison*/
			UPDATE PH SET PH.SegmentFlight = (
			STUFF((SELECT  ',' + airSegmentMarketingAirlineCode 
			From AirSegments SG With (NoLock) Where SG.airResponseKey = PH.AirResponseKey Order By airSegmentDepartureDate Asc FOR XML PATH ('')),1,1,'')
			) FROM @TblMinThreshHoldPriceDaily AS PH
			
			Set @ComparisonCount = (Select COUNT(*) From (Select Distinct vendorDetails From TripSavedDeals With (NoLock) Where componentType = 1 
				And (creationDate > (DATEADD(d,@RepetitionInterval,(Select MAX(creationDate) From TripSavedDeals With (NoLock) Where componentType = 1)))) And vendorDetails <> ''
				And tripKey = @TK And vendorDetails in (Select SegmentFlight From @TblMinThreshHoldPriceDaily)) AS TblCount)
				
			Set @DistinctThreshHoldPriceCount = (Select COUNT(*) From (Select Distinct SegmentFlight From @TblMinThreshHoldPriceDaily) As TblSeg)
			
			/*Comparing the variation greater than +/-2 hours*/
			If(@ComparisonCount < @DistinctThreshHoldPriceCount)
			Begin
				/*The below code is commented because it was inserting values present within +/-2 hours having a price difference of 45$*/
				--Insert Into @TblMinCurrentPrice (CurrentMinimumPrice,AirResponseKey,SegmentFlight)
				--Select CurrentMinimumPrice,AirResponseKey,SegmentFlight From @TblMinThreshHoldPriceDaily
				
				Insert Into @TblMinCurrentPrice (CurrentMinimumPrice,AirResponseKey,SegmentFlight)
				Select CurrentMinimumPrice,AirResponseKey,SegmentFlight From @TblMinThreshHoldPriceDaily
				Where SegmentFlight Not In (Select Airlines from @TblAirline)
				
				Set @Remarks = @Remarks + 'Executing for condition Greater than +/-2 hrs. Variation available to insert. The price difference is >= 45$.'
			End
			Else
			Begin
				Insert Into @TblMinVariation(CurrentMinimumPrice,AirResponseKey,SegmentFlight)
				Select CurrentMinimumPrice,AirResponseKey,SegmentFlight From @TblMinThreshHoldPriceDaily
				Set @Remarks = @Remarks + 'Executing for condition Greater than +/-2 hrs. Variation NOT available to insert. '
			End
		End
		Else
		Begin
			Set @Remarks = @Remarks + 'Greater than +/-2 hrs fail. '
		End
    End
    
    /*If variation not available for +/-2 hours and greater than +/-2 hours*/
    If((Select COUNT(*) From @TblMinCurrentPrice) < 1)
    Begin
		If((Select COUNT(*) From @TblMinVariation) > 0)
		Begin
			Insert Into @TblMinCurrentPrice (CurrentMinimumPrice,AirResponseKey,SegmentFlight)
			Select CurrentMinimumPrice,AirResponseKey,SegmentFlight From @TblMinVariation
			Set @Remarks = @Remarks + 'Checking if any values available for +/-2 hrs AND greater than +/-2 hrs. Data inserted depending on history of repetition. The price difference cannot be less than 15$. '
			SET @isDefaultVal = 0
		End
		Else
		Begin
			/*@MinimumPrice -> Least minimum price of current search*/
			Set @MinimumPrice = (Select Distinct TOP 1 (airPriceBaseDisplay + airPriceTaxDisplay) As MinPrice from @TblAirResponse    
			Order By MinPrice Asc)
			
			/*Inserts all the data having same @MinimumPrice*/
			Insert Into @TblMinCurrentPrice (CurrentMinimumPrice,AirResponseKey)    
			Select (airPriceBaseDisplay + airPriceTaxDisplay) As MinPrice,airResponseKey from @TblAirResponse    
			Where (airPriceBaseDisplay + airPriceTaxDisplay) = @MinimumPrice
			
			Set @Remarks = 'All conditions fail. Executing default condition. The price difference can be less than 15$ OR Negative'
			SET @isDefaultVal = 1
		End
    End    
    
    /*@MinCurrentPriceCount -> required for looping through all the minimum price for a trip*/
    Set @MinCurrentPriceCount = (Select COUNT(*) from @TblMinCurrentPrice)    
	
	Set @LoopCount = 1
	
	/*Executing for all the selected minimum price*/
    WHILE (@LoopCount <= @MinCurrentPriceCount)    
    BEGIN    
		 /*IsUsed flag of @TblMinCurrentPrice table is updated as 1 at end to avoid repetation. 
		 @TblMinCurrentPrice table is deleted after executing one tripKey*/
		 Set @PkId = (Select Top 1 PkId from @TblMinCurrentPrice where IsUsed = 0)
		 Select @CurrentMinimumPrice = CurrentMinimumPrice,@AirResponseKey = AirResponseKey From @TblMinCurrentPrice Where PkId = @PkId
		 
		 /*@NewMarketingAirline -> Need to compare with the original marketing airline for isAlternative flag of TripSavedDeals*/
		 Select @NewMarketingAirline = STUFF((SELECT  ',' + airSegmentMarketingAirlineCode 
		 From AirSegments With (NoLock) Where airResponseKey = @AirResponseKey Order By airSegmentDepartureDate Asc FOR XML PATH ('')),1,1,'')
		 
		 /*@StoreNewMarketingAirline is initially stored as null and compared with @NewMarketingAirline.
		 This is required to avoid execution of same new marketing airline*/
		 If(@StoreNewMarketingAirline <> @NewMarketingAirline)
		 Begin
			Set @StoreNewMarketingAirline = @NewMarketingAirline
			Insert Into @TblVendorDetails (VendorDetails,CreationDate)
			Select Distinct vendorDetails,creationDate From TripSavedDeals With (NoLock) Where componentType = 1 
			And (creationDate > (DATEADD(d,@RepetitionInterval,(Select MAX(creationDate) From TripSavedDeals With (NoLock) Where componentType = 1)))) And vendorDetails <> ''
			And tripKey = @TK
			Set @VendorDetailsCount = (Select COUNT(*) From @TblVendorDetails Where VendorDetails = @StoreNewMarketingAirline)
		 End
		 
		 /*If @VendorDetailsCount > 0 then the marketing airline is already present in TripSavedDeals. It is required for interval of repetation.*/
		 If(@VendorDetailsCount > 0)
		 Begin
			/*@IntervalDays is the difference between the @StoreNewMarketingAirline and current date. 
			The @IntervalDays is always stored in variable "@StoreIntervalDays" whenever it is greater then previous @IntervalDays*/
			Set @IntervalDays = (Select Top 1 DATEDIFF(day, CONVERT(VARCHAR(10), CreationDate, 120), CONVERT(VARCHAR(10), GETDATE(), 120)) 
			From @TblVendorDetails Where VendorDetails = @StoreNewMarketingAirline Order by CreationDate Desc)
			
			If(@IntervalDays > ISNULL(@StoreIntervalDays,0))
			Begin
				Set @StoreIntervalDays = @IntervalDays
				Set @StoreAirResponseKey = @AirResponseKey
				Set @IntervalNewMarketingAirline = @NewMarketingAirline
			End
		 End
	 
	 /*if any of the condition above doesnt match then @AirResponseKey is assigned the value of @StoreAirResponseKey
	 @StoreAirResponseKey is the key whose @IntervalDays is maximum*/
	 If(@LoopCount = @MinCurrentPriceCount And ISNULL(@StoreIntervalDays,0) <> 0)
	 Begin
		Set @AirResponseKey = @StoreAirResponseKey
		Set @NewMarketingAirline = @IntervalNewMarketingAirline
	 End
	 
	 /*Executing To insert data in TripSavedDeals*/
     If(@VendorDetailsCount = 0 OR (@LoopCount = @MinCurrentPriceCount))
     Begin
		 Insert Into TripSavedDeals (tripKey,responseKey,componentType,currentPerPersonPrice,originalPerPersonPrice
		 ,fareCategory,isAlternate
		 ,vendorDetails,currentTotalPrice,originalTotalPrice,Remarks)
		 Select @TK,airResponseKey,1,Convert(Decimal(10,2),(airPriceBaseDisplay + airPriceTaxDisplay)),@BookedPrice    
		 ,Case When FareCategory <> '' Then 'SnapCode' Else 'Publish' End
		 ,Case When(@OriginalMarketingAirline = @NewMarketingAirline) Then 0 Else 1 End
		 ,@NewMarketingAirline,(airPriceBaseTotal + airPriceTaxTotal),@originalTotalPrice,(@Remarks + ' ==> ' + CONVERT(Varchar,@AirSubRequestKey) + ', ' + CONVERT(varchar,@PkGroupId))
		 From @TblAirResponse Where airResponseKey = @AirResponseKey
		 
		 /*Update AirRequestTripSavedDeal To keep track if a particular trip id was successful*/
		 Update AirRequestTripSavedDeal Set IsSuccess = 1 Where TripKey = @TK
		 	     
	     /*Dont delete it will be required for repricing*/
		 --Select @Category = FareCategory From @TblAirResponse Where airResponseKey = @AirResponseKey
		 --If(@Category = '') Begin Set @Category = 'PUBLISH' End Else Begin Set @Category = 'SNAPCODE' End*/
	     
		 SET @ResponseKeyCount = (SELECT COUNT(*) FROM TripAirResponse With (NoLock) WHERE airResponseKey = @AirResponseKey)
		 		/*Inserting data in Trip tables*/
		 		IF(@ResponseKeyCount < 1)
				BEGIN
				
					DECLARE @TripAirLegsTmp AS TABLE(AirResponseKey VARCHAR(100),AirLegNumber INT,tripKey INT, GdsSourceKey INT
					,ContractCode VARCHAR(50),IsRefundable BIT,ValidatingCarrier VARCHAR(3))
					
					DECLARE @TripAirSegmentsTmp AS TABLE (AirSegmentKey VARCHAR(100),AirResponseKey VARCHAR(100),AirLegNumber INT
					,AirSegmentMarketingAirlineCode VARCHAR(2),AirSegmentOperatingAirlineCode VARCHAR(2),AirSegmentFlightNumber INT
					,AirSegmentDuration TIME,AirSegmentEquipment NVARCHAR(100),AirSegmentMiles INT,AirSegmentDepartureDate DATETIME
					,AirSegmentArrivalDate DATETIME,airSegmentDepartureAirport VARCHAR(50),AirSegmentArrivalAirport VARCHAR(50)
					,AirSegmentResBookDesigCode VARCHAR(3),AirSegmentDepartureOffset FLOAT,AirSegmentArrivalOffset FLOAT,AirSegmentSeatRemaining INT
					,AirSegmentMarriageGrp CHAR(10),AirFareBasisCode VARCHAR(50),AirFareReferenceKey VARCHAR(400)
					,AirSegmentCabin VARCHAR(20),TripAirLegsKey INT,airSegmentOperatingAirlineCompanyShortName VARCHAR(100),segmentOrder INT)
					
					Insert Into TripAirprices(tripAdultBase,tripAdultTax,tripSeniorBase,tripSeniorTax,tripYouthBase
					,tripYouthTax,tripChildBase,tripChildTax,tripInfantBase,tripInfantTax,creationDate)
					Select airPriceBaseDisplay,airPriceTaxDisplay,airPriceBaseSenior,airPriceTaxSenior,airPriceBaseYouth,airPriceTaxYouth
					,airPriceBaseChildren,airPriceTaxChildren,airPriceBaseInfant,airPriceTaxInfant,GETDATE() 
					From AirResponse With (NoLock) Where airResponseKey = @AirResponseKey Select @TripAirPriceKey = SCOPE_IDENTITY()
										
					INSERT INTO TripAirResponse(airResponseKey,tripKey,searchAirPrice,searchAirTax,ValidatingCarrier,searchAirPriceBreakupKey)
					SELECT airResponseKey,0,airPriceBaseTotal,airPriceTaxTotal,ValidatingCarrier,@TripAirPriceKey FROM AirResponse With (NoLock) 
					Where airResponseKey = @AirResponseKey Select @TripAirResponseKey = SCOPE_IDENTITY()
					
					/*For repricing*/
					Insert Into @AirReprice(AirResponseKey,TripAirResponseKey,Category,TripAirPriceKey)
					Select airResponseKey,@TripAirResponseKey,FareCategory,@TripAirPriceKey From @TblAirResponse Where airResponseKey = @AirResponseKey
										
					INSERT INTO @TripAirLegsTmp(AirResponseKey,AirLegNumber,tripKey)
					SELECT distinct airResponseKey,airLegNumber,0 FROM AirSegments With (NoLock) 
					Where airResponseKey = @AirResponseKey
					
					Select @ValidatingCarrier = ValidatingCarrier,@ContractCode = contractCode,@IsRefundable = refundable 
					From AirResponse With (NoLock) Where airResponseKey = @AirResponseKey
									
					UPDATE @TripAirLegsTmp SET GdsSourceKey = (SELECT GdsSourceKey FROM AirResponse With (NoLock) WHERE AirResponseKey = @AirResponseKey)
														
					INSERT INTO TripAirLegs(airResponseKey,airLegNumber,tripKey,gdsSourceKey,ValidatingCarrier,contractCode,isRefundable)
					SELECT distinct airResponseKey,airLegNumber,0,GdsSourceKey,@ValidatingCarrier,@ContractCode,@IsRefundable 
					FROM @TripAirLegsTmp WHERE airResponseKey = @AirResponseKey
					
					INSERT INTO @TripAirSegmentsTmp (airSegmentKey,airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode
					,airSegmentFlightNumber,airSegmentDuration,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport
					,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp
					,airFareBasisCode,airFareReferenceKey,airsegmentcabin,airSegmentOperatingAirlineCompanyShortName,segmentOrder)
					SELECT airSegmentKey,airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode
					,airSegmentFlightNumber,airSegmentDuration,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport
					,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp
					,airFareBasisCode,airFareReferenceKey,airsegmentcabin,airSegmentOperatingAirlineCompanyShortName,segmentOrder FROM AirSegments With (NoLock) 
					WHERE airResponseKey = @AirResponseKey
					ORDER BY airLegNumber, segmentOrder
								
					UPDATE TS SET TS.tripAirLegsKey = TL.tripAirLegsKey
					FROM  @TripAirSegmentsTmp TS inner join TripAirLegs TL ON TS.airResponseKey = TL.airResponseKey
					and TL.airLegNumber = TS.airLegNumber
					
					INSERT INTO TripAirSegments (airSegmentKey,airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode
					,airSegmentFlightNumber,airSegmentDuration,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport
					,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp
					,airFareBasisCode,airFareReferenceKey,airsegmentcabin,tripAirLegsKey)
					SELECT airSegmentKey,airResponseKey,airLegNumber,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode
					,airSegmentFlightNumber,airSegmentDuration,airSegmentEquipment,airSegmentMiles,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport
					,airSegmentArrivalAirport,airSegmentResBookDesigCode,airSegmentDepartureOffset,airSegmentArrivalOffset,airSegmentSeatRemaining,airSegmentMarriageGrp
					,airFareBasisCode,airFareReferenceKey,airsegmentcabin,tripAirLegsKey FROM @TripAirSegmentsTmp
					WHERE airResponseKey = @AirResponseKey
					ORDER BY airLegNumber ASC, segmentOrder ASC
				END	
				/*End Inserting data in Trip tables*/
				
		 /*TMU DATA INSERTED IN TABLE TripDetails*/
		 BEGIN TRY
			SELECT @TripRequestKey = tripRequestKey, @UserKey = userKey
			FROM Trip WITH (NOLOCK) WHERE tripKey = @TK
			
			SELECT @TripFrom = tripFrom1, @TripTo = tripTo1
			,@TripStartDate = tripFromDate1
			,@TripEndDate = (CASE WHEN tripToDate1 = '1753-01-01 00:00:00.000' THEN tripFromDate1 ELSE tripToDate1 END)
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
			
			SELECT TOP 1 
			@AirRequestTypeKey = AirRequestTypeKey
			,@AirRequestType = (CASE WHEN AirRequestTypeKey = 2 THEN 'RoundTrip' ELSE 'OneWay' END)
			FROM AirRequestTripSavedDeal WITH (NOLOCK) WHERE TripKey = @TK
			
			IF(@AirRequestTypeKey = 1) -- FOR ONE-WAY
			BEGIN
				SELECT @NoOfLeg1Stops = COUNT(airLegNumber) 
				FROM airsegments				
				WHERE airResponseKey = @AirResponseKey
				
				SET @NoOfAirStops = (@NoOfLeg1Stops - 1)
			END
			ELSE -- FOR ROUND-TRIP
			BEGIN
				SELECT @NoOfLeg1Stops = COUNT(airLegNumber) 
				FROM airsegments				
				WHERE airResponseKey = @AirResponseKey
				AND airLegNumber = 1
				
				SELECT @NoOfLeg2Stops = COUNT(airLegNumber) 
				FROM airsegments				
				WHERE airResponseKey = @AirResponseKey
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
			
			
			--SELECT TOP 1 @UserKey = UserKey, @TripFrom = DepartureAirportLeg1
			--,@TripTo = ArrivalAirportLeg1, @TripStartDate = DepartureDateLeg1
			--,@TripEndDate = (CASE WHEN AirRequestTypeKey = 2 THEN DepartureDateLeg2 ELSE DepartureDateLeg1 END)
			--,@TripEndMonth = (CASE WHEN AirRequestTypeKey = 2 THEN DATEPART(MONTH,DepartureDateLeg2) ELSE DATEPART(MONTH,DepartureDateLeg1) END)
			--,@TripEndYear = (CASE WHEN AirRequestTypeKey = 2 THEN DATEPART(YEAR,DepartureDateLeg2) ELSE DATEPART(YEAR,DepartureDateLeg1) END)
			--,@AirRequestType = (CASE WHEN AirRequestTypeKey = 2 THEN 'RoundTrip' ELSE 'OneWay' END)
			--,@FromCountryCode = FromCountryCode
			--,@FromCountryName = FromCountryName
			--,@FromStateCode = FromStateCode
			--,@FromCityName = FromCityName
			--,@ToCountryCode = ToCountryCode
			--,@ToCountryName = ToCountryName
			--,@ToStateCode = ToStateCode
			--,@ToCityName = ToCityName
			--FROM AirRequestTripSavedDeal WHERE TripKey = @TK
			
			SELECT @CurrentPerPersonPrice  = (airPriceBaseDisplay + airPriceTaxDisplay)
			,@CurrentTotalPrice = (airPriceBaseTotal + airPriceTaxTotal)
			FROM @TblAirResponse WHERE airResponseKey = @AirResponseKey
			
			
			DECLARE @PriceDiff INT = CONVERT(DECIMAL(10,2),(@BookedPrice - @CurrentPerPersonPrice))
			IF @PriceDiff > 0
			BEGIN
			SET @isDefaultVal = 0
			END
			ELSE
			BEGIN
			SET @isDefaultVal = 1
			END
			
			SELECT TOP 1 @AirSegmentCabin = airsegmentcabin FROM @TripAirSegmentsTmp
			WHERE airResponseKey = @AirResponseKey
			ORDER BY airLegNumber ASC, segmentOrder ASC
			
			SET @isMultipleAirline = dbo.udf_ComapreMultipleAirlines(@NewMarketingAirline)
			IF (@isMultipleAirline = 0)
			BEGIN
				SET @singleAirlineCode = SUBSTRING(@NewMarketingAirline, 1, 2)
				SET @TMUMarketingAirlineCode = @singleAirlineCode
				SET @TMUMarketingAirlineName = (SELECT ShortName FROM AirVendorLookup WHERE AirlineCode = @singleAirlineCode)
			END
			ELSE
			BEGIN
				SET @TMUMarketingAirlineCode = 'Multiple Airlines'
				SET @TMUMarketingAirlineName = 'Multiple Airlines'
			END
			
			/*IF TRIP KEY IS NOT PRESENT IN TRIPDETAILS TABLE THEN INSERT OR ELSE UPDATE*/
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
					,tripEndMonth
					,tripEndYear
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
				(
					@TK
					,@TripSavedKey
					,@UserKey
					,@TripFrom
					,@TripTo
					,@TripStartDate
					,@TripEndMonth
					,@TripEndYear
					,CONVERT(DECIMAL(10,2),(@BookedPrice - @CurrentPerPersonPrice))
					,CONVERT(DECIMAL(10,2),(@originalTotalPrice - @CurrentTotalPrice))
					,CONVERT(DECIMAL(10,2),@CurrentPerPersonPrice)
					,CONVERT(DECIMAL(10,2),@CurrentTotalPrice)
					,@AirRequestType
					,@AirSegmentCabin
					,@FromCountryCode
					,@FromCountryName
					,@FromStateCode
					,@FromCityName
					,@ToCountryCode
					,@ToCountryName
					,@ToStateCode
					,@ToCityName
					,@TripEndDate
					,@TMUMarketingAirlineCode
					,@TMUMarketingAirlineName
					,@NoOfAirStops
					--,@BookedPrice
					--,@originalTotalPrice
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
				,latestDealAirSavingsPerPerson = CONVERT(DECIMAL(10,2),(@BookedPrice - @CurrentPerPersonPrice))
				,latestDealAirSavingsTotal = CONVERT(DECIMAL(10,2),(@originalTotalPrice - @CurrentTotalPrice))
				,latestDealAirPricePerPerson = CONVERT(DECIMAL(10,2),@CurrentPerPersonPrice)
				,latestDealAirPriceTotal = CONVERT(DECIMAL(10,2),@CurrentTotalPrice)
				,AirRequestTypeName = @AirRequestType
				,AirCabin = @AirSegmentCabin
				,FromCountryCode = @FromCountryCode
				,FromCountryName = @FromCountryName
				,FromStateCode = @FromStateCode
				,FromCityName = @FromCityName
				,ToCountryCode = @ToCountryCode
				,ToCountryName = @ToCountryName
				,ToStateCode = @ToStateCode
				,ToCityName = @ToCityName
				,LatestAirLineCode = @TMUMarketingAirlineCode
				,LatestAirlineName = @TMUMarketingAirlineName
				,NumberOfCurrentAirStops = @NoOfAirStops
				,lastUpdatedDate = GETDATE()
				WHERE tripKey = @TK
			END
			
			
			IF(@isDefaultVal = 1)
			BEGIN
				UPDATE TripDetails SET
				 latestDealAirPricePerPerson = 0,latestDealAirPriceTotal = 0,latestDealAirSavingsPerPerson = 0 , latestDealAirSavingsTotal = 0
				WHERE tripKey = @TK
			END
			
		 END TRY
		 BEGIN CATCH
			DECLARE @ErrorMessage VARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE();
			INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, ErrorMessage, Remarks, InitiatedFrom) 
			VALUES(@TK, @PkGroupId, 1, @ErrorMessage
			,'Error while inserting data in table TripDetails. stored procedure USP_GetTripSavedDealAirMinPrice', 'TMU')
		 END CATCH
		 /*END: TMU DATA INSERTED IN TABLE TripDetails*/
				
			BREAK	
			END    
	 /*End Executing To insert data in TripSavedDeals*/
	 
    Delete @TblVendorDetails
    Update @TblMinCurrentPrice Set IsUsed = 1 Where PkId = @PkId    
	SET  @LoopCount += 1    
    End
    /*End Executing for all the selected minimum price*/
    
    /*@TblMinCurrentPrice is deleted after every tripKey is executed*/
    Delete From @TblMinCurrentPrice 
    Update @TblGroup set IsInserted = 1 where TblGroupKey = @TblGroupKey
    SET  @insertCount += 1    
    
   END    
   /*Dont delete it will be required for repricing*/
   --Select Category = @Category, AirResponseKey = @AirResponseKey, TripAirResponseKey = @TripAirResponseKey
   
   /*For repricing*/
   Select AirResponseKey, TripAirResponseKey, Category, TripAirPriceKey From @AirReprice
   
END
GO
