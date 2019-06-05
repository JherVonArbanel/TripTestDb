SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CarResponses_GET]
(
	@CarRequestKey	INT				= NULL,
	@CarResponseKey	UNIQUEIDENTIFIER= NULL
)
AS
BEGIN

	IF @CarRequestKey IS NOT NULL
	BEGIN
		SELECT * 
		FROM vw_sabreCarResponse 
		WHERE CarRequestKey = @CarRequestKey
		ORDER BY minRate
	END
	ELSE
	BEGIN
		SELECT * 
		FROM vw_sabreCarResponse 
		WHERE CarResponseKey = @CarResponseKey
	END
END
GO
