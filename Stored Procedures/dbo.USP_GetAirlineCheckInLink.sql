SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetAirlineCheckInLink]
@airlineCode nchar(10)
AS
BEGIN
select checkInLink from AirlineBaggageLink where AirlineCode=@airlineCode
END
GO
