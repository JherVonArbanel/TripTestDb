SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- usp_GetTripDetailsForMultipax null,859894

		--exec [usp_GetTripDetailsForMultipax] 27026,0
		CREATE PROCEDURE [dbo].[usp_GetTripDetailsForMultipax_20170309]
		(                      
			@tripID   int   ,                        
			@tripRequestID Int = 0                        
		)                      
		as                          
		BEGIN                        

--SELECT @tripId=30989, @tripRequestId=735461

		Declare @TimeStampLog Table 
	(SPName nvarchar(1000), Steps nvarchar(500),StepsDesc nvarchar(1000), LastDateTime DateTime,CurrentDateTime DateTime,InMillisecond bigint)
	
	Declare  @LogLastDateTime Datetime = GETDATE()
			,@LogSPName nvarchar(100)
			,@LogExecutedOn  nvarchar(100)
			,@LogExecutionTime nvarchar(100)

	SET @LogSPName = 'usp_GetTripDetailsForMultipax'; 
	SET @LogExecutedOn  = CONVERT(NVARCHAR(50),GETDATE(),127)

	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'START','',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE(); 
	
		                        
		DECLARE @tblTrip as table                        
		(                        
		 tripKey int,                        
		 RequestKey int,            
		 statusKey int,
		 tripPurchasedKey UNIQUEIDENTIFIER                  
		)                        
		                        
		                        
		if(@tripRequestID is Null  or @tripRequestID = 0 )                         
		BEGIN                        
		 INSERT Into @tblTrip                        
		 Select  @tripID,   tripRequestKey, tripStatusKey, tripPurchasedKey  from Trip WITH(NOLOCK) where tripKey  = @tripID and   tripStatusKey <>17                      
		 --ORDER BY tripKey DESC
		END                        
		ELSE                         
		BEGIN                        
		 INSERT Into @tblTrip                        
		 Select  tripKey ,  tripRequestKey, tripStatusKey, tripPurchasedKey  from Trip WITH(NOLOCK) where tripRequestKey  = @tripRequestID  and   tripStatusKey <>17                      
		 --ORDER BY tripKey DESC
		END                        
		                        
		                        
		                        
		                        
		Declare @tblUser as table                        
		(                        
		 UserKey Int,                        
		 UserFirst_Name nvarchar(200),                        
		 UserLast_Name nvarchar(200),                        
		 User_Login nvarchar(50) ,                        
		 companyKey int,
		 ReceiptEmail nvarchar(100)
		)                        
		                        
		                         
--SELECT '1', GETDATE() 
CREATE TABLE #vw_TripCarResponseDetails
(
	[recordLocator] [varchar](50) NULL,
	[carResponseKey] [uniqueidentifier] NOT NULL,
	[confirmationNumber] [varchar](50) NULL,
	[carVendorKey] [varchar](50) NOT NULL,
	[supplierId] [varchar](50) NOT NULL,
	[carCategoryCode] [varchar](50) NOT NULL,
	[carLocationCode] [varchar](50) NOT NULL,
	[carLocationCategoryCode] [varchar](50) NOT NULL,
	[PerDayRate] [float] NOT NULL,
	[searchCarTax] [float] NULL,
	[actualCarPrice] [float] NULL,
	[actualCarTax] [float] NULL,
	[SearchCarPrice] [float] NOT NULL,
	[VehicleName] [nvarchar](150) NULL,
	[pickupLocationName] [nvarchar](256) NULL,
	[pickupLocationAddress] [nvarchar](500) NULL,
	[pickupLatitude] [float] NULL,
	[pickupLongitude] [float] NULL,
	[pickupZipCode] [nvarchar](16) NULL,
	[dropoffLatitude] [float] NULL,
	[dropoffLongitude] [float] NULL,
	[dropoffZipCode] [nvarchar](16) NULL,
	[dropoffLocationAddress] [nvarchar](500) NULL,
	[dropoffLocationName] [nvarchar](256) NULL,
	[PickUpdate] [datetime] NULL,
	[dropOutDate] [datetime] NULL,
	[SippCodeDescription] [nvarchar](150) NULL,
	[SippCodeTransmission] [nvarchar](32) NULL,
	[SippCodeAC] [int] NULL,
	[CarCompanyName] [nvarchar](64) NULL,
	[SippCodeClass] [nvarchar](150) NULL,
	[dropoffCity] [nvarchar](200) NULL,
	[dropoffState] [nvarchar](32) NULL,
	[dropoffCountry] [nvarchar](64) NULL,
	[pickupCity] [nvarchar](200) NULL,
	[pickupState] [nvarchar](32) NULL,
	[pickupCountry] [nvarchar](64) NULL,
	[minRateTax] [float] NOT NULL,
	[TotalChargeAmt] [float] NULL,
	[minRate] [float] NOT NULL,
	[passenger] [nvarchar](50) NULL,
	[baggage] [nvarchar](50) NULL,
	[isExpenseAdded] [bit] NULL,
	[NoOfDays] [int] NULL,
	[tripGUIDKey] [uniqueidentifier] NULL,
	[contractCode] [varchar](50) NULL,
	[carRules] [varchar](2000) NULL,
	[tripKey] [int] NULL,
	[rateTypeCode] [varchar](20) NULL,
	[OperationTimeStart] [varchar](10) NULL,
	[OperationTimeEnd] [varchar](10) NULL,
	[PickupLocationInfo] [varchar](100) NULL,
	[InvoiceNumber] [varchar](20) NULL,
	[MileageAllowance] [varchar](10) NULL,
	[RPH] [varchar](2) NULL,
	[CurrencyCodeKey] [nvarchar](10) NULL,
	[imageName] [nvarchar](200) NULL,
	[PhoneNumber] [varchar](32) NULL,
	[carDropOffLocationCode] [varchar](50) NULL, 
	[carDropOffLocationCategoryCode] [varchar](50) NULL
)


INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'1','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();
		                         
		Insert into @tblUser                         
		Select distinct U.userKey , LTRIM(RTRIM(U.userFirstName)) userFirstName , LTRIM(RTRIM(U.userLastName)) userLastName , U.userLogin  ,U.companyKey, UP.ReceiptEmail                         
		From Vault.dbo.[User] U  WITH(NOLOCK)                      
		 inner join Trip T WITH(NOLOCK) on  U.userKey = T.userKey  and   T.tripStatusKey <>17                       
		 Inner join @tblTrip tt on tt.tripKey = T.tripKey      and   T.tripStatusKey <>17                   
		 inner join Vault.dbo.UserProfile UP WITH(NOLOCK) ON U.userKey = UP.userKey
		            
		            
--SELECT '2', GETDATE() 

	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'2','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        
		                        
		select Trip.*, vault.dbo.Agency .agencyKey As Agency_ID, U.* from Trip                         
		inner join vault.dbo.Agency WITH(NOLOCK) on trip.agencyKey = Agency .agencyKey                         
		Left Outer join @tblUser U  on Trip.userKey = U.UserKey                         
		Inner join @tblTrip tt on tt.tripKey = Trip.tripKey    and   Trip.tripStatusKey <>17                          
		Order by tripKey                         

--SELECT '3', GETDATE() 
	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'3','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        
		                        
		select TPI.TripPassengerInfoKey,TPI.TripKey,TPI.PassengerKey,PassengerTypeKey,IsPrimaryPassenger
		,PassengerEmailID,LTRIM(RTRIM(PassengerFirstName)) PassengerFirstName,LTRIM(RTRIM(PassengerLastName)) PassengerLastName,PassengerLocale,PassengerTitle
		,PassengerGender,PassengerBirthDate,TravelReferenceNo,PassengerRedressNo
		PassengerKnownTravellerNo,IsExcludePricingInfo from TripPassengerInfo TPI WITH(NOLOCK)                         
		  Inner join @tblTrip tt on tt.tripKey = TPI.tripKey                          
		  WHERE    TPI.Active = 1                   

