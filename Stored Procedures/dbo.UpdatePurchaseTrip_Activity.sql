SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdatePurchaseTrip_Activity] 
(
	@xml XML
)
AS
BEGIN

	DECLARE @XmlDocumentHandle int 
	EXEC sp_xml_preparedocument @XmlDocumentHandle OUTPUT, @Xml
	
	--Update [TripActivityResponse] set isDeleted = 1 where ActivityResponseKey = @ActivityResponseKey
	
	/*
	INSERT INTO TripPassengerCarVendorPreference
	(
			 TripKey
			,PassengerKey
			,Id
			,CarVendorCode
			,CarVendorName 
			,PreferenceNo
			,ProgramNumber
			,TripPassengerInfoKey
	)
	SELECT	 TripKey
			,PassengerKey
			,Id
			,CarVendorCode
			,CarVendorName 
			,PreferenceNo
			,ProgramNumber
			,TripPassengerInfoKey
	FROM OPENXML (@XmlDocumentHandle, '/SavePurchasedTrip/SaveTrip/Trip')  
	WITH (
			 TripKey				INT				'(./TripKey/text())[1]'
			,PassengerKey			INT				'(./PassengerKey/text())[1]'
			,Id						INT				'(./Id/text())[1]'
			,CarVendorCode			NVARCHAR(60)	'(./CarVendorCode/text())[1]'
			,CarVendorName			NVARCHAR(1000)	'(./CarVendorName/text())[1]'
			,PreferenceNo			NVARCHAR(100)	'(./PreferenceNo/text())[1]'
			,ProgramNumber			NVARCHAR(100)	'(./ProgramNumber/text())[1]'
			,TripPassengerInfoKey	INT				'(./TripPassengerInfoKey/text())[1]'
		 )
	*/	 
	--Update [TripCarResponse] set isDeleted = 1 where carResponseKey = @carResponseKey	 
		 
	EXEC sp_xml_removedocument @XmlDocumentHandle 
END
GO
