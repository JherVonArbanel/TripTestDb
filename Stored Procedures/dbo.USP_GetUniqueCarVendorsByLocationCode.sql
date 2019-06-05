SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Manoj Kumar Naik	
-- Create date: 13-11-2018 5.50pm
-- Description:	Get unique vendors for car location from sabreVendorLocations in CarContent table.
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetUniqueCarVendorsByLocationCode] 
	@LocationAirportCode varchar(3)
AS
BEGIN

	SELECT VendorCode
	  FROM [CarContent].[dbo].[SabreLocations] where LocationAirportCode=@LocationAirportCode Group by VendorCode
END
GO
