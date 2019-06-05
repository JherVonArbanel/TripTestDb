SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 11-12-2013 16:27pm
-- Description:	Get city details by id.
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetCityDetailsByID]

	@cityId INT = 0
AS
BEGIN
   SELECT * FROM CityLookup WHERE cityKey = @cityId
	
END
GO
