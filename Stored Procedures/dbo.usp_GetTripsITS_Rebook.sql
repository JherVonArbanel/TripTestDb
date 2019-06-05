SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Kinjal Modi>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[usp_GetTripsITS_Rebook]
	-- Add the parameters for the stored procedure here
	@IROPKey int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT --ROW_NUMBER() OVER (ORDER BY Trip.startDate), 
				Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey
			, Trip.recordLocator, Trip.startDate, Trip.endDate, Trip.tripStatusKey
			, S.tripStatusName 					
			, TI.FirstName, TI.LastName
			, trip.tripPurchasedKey, trip.CreatedDate 
			, LTRIM(RTRIM(ISNULL(TI.FirstName, '') + '/' + LEFT(ISNULL(TI.LastName, ''), 1))) as TravelerName,resp.actualAirPrice + resp.actualAirTax AS TotalCost					
	FROM	Vault..IROP_TravelerInfo TI WITH(NOLOCK)    
	           INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON TI.IROPTravelerKey=TPI.IROPPassengerKey			
			INNER JOIN Trip..Trip  WITH(NOLOCK) ON trip.tripKey = TPI.TripKey					
			INNER JOIN Trip.dbo.TripStatusLookup S WITH (NOLOCK) ON trip.tripStatusKey = S.tripStatusKey  										
			INNER JOIN Trip.dbo.TripAirResponse resp WITH (NOLOCK) ON trip.tripPurchasedKey = resp.tripGUIDKey AND resp.isDeleted = 0
	WHERE	
			--trip.recordlocator IS NOT NULL 
			--AND trip.recordlocator <> '' 
			--AND trip.recordLocator = CASE WHEN @PNR IS NOT NULL THEN @PNR ELSE trip.RecordLocator END 
			trip.tripStatusKey <> 10 AND Trip.tripStatusKey <> 17 AND
			TI.IROPkey = @iropKey
	ORDER BY trip.startDate DESC
    -- Insert statements for procedure here

END

GO