--SELECT '4', GETDATE() 
	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'4','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        

		/*Getting Add Collect Amount From Trip Ticket Info table*/                  
		DECLARE @AddCollectAmount FLOAT,@ExchangeFee Float
		SET @AddCollectAmount = 0 
		Set @ExchangeFee = 0     
		      
		--SELECT TOP 1 @AddCollectAmount = AddCollectFare + serviceCharge FROM TripTicketInfo TTI       
		--INNER JOIN @tblTrip tt ON tt.tripKey = TTI.tripKey WHERE IsExchanged = 1 AND tt.statusKey = 12      
		--ORDER BY tripTicketInfoKey Desc      

		SELECT TOP 1 @AddCollectAmount = TotalFare,@ExchangeFee = ExchangeFee FROM TripTicketInfo TTI       
		INNER JOIN @tblTrip tt ON tt.tripKey = TTI.tripKey WHERE IsExchanged = 1 AND tt.statusKey = 12      
		ORDER BY tripTicketInfoKey Desc   
		---------------------------------------------


		SELECT          
		DISTINCT T.tripKey ,                        
			   t.tripRequestKey ,                   
		segments.tripAirSegmentKey,                  
		segments.airSegmentKey,                  
		segments.tripAirLegsKey,                  
		--segments.airResponseKey,                  
		segments.airLegNumber,                  
		segments.airSegmentMarketingAirlineCode,                  
		segments.airSegmentOperatingAirlineCode,                  
		segments.airSegmentFlightNumber,                  
		segments.airSegmentDuration,  
		segments.airSegmentMiles,                  
		segments.airSegmentDepartureDate,                  
		segments.airSegmentArrivalDate,                  
		segments.airSegmentDepartureAirport,                  
		segments.airSegmentArrivalAirport,                  
		segments.airSegmentResBookDesigCode,                  
		segments.airSegmentDepartureOffset,                  
		segments.airSegmentArrivalOffset,       
		(case when AircraftsLookup.AircraftName IS NULL then airSegmentEquipment else AircraftsLookup.AircraftName end) as airSegmentEquipment,                             
		segments.airSegmentSeatRemaining,                  
		segments.airSegmentMarriageGrp,                  
		segments.airFareBasisCode,                  
		segments.airFareReferenceKey,                  
		segments.airSelectedSeatNumber,                  
		segments.ticketNumber,                  
		segments.airsegmentcabin,                  
		segments.recordLocator as SegRecordLocator,                     
		segments.airSegmentOperatingAirlineCompanyShortName    
		,legs.gdsSourceKey ,                          
		departureAirport.AirportName  as departureAirportName ,                          
		departureAirport.CityCode as departureAirportCityCode,departureAirport.CityName as departureAirportCityName,departureAirport.StateCode   as departureAirportStateCode                           
		,departureAirport.CountryCode as departureAirportCountryCode,                          
		arrivalAirport.AirportName  as arrivalAirportName ,arrivalAirport.CityCode as arrivalAirportCityCode,arrivalAirport.CityName as arrivalAirportCityName,                          
		arrivalAirport.StateCode  as arrivalAirportStateCode ,arrivalAirport.CountryCode as arrivalAirportCountryCode,                          
		legs.recordLocator , 
		--AirResp.actualAirPrice ,  
		--AirResp.actualAirTax ,
		--AirResp.airResponseKey ,
		ISNULL (airven.ShortName,segments.airSegmentMarketingAirlineCode ) as MarketingAirLine,airSegmentOperatingAirlineCode  ,  
		AirResp.CurrencyCodeKey as CurrencyCode,                        
		ISNULL (airOperatingven.ShortName,segments.airSegmentOperatingAirlineCode ) as OperatingAirLine,                  isnull(airSelectedSeatNumber,0)  as SeatNumber  , 
		segments.ticketNumber as TicketNumber ,
		segments.airsegmentcabin as airsegmentcabin,
		--AirResp.isExpenseAdded,                      
		ISNULL(t.deniedReason,'') as deniedReason, 
		t.CreatedDate ,
		segments.airSegmentOperatingFlightNumber ,
		--airresp.bookingcharges ,
		ISNULL(seatMapStatus,'') AS seatMapStatus, 

		@AddCollectAmount AS AddCollectAmount,
		@ExchangeFee as ExchangeBookingFee,               
		 G.AgentURL     , 

		 segments.RPH ,
		 segments.ArrivalTerminal ,
		 segments.DepartureTerminal,      
		  AirResp.* ,
		 legs.ValidatingCarrier as LegValidatingCarrier
		--   ,TPR.RemarkFieldName                        
		--,TPR.RemarkFieldValue                        
		--,TPR.TripTypeKey                        
		--,TPR.RemarksDesc                        
		--,TPR.GeneratedType                        
		--,TPR.CreatedOn       
		             
		 from TripAirSegments  segments  WITH(NOLOCK)                         
		  inner join TripAirLegs legs  WITH(NOLOCK)                         
		   on ( segments .tripAirLegsKey = legs .tripAirLegsKey --and segments .airResponseKey = legs.airResponseKey                           
		   and segments .airLegNumber = legs .airLegNumber )                          
		  inner join TripAirResponse   AirResp  WITH(NOLOCK)                         
		   on segments .airResponseKey = AirResp .airResponseKey                            
		  inner join Trip t WITH(NOLOCK) on AirResp.tripGUIDKey  = t.tripPurchasedKey                         
		Inner join @tblTrip tt on tt.tripKey = t.tripKey                         
		  left outer join AirVendorLookup airVen  WITH(NOLOCK)                         
		   on segments .airSegmentMarketingAirlineCode =airVen .AirlineCode                           
		  left outer join AirVendorLookup airOperatingVen  WITH(NOLOCK)                          
		   on segments .airSegmentOperatingAirlineCode =airOperatingVen .AirlineCode                           
		  left outer join AirportLookup departureAirport WITH(NOLOCK)                           
		   on departureAirport .AirportCode = segments .airSegmentdepartureAirport                           
		 left outer join AirportLookup arrivalAirport WITH(NOLOCK)                          
		   on arrivalAirport.AirportCode = segments .airSegmentarrivalAirport                           
		  inner join Vault.dbo.GDSSourceLookup G WITH(NOLOCK) on G.gdsSourceKey = legs.gdsSourceKey            
		 LEFT OUTER JOIN AircraftsLookup WITH (NOLOCK) on (segments.airSegmentEquipment = AircraftsLookup.SubTypeCode AND AircraftsLookup.SubTypeCode = AircraftsLookup.AircraftCode)    
		            
		 WHERE ISNULL(LEGS.ISDELETED,0) = 0 AND ISNULL (segments.ISDELETED ,0) = 0  and   T.tripStatusKey <>17             
		 AND ISNULL (AirResp.ISDELETED ,0) = 0                                    
		 ORDER BY T.tripKey ,segments.tripAirSegmentKey , segments .airSegmentDepartureDate                           
		-- where t.tripRequestKey = @tripRequestID                             

--SELECT '5', GETDATE() 
	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'5','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        
		          
		--Commented as suggested by Hemali/Asha-New view is used          
		--select                  
		--hotel.*,GL.AgentURL from vw_TripHotelResponse hotel --commented as suggested by Asha as it was not displaying duplicate hotel                         
		--inner join trip t on hotel.tripkey = t.tripkey                           
		--Inner join @tblTrip tt on tt.tripKey = t.tripKey          
		--Inner Join vault.dbo.GDSSourceLookup GL On GL.GDSName = hotel.SupplierId          
		--Order by t.tripKey          
		--End Commented as suggested by Hemali/Asha-New view is used          
		          
		select                
		hotel.*,t.tripKey,GL.AgentURL,HI.SupplierImageURL,CRH.RedeemedAmount from vw_TripHotelResponseDetails hotel WITH(NOLOCK)          
		inner join trip t WITH(NOLOCK) on hotel.tripGUIDKey = t.tripPurchasedKey    and   T.tripStatusKey <>17        
		Inner join @tblTrip tt on tt.tripKey = t.tripKey           and   T.tripStatusKey <>17   
		Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = hotel.SupplierId          
		LEFT OUTER JOIN HotelContent..HotelImages HI WITH(NOLOCK) ON HI.HotelId = hotel.HotelId AND HI.ImageType = 'Exterior'         
		LEFT OUTER JOIN Loyalty..CashRewardHistory CRH WITH(NOLOCK) ON CRH.Id = T.cashRewardId
		Order by t.tripKey          
		                          
