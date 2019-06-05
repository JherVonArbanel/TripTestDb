SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetNonDetailedTrips_ByID]
(
	@userKey			INT,
	@chargeStatusKey	INT
)
AS
BEGIN

	SELECT 
		tripKey, 
		tripName, 
		startDate 
	FROM trip 
	WHERE tripKey IN 
	(
		SELECT DISTINCT tripKey 
		FROM [Expense].[dbo].Charge 
		WHERE (userKey = @userKey) 
			AND (chargeStatusKey = @chargeStatusKey) 
			AND (tripKey IS NOT NULL) 
	)
	
END
GO
