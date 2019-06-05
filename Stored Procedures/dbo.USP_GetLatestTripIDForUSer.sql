SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetLatestTripIDForUSer]
(
	@userkey	INT
)
AS
BEGIN

	SELECT TOP 1 * FROM trip WHERE userkey = @userkey  and tripStatusKey <> 17 ORDER BY tripKey DESC
	
END
GO