--SELECT '6', GETDATE() 
	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'6','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        

		--Select * from vw_TripCarResponse car WITH(NOLOCK) inner join                           
		--trip t WITH(NOLOCK) on car .tripkey =t.tripkey                         
		--Inner join @tblTrip tt on tt.tripKey  = t.tripKey               
		--Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = car.SupplierId                        
		--Inner join vault.dbo.[User] U on t.userKey = U.userKey                         
		 --where t.tripRequestKey = @tripRequestID                         
		 --Order by t.tripKey                        

--------------------------- ADDED BY GOPAL TO AVOID USING VIEW -------------------------------------------------

INSERT INTO #vw_TripCarResponseDetails 
SELECT      TR.recordLocator,		TR.carResponseKey,			TR.confirmationNumber,		TR.carVendorKey,		TR.supplierId,		TR.carCategoryCode, 
                      TR.carLocationCode,	TR.carLocationCategoryCode, TR.minRate AS PerDayRate,	TR.searchCarTax,		TR.actualCarPrice,	TR.actualCarTax, 
                      TR.SearchCarPrice,    SV.VehicleName,				SL.LocationName AS pickupLocationName,              SL.LocationAddress1 AS pickupLocationAddress, 
                      SL.Latitude AS pickupLatitude,					SL.Longitude AS pickupLongitude,                    SL.ZipCode AS pickupZipCode, 
                      DO.Latitude AS dropoffLatitude,                   DO.Longitude AS dropoffLongitude,					DO.ZipCode AS dropoffZipCode, 
                      DO.LocationAddress1 AS dropoffLocationAddress,	DO.LocationName AS dropoffLocationName,             TR.PickUpdate, TR.dropOutDate, 
                      S.SippCodeDescription,                            S.SippCodeTransmission,								CASE WHEN S.SippCodeAC = 'Air Conditioning' THEN 1 ELSE 0 END AS SippCodeAC, 
                      CC.CarCompanyName,	S.SippCodeClass,			DO.LocationCity AS dropoffCity,                     DO.Locationstate AS dropoffState, 
                      DO.LocationCountry AS dropoffCountry,             SL.LocationCity AS pickupCity,						SL.Locationstate AS pickupState, 
                      SL.LocationCountry AS pickupCountry,              TR.minRateTax,				TR.TotalChargeAmt,		TR.minRate, 
                      SV.PsgrCapacity AS passenger,                     SV.Baggage AS baggage,		TR.isExpenseAdded,		TR.NoOfDays,TR.tripGUIDKey, 
                      TR.contractCode,		TR.carRules ,				TR.tripKey,					TR.rateTypeCode,
                      TR.OperationTimeStart,		            		TR.OperationTimeEnd,		TR.PickupLocationInfo,	TR.InvoiceNumber,		TR.MileageAllowance,
                      TR.RPH, TR.CurrencyCodeKey,sv.imageName, TR.PhoneNumber, TR.carDropOffLocationCode,TR.carDropOffLocationCategoryCode
		  FROM		 CarContent.dbo.CarCompanies CC WITH (NOLOCK) 
					 INNER JOIN dbo.TripCarResponse TR WITH (NOLOCK) ON  CC.CarCompanyCode = TR.carVendorKey 
				     INNER JOIN CarContent.dbo.SippCodes S WITH (NOLOCK) ON TR.carCategoryCode = S.SippCodeCarType 
					 LEFT OUTER JOIN  CarContent.dbo.SabreVehicles SV WITH (NOLOCK) ON TR.carVendorKey = SV.VendorCode 
					             AND   TR.carCategoryCode = SV.SippCode 
					             AND   TR.carLocationCode = SV.LocationAirportCode 
					             AND   TR.carLocationCategoryCode = SV.LocationCategoryCode 
				   --LEFT OUTER JOIN CarContent.dbo.SabreLocations S1 WITH (NOLOCK) ON SV.VendorCode = S1.VendorCode 
				   --            AND SV.LocationAirportCode = S1.LocationAirportCode 
				   --            AND SV.LocationCategoryCode = S1.LocationCategoryCode 
					LEFT OUTER JOIN  CarContent.dbo.SabreLocations SL WITH (NOLOCK) ON SL.VendorCode = SV.VendorCode 
							    AND SL.LocationAirportCode = SV.LocationAirportCode 
							    AND SL.LocationCategoryCode = SV.LocationCategoryCode
					LEFT OUTER JOIN CarContent.dbo.SabreLocations DO WITH (NOLOCK) ON DO.VendorCode = SV.VendorCode 
							    AND DO.LocationAirportCode = ISNULL(TR.carDropOffLocationCode, SV.LocationAirportCode)
							    AND DO.LocationCategoryCode = ISNULL(TR.carDropOffLocationCode,SV.LocationAirportCode)
                      INNER JOIN @tblTrip tt ON tt.tripKey  = TR.tripKey 
		 WHERE     TR.SupplierId = 'Sabre' AND ISNULL (TR.ISDELETED ,0) = 0  

