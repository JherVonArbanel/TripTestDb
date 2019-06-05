SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdatePurchaseTrip_Air] 
(
	  @xml XML
	 ,@IsAirInsert bit
	 ,@IsAirCancel bit
	 ,@TripKey int
	 ,@TripPassenger SavePurchaseTrip_TripPassenger Readonly
)
AS
BEGIN

	DECLARE @XmlDocumentHandle int 
	EXEC sp_xml_preparedocument @XmlDocumentHandle OUTPUT, @Xml	

	IF (@IsAirInsert = 0 and @IsAirCancel = 0)
	BEGIN

	Declare @airResponseKey uniqueidentifier 
		
	select @airResponseKey = airresponsekey from trip..TripAirResponse where tripGUIDKey in( select tripPurchasedKey from trip..Trip where tripkey = @TripKey )

	
	-- Insert TripAirSegmentOptionalServices
	--INSERT INTO  TripAirSegmentOptionalServices 
	--(	
	--		 tripKey
	--		,serviceStatus
	--		,airSegmentKey
	--		,description
	--		,descriptionDetail
	--		,icon,subcode
	--		,serviceAmount
	--		,method
	--		,serviceType
	--		,ReasonCode
	--		,type
	--		,bookingInstructions
	--		,serviceCode
	--		,attributes
	--)
	--SELECT	tripKey			
	--		,serviceStatus
	--		,airSegmentKey
	--		,description
	--		,descriptionDetail
	--		,icon
	--		,subcode
	--		,serviceAmount
	--		,method
	--		,serviceType
	--		,ReasonCode
	--		,type
	--		,bookingInstructions
	--		,serviceCode
	--		,attributes
	--FROM OPENXML (@XmlDocumentHandle, '/SavePurchasedTrip/SaveTrip/Trip')  
	--WITH (	 tripKey				INT '(./tripKey/text())[1]'
	--		,serviceStatus			VARCHAR(100)	'(./serviceStatus/text())[1]'
	--		,airSegmentKey			VARCHAR(MAX)	'(./airSegmentKey/text())[1]'
	--		,description			VARCHAR(MAX)	'(./description/text())[1]'
	--		,descriptionDetail		VARCHAR(MAX)	'(./descriptionDetail/text())[1]'
	--		,icon					VARCHAR(50)		'(./icon/text())[1]'
	--		,subcode				VARCHAR(50)		'(./subcode/text())[1]'
	--		,serviceAmount			FLOAT			'(./serviceAmount/text())[1]'
	--		,method					VARCHAR(10)		'(./method/text())[1]'
	--		,serviceType			VARCHAR(50)		'(./serviceType/text())[1]'
	--		,ReasonCode				VARCHAR(50)		'(./ReasonCode/text())[1]'
	--		,type					VARCHAR(50)		'(./type/text())[1]'
	--		,bookingInstructions	VARCHAR(200)	'(./bookingInstructions/text())[1]'
	--		,serviceCode			VARCHAR(50)		'(./serviceCode/text())[1]'
	--		,attributes				VARCHAR(500)	'(./attributes/text())[1]'
	--	  )  
	
	-- Insert TripAirPrices
	INSERT INTO [TripAirPrices] 
	(
			 [tripAdultBase] 
			,[tripAdultTax] 
			,[tripSeniorBase] 
			,[tripSeniorTax] 
			,[tripYouthBase] 
			,[tripYouthTax] 
			,[tripChildBase]  
			,[tripChildTax] 
			,[tripInfantBase] 
			,[tripInfantTax]
			,[creationDate]
			,[tripInfantWithSeatBase]
			,[tripInfantWithSeatTax]
	) 
	SELECT	 [tripAdultBase] 
			,[tripAdultTax] 
			,[tripSeniorBase] 
			,[tripSeniorTax] 
			,[tripYouthBase] 
			,[tripYouthTax] 
			,[tripChildBase]  
			,[tripChildTax] 
			,[tripInfantBase] 
			,[tripInfantTax]
			,[creationDate]
			,[tripInfantWithSeatBase]
			,[tripInfantWithSeatTax]
	FROM OPENXML (@XmlDocumentHandle, '/Air/TripAirPrices/TripAirPrice')  
	WITH (	 tripAdultBase			FLOAT '(./tripAdultBase/text())[1]'
			,tripAdultTax			FLOAT '(./tripAdultTax/text())[1]'
			,tripSeniorBase			FLOAT '(./tripSeniorBase/text())[1]'
			,tripSeniorTax			FLOAT '(./tripSeniorTax/text())[1]'
			,tripYouthBase			FLOAT '(./tripYouthBase/text())[1]'
			,tripYouthTax			FLOAT '(./tripYouthTax/text())[1]'
			,tripChildBase			FLOAT '(./tripChildBase/text())[1]'
			,tripChildTax			FLOAT '(./tripChildTax/text())[1]'
			,tripInfantBase			FLOAT '(./tripInfantBase/text())[1]'
			,tripInfantTax			FLOAT '(./tripInfantTax/text())[1]'
			,creationDate			FLOAT '(./creationDate/text())[1]'
			,tripInfantWithSeatBase	FLOAT '(./tripInfantWithSeatBase/text())[1]'
			,tripInfantWithSeatTax	FLOAT '(./tripInfantWithSeatTax/text())[1]'
			,tripCategory			VARCHAR(10) '(./tripCategory/text())[1]'
		 )  
	WHERE tripCategory='Actual'
	
	DECLARE @tripAirPriceKey INT
	SELECT @tripAirPriceKey=Scope_Identity()
	

	DECLARE @xmlTripAirLegs xml
	SELECT @xmlTripAirLegs = @xml.query('/Air/TripAirResponse/TripAirLegs')	
	EXEC [dbo].[SavePurchaseTrip_TripAirLegs_Insert] @xmlTripAirLegs, @airResponseKey, @TripPassenger

		
	UPDATE  [TripAirResponse] 
	SET		 actualAirPrice=actualAirPrice_xml
			,actualAirTax=actualAirTax_xml
			,CurrencyCodeKey=CurrencyCodeKey_xml
			,bookingCharges=bookingcharges_xml
			,actualAirPriceBreakupKey=@tripAirPriceKey
			,redeemPoints=redeemPoints_xml
			,redeemAuthNumber=redeemAuthNumber_xml
	FROM OPENXML (@XmlDocumentHandle, '/Air/TripAirResponse')  
	WITH (	 actualAirPrice_xml				FLOAT				'(./actualAirPrice/text())[1]'
			,actualAirTax_xml				FLOAT				'(./actualAirTax/text())[1]'
			,CurrencyCodeKey_xml			NVARCHAR(20)		'(./CurrencyCodeKey/text())[1]'
			,bookingcharges_xml				FLOAT				'(./bookingcharges/text())[1]'
			,redeemPoints_xml				INT					'(./redeemPoints/text())[1]'
			,redeemAuthNumber_xml			NVARCHAR(200)		'(./redeemAuthNumber/text())[1]'
		  ) 
	WHERE airResponseKey = @airResponseKey
	

	INSERT INTO [tripAirResponseTax]
	(
			 [airResponseKey]  
			,[amount]
			,[designator]   
			,[nature]  
			,[description]
			,[tripAirPriceKey]
	)
	SELECT	 @airResponseKey
			,amount
			,designator
			,nature
			,description
			,@tripAirPriceKey
	FROM OPENXML (@XmlDocumentHandle, '/Air/TripAirPrices/TripAirPrice/tripAirResponseTaxes/tripAirResponseTax')  
	WITH (	 airResponseKey	UNIQUEIDENTIFIER	'(./airResponseKey/text())[1]'
			,amount			FLOAT				'(./amount/text())[1]'
			,designator		NVARCHAR(100)		'(./designator/text())[1]'
			,nature			NVARCHAR(100)		'(./nature/text())[1]'
			,description	NVARCHAR(100)		'(./description/text())[1]'
		  )

	END
	ELSE IF (@IsAirInsert = 1 )
	BEGIN		
		DECLARE @TripPurchaseKey UNIQUEIDENTIFIER= NEWID()
		EXEC [dbo].[SavePurchaseTrip_TravelComponent_Air_Insert] @xml, @TripPurchaseKey , @TripKey, @TripPassenger
	END		 
	
	EXEC sp_xml_removedocument @XmlDocumentHandle 
END
GO
