SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [dbo].[USP_GetNonDetailedTripsnew]
(
	@userKey	INT,
	@tripRequestKey int
	
)
AS
BEGIN

	SELECT tripKey, tripName FROM trip WITH(NOLOCK) WHERE userKey = @userKey or tripRequestKey=@tripRequestKey ORDER BY tripKey DESC
	
END

GO
