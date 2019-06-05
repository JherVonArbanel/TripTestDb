SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_AddTripAncillaryServicesInfo]  
  
@tripKey INT,  
@typeOfAncillary Int,  
@serviceFeeVendorCode float,  
@invoiceNo nvarchar(20),  
@totalAmountCharged float,  
@maskedCardNo VARCHAR(20),
@documentNo varchar(20),
@invoiceDateTime datetime,
@isXAC bit,
@nameOnCard nvarchar(1000)
AS  
BEGIN  
  
 /* Condition for same ticket is exist or not */  
 --IF(SELECT COUNT(*) FROM TripAncillaryServices WITH(NOLOCK)  
 --WHERE tripKey = @tripKey   
 --AND InvoiceDateTime=@lastSyncDateTime) = 0  
  
  --BEGIN  
  
  INSERT INTO trip..TripAncillaryServices(TripKey,TypeOfAncillary,InvoiceNo,MaskedCardNo,ServiceFeeVendorCode,TotalAmountCharged,CreatedDate,DocumentNo,InvoiceDateTime,ISXAC,NameOnCard)
  VALUES(@tripKey,@typeOfAncillary,@invoiceNo,@maskedCardNo,@serviceFeeVendorCode,@totalAmountCharged,GETDATE(),@documentNo,@invoiceDateTime,@isXAC,@nameOnCard)  
  
  --END  
  
END  
GO
