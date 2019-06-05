SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetAirVendor] 
(
@airlineCode varchar (100)
)
AS
BEGIN
SELECT AirlineCode,ShortName,FullName FROM AirVendorLookup WITH (NOLOCK) WHERE AirlineCode = @airlineCode 
END 
 
GO
