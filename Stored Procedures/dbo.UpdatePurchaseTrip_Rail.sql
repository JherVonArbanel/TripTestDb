SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdatePurchaseTrip_Rail] 
(
	 @xml XML
	,@IsRailInsert bit
	,@IsRailCancel bit
)
AS
BEGIN

	DECLARE @XmlDocumentHandle int 
	EXEC sp_xml_preparedocument @XmlDocumentHandle OUTPUT, @Xml
	
	IF @IsRailInsert=0
	BEGIN
	
	
	--Update [TripRailResponse] set InvoiceNumber = @InvoiceNumber,RPH=@RPH where railResponseKey = @railResponseKey
	
	INSERT INTO TripRailResponse
	(
			 RailResponseKey
			,tripGUIDKey
			,tripKey
			,VendorCode
			,supplierId
			,Type
			,OriginLocationCode
			,DestinationLocationCode
			,TrainNumber
			,BaseFare
			,Taxes
			,Commission
			,TotalPrice
			,DepartureDate
			,ArrivalDate
			,DepartureTime
			,ArrivalTime
			,ConfirmationNumber
			,InvoiceNumber
			,RecordLocator
			,status
			,LinkCode
			,Text
			,NoOfAdult
			,TripPassengerInfoKey
			,RPH
			,creationDate
	)
	SELECT	 RailResponseKey
			,tripGUIDKey
			,tripKey
			,VendorCode
			,supplierId
			,Type
			,OriginLocationCode
			,DestinationLocationCode
			,TrainNumber
			,BaseFare
			,Taxes
			,Commission
			,TotalPrice
			,DepartureDate
			,ArrivalDate
			,DepartureTime
			,ArrivalTime
			,ConfirmationNumber
			,InvoiceNumber
			,RecordLocator
			,status
			,LinkCode
			,Text
			,NoOfAdult
			,TripPassengerInfoKey
			,RPH
			,creationDate
	FROM OPENXML (@XmlDocumentHandle, '/UpdatePurchasedTrip/TripComponents/Rail')  
	WITH (		
			 RailResponseKey			uniqueidentifier	'(./RailResponseKey/text())[1]'
			,tripGUIDKey				uniqueidentifier	'(./tripGUIDKey/text())[1]'
			,tripKey					int					'(./tripKey/text())[1]'
			,VendorCode					varchar(10)			'(./VendorCode/text())[1]'
			,supplierId					varchar(50)			'(./supplierId/text())[1]'
			,Type						varchar(20)			'(./Type/text())[1]'
			,OriginLocationCode			varchar(50)			'(./OriginLocationCode/text())[1]'
			,DestinationLocationCode	varchar(50)			'(./DestinationLocationCode/text())[1]'
			,TrainNumber				varchar(100)		'(./TrainNumber/text())[1]'
			,BaseFare					DECIMAL(10,2)		'(./BaseFare/text())[1]'
			,Taxes						DECIMAL(10,2)		'(./Taxes/text())[1]'
			,Commission					decimal(10,2)		'(./Commission/text())[1]'					
			,TotalPrice					FLOAT				'(./TotalPrice/text())[1]'
			,DepartureDate				DATETIME			'(./DepartureDate/text())[1]'
			,ArrivalDate				DATETIME			'(./ArrivalDate/text())[1]'
			,DepartureTime				DATETIME			'(./DepartureTime/text())[1]'
			,ArrivalTime				DATETIME			'(./ArrivalTime/text())[1]'
			,ConfirmationNumber			VARCHAR(100)		'(./ConfirmationNumber/text())[1]'
			,InvoiceNumber				VARCHAR(20)			'(./InvoiceNumber/text())[1]'
			,RecordLocator				VARCHAR(100)		'(./RecordLocator/text())[1]'
			,status						VARCHAR(10)			'(./status/text())[1]'
			,LinkCode					VARCHAR(10)			'(./LinkCode/text())[1]'
			,Text						VARCHAR(5000)		'(./Text/text())[1]'
			,NoOfAdult					INT					'(./NoOfAdult/text())[1]'
			,TripPassengerInfoKey		INT					'(./TripPassengerInfoKey/text())[1]'
			,RPH						VARCHAR(2)			'(./RPH/text())[1]'
			,creationDate				DATETIME			'(./creationDate/text())[1]'
		)
	
	--Update [TripRailResponse] set isDeleted = 1 where railResponseKey = @railResponseKey 
	END
	ELSE
	BEGIN
		PRINT 'Else code here'
	END	 
	EXEC sp_xml_removedocument @XmlDocumentHandle 
END
GO