INSERT INTO #vw_TripCarResponseDetails 
		  SELECT      TR.recordLocator,TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, AV.ALVehicleName, AL_1.ALLocationName AS pickupLocationName, AL_1.ALLocationAddress1 AS pickupLocationAddress, 
                      AL_1.ALLatitude AS pickupLatitude, AL_1.ALLongitude AS pickupLongitude, AL_1.ALZipCode AS pickupZipCode, AL.ALLatitude AS dropoffLatitude, 
                      AL.ALLongitude AS dropoffLongitude, AL.ALZipCode AS dropoffZipCode, AL.ALLocationAddress1 AS dropoffLocationAddress, 
                      AL.ALLocationName AS dropoffLocationName, TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, 
                      AV.ALTRANSMISSIONTYPE AS SippCodeTransmission, AV.ALAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, 
                      S.VehicleClass AS SippCodeClass, AL.ALLocationCityName AS dropoffCity, AL.ALLocationStateCode AS dropoffState, AL.ALLocationCountryCode AS dropoffCountry, 
                      AL_1.ALLocationCityName AS pickupCity, AL_1.ALLocationStateCode AS pickupState, AL_1.ALLocationCountryCode AS pickupCountry, TR.minRateTax, 
                      TR.TotalChargeAmt, TR.minRate, AV.ALPASSENGERQUANTITY AS passenger, AV.ALBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded, TR.NoOfDays,TR.tripGUIDKey, TR.contractCode,TR.carRules ,	TR.tripKey,
                      TR.rateTypeCode,   TR.OperationTimeStart,TR.OperationTimeEnd,TR.PickupLocationInfo,TR.InvoiceNumber,TR.MileageAllowance,
                      TR.RPH, TR.CurrencyCodeKey,'' as ImageName, TR.PhoneNumber, TR.carDropOffLocationCode,TR.carDropOffLocationCategoryCode
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey 
                      LEFT OUTER JOIN
                      CarContent.dbo.AlamoLocations AL WITH (NOLOCK) ON TR.carLocationCode = LEFT(AL.ALLocationCode, 3) AND AL.ALAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.ALAMOVEHICLES AV WITH (NOLOCK) ON AL.ALLocationCode = AV.ALLOCATIONCODE AND AV.ALVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.AlamoLocations AL_1 ON AL.ALLocationCode = AL_1.ALLocationCode AND AL_1.ALAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON AV.ALVEHICLECLASSSIZE = S.VehicleClassSize
                      INNER JOIN @tblTrip tt ON tt.tripKey  = TR.tripKey 
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'AL'

INSERT INTO #vw_TripCarResponseDetails 
SELECT     TR.recordLocator,TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, NV.ZLVehicleName, NL_1.ZLLocationName AS pickupLocationName, NL_1.ZLLocationAddress1 AS pickupLocationAddress, 
                      NL_1.ZLLatitude AS pickupLatitude, NL_1.ZLLongitude AS pickupLongitude, NL_1.ZLZipCode AS pickupZipCode, NL.ZLLatitude AS dropoffLatitude, 
                      NL.ZLLongitude AS dropoffLongitude, NL.ZLZipCode AS dropoffZipCode, NL.ZLLocationAddress1 AS dropoffLocationAddress, 
                      NL.ZLLocationName AS dropoffLocationName, TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, 
                      NV.ZLTRANSMISSIONTYPE AS SippCodeTransmission, NV.ZLAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, 
                      S.VehicleClass AS SippCodeClass, NL.ZLLocationCityName AS dropoffCity, NL.ZLLocationStateCode AS dropoffState, NL.ZLLocationCountryCode AS dropoffCountry, 
                      NL_1.ZLLocationCityName AS pickupCity, NL_1.ZLLocationStateCode AS pickupState, NL_1.ZLLocationCountryCode AS pickupCountry, TR.minRateTax, 
                      TR.TotalChargeAmt, TR.minRate, NV.ZLPASSENGERQUANTITY AS passenger, NV.ZLBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded, TR.NoOfDays,TR.tripGUIDKey, TR.contractCode,TR.carRules ,	TR.tripKey,
                      TR.rateTypeCode,   TR.OperationTimeStart,TR.OperationTimeEnd,TR.PickupLocationInfo,TR.InvoiceNumber,TR.MileageAllowance,
                      TR.RPH, TR.CurrencyCodeKey,'' as ImageName,  TR.PhoneNumber, TR.carDropOffLocationCode,TR.carDropOffLocationCategoryCode
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey 
                      LEFT OUTER JOIN
                      CarContent.dbo.NationalLocations NL WITH (NOLOCK) ON TR.carLocationCode = LEFT(NL.ZLLocationCode, 3) AND NL.ZLAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.NationalVehicles NV WITH (NOLOCK) ON NL.ZLLocationCode = NV.ZLLOCATIONCODE AND NV.ZLVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.NationalLocations NL_1 ON NL.ZLLocationCode = NL_1.ZLLocationCode AND NL_1.ZLAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON NV.ZLVEHICLECLASSSIZE = S.VehicleClassSize
                      INNER JOIN @tblTrip tt ON tt.tripKey  = TR.tripKey 
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZL'

