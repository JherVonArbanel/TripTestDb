SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <23rd Aug 17>
-- Description:	<To Insert TripPassenger>
-- =============================================
CREATE PROCEDURE [dbo].[SavePurchaseTrip_TripPassenger_Insert_20181008]
	-- Add the parameters for the stored procedure here
	@xmldata XML, @TripPurchaseKey uniqueidentifier, @tripId int
AS
BEGIN
	DEclare @CreditCardNumber NVARCHAR(MAX)
	DEclare @CreditCardNumberEncrypted VARBINARY(MAX)	
	DECLARE @output SavePurchaseTrip_TripPassenger
		
	INSERT INTO TripPassengerInfo (TripKey, TripHistoryKey, PassengerKey, PassengerTypeKey, IsPrimaryPassenger, TripRequestKey, AdditionalRequest,  
					PassengerEmailID, PassengerFirstName, PassengerLastName, PassengerLocale, PassengerTitle, PassengerGender, PassengerBirthDate, 
					TravelReferenceNo, IsExcludePricingInfo, ReimbursementAddressId)
	OUTPUT inserted.TripHistoryKey, inserted.PassengerKey, inserted.TripPassengerInfoKey INTO @output				 
	SELECT @tripId, 
	  TripPassengerInfo.value('(TripHistoryKey/text())[1]','VARCHAR(50)') AS TripHistoryKey,
	  TripPassengerInfo.value('(PassengerKey/text())[1]','int') AS PassengerKey,
	  TripPassengerInfo.value('(PassengerTypeKey/text())[1]','int') AS PassengerTypeKey,
	  TripPassengerInfo.value('(IsPrimaryPassenger/text())[1]','bit') AS IsPrimaryPassenger,
	  TripPassengerInfo.value('(TripRequestKey/text())[1]','int') AS TripRequestKey,
	  TripPassengerInfo.value('(AdditionalRequest/text())[1]','VARCHAR(3000)') AS AdditionalRequest,
	  TripPassengerInfo.value('(PassengerEmailID/text())[1]','VARCHAR(100)') AS PassengerEmailID,
	  TripPassengerInfo.value('(PassengerFirstName/text())[1]','VARCHAR(200)') AS PassengerFirstName,
	  TripPassengerInfo.value('(PassengerLastName/text())[1]','VARCHAR(200)') AS PassengerLastName,
	  TripPassengerInfo.value('(PassengerLocale/text())[1]','VARCHAR(10)') AS PassengerLocale,
	  TripPassengerInfo.value('(PassengerTitle/text())[1]','VARCHAR(200)') AS PassengerTitle,
	  TripPassengerInfo.value('(PassengerGender/text())[1]','VARCHAR(1)') AS PassengerGender,
	  (case when (charindex('-', TripPassengerInfo.value('(PassengerBirthDate/text())[1]','VARCHAR(30)')) > 0) then CONVERT(datetime, TripPassengerInfo.value('(PassengerBirthDate/text())[1]','VARCHAR(30)'), 103) else TripPassengerInfo.value('(PassengerBirthDate/text())[1]','datetime') end) AS PassengerBirthDate,
	  TripPassengerInfo.value('(TravelReferenceNo/text())[1]','VARCHAR(5)') AS TravelReferenceNo,
	  TripPassengerInfo.value('(IsExcludePricingInfo/text())[1]','bit') AS IsExcludePricingInfo,
	  TripPassengerInfo.value('(ReimbursementAddressId/text())[1]','INT') AS ReimbursementAddressId	  
	FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo')AS TEMPTABLE(TripPassengerInfo)

	
	SELECT @CreditCardNumber=TripPassengerCreditCardInfo.value('(CreditCardCVVNumber/text())[1]','NVARCHAR(MAX)')
	FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerCreditCardInfos/TripPassengerCreditCardInfo')AS TEMPTABLE(TripPassengerCreditCardInfo)
	    
    EXEC vault..[usp_GetEncryptByKey] @CreditCardNumber,@CreditCardNumberEncrypted OUTPUT


	INSERT INTO TripPassengerCreditCardInfo( TripKey, TripHistoryKey, PassengerKey, TripTypeComponent, CreditCardKey, creditCardVendorCode,
					creditCardDescription, creditCardLastFourDigit, expiryMonth, expiryYear, creditCardTypeKey, TripPassengerInfoKey, NameOnCard, 
					UsedforAir,UsedforHotel,UsedforCar,PTACode)
	SELECT @tripId, 
	  O.TripHistoryKey,
	  TripPassengerCreditCardInfo.value('(PassengerKey/text())[1]','int') AS PassengerKey,
	  TripPassengerCreditCardInfo.value('(TripTypeComponent/text())[1]','int') AS TripTypeComponent,
	  TripPassengerCreditCardInfo.value('(CreditCardKey/text())[1]','int') AS CreditCardKey,
	  TripPassengerCreditCardInfo.value('(creditCardVendorCode/text())[1]','VARCHAR(2)') AS creditCardVendorCode,
	  TripPassengerCreditCardInfo.value('(creditCardDescription/text())[1]','VARCHAR(50)') AS creditCardDescription,
	  TripPassengerCreditCardInfo.value('(creditCardLastFourDigit/text())[1]','int') AS creditCardLastFourDigit,
	  TripPassengerCreditCardInfo.value('(expiryMonth/text())[1]','int') AS expiryMonth,
	  TripPassengerCreditCardInfo.value('(expiryYear/text())[1]','int') AS expiryYear,
	  TripPassengerCreditCardInfo.value('(creditCardTypeKey/text())[1]','int') AS creditCardTypeKey,
	  O.TripPassengerInfoKey,
	  TripPassengerCreditCardInfo.value('(NameOnCard/text())[1]','VARCHAR(500)') AS NameOnCard,
	  TripPassengerCreditCardInfo.value('(UsedforAir/text())[1]','bit') AS UsedforAir,
	  TripPassengerCreditCardInfo.value('(UsedforHotel/text())[1]','bit') AS UsedforHotel,
	  TripPassengerCreditCardInfo.value('(UsedforCar/text())[1]','bit') AS UsedforCar,
	  CONVERT(NVARCHAR(MAX),  @CreditCardNumberEncrypted) AS PTACode
	FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerCreditCardInfos/TripPassengerCreditCardInfo')AS TEMPTABLE(TripPassengerCreditCardInfo)
	  inner join @output O on O.PassengerKey = TripPassengerCreditCardInfo.value('(TripPassengerInfoKey/text())[1]','int') 
	  
	INSERT INTO  TripPassengerAirPreference (TripKey, TripHistoryKey, PassengerKey, Id, OriginAirportCode, TicketDelivery, AirSeatingType, AirRowType,
					 AirMealType, AirSpecialSevicesType, TripPassengerInfoKey)
	SELECT @tripId, 
	  O.TripHistoryKey,
	  TripPassengerAirPreference.value('(PassengerKey/text())[1]','int') AS PassengerKey,
	  TripPassengerAirPreference.value('(ID/text())[1]','int') AS ID,
	  TripPassengerAirPreference.value('(OriginAirportCode/text())[1]','VARCHAR(30)') AS OriginAirportCode,
	  TripPassengerAirPreference.value('(TicketDelivery/text())[1]','VARCHAR(50)') AS TicketDelivery,
	  TripPassengerAirPreference.value('(AirSeatingType/text())[1]','int') AS AirSeatingType,
	  TripPassengerAirPreference.value('(AirRowType/text())[1]','int') AS AirRowType,
	  TripPassengerAirPreference.value('(AirMealType/text())[1]','int') AS AirMealType,
	  TripPassengerAirPreference.value('(AirSpecialSevicesType/text())[1]','int') AS AirSpecialSevicesType,
	  O.TripPassengerInfoKey	  
	FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerPreferences/TripPassengerAirPreference')AS TEMPTABLE(TripPassengerAirPreference)
	  inner join @output O on O.PassengerKey = TripPassengerAirPreference.value('(PassengerKey/text())[1]','int')				 
	
	INSERT INTO TripPassengerAirVendorPreference (TripKey, TripHistoryKey, PassengerKey, ID, AirLineCode, AirLineName, PreferenceNo, ProgramNumber,	TripPassengerInfoKey)  
	SELECT @tripId, 
	  O.TripHistoryKey,
	  TripPassengerAirVendorPreference.value('(PassengerKey/text())[1]','int') AS PassengerKey,
	  TripPassengerAirVendorPreference.value('(ID/text())[1]','int') AS ID,
	  TripPassengerAirVendorPreference.value('(AirLineCode/text())[1]','VARCHAR(30)') AS AirLineCode,
	  TripPassengerAirVendorPreference.value('(AirLineName/text())[1]','VARCHAR(50)') AS AirLineName,
	  TripPassengerAirVendorPreference.value('(PreferenceNo/text())[1]','VARCHAR(50)') AS PreferenceNo,
	  TripPassengerAirVendorPreference.value('(ProgramNumber/text())[1]','VARCHAR(50)') AS ProgramNumber,
	  O.TripPassengerInfoKey	  
	FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerPreferences/TripPassengerAirPreference/TripPassengerAirVendorPreferences/TripPassengerAirVendorPreference')AS TEMPTABLE(TripPassengerAirVendorPreference)
	  inner join @output O on O.PassengerKey = TripPassengerAirVendorPreference.value('(PassengerKey/text())[1]','int')
	  
	INSERT INTO TripPassengerHotelPreference( TripKey, TripHistoryKey, PassengerKey, Id, SmokingType, BedType,TripPassengerInfoKey)
	SELECT @tripId, 
	  O.TripHistoryKey,
	  TripPassengerHotelPreference.value('(PassengerKey/text())[1]','int') AS PassengerKey,
	  TripPassengerHotelPreference.value('(ID/text())[1]','int') AS ID,
	  TripPassengerHotelPreference.value('(SmokingType/text())[1]','int') AS SmokingType,
	  TripPassengerHotelPreference.value('(BedType/text())[1]','int') AS BedType,
	  O.TripPassengerInfoKey	  
	FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerPreferences/TripPassengerHotelPreference')AS TEMPTABLE(TripPassengerHotelPreference)
	  inner join @output O on O.PassengerKey = TripPassengerHotelPreference.value('(PassengerKey/text())[1]','int')				 
	
	INSERT INTO TripPassengerHotelVendorPreference(TripKey, TripHistoryKey, PassengerKey, ID, HotelChainCode, HotelChainName, PreferenceNo, 
						ProgramNumber, TripPassengerInfoKey)
	SELECT @tripId, 
	  O.TripHistoryKey,
	  TripPassengerHotelVendorPreference.value('(PassengerKey/text())[1]','int') AS PassengerKey,
	  TripPassengerHotelVendorPreference.value('(ID/text())[1]','int') AS ID,
	  TripPassengerHotelVendorPreference.value('(HotelChainCode/text())[1]','VARCHAR(30)') AS HotelChainCode,
	  TripPassengerHotelVendorPreference.value('(HotelChainName/text())[1]','VARCHAR(500)') AS HotelChainName,
	  TripPassengerHotelVendorPreference.value('(PreferenceNo/text())[1]','VARCHAR(50)') AS PreferenceNo,
	  TripPassengerHotelVendorPreference.value('(ProgramNumber/text())[1]','VARCHAR(50)') AS ProgramNumber,
	  O.TripPassengerInfoKey	  
	FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerPreferences/TripPassengerHotelPreference/TripPassengerHotelVendorPreferences/TripPassengerHotelVendorPreference')AS TEMPTABLE(TripPassengerHotelVendorPreference)
	  inner join @output O on O.PassengerKey = TripPassengerHotelVendorPreference.value('(PassengerKey/text())[1]','int')  
	  
	INSERT INTO TripPassengerCarPreference(TripKey, PassengerKey, Id, TripPassengerInfoKey)
	SELECT @tripId,
	  TripPassengerCarPreference.value('(PassengerKey/text())[1]','int') AS PassengerKey,
	  TripPassengerCarPreference.value('(ID/text())[1]','int') AS ID,
	  O.TripPassengerInfoKey	  
	FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerPreferences/TripPassengerCarPreference')AS TEMPTABLE(TripPassengerCarPreference)
	  inner join @output O on O.PassengerKey = TripPassengerCarPreference.value('(PassengerKey/text())[1]','int')				 
	
	INSERT INTO TripPassengerCarVendorPreference(TripKey, TripHistoryKey, PassengerKey, Id, CarVendorCode, CarVendorName, PreferenceNo, ProgramNumber, TripPassengerInfoKey)
	SELECT @tripId, 
	  O.TripHistoryKey,
	  TripPassengerCarVendorPreference.value('(PassengerKey/text())[1]','int') AS PassengerKey,
	  TripPassengerCarVendorPreference.value('(ID/text())[1]','int') AS ID,
	  TripPassengerCarVendorPreference.value('(CarVendorCode/text())[1]','VARCHAR(30)') AS CarVendorCode,
	  TripPassengerCarVendorPreference.value('(CarVendorName/text())[1]','VARCHAR(500)') AS CarVendorName,
	  TripPassengerCarVendorPreference.value('(PreferenceNo/text())[1]','VARCHAR(50)') AS PreferenceNo,
	  TripPassengerCarVendorPreference.value('(ProgramNumber/text())[1]','VARCHAR(50)') AS ProgramNumber,
	  O.TripPassengerInfoKey	  
	FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerPreferences/TripPassengerCarPreference/TripPassengerCarVendorPreferences/TripPassengerCarVendorPreference')AS TEMPTABLE(TripPassengerCarVendorPreference)
	  inner join @output O on O.PassengerKey = TripPassengerCarVendorPreference.value('(PassengerKey/text())[1]','int')  
	
	INSERT INTO TripPassengerUDIDInfo(TripKey, TripHistoryKey, PassengerKey, CompanyUDIDKey, CompanyUDIDDescription, CompanyUDIDNumber, CompanyUDIDOptionID, 
					CompanyUDIDOptionCode, CompanyUDIDOptionText, IsPrintInvoice, ReportFieldType, TextEntryType, UserID, PassengerUDIDValue, TripPassengerInfoKey)
	SELECT @tripId, 
	  O.TripHistoryKey,
	  O.TripPassengerInfoKey,
	  TripPassengerUDIDInfo.value('(CompanyUDIDKey/text())[1]','int') AS CompanyUDIDKey,
	  TripPassengerUDIDInfo.value('(CompanyUDIDDescription/text())[1]','VARCHAR(3000)') AS CompanyUDIDDescription,
	  TripPassengerUDIDInfo.value('(CompanyUDIDNumber/text())[1]','int') AS CompanyUDIDNumber,
	  TripPassengerUDIDInfo.value('(CompanyUDIDOptionID/text())[1]','int') AS CompanyUDIDOptionID,
	  TripPassengerUDIDInfo.value('(CompanyUDIDOptionCode/text())[1]','VARCHAR(50)') AS CompanyUDIDOptionCode,
	  TripPassengerUDIDInfo.value('(CompanyUDIDOptionText/text())[1]','VARCHAR(1000)') AS CompanyUDIDOptionText,	  
	  TripPassengerUDIDInfo.value('(IsPrintInvoice/text())[1]','bit') AS IsPrintInvoice,
	  TripPassengerUDIDInfo.value('(ReportFieldType/text())[1]','int') AS ReportFieldType,
	  TripPassengerUDIDInfo.value('(TextEntryType/text())[1]','int') AS TextEntryType,
	  TripPassengerUDIDInfo.value('(UserID/text())[1]','int') AS UserID,
	  TripPassengerUDIDInfo.value('(PassengerUDIDValue/text())[1]','VARCHAR(500)') AS PassengerUDIDValue,
	  O.TripPassengerInfoKey	  
	FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo/TripPassengerUDIDInfos/TripPassengerUDIDInfo')AS TEMPTABLE(TripPassengerUDIDInfo)
	  inner join @output O on O.PassengerKey = TripPassengerUDIDInfo.value('(UserID/text())[1]','int') 				
	
	Declare @UserId int, @companyUDIDKeys nvarchar(max)
	Select @UserId = DeleteReportingField.value('(userKey/text())[1]','int'),
		   @companyUDIDKeys = DeleteReportingField.value('(CompanyUDIDKeys/text())[1]','VARCHAR')
		FROM @xmldata.nodes('/TripPassenger/TripPassengerInfos/TripPassengerInfo/DeleteReportingField')AS TEMPTABLE(DeleteReportingField)
	IF(@UserId <> 0)
	Begin
		EXEC [vault].[dbo].[USP_DeleteReportingField] @UserId, @companyUDIDKeys
	End
	
	IF (@xmldata.exist('(//Pnr)') = 1)				
	BEGIN
		declare @TripHistoryKey uniqueidentifier, @Pnr nvarchar(50)
		select top 1 @TripHistoryKey = TripHistoryKey from @output 
		Select @Pnr = TripPassenger.value('(Pnr/text())[1]','VARCHAR(50)') FROM @xmldata.nodes('/TripPassenger')AS TEMPTABLE(TripPassenger)
		
		EXEC [dbo].[usp_TripPNRRemarksForHistory] @Pnr, @TripHistoryKey
		--Insert into TripPNRRemarks(TripKey, RemarkFieldName, RemarkFieldValue, TripTypeKey, RemarksDesc, GeneratedType, CreatedOn, Active, TripHistoryKey )
		--select 0 as TripKey, RemarkFieldName, RemarkFieldValue, TripTypeKey, RemarksDesc, GeneratedType, CreatedOn, Active, @TripHistoryKey 
		--	From TripPNRRemarks Where TripKey in (select TripKey from Trip where recordLocator = (
		--			Select TripPassenger.value('(Pnr/text())[1]','VARCHAR(50)') AS Pnr FROM @xmldata.nodes('/TripPassenger')AS TEMPTABLE(TripPassenger)) )
		
	END

	
    Select * from @output                    
END
GO
