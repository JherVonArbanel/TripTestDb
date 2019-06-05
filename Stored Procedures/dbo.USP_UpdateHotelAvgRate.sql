SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/***********************************       
  createdBy - Manoj Kumar Naik         
  Description - Update Hotel Response with hotelAvgRate
  w.r.t hotelResquestKey.
  created on - 05/10/2018  08:54pm
  EXEC [USP_UpdateHotelAvgRate] 34505

 **********************************/   
CREATE PROCEDURE [dbo].[USP_UpdateHotelAvgRate]
	@hotelRequestKey int
AS
BEGIN
	
	DECLARE @tbl TABLE(avgRate FLOAT, supplierHotelKey NVARCHAR(50))
	DECLARE @noOfDays int

	select @noOfDays = datediff(day,checkInDate,checkOutDate) FROM Trip..HotelRequest WHERE hotelRequestKey=@hotelRequestKey

	INSERT INTO @tbl 
     Select AVG(minRate),SupplierHotelKey from HotelResponseSabreAvgRateCall where  hotelRequestKey=@hotelRequestKey group by SupplierHotelKey  Having Count(supplierHotelKey) = @noOfDays
		

	UPDATE HR
	SET HR.minRate = SH.avgRate,
	HR.isAvgRateUpdated =1
	FROM Trip..HotelResponse HR WITH (NOLOCK)
		INNER JOIN @tbl SH ON SH.SupplierHotelKey = HR.supplierHotelKey
	WHERE HR.hotelRequestKey = @hotelRequestKey  AND SupplierId='Sabre'

	
END
GO