INSERT INTO #vw_TripCarResponseDetails 
SELECT      TR.recordLocator,TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, ZV.ZRVehicleName, ZL_1.ZRLocationName AS pickupLocationName, ZL_1.ZRAddress1 AS pickupLocationAddress, 
                      ZL_1.ZRLatitude AS pickupLatitude, ZL_1.ZRLongitude AS pickupLongitude, ZL_1.ZRZipCode AS pickupZipCode, ZL.ZRLatitude AS dropoffLatitude, 
                      ZL.ZRLongitude AS dropoffLongitude, ZL.ZRZipCode AS dropoffZipCode, ZL.ZRAddress1 AS dropoffLocationAddress, ZL.ZRLocationName AS dropoffLocationName, 
                      TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, ZV.ZRTRANSMISSIONTYPE AS SippCodeTransmission, 
                      ZV.ZRAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, S.VehicleClass AS SippCodeClass, ZL.ZRCityName AS dropoffCity, 
                      ZL.ZRStateCode AS dropoffState, ZL.ZRCountryCode AS dropoffCountry, ZL_1.ZRCityName AS pickupCity, ZL_1.ZRStateCode AS pickupState, 
                      ZL_1.ZRCountryCode AS pickupCountry, TR.minRateTax, TR.TotalChargeAmt, TR.minRate, ZV.ZRPASSENGERQUANTITY AS passenger, 
                      ZV.ZRBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded, TR.NoOfDays,TR.tripGUIDKey, TR.contractCode,TR.carRules ,	TR.tripKey,
                      TR.rateTypeCode,   TR.OperationTimeStart,TR.OperationTimeEnd,TR.PickupLocationInfo,TR.InvoiceNumber,TR.MileageAllowance,
                      TR.RPH,TR.CurrencyCodeKey,'' as ImageName ,  TR.PhoneNumber, TR.carDropOffLocationCode,TR.carDropOffLocationCategoryCode
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey 
                      LEFT OUTER JOIN
                      CarContent.dbo.DollarLocations ZL WITH (NOLOCK) ON TR.carLocationCode = LEFT(ZL.ZRLocationCode, 3) AND ZL.ZRAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.DollarVehicles ZV WITH (NOLOCK) ON ZL.ZRLocationCode = ZV.ZRLOCATIONCODE AND ZV.ZRVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.DollarLocations ZL_1 ON ZL.ZRLocationCode = ZL_1.ZRLocationCode AND ZL_1.ZRAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON ZV.ZRVEHICLECLASSSIZE = S.VehicleClassSize
                      INNER JOIN @tblTrip tt ON tt.tripKey  = TR.tripKey 
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZR'

INSERT INTO #vw_TripCarResponseDetails 
SELECT     TR.recordLocator, TR.carResponseKey, TR.confirmationNumber, TR.carVendorKey, 
                      TR.supplierId, TR.carCategoryCode, TR.carLocationCode, TR.carLocationCategoryCode, TR.minRate AS PerDayRate, TR.searchCarTax, TR.actualCarPrice, 
                      TR.actualCarTax, TR.SearchCarPrice, TV.ZTVEHICLENAME, TL_1.ZTLocationName AS pickupLocationName, TL_1.ZTAddress1 AS pickupLocationAddress, 
                      TL_1.ZTLatitude AS pickupLatitude, TL_1.ZTLongitude AS pickupLongitude, TL_1.ZTZipCode AS pickupZipCode, TL.ZTLatitude AS dropoffLatitude, 
                      TL.ZTLongitude AS dropoffLongitude, TL.ZTZipCode AS dropoffZipCode, TL.ZTAddress1 AS dropoffLocationAddress, TL.ZTLocationName AS dropoffLocationName, 
                      TR.PickUpdate, TR.dropOutDate, S.VehicleClass AS SippCodeDescription, TV.ZTTRANSMISSIONTYPE AS SippCodeTransmission, 
                      TV.ZTAIRCONDITIONIND AS SippCodeAC, CarContent.dbo.CarCompanies.CarCompanyName, S.VehicleClass AS SippCodeClass, TL.ZTCityName AS dropoffCity, 
                      TL.ZTStateCode AS dropoffState, TL.ZTCountryCode AS dropoffCountry, TL_1.ZTCityName AS pickupCity, TL_1.ZTStateCode AS pickupState, 
                      TL_1.ZTCountryCode AS pickupCountry, TR.minRateTax, TR.TotalChargeAmt, TR.minRate, TV.ZTPASSENGERQUANTITY AS passenger, 
                      TV.ZTBAGGAGEQUANTITY AS baggage, TR.isExpenseAdded, TR.NoOfDays,TR.tripGUIDKey, TR.contractCode,TR.carRules ,	TR.tripKey,
                      TR.rateTypeCode,   TR.OperationTimeStart,TR.OperationTimeEnd,TR.PickupLocationInfo,TR.InvoiceNumber,TR.MileageAllowance,
                      TR.RPH, TR.CurrencyCodeKey,'' as Imagename , TR.PhoneNumber, TR.carDropOffLocationCode,TR.carDropOffLocationCategoryCode
FROM         TripCarResponse TR WITH (NOLOCK) INNER JOIN
                      CarContent.dbo.CarCompanies WITH (NOLOCK) ON CarContent.dbo.CarCompanies.CarCompanyCode = TR.carVendorKey LEFT OUTER JOIN
                      CarContent.dbo.ThriftyLocations TL WITH (NOLOCK) ON TR.carLocationCode = LEFT(TL.ZTLocationCode, 3) AND TL.ZTAtAirport = 1 LEFT OUTER JOIN
                      CarContent.dbo.ThriftyVehicles TV WITH (NOLOCK) ON TL.ZTLocationCode = TV.ZTLOCATIONCODE AND TV.ZTVEHICLECODE = TR.carCategoryCode INNER JOIN
                      CarContent.dbo.ThriftyLocations TL_1 ON TL.ZTLocationCode = TL_1.ZTLocationCode AND TL_1.ZTAtAirport = 1 INNER JOIN
                      CarContent.dbo.DirectConnectSipCodes S WITH (NOLOCK) ON TV.ZTVEHICLECLASSSIZE = S.VehicleClassSize
                      INNER JOIN @tblTrip tt ON tt.tripKey  = TR.tripKey 
