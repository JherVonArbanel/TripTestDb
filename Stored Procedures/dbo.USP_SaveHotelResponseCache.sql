SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/***********************************       
  createdBy - Manoj Kumar Naik         
  Description - Save hotel response from cache result to Hotelresponse Table 
  w.r.t hotelResquestKey.
  created on - 11/10/2012  16:31
  EXEC [USP_SaveHotelResponseCache] '12711', '34', 'HotelsCom,Tourico,Sabre'
  
  updated on - 19-11-2012
  Added inner join of supplierHotels1 table for HotelId in hotelResponse tbl.
  
  updated by manoj on - 10-01-2012 15:13
  Added lowRate & highRate column for tripaudit project requirement.
 **********************************/   
CREATE PROCEDURE [dbo].[USP_SaveHotelResponseCache]
	@hotelRequestKey int,   
	@hotelAirportCacheId int,
	@marketConfigurationSupplier varchar(50)='HotelsCom'
AS
BEGIN
	
	Declare @SQL varchar(MAX)
	SET @marketConfigurationSupplier = '''' + REPLACE(@marketConfigurationSupplier, ',', ''',''') + ''''
	--SET @SQL = 'SELECT NEWID(),' + CONVERT(VARCHAR, @hotelRequestKey) + ',  * 
	--		FROM
	--		(SELECT DISTINCT  HC.supplierHotelId, HC.price, HC.SupplierFamily
	--		FROM HotelContent..HotelPriceCache HC 
	--			INNER JOIN HotelContent..SupplierHotels1 SH ON HC.supplierHotelId = SH.SupplierHotelId AND HC.SupplierFamily = SH.SupplierFamily
	--		WHERE HC.hotelAirportCacheId=' + CONVERT(VARCHAR, @hotelAirportCacheId) + ' AND (HC.price IS not Null AND HC.price > 0) AND HC.SupplierFamily In (' + @marketConfigurationSupplier + ') ) A'	
	SET @SQL = 'SELECT NEWID(),' + CONVERT(VARCHAR, @hotelRequestKey) + ',  * 
			FROM
			(SELECT DISTINCT  HC.supplierHotelId, HC.price, HC.SupplierFamily, HC.rating, HC.airportCode, SH.HotelId, HC.lowRate, HC.highRate
			FROM HotelContent..HotelPriceCache HC INNER JOIN HotelContent..SupplierHotels1 SH ON SH.supplierHotelId = HC.supplierHotelId  AND SH.SupplierFamily = HC.SupplierFamily
			WHERE HC.hotelAirportCacheId=' + CONVERT(VARCHAR, @hotelAirportCacheId) + ' AND (HC.price IS not Null AND HC.price > 0) AND HC.SupplierFamily In (' + @marketConfigurationSupplier + ') ) A'	
	
	--PRINT(@SQL)
	
	INSERT INTO HotelResponse(hotelResponseKey,hotelRequestKey, supplierHotelKey, minRate,supplierId,tripAdvisorRating, cityCode, hotelId, lowRate, highRate)
    EXEC(@SQL)
	
	
END
GO
