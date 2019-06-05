SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/* Created by Anupam (07/March/13) */
/* ------------------------------------------------------ */
CREATE PROCEDURE [dbo].[USP_DeleteAirVendorClassLookup]
(
	@AirVendorClassId int
)
AS

BEGIN
	
	DELETE FROM AirVendorClassLookup
	WHERE AirVendorClassId = @AirVendorClassId
END
GO
