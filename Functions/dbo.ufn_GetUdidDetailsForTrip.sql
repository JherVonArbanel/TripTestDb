SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[ufn_GetUdidDetailsForTrip]
( @tripID as bigint )
returns varchar (1000) 
as begin 
DECLARE
@AllValues VARCHAR(4000) 
SELECT
@AllValues = COALESCE(@AllValues + ',', '')+ CONVERT(varchar(20),CompanyUDIDNumber  ) +'='+ PassengerUDIDValue  
FROM
TripPassengerUDIDInfo TUDID inner join 
trip 
on  TUDID.tripkey  = trip.tripkey 
 WHERE trip.tripkey = @tripID
if   @AllValues is null select @AllValues =''
return ( @AllValues )
end
GO
