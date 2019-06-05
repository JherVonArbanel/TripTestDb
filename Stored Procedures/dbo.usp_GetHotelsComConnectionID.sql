SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 08/12/2012 17:21PM
-- Description:	Get connection info for hotelscom operation set in siteConfiguration. 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetHotelsComConnectionID]
	-- Add the parameters for the stored procedure here
	@ConnectionID int
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT * FROM HotelsComConnection WHERE connectionID = @ConnectionID
END
GO
