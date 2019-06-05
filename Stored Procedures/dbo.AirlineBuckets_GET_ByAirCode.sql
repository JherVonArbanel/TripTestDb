SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AirlineBuckets_GET_ByAirCode]
(
	@AirlineCode VARCHAR(100)
)
AS
BEGIN
--ci test meena in branch name --
	SELECT * 
	FROM AirlineBuckets  
	WHERE airlineCode = @AirlineCode

END
GO
