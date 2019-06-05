SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Trip_GetNonDetailedTripByID]
(
	@tripKey	INT
)
AS
BEGIN

	SELECT tripKey, tripName, startDate, endDate, tripStatusKey FROM trip WHERE tripKey = @tripKey
	
END
GO
