SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetPartialPurchasesforCurrentTrip]
@tripKey int
AS
BEGIN
    SELECT tripComponentType, recordLocator, startDate 
	FROM 
		Trip
	WHERE  
		(((tripKey = @tripKey) AND (cross_reference_trip_id IS NULL OR cross_reference_trip_id = 0) AND LOWER([type]) = 'real')
		OR
		(cross_reference_trip_id IS NOT NULL AND cross_reference_trip_id = @tripKey))
		AND tripStatusKey <> 17 AND ([type] IS NULL OR LOWER([type]) = 'real')
END
GO
