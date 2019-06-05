SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetDetailedTrips_Insert]
(
	@tripKey		INT,
	@tripName		VARCHAR(100),
	@startDate		DATETIME,
	@endDate		DATETIME,
	@userkey		INT,
	@tripStatusKey	INT
)
AS
BEGIN

	INSERT INTO trip
	(
		tripkey,
		tripName,
		startDate,
		endDate,
		userkey,
		tripStatusKey
	) 
	VALUES
	(
		@tripkey,
		@tripName,
		@startDate,
		@endDate,
		@userkey,
		@tripStatusKey
	)
	
END
GO
