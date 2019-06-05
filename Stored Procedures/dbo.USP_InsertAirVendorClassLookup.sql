SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/* Created by Anupam (07/March/13) */
/* ------------------------------------------------------ */
CREATE PROCEDURE [dbo].[USP_InsertAirVendorClassLookup]
(
	@AirVendorCode VARCHAR(4),
	@BookingClass VARCHAR(2),
	@CabinClass VARCHAR(20)
)
AS

BEGIN
	
	INSERT INTO AirVendorClassLookUp(AirVendorCode,BookingClass,CabinClass,CreatedDate)
	VALUES (@AirVendorCode,@BookingClass,@CabinClass,GetDate())
END
GO
