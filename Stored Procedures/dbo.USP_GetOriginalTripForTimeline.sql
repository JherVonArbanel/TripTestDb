SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Anupam Patel
-- Create date: 02/JUN/2015
-- Description:	It is used to compare current trips to original trip for recommended in timeline
-- Exec USP_GetOriginalTripForTimeline 20549
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetOriginalTripForTimeline]
	-- Add the parameters for the stored procedure here
	@tripKey INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


   DECLARE @listAirSegments VARCHAR(100)
   DECLARE @hotelId INT
   DECLARE @vendorKey VARCHAR(6)
   DECLARE @componentType INT
   
	SELECT @componentType = tripComponentType
	FROM Trip
	WHERE tripKey = @tripKey

   
   SELECT @listAirSegments = COALESCE(@listAirSegments+',' ,'') + airSegmentMarketingAirlineCode
    FROM TripAirSegments WITH(NOLOCK)
    WHERE isDeleted = 0
    AND airResponseKey =
    ( SELECT airResponseKey 
      FROM TripAirResponse WITH(NOLOCK)
      WHERE tripGUIDKey = (SELECT tripSavedKey FROM Trip WITH(NOLOCK) WHERE tripKey = @tripKey)
    )
   
   
   SELECT @hotelId = hotelID
   FROM (SELECT supplierHotelKey,supplierId,vendorCode
   FROM TripHotelResponse WITH(NOLOCK)
   WHERE tripGUIDKey = (SELECT tripSavedKey FROM Trip WITH(NOLOCK) WHERE tripKey = @tripKey)) THR
   INNER JOIN HotelContent..SupplierHotels1 SH WITH(NOLOCK) ON THR.supplierHotelKey = SH.SupplierHotelId 
   AND THR.supplierId = SH.SupplierFamily AND isDeleted = 0
   
   SELECT @vendorKey = TCR.carVendorKey
   FROM TripCarResponse  TCR WITH(NOLOCK)
   WHERE tripGUIDKey = (SELECT tripSavedKey FROM Trip WITH(NOLOCK) WHERE tripKey = @tripKey)
   
   SELECT  @componentType ComponentType, @listAirSegments AirLineCode, @hotelId HotelId, @vendorKey CarVendorCode
   
   SELECT componentType,vendorDetails
   FROM TripSavedDeals WITH(NOLOCK)
   WHERE tripKey = @tripKey
   AND Convert(Date,creationDate)= Convert(Date,GETDATE())
   
    
END
GO
