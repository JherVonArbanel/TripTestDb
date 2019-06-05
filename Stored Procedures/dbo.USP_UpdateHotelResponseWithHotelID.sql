SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/***********************************       
  createdBy - Manoj Kumar Naik         
  Description - Update Hotel Response with HotelId
  w.r.t hotelResquestKey.
  created on - 22/01/2012  13:13
  EXEC USP_UpdateHotelResponseWithHotelID 34505

 **********************************/   
CREATE PROCEDURE [dbo].[USP_UpdateHotelResponseWithHotelID]
	@hotelRequestKey int
AS
BEGIN
	
	DECLARE @tbl TABLE(hotelID INT, SHHotelID INT, supplierHotelKey NVARCHAR(50), SupplierId NVARCHAR(50))
	
	INSERT INTO @tbl 
	SELECT HR.hotelId, SH.HotelId, HR.supplierHotelKey, HR.SupplierId
	FROM  Trip..HotelResponse HR WITH (NOLOCK)
		INNER JOIN HotelContent..SupplierHotels1 SH WITH (NOLOCK) ON SH.SupplierHotelId = HR.supplierHotelKey 
			AND SH.SupplierFamily = HR.SupplierId AND HR.hotelRequestKey = @hotelRequestKey
		

	UPDATE HR
	SET HR.hotelId = SH.SHHotelID  
	FROM Trip..HotelResponse HR WITH (NOLOCK)
		INNER JOIN @tbl SH ON SH.SupplierHotelKey = HR.supplierHotelKey 
			AND SH.SupplierId = HR.SupplierId AND HR.hotelRequestKey = @hotelRequestKey


	--UPDATE HR
	--SET HR.hotelId = SH.HotelId 
	--FROM  Trip..HotelResponse HR 
	--	INNER JOIN HotelContent..SupplierHotels1  SH ON SH.SupplierHotelId = HR.supplierHotelKey 
	--		AND SH.SupplierFamily = HR.SupplierId AND HR.hotelRequestKey = @hotelRequestKey
	
END
GO
