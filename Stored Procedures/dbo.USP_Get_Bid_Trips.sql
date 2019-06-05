SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author : Gopal
-- Create date : Jan/10/2012  
-- Description : Trip Information will be received from Web Service.  
-- Param : TripKey is optional.
-- =============================================   
   
CREATE PROCEDURE [dbo].[USP_Get_Bid_Trips]     
	@tripKey INT = NULL
AS    
BEGIN       

	SELECT Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, Trip.recordLocator, Trip.startDate, Trip.endDate, 
		Trip.tripStatusKey, Trip.agencyKey
	FROM trip WITH(NOLOCK) 
		INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) on trip.userKey =  U.UserKey 
	WHERE tripKey = ISNULL(@tripKey, tripKey) AND recordlocator IS NOT NULL AND recordlocator <> '' 
		AND tripStatusKey = 10
		
	SELECT vt.TYPE,vt.tripKey,vt.recordLocator,vt.basecost,vt.tax,vt.vendorcode,
		vt.VendorName,vt.airSegmentDepartureAirport,vt.airSegmentArrivalAirport,vt.flightNumber,
		vt.departuredate,vt.arrivaldate,vt.carType,vt.Ratingtype ,vt.responseKey  ,vt.vendorLocator  
	FROM vw_TripDetails vt WITH(NOLOCK)  
	WHERE vt.tripStatusKey = 10
	ORDER BY tripKey DESC, type, segmentOrder, departuredate ASC  

	SELECT OPT.* 
	FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK)     
	INNER JOIN Trip T ON OPT.tripKey = T.tripKey AND isDeleted = 0 AND T.tripStatusKey = 10

END    
    
GO
