SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 28-12-2018 12.55pm
-- Description:	Get priceline connection information.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetPricelineConnectionID]
	@ConnectionID int
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT * FROM PricelineConnection WHERE connectionID = @ConnectionID
END


GO
