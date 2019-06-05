SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[usp_updateSabreHotelCarContentBySupplierID]
(
@HotelSupplierId bigint,
@Phone varchar(32), 
@ZipCode varchar(16) = null
)
as 
BEGIN


         UPDATE HotelContent .dbo.Hotels 
         SET PhoneNumber = @Phone 
          FROM HotelContent .dbo.Hotels  HT inner join    HotelContent.dbo.SupplierHotels1  SH on  SH.HotelId = HT.HotelId 
         where SH.SupplierFamily = 'Sabre' and SupplierHotelId = @HotelSupplierId

END
GO
