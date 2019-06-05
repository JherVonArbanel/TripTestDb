SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[USP_GetTripPNRForCancellation](@SiteKey INT)
AS
BEGIN
SELECT recordLocator,tripStatusKey 
	FROM Trip..Trip 
	WHERE siteKey=@SiteKey 
	AND tripStatusKey NOT IN (5,17) 
	AND cancellationflag=0 
END
GO
