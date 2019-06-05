SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetDetailedTrips_Update]
(
	@tripKey		INT,
	@startDate		DATETIME,
	@endDate		DATETIME,
	@tripStatusKey	INT
)
AS
BEGIN

	UPDATE trip 
	SET startDate = @startDate,
		endDate = @endDate,
		tripStatusKey = @tripStatusKey
	WHERE tripkey = @tripKey
	
END
GO
