SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into TripPassengerUDIDInfo table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_UpdateTripForRecord_PasUDIDInfo]
	 @TripKey As int ,
	 @PassengerKey As int ,
	 @CompanyUDIDKey As int,
	 @CompanyUDIDDescription As nvarchar(3000) ,
	 @CompanyUDIDNumber As int ,
	 @CompanyUDIDOptionID As int,
	 @CompanyUDIDOptionCode AS nvarchar(50),
	 @CompanyUDIDOptionText As nvarchar(1000), 
	 @IsPrintInvoice As bit ,
	 @ReportFieldType As int,
	 @TextEntryType AS int,
	 @UserID As int,
	 @PassengerUDIDValue AS nvarchar(500)
	 
AS
BEGIN
 
INSERT INTO TripPassengerUDIDInfo
			(TripKey, PassengerKey, CompanyUDIDKey, CompanyUDIDDescription, CompanyUDIDNumber
            ,CompanyUDIDOptionID, CompanyUDIDOptionCode, CompanyUDIDOptionText, IsPrintInvoice 
            ,ReportFieldType, TextEntryType,UserID , PassengerUDIDValue)
		VALUES
			(@TripKey, @PassengerKey, @CompanyUDIDKey, @CompanyUDIDDescription, @CompanyUDIDNumber
            ,@CompanyUDIDOptionID, @CompanyUDIDOptionCode, @CompanyUDIDOptionText, @IsPrintInvoice 
            ,@ReportFieldType, @TextEntryType,@UserID , @PassengerUDIDValue)
                    
END
GO
