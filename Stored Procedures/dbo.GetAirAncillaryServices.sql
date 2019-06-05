SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetAirAncillaryServices]
AS
BEGIN
--select * from trip..AirAncillaryLookup 
--select * from trip..AirlineAncillaryMappingLookup 
SELECT	anc.AirAncillaryId,
		anc.ServiceType,
		mpng.AirlineCode,
		mpng.Fees,
		mpng.[Type],
		mpng.AncillaryText
FROM AirAncillaryLookup anc
INNER JOIN AirlineAncillaryMappingLookup mpng
ON anc.AirAncillaryId=mpng.AirAncillaryId
END
GO
