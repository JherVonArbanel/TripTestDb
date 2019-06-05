SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetNonDetailedTrips]
(
	@userKey	INT
	
	
)
AS
BEGIN

	SELECT tripKey, tripName FROM trip WITH(NOLOCK) WHERE userKey = @userKey  ORDER BY tripKey DESC
	
END

GO
