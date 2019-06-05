SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetRoommatePNR]
@tripKey int
AS
BEGIN
    SELECT recordLocator, userKey, tripKey
	FROM 
		Trip
	WHERE  	(cross_reference_trip_id IS NOT NULL AND cross_reference_trip_id = @tripKey)
		    AND tripStatusKey <> 17 AND ([type] IS NOT NULL AND LOWER([type]) = 'ghost')
END
GO
