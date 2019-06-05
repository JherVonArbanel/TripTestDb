SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetAirlineStatusLink]
@airlineCode nchar(10)
AS
BEGIN
select statusLink from AirlineBaggageLink where AirlineCode=@airlineCode
END
GO
