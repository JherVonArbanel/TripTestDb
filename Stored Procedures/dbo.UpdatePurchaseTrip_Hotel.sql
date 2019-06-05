SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdatePurchaseTrip_Hotel] 
(
	 @xml XML
	,@IsHotelInsert bit
	,@IsHotelCancel bit
	,@TripKey int
	,@TripPassenger SavePurchaseTrip_TripPassenger Readonly
)
AS
BEGIN

	DECLARE @XmlDocumentHandle int 
	EXEC sp_xml_preparedocument @XmlDocumentHandle OUTPUT, @Xml
	
	
	IF (@IsHotelInsert = 0 and @IsHotelCancel = 0)
	BEGIN

	Declare @HotelResponseKey uniqueidentifier 
		
	select @HotelResponseKey = hotelResponseKey from trip..TripHotelResponse where tripGUIDKey in( select tripPurchasedKey from trip..Trip where tripkey = @TripKey )

	UPDATE	[TripHotelResponse] 
	SET		InvoiceNumber =XML_DATA.InvoiceNumber
		   ,RPH=XML_DATA.RPH 
	FROM OPENXML (@XmlDocumentHandle, '/Hotel/TripHotelResponse')  
	WITH (	InvoiceNumber					VARCHAR(20)			'(./InvoiceNumber/text())[1]'
			,RPH							VARCHAR(2)			'(./RPH/text())[1]'
		  ) XML_DATA
	WHERE hotelResponseKey =@HotelResponseKey
		
	END
	ELSE IF (@IsHotelInsert = 1 )
	BEGIN
		DECLARE @TripPurchaseKey UNIQUEIDENTIFIER= NEWID()
		EXEC [dbo].[SavePurchaseTrip_TravelComponent_Hotel_Insert] @xml, @TripPurchaseKey , @TripKey, @TripPassenger
	END
	EXEC sp_xml_removedocument @XmlDocumentHandle 
END
GO
