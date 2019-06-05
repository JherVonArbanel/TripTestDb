SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- EXEC usp_GetHotelChainCode '105414'

CREATE PROC [dbo].[usp_GetHotelChainCode]
(
	@SupplierHotelId VARCHAR(20) 
)
AS BEGIN
SET NOCOUNT ON
	
	DECLARE @HotelId INT,
			@HotelChainCode VARCHAR(20)


	SELECT 
		@HotelId = HotelId
	FROM 
		HotelContent..SupplierHotels1
	WHERE
		SupplierFamily = 'HotelsCom'
	AND
		SupplierHotelId = @SupplierHotelId		
		
	-----
	
	PRINT 'Hotel Id :- ' + CAST(@HotelId AS VARCHAR)
	
	SELECT 
		@HotelChainCode = ISNULL(ChainCode,'')
	FROM 
		HotelContent..Hotels
	WHERE 
		HotelId = @HotelId
	
	PRINT 'Hotel Chain Code :- ' + CAST(@HotelChainCode AS VARCHAR)
	
	------
	
	IF @HotelChainCode = ''
	BEGIN		
		SET @HotelChainCode = 'defaulthotel'
	
	END


	SELECT @HotelChainCode as HotelChainCode

SET NOCOUNT OFF
END
GO
