SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


    --exec airResponse_GET_ByID 'f66766d7-13c3-43bd-bdf1-e9e60a32884a','58f5529c-9c4d-4978-b3a1-59c013c30d52','1' 
    
    
CREATE PROCEDURE [dbo].[airResponse_GET_ByID_tmp]          
(          
--DECLARE
 @airResponseKey UNIQUEIDENTIFIER,          
 @airResponseMultiBrandID UNIQUEIDENTIFIER = N'00000000-0000-0000-0000-000000000000' ,         
 @withSegment INT          
) AS          
BEGIN          

--SELECT @airResponseKey='90115968-51B7-4694-AE37-1AC8BC1B7AC1',@airResponseMultiBrandID= '00000000-0000-0000-0000-000000000000'
--	,@withSegment = 0
          
 IF @withSegment <> 1           
 BEGIN          
		IF (@airResponseMultiBrandID = N'00000000-0000-0000-0000-000000000000')	
		BEGIN
		
			SELECT airResponseKey, Resp.airSubRequestKey, airPriceBase, airPriceTax, gdsSourceKey, refundable, airClass
			, priceClassCommentsSuperSaver, priceClassCommentsEconSaver, priceClassCommentsFirstFlex, priceClassCommentsCorporate
			, priceClassCommentsEconFlex, priceClassCommentsEconUpgrade, airSuperSaverPrice, airEconSaverPrice, airFirstFlexPrice
			, airCorporatePrice, airEconFlexPrice, airEconUpgradePrice, airClassSuperSaver, airClassEconSaver, airClassFirstFlex
			, airClassCorporate, airClassEconFlex, airClassEconUpgrade, airSuperSaverSeatRemaining, airEconSaverSeatRemaining
			, airFirstFlexSeatRemaining, airCorporateSeatRemaining, airEconFlexSeatRemaining, airEconUpgradeSeatRemaining
			, airSuperSaverFareReferenceKey, airEconSaverFareReferenceKey, airFirstFlexFareReferenceKey, airCorporateFareReferenceKey
			, airEconFlexFareReferenceKey, airEconUpgradeFareReferenceKey, airPriceClassSelected, airSuperSaverTax, airEconSaverTax
			, airEconFlexTax, airCorporateTax, airEconUpgradetax, airFirstFlexTax, airSuperSaverFareBasisCode, airEconSaverFareBasisCode
			, airFirstFlexFareBasisCode, airCorporateFareBasisCode, airEconFlexFareBasisCode, airEconUpgradeFareBasisCode, isBrandedFare
			, cabinClass, fareType, isGeneratedBundle, ValidatingCarrier, contractCode, airPriceBaseSenior, airPriceTaxSenior
			, airPriceBaseChildren, airPriceTaxChildren, airPriceBaseInfant, airPriceTaxInfant, airPriceBaseDisplay, airPriceTaxDisplay
			, airPriceBaseTotal, airPriceTaxTotal, airPriceBaseYouth, airPriceTaxYouth, airCurrencyCode, airResponseId
			, airPriceBaseInfantWithSeat, airPriceTaxInfantWithSeat, agentwareQueryID, agentwareItineraryID
			,CONVERT(bit, Case WHEN  SubRq.groupKey = 2 THEN 1 ELSE 0 END ) AS IsPublishedCallResponse ,Resp.Points,Resp.ticketDesignator,Resp.awardCode,Resp.ITAQueryId,Resp.ITAItineraryId      
			FROM AirResponse  Resp  WITH (NOLOCK)   
			INNER JOIN AirSubRequest SubRq WITH (NOLOCK)  on     Resp.airSubRequestKey =subrq.airSubRequestKey    
			WHERE airResponseKey = @airResponseKey          
		END
		ELSE 
		BEGIN
			SELECT ARMB.airResponseKey, ARMB.airSubRequestKey, ARMB.airPriceBase, ARMB.airPriceTax, ARMB.gdsSourceKey, ARMB.refundable
			, ARMB.airClass, priceClassCommentsSuperSaver, priceClassCommentsEconSaver, priceClassCommentsFirstFlex
			, priceClassCommentsCorporate, priceClassCommentsEconFlex, priceClassCommentsEconUpgrade, airSuperSaverPrice
			, airEconSaverPrice, airFirstFlexPrice, airCorporatePrice, airEconFlexPrice, airEconUpgradePrice, airClassSuperSaver
			, airClassEconSaver, airClassFirstFlex, airClassCorporate, airClassEconFlex, airClassEconUpgrade, airSuperSaverSeatRemaining
			, airEconSaverSeatRemaining, airFirstFlexSeatRemaining, airCorporateSeatRemaining, airEconFlexSeatRemaining
			, airEconUpgradeSeatRemaining, airSuperSaverFareReferenceKey, airEconSaverFareReferenceKey, airFirstFlexFareReferenceKey
			, airCorporateFareReferenceKey, airEconFlexFareReferenceKey, airEconUpgradeFareReferenceKey, Resp.airPriceClassSelected
			, airSuperSaverTax, airEconSaverTax, airEconFlexTax, airCorporateTax, airEconUpgradetax, airFirstFlexTax
			, airSuperSaverFareBasisCode, airEconSaverFareBasisCode, airFirstFlexFareBasisCode, airCorporateFareBasisCode
			, airEconFlexFareBasisCode, airEconUpgradeFareBasisCode, isBrandedFare, ARMB.cabinClass, ARMB.fareType, ARMB.isGeneratedBundle
			, ARMB.ValidatingCarrier, ARMB.contractCode, ARMB.airPriceBaseSenior, ARMB.airPriceTaxSenior, ARMB.airPriceBaseChildren
			, ARMB.airPriceTaxChildren, ARMB.airPriceBaseInfant, ARMB.airPriceTaxInfant, ARMB.airPriceBaseDisplay, ARMB.airPriceTaxDisplay
			, ARMB.airPriceBaseTotal, ARMB.airPriceTaxTotal, ARMB.airPriceBaseYouth, ARMB.airPriceTaxYouth, ARMB.airCurrencyCode
			, airResponseId, ARMB.airPriceBaseInfantWithSeat, ARMB.airPriceTaxInfantWithSeat, agentwareQueryID, agentwareItineraryID
			,CONVERT(bit, Case WHEN  SubRq.groupKey = 2 THEN 1 ELSE 0 END ) AS IsPublishedCallResponse ,ARMB.Points,ARMB.ticketDesignator,ARMB.awardCode,Resp.ITAQueryId,ARMB.ITAItineraryId     
			FROM AirResponse  Resp  WITH (NOLOCK)   
			INNER JOIN AirSubRequest SubRq WITH (NOLOCK)  on     Resp.airSubRequestKey =subrq.airSubRequestKey    
			INNER JOIN AirResponseMultiBrand ARMB WITH (NOLOCK) on ARMB.airResponseKey = Resp.airResponseKey  
			WHERE ARMB.airResponseMultiBrandKey = @airResponseMultiBrandID 
		END
 END          
 ELSE          
 BEGIN	
	IF (@airResponseMultiBrandID = N'00000000-0000-0000-0000-000000000000')	
	BEGIN
		SELECT           
		airSegmentKey,          
		airResponseKey,          
		airLegNumber,          
		airSegmentMarketingAirlineCode,          
		airSegmentOperatingAirlineCode,          
		airSegmentResBookDesigCode,          
		airSegmentFlightNumber,          
		airSegmentDuration,          
		airSegmentEquipment,          
		airSegmentMiles,           
		airSegmentDepartureDate,           
		airSegmentArrivalDate,          
		airSegmentDepartureAirport,          
		DepartureAirport.AirportName AS DepartureAirportName,           
		DepartureAirport.CityName AS DepartureAirportCityName,          
		DepartureAirport.StateCode AS DepartureAirportStateCode,          
		DepartureAirport.CountryCode AS DepartureAirportCountryCode,           
		airSegmentArrivalAirport,          
		ArrivalAirport.AirportName AS ArrivalAirportName,          
		ArrivalAirport.CityName AS ArrivalAirportCityName,          
		ArrivalAirport.StateCode AS ArrivalAirportStateCode,          
		ArrivalAirport.CountryCode AS ArrivalAirportCountryCode,          
		airSegmentDepartureOffset,          
		airSegmentArrivalOffset,          
		airSegmentMarriageGrp,          
		airSegmentSeatRemaining,           
		airFareBasisCode,          
		airFareReferenceKey,          
		ISNULL((DATEADD(HH, (airSegmentDepartureOffset * -1), airSegmentDepartureDate)), airSegmentDepartureDate) AS EquiairSegmentDepartureDate,     
		DepartureAirport.CityCode AS departureCityCode,     
		ArrivalAirport.CityCode AS ArrivalCityCode,     
		AVL.ShortName AS airSegmentOperatingAirlineName,     
		AVL1.ShortName AS airSegmentMarketingAirlineName,     
		airsegmentCabin ,segmentOrder , airSegmentOperatingFlightNumber,amadeusSNDIndicator     
		,AB.[airlineBaggageLink] As MarketingAirlineBaggageLink, ABO.[airlineBaggageLink] As OperatingAirlineBaggageLink,    
		airSegmentOperatingAirlineCompanyShortName ,CD.CountryName AS DepartureAirportCountryName, CA.CountryName AS ArrivalAirportCountryName    
		,AC.[conditionOfCarriageLink] As MarketingAirlineCarriageLink, ACO.[conditionOfCarriageLink] As OperatingAirlineCarriageLink  
		,airSuperSaverFareBasisCode
		,airEconSaverFareBasisCode
		,airFirstFlexFareBasisCode
		,airCorporateFareBasisCode
		,airEconFlexFareBasisCode
		,airEconUpgradeFareBasisCode
		,airSuperSaverFareReferenceKey
		,airEconSaverFareReferenceKey
		,airFirstFlexFareReferenceKey
		,airCorporateFareReferenceKey
		,airEconFlexFareReferenceKey
		,airEconUpgradeFareReferenceKey
		,airSegmentClassSuperSaver 
		,airSegmentClassEconSaver 
		,airSegmentClassFirstFlex 
		,airSegmentClassEconFlex
		, airsegmentPricingKey
		--airSegmentFareCategory
		, airSegmentBrandName	 
		FROM AirSegments   WITH (NOLOCK)   
		LEFT OUTER JOIN AirportLookup DepartureAirport WITH (NOLOCK)  ON airSegmentDepartureAirport = DepartureAirport.AirportCode     
		LEFT OUTER JOIN AirportLookup ArrivalAirport WITH (NOLOCK)  ON airSegmentArrivalAirport = ArrivalAirport.AirportCode     
		LEFT OUTER JOIN AirVendorLookup AVL WITH (NOLOCK) ON AVL.AirlineCode = airSegmentOperatingAirlineCode     
		LEFT OUTER JOIN AirVendorLookup AVL1 WITH (NOLOCK)  ON AVL1.AirlineCode = airSegmentMarketingAirlineCode     
		LEFT OUTER JOIN [AirlineBaggageLink] AB WITH (NOLOCK)  ON AB.AirlineCode = airSegmentMarketingAirlineCode    
		LEFT OUTER JOIN [AirlineBaggageLink] ABO WITH (NOLOCK) ON ABO.AirlineCode = airSegmentOperatingAirlineCode    
		LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)  ON departureAirport.CountryCode = CD.CountryCode    
		LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)  ON arrivalAirport.CountryCode = CA.CountryCode    
		LEFT OUTER JOIN [AirlineCarriageLink] AC WITH (NOLOCK)  ON AC.airline = airSegmentMarketingAirlineCode    
		LEFT OUTER JOIN [AirlineCarriageLink] ACO WITH (NOLOCK)  ON ACO.airline = airSegmentOperatingAirlineCode    
		WHERE airResponseKey=@airResponseKey     
		ORDER BY  airLegNumber ASC , EquiairSegmentDepartureDate ASC,segmentOrder ASC    
	END
	ELSE
	BEGIN
		SELECT           
		ASMB.airSegmentKey,          
		ASMB.airResponseKey,          
		ASMB.airLegNumber,          
		airSegmentMarketingAirlineCode,          
		airSegmentOperatingAirlineCode,          
		ASMB.airSegmentResBookDesigCode,          
		airSegmentFlightNumber,          
		airSegmentDuration,          
		airSegmentEquipment,          
		airSegmentMiles,           
		airSegmentDepartureDate,           
		airSegmentArrivalDate,          
		airSegmentDepartureAirport,          
		DepartureAirport.AirportName AS DepartureAirportName,           
		DepartureAirport.CityName AS DepartureAirportCityName,          
		DepartureAirport.StateCode AS DepartureAirportStateCode,          
		DepartureAirport.CountryCode AS DepartureAirportCountryCode,           
		airSegmentArrivalAirport,          
		ArrivalAirport.AirportName AS ArrivalAirportName,          
		ArrivalAirport.CityName AS ArrivalAirportCityName,          
		ArrivalAirport.StateCode AS ArrivalAirportStateCode,          
		ArrivalAirport.CountryCode AS ArrivalAirportCountryCode,          
		airSegmentDepartureOffset,          
		airSegmentArrivalOffset,          
		airSegmentMarriageGrp,          
		ASMB.airSegmentSeatRemaining,           
		ASMB.airSegmentFareBasisCode as airFareBasisCode,          
		airFareReferenceKey,          
		ISNULL((DATEADD(HH, (airSegmentDepartureOffset * -1), airSegmentDepartureDate)), airSegmentDepartureDate) AS EquiairSegmentDepartureDate,     
		DepartureAirport.CityCode AS departureCityCode,     
		ArrivalAirport.CityCode AS ArrivalCityCode,     
		AVL.ShortName AS airSegmentOperatingAirlineName,     
		AVL1.ShortName AS airSegmentMarketingAirlineName,     
		ASMB.airsegmentCabin ,ASMB.segmentOrder , airSegmentOperatingFlightNumber,amadeusSNDIndicator     
		,AB.[airlineBaggageLink] As MarketingAirlineBaggageLink, ABO.[airlineBaggageLink] As OperatingAirlineBaggageLink,    
		airSegmentOperatingAirlineCompanyShortName ,CD.CountryName AS DepartureAirportCountryName, CA.CountryName AS ArrivalAirportCountryName    
		,AC.[conditionOfCarriageLink] As MarketingAirlineCarriageLink, ACO.[conditionOfCarriageLink] As OperatingAirlineCarriageLink  
		,airSuperSaverFareBasisCode
		,airEconSaverFareBasisCode
		,airFirstFlexFareBasisCode
		,airCorporateFareBasisCode
		,airEconFlexFareBasisCode
		,airEconUpgradeFareBasisCode
		,airSuperSaverFareReferenceKey
		,airEconSaverFareReferenceKey
		,airFirstFlexFareReferenceKey
		,airCorporateFareReferenceKey
		,airEconFlexFareReferenceKey
		,airEconUpgradeFareReferenceKey
		,airSegmentClassSuperSaver 
		,airSegmentClassEconSaver 
		,airSegmentClassFirstFlex 
		,airSegmentClassEconFlex 
		,ASMB.airsegmentPricingKey
		--airSegmentFareCategory
		,ASMB.airSegmentBrandName
		FROM AirSegments   WITH (NOLOCK)   
		INNER JOIN AirSegmentsMultiBrand ASMB WITH (NOLOCK) on ASMB.airSegmentKey = AirSegments.airSegmentKey  		
		LEFT OUTER JOIN AirportLookup DepartureAirport WITH (NOLOCK)  ON airSegmentDepartureAirport = DepartureAirport.AirportCode     
		LEFT OUTER JOIN AirportLookup ArrivalAirport WITH (NOLOCK)  ON airSegmentArrivalAirport = ArrivalAirport.AirportCode     
		LEFT OUTER JOIN AirVendorLookup AVL WITH (NOLOCK) ON AVL.AirlineCode = airSegmentOperatingAirlineCode     
		LEFT OUTER JOIN AirVendorLookup AVL1 WITH (NOLOCK)  ON AVL1.AirlineCode = airSegmentMarketingAirlineCode     
		LEFT OUTER JOIN [AirlineBaggageLink] AB WITH (NOLOCK)  ON AB.AirlineCode = airSegmentMarketingAirlineCode    
		LEFT OUTER JOIN [AirlineBaggageLink] ABO WITH (NOLOCK) ON ABO.AirlineCode = airSegmentOperatingAirlineCode    
		LEFT OUTER JOIN Vault..CountryLookup CD  WITH (NOLOCK)  ON departureAirport.CountryCode = CD.CountryCode    
		LEFT OUTER JOIN Vault..CountryLookup CA WITH (NOLOCK)  ON arrivalAirport.CountryCode = CA.CountryCode    
		LEFT OUTER JOIN [AirlineCarriageLink] AC WITH (NOLOCK)  ON AC.airline = airSegmentMarketingAirlineCode    
		LEFT OUTER JOIN [AirlineCarriageLink] ACO WITH (NOLOCK)  ON ACO.airline = airSegmentOperatingAirlineCode    
		WHERE ASMB.airResponseMultiBrandKey = @airResponseMultiBrandID
		ORDER BY  ASMB.airLegNumber ASC , EquiairSegmentDepartureDate ASC,ASMB.segmentOrder ASC   
	END
 END     
END     

GO
