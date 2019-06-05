SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[USP_GetAllAiportsDefaultAirports]
	@airportCode VARCHAR(5)
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT DefaultAirportCode 
	FROM [Trip].[dbo].[DefaultAirportsForAllAirports] 
	WHERE AllAiportCode = @airportCode
	-- COUNT(1) AS 'IsAirportTypeAll'
		
END
GO
