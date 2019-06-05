SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[usp_GetBXAwardId]
(
	@AwardCode VARCHAR(10),	
	@SiteKey INT

)
AS
BEGIN 

	SET NOCOUNT ON;


	SELECT 
		AwardId 
	FROM BXTermAndConditionMapping WITH (NOLOCK)
	WHERE 
		LTRIM(RTRIM(AwardCode)) = LTRIM(RTRIM(@AwardCode))
	AND 
		siteKey = @SiteKey



END
GO
