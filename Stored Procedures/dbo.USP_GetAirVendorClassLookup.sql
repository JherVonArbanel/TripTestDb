SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/* Created by Anupam (07/March/13) */
/* EXEC USP_GetAirVendorClassLookup '','','' */
/* ------------------------------------------------------ */
CREATE PROCEDURE [dbo].[USP_GetAirVendorClassLookup]
(
	@AirVendorCode VARCHAR(4),
	@BookingClass VARCHAR(2),
	@CabinClass VARCHAR(20)
)
AS

BEGIN

SELECT *
FROM AirVendorClassLookup WITH(NOLOCK)
WHERE (@AirVendorCode = '' OR AirVendorCode = @AirVendorCode)
AND (@BookingClass = '' OR BookingClass = @BookingClass)
AND (@CabinClass = '' OR CabinClass = @CabinClass)
	
END
GO
