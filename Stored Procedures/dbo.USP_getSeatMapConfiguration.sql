SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Exec USP_getSeatMapConfiguration 2
-- Drop procedure USP_getSeatMapConfiguration 
CREATE PROCEDURE [dbo].[USP_getSeatMapConfiguration]
@gdsSourceKey Int

AS
BEGIN

	SELECT gdsSourceKey,AirlinesForSelection,AirlinesForView
	FROM SeatMapConfiguration WITH(NOLOCK)
	WHERE [primaryGDSSourceKey] = @gdsSourceKey

	SELECT AL.AirCraftCode,AL.AircraftName
	FROM NotSupportSeatMapEquipment NSM WITH(NOLOCK)
	INNER JOIN AircraftsLookup AL ON NSM.EquipmentCode = AL.AircraftCode

END
GO
