SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Nikki Hawkins>
-- Create date: <20-Jan-2014>
-- Description:	<Function used to get Trip Status definition>
-- =============================================
CREATE FUNCTION [dbo].[udf_GetTripStatusDefinition](@tripstatuskey as int)
RETURNS varchar(200) AS

BEGIN
DECLARE @TripStatus varchar(200)

select @TripStatus = tripstatusname
from [Trip].[dbo].[TripStatusLookup]
where [tripStatusKey] = @tripstatuskey

RETURN @TripStatus
END

GO
