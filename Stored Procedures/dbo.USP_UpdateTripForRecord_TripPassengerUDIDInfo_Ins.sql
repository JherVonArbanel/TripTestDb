SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_TripPassengerUDIDInfo_Ins]
(  
	@TripKey INT,
	@PassengerKey INT,
	@CompanyUDIDKey INT, 
	@CompanyUDIDDescription NVARCHAR(4000), 
	@CompanyUDIDNumber INT, 
	@CompanyUDIDOptionID INT, 
	@CompanyUDIDOptionCode NVARCHAR(100), 
	@CompanyUDIDOptionText NVARCHAR(2000), 
	@IsPrintInvoice BIT, 
	@ReportFieldType INT, 
	@TextEntryType INT, 
	@UserID INT, 
	@PassengerUDIDValue NVARCHAR(1000)
)AS  
  
BEGIN  

	INSERT INTO TripPassengerUDIDInfo(TripKey, PassengerKey, CompanyUDIDKey, CompanyUDIDDescription, CompanyUDIDNumber
            , CompanyUDIDOptionID, CompanyUDIDOptionCode, CompanyUDIDOptionText, IsPrintInvoice, ReportFieldType, TextEntryType
            , UserID , PassengerUDIDValue)
    VALUES(@TripKey, @PassengerKey, @CompanyUDIDKey, @CompanyUDIDDescription, @CompanyUDIDNumber, 
		@CompanyUDIDOptionID, @CompanyUDIDOptionCode, @CompanyUDIDOptionText, @IsPrintInvoice, @ReportFieldType, @TextEntryType, 
			@UserID, @PassengerUDIDValue)
   
END  
GO
