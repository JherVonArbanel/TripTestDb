SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdatePurchaseTrip_Car] 
(
	 @xml XML
	,@IsCarInsert bit
	,@IsCarCancel bit
	,@TripKey int
	,@TripPassenger SavePurchaseTrip_TripPassenger Readonly
)
AS
BEGIN

	DECLARE @XmlDocumentHandle int 
	EXEC sp_xml_preparedocument @XmlDocumentHandle OUTPUT, @Xml
	
	IF (@IsCarInsert = 0 and @IsCarCancel = 0)
	BEGIN
	Declare @CarResponseKey uniqueidentifier 
		
	select @CarResponseKey = carResponseKey from trip..TripCarResponse where tripGUIDKey in( select tripPurchasedKey from trip..Trip where tripkey = @TripKey )

		UPDATE	[TripCarResponse] 
		SET		 InvoiceNumber = XML_DATA.InvoiceNumber
				,MileageAllowance=XML_DATA.MileageAllowance
				,RPH=XML_DATA.RPH
				,carDropOffLocationCode = XML_DATA.carDropOffLocationCode
				,carDropOffLocationCategoryCode = XML_DATA.carDropOffLocationCategoryCode 
		FROM OPENXML (@XmlDocumentHandle, '/Car/TripCarResponse')  
		WITH (	 InvoiceNumber						VARCHAR(20)				'(./InvoiceNumber/text())[1]'
				,MileageAllowance					VARCHAR(10)				'(./MileageAllowance/text())[1]'
				,RPH								VARCHAR(2)				'(./RPH/text())[1]'
				,carDropOffLocationCode				VARCHAR(50)				'(./carDropOffLocationCode/text())[1]'
				,carDropOffLocationCategoryCode		VARCHAR(50)				'(./carDropOffLocationCategoryCode/text())[1]'
			  ) XML_DATA
		--ON CR.carResponseKey=XML_DATA.carResponseKey
		WHERE carResponseKey = @CarResponseKey
	
	
	END
	ELSE IF (@IsCarInsert = 1 )
	BEGIN
		DECLARE @TripPurchaseKey UNIQUEIDENTIFIER= NEWID()
		EXEC [dbo].[SavePurchaseTrip_TravelComponent_CAR_Insert] @xml, @TripPurchaseKey , @TripKey, @TripPassenger
	END 
	EXEC sp_xml_removedocument @XmlDocumentHandle 
END
GO
