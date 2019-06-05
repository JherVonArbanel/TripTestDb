SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CarResponseDetails_GET_ByTripID]
(
	@tripKey	INT = NULL
)
AS
BEGIN

	SELECT 
		vw_sabreCarResponse.*, 
		Trip_carResponse.* 
	FROM vw_sabreCarResponse 
		LEFT OUTER JOIN Trip_carResponse ON vw_sabreCarResponse.carResponseKey = Trip_carResponse.carResponseKey 
	WHERE tripKey = @tripKey
	
END
GO
