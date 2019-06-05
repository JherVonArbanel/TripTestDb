SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_UpdateNonDetailedTrip]
(
	@tripKey			INT,
	@tripName			VARCHAR(100)
)
AS
BEGIN

	IF NOT EXISTS (SELECT tripkey FROM trip WHERE tripkey = @tripKey) 
		INSERT INTO trip(tripkey, tripName) VALUES(@tripKey, @tripName) 
	ELSE 
		UPDATE trip SET tripName = @tripName WHERE tripKey = @tripKey
	
END
GO
