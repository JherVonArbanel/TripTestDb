SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 21-02-2019 08.34pm
-- Description:	Get hotelbeds connection information.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetHotelBedsConnectionID]
	@ConnectionID int
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT * FROM HotelBedsConnection WHERE connectionId = @ConnectionID
END


GO
