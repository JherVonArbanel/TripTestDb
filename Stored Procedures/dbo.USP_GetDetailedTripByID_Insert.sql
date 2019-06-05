SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetDetailedTripByID_Insert]
(
	@tripkey	INT,
	@tripName	VARCHAR(100),
	@startDate	DATETIME,
	@endDate	DATETIME,
	@userkey	INT
)
AS
BEGIN

	INSERT INTO trip
	(
		tripkey,
		tripName,
		startDate,
		endDate,
		userkey
	) 
	VALUES
	(
		@tripkey,
		@tripName,
		@startDate,
		@endDate,
		@userkey
	)

END
GO
