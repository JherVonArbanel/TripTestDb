SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetAirlineGateLink]
@airlineCode nchar(10)
AS
BEGIN
select gateLink from AirlineBaggageLink where AirlineCode=@airlineCode
END
GO
