SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoFlx_TripPassengerUDID_Ins]
(  
	@TripKey INT, 
	@PassengerKey INT, 
	@CompanyUDIDKey INT, 
	@CompanyUDIDDescription NVARCHAR(3000), 
	@CompanyUDIDNumber INT, 
	@CompanyUDIDOptionID INT, 
	@CompanyUDIDOptionCode NVARCHAR(50), 
	@CompanyUDIDOptionText NVARCHAR(1000),  
	@IsPrintInvoice BIT, 
	@ReportFieldType INT, 
	@TextEntryType INT, 
	@UserID INT, 
	@PassengerUDIDValue NVARCHAR(500)
)
AS  
  
BEGIN  

	INSERT INTO TripPassengerUDIDInfo( TripKey, PassengerKey, CompanyUDIDKey, CompanyUDIDDescription, CompanyUDIDNumber, 
		CompanyUDIDOptionID, CompanyUDIDOptionCode, CompanyUDIDOptionText, IsPrintInvoice, ReportFieldType, TextEntryType, 
		UserID, PassengerUDIDValue)
    VALUES(@TripKey, @PassengerKey, @CompanyUDIDKey, @CompanyUDIDDescription, @CompanyUDIDNumber, 
		@CompanyUDIDOptionID, @CompanyUDIDOptionCode, @CompanyUDIDOptionText, @IsPrintInvoice, @ReportFieldType, @TextEntryType, 
		@UserID , @PassengerUDIDValue)
 
END  

GO
