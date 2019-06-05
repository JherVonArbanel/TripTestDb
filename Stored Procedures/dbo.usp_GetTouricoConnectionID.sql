SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 9/11/2012 14:57PM
-- Description:	Get connection info for tourico operation set in siteConfiguration. 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetTouricoConnectionID]
	-- Add the parameters for the stored procedure here
	@ConnectionID int
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT * FROM TouricoConnection WHERE connectionID = @ConnectionID
END
GO
