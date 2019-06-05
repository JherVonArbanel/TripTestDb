SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Shrikant Sonawane>
-- Create date: <26May2017>
-- Description:	<to get airport details from airport lookup>
-- exec USP_GetAirportDetails 'MIA'
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetAirportDetails]
(
	@airportCode varchar(100)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT * from AirportLookup where AirportCode = @airportCode;
END
GO