WHERE     TR.SupplierId <> 'Sabre' AND TR.carVendorKey = 'ZT'



		 SELECT Tt.tripKey as tripKey,* 
		 FROM #vw_TripCarResponseDetails TD  
		 --INNER JOIN dbo.Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey    and   T.tripStatusKey <>17   
		 Inner join @tblTrip tt ON tt.tripKey  = Td.tripKey       and   Tt.statusKey  <>17            
		 Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TD.SupplierId                        
		 UNION   
		 SELECT Tt.tripKey as tripKey,* 
		 FROM #vw_TripCarResponseDetails TD  
		 --INNER JOIN dbo.Trip T WITH (NOLOCK) ON TD.tripguidkey = T.tripPurchasedKey    and   T.tripStatusKey <>17   
		 Inner join @tblTrip tt ON td.tripguidkey = tt.tripPurchasedKey   and   Tt.StatusKey <>17       
		 Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TD.SupplierId                        
		 ORDER BY tT.tripKey                

		 --SELECT T.tripKey as tripKey,* 
		 --FROM vw_TripCarResponseDetails TD  
		 --INNER JOIN dbo.Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey    and   T.tripStatusKey <>17   
		 --Inner join @tblTrip tt ON tt.tripKey  = T.tripKey       and   T.tripStatusKey <>17            
		 --Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TD.SupplierId                        
		 --UNION   
		 --SELECT T.tripKey as tripKey,* FROM vw_TripCarResponseDetails TD  
		 --INNER JOIN dbo.Trip T WITH (NOLOCK) ON TD.tripguidkey = T.tripPurchasedKey    and   T.tripStatusKey <>17   
		 --Inner join @tblTrip tt ON tt.tripKey  = T.tripKey            and   T.tripStatusKey <>17       
		 --Inner Join vault.dbo.GDSSourceLookup GL WITH(NOLOCK) On GL.GDSName = TD.SupplierId                        
		 --ORDER BY T.tripKey                


--------------------------- ADDED BY GOPAL TO AVOID USING VIEW - END -------------------------------------------------
		   
		                    
--SELECT '7', GETDATE() 
	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'7','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        
                 
		select TAVP.*, TPI.PassengerFirstName,TPI.PassengerLastName, TPI.PassengerLocale,TPI.PassengerEmailID            
		from TripPassengerInfo TPI   WITH(NOLOCK)                       
		  INNER JOIN  TripPassengerAirVendorPreference TAVP WITH(NOLOCK) ON TPI.TripKey = TAVP.TripKey                        
		  Inner join @tblTrip tt on tt.tripKey = TPI.tripKey                          
		  WHERE    TPI.Active = 1 and TAVP.Active = 1                         
		  order by TPI.TripKey                        
		                        
--SELECT '8', GETDATE() 
	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'8','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        

		SELECT GeneratedType ,TPR.TripKey ,TPR.RemarksDesc,RemarkFieldName,RemarkFieldValue   
		FROM TripPNRRemarks TPR WITH(NOLOCK)                        
		INNER JOIN @tblTrip tt on TPR.tripKey = tt.tripKey                         
		WHERE TPR.Active= 1  and (tt.statusKey != 5)  
		   --AND DATEDIFF( DAY  ,CreatedOn, GETDATE())<=1        
		                        
		SELECT TOP 1                      
		  ISNULL(ReasonDescription,'') as ReasonDescription, ReasonCode, TripKey                       
		FROM                       
		  TripPolicyException                      
		WHERE                       
		  TripKey = @tripID                   
		                  
		                  
		select distinct TAVP.AirsegmentKey,                   
		                  
		TAVP.PassengerKey,                  
		TAVP.OriginAirportCode,                  
		TAVP.TicketDelivery,                  
		TAVP.AirSeatingType,                  
		TAVP.AirRowType,                  
		TAVP.AirMealType,                  
		TAVP.AirSpecialSevicesType,                  
		TAVP.Active,                  
		TAVP.AirsegmentKey                  
		 , TPI.PassengerFirstName,TPI.PassengerLastName, TPI.PassengerLocale,TPI.PassengerEmailID ,TPI.tripKey,TPI.TripPassengerInfoKey  from TripPassengerInfo TPI WITH(NOLOCK)                        
		  INNER JOIN  TripPassengerAirPreference  TAVP WITH(NOLOCK) ON TPI.TripKey = TAVP.TripKey                        
		  Inner join @tblTrip tt on tt.tripKey = TPI.tripKey                          
		  WHERE    TPI.Active = 1 and TAVP.Active = 1     
		                  
		                  
--SELECT '9', GETDATE() 
	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'9','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        
		                  
		            
		select TCVP.* from TripPassengerInfo TPI   WITH(NOLOCK)                  
		  INNER JOIN  TripPassengerUDIDInfo TCVP WITH(NOLOCK) ON TCVP.TripKey = TPI.TripKey                       
		   Inner join @tblTrip tt   on tt.tripKey = TPI.tripKey                  
		  WHERE   TCVP.Active=1                  
		  order by TPI.TripKey                    
		                  
		Select * from vw_TripCruiseResponse cruise  WITH(NOLOCK)              
		 inner join trip t WITH(NOLOCK) on cruise.tripGuidkey =t.tripPurchasedKey   and   T.tripStatusKey <>17                          
		 Inner join @tblTrip tt on tt.tripKey = t.tripKey       and   T.tripStatusKey <>17                      
			Order by t.tripKey                 
		                   
