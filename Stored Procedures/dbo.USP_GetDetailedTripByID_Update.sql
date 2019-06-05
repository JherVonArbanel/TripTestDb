SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetDetailedTripByID_Update]
(
	@startDate	DATETIME,
	@endDate	DATETIME,
	@tripkey	INT
)
AS
BEGIN

	UPDATE trip 
	SET startDate = @startDate,
		endDate = @endDate
	WHERE tripkey = @tripkey

END
GO
