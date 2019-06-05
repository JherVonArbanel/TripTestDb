SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/***********************************       
  createdBy - Manoj Kumar Naik         
  Description - Save static hotel response from HotelContent db to Trip Hotelresponse Table 
  w.r.t hotelResquestKey.
  created on - 10/09/2012 
  updated on - 11/09/2012
 **********************************/   
CREATE PROCEDURE [dbo].[USP_SaveStaticHotelResponse]
	@hotelRequestKey int=0,   
	@cityCode VARCHAR(50)='',
	@supplierFamily Varchar(50)='HotelsCom'
AS
BEGIN
	
	Declare @SQL varchar(MAX)
	SET @supplierFamily = '''' + REPLACE(@supplierFamily, ',', ''',''') + ''''
	SET @SQL = 'SELECT NEWID(),' + CONVERT(VARCHAR, @hotelRequestKey) + ',  * 
			FROM
			(SELECT DISTINCT HS.HotelId, HS.LowRate, HS.SupplierFamily  
			FROM HotelContent..Hotels HS 
				INNER JOIN HotelContent..SupplierHotels1 SH ON HS.HotelId = SH.HotelId 
			WHERE HS.CityCode=''' + @CityCode + ''' AND (HS.LowRate IS not Null AND HS.LowRate > 0) AND SH.SupplierFamily In (' + @supplierFamily + ') ) A'	
	
	INSERT INTO HotelResponse(hotelResponseKey,hotelRequestKey,hotelId,minRate,supplierId )
    EXEC(@SQL)
	
	
END
GO