--SELECT '10', GETDATE() 
	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'10','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        

			/***tripairleg pax info****/            
		                
		 SELECT TLP.* ,TLA.tripAirLegsKey FROM TripAirLegPassengerInfo  TLP  WITH(NOLOCK) inner join              
		 TripAirLegs  TLA WITH(NOLOCK) ON Tlp.tripAirLegKey = TLA.tripAirLegsKey inner join              
		   TripAirResponse TA  WITH(NOLOCK) ON TLA.airResponseKey= TA.airResponseKey             
		 inner join Trip T WITH(NOLOCK) ON TA.tripGUIDKey = t.tripPurchasedKey inner join @tblTrip Tbl on t.tripKey = tbl.tripKey  and   T.tripStatusKey <>17               
		 Where TLA.isDeleted = 0    
		     
			/****TRipSEGMENT pax details DETAILS***/            
		 SELECT TSP.* ,TSA.airSegmentKey FROM TripAirSegmentPassengerInfo TSP  WITH(NOLOCK) inner join              
		 TripAirSegments TSA WITH(NOLOCK) ON TSp.tripAirSegmentkey = TSA.tripAirSegmentKey inner join              
		   TripAirResponse TA  ON TSA.airResponseKey= TA.airResponseKey             
		 inner join Trip T ON TA.tripGUIDKey = t.tripPurchasedKey inner join @tblTrip Tbl on t.tripKey = tbl.tripKey    and   T.tripStatusKey <>17              
		 Where TSA.isDeleted = 0    
		            
		 /* trip hotel pax info */          
		 SELECT THP.* FROM TripHotelResponsePassengerInfo THP WITH(NOLOCK)          
		 INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON TPI.TripPassengerInfoKey = THP.TripPassengerInfoKey          
		 INNER JOIN TripHotelResponse TH WITH(NOLOCK) ON TH.hotelResponseKey = THP.hotelResponseKey          
		 INNER JOIN Trip T WITH(NOLOCK) ON TH.tripGUIDKey = T.tripPurchasedKey  and   T.tripStatusKey <>17              
		 INNER JOIN @tblTrip Tbl on T.tripKey = tbl.tripKey    and   T.tripStatusKey <>17             
		           
--SELECT '11', GETDATE() 
	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'11','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        


		 SELECT TT.tripKey, friendEmailAddress FROM TripConfirmationFriendEmail TCFE WITH(NOLOCK)          
		 INNER JOIN @tblTrip TT ON TCFE.tripKey = TT.tripKey          
		           
		  /* Trip Activity Details */          
		  SELECT       
		  TAR.ActivityResponseKey,      
		  ISNULL(ConfirmationNumber, '')as ConfirmationNumber,      
		  ISNULL(RecordLocator, '') as RecordLocator,             
		  ISNULL(ActivityType, '') as ActivityType,       
		  ISNULL(ActivityTitle, '') as ActivityTitle,      
		  ISNULL(ActivityText, '') as ActivityText,             
		  ActivityDate,       
		  ISNULL(VoucherURL, '') as VoucherURL,      
		  ISNULL(CancellationFormURL, '') as CancellationFormURL,       
		  NoOfAdult,            
		  NoOfChild,      
		  NoOfYouth,      
		  NoOfInfant,      
		  NoOfSenior,      
		  TotalPrice,      
		  ISNULL(Link, '') as Link,     
		  TAR.ActivityCode,    
		  TAR.OptionCode,    
		  AL.City, AL.IATACode        
		 FROM  TripActivityResponse  TAR WITH(NOLOCK)     
		 INNER JOIN Activity..ActivityLookUp AC WITH(NOLOCK) ON TAR.ActivityCode = AC.Code          
		 INNER JOIN Activity.dbo.ActivityLocations AL WITH(NOLOCK) ON AC.Id = AL.ActivityId          
		 INNER JOIN @tblTrip TT ON TAR.tripKey = TT.tripKey AND ISNULL(TAR.isDeleted,0) = 0      
		           
		 /* Trip Insurance Details */          
		 SELECT *           
		 FROM [TripPurchasedInsurance] TPI WITH(NOLOCK)          
		 INNER JOIN @tblTrip TT ON TPI.tripKey = TT.tripKey  
		 AND TPI.isDeleted = 0  AND ISNULL(TPI.isDeleted,0) = 0        
		 
		 /* Trip Rail Details */
		 Select * from TripRailResponse rail  WITH(NOLOCK)              
		 inner join trip t WITH(NOLOCK) on rail.TripGUIDKey =t.tripPurchasedKey   and   T.tripStatusKey <>17                          
		 Inner join @tblTrip tt on tt.tripKey = t.tripKey  and   T.tripStatusKey <>17       
		 AND ISNULL(rail.isDeleted,0) = 0                     
		 Order by t.tripKey   

--SELECT '12', GETDATE() 
	INSERT INTO @TimeStampLog (SPName, Steps,StepsDesc, LastDateTime, CurrentDateTime, InMillisecond) 
	Values (@LogSPName,'12','1',@LogLastDateTime,GETDATE(),DATEDIFF (MS,@LogLastDateTime,GETDATE()))
	SET @LogLastDateTime = GETDATE();		                        


	/* Start: Logging - Insert into main log table */
	INSERT INTO Log.dbo.speedTest (SPName, Steps, StepsDesc, LastDateTime, CurrentDateTime, InMillisecond, ExecutedOn, InSeconds )
	SELECT	 SPName
			--,@LogExecutedOn
			,Steps
			,StepsDesc
			,LastDateTime
			,CurrentDateTime
			,InMillisecond
			, @LogLastDateTime
			,InMillisecond/1000  
	FROM	 @TimeStampLog

	DROP TABLE #vw_TripCarResponseDetails 
		
		END            
GO
