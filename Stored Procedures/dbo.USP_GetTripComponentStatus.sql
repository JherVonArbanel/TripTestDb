SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 06-01-2012
-- Description:	Updating & getting the trip status & components status
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripComponentStatus]
	@tripKey int
AS
BEGIN
	
	Declare @tblTripComponentStatus as table            
	(            
		 tripKey Int,            
		 componentKey uniqueidentifier,
		 componentType varchar(10),
		 componentStatus varchar(15),
		 cityCode varchar(15),
		 vendorCode varchar(15) 
	)            

-- Air        
    Insert into @tblTripComponentStatus             
    Select tripKey , airResponseKey , 'Air' , TripStatusKey, '', ''
    From TripAirResponse Inner join TripStatusLookup On [status] = tripStatusKey WHERE isDeleted =0
    
-- Car    
    Insert into @tblTripComponentStatus             
    Select tripKey , carResponseKey , 'Car' , TripStatusKey, carLocationCode, carVendorKey
    From TripCarResponse Inner join TripStatusLookup On [status] = tripStatusKey WHERE isDeleted =0
    
-- Hotel
    Insert into @tblTripComponentStatus             
    Select tripKey , hotelResponseKey , 'Hotel' , TripStatusKey, cityCode, vendorCode
    From TripHotelResponse Inner join TripStatusLookup On [status] = tripStatusKey WHERE isDeleted =0
	
	IF((Select COUNT(*) FROM @tblTripComponentStatus WHERE componentStatus <> 'Active') > 0)
	 BEGIN
	  print ''
	 END
   ELSE
     BEGIN	 
     UPDATE [Trip] set tripStatusKey = 2 WHERE tripKey = @tripKey
	 END  
	
	SELECT * FROM @tblTripComponentStatus
	
END
GO
