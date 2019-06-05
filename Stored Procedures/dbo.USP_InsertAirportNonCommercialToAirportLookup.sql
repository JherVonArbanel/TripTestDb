SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Pradeep Gupta>
-- Create date: <11-March-16>
-- Description:	<used to add airport code which contains "bus" or "station" in their name (REF : one world issue #176)>
-- =============================================
CREATE PROCEDURE [dbo].[USP_InsertAirportNonCommercialToAirportLookup] 
	
AS
BEGIN


         
WITH AirporLookUpUpdate ([AirportCode],[AirportName],[CityCode],[CityName],[StateCode],[CountryCode],[Longitude],[Latitude],[TimeZoneCode],[IsDomestic],[Preference],[AirPriority],[AirStatus]
,[GMT_offset],[DST_offset],[Time_zone_id],[Zone],[CountryName],[CountryPriority],[IsVisible])
As
(
SELECT [AirportCode],[AirportName],[CityCode],[CityName],[StateCode],[CountryCode],[Longitude],[Latitude],[TimeZoneCode],[IsDomestic],[Preference],[AirPriority],[AirStatus],[GMT_offset],[DST_offset],[Time_zone_id],[Zone],[CountryName],[CountryPriority] ,0
FROM [Trip].[dbo].[AirportLookupNonCommercial] where AirportCode not in 
  (
	SELECT AirportCode FROM [Trip].[dbo].[AirportLookup] 
  ) 
  and (AirportName like '% train %' OR AirportName like '% bus %')
)  


INSERT INTO [Trip].[dbo].[AirportLookup]([AirportCode],[AirportName],[CityCode],[CityName],[StateCode],[CountryCode],[Longitude],[Latitude]
           ,[TimeZoneCode],[IsDomestic],[Preference],[AirPriority],[AirStatus],[GMT_offset],[DST_offset],[Time_zone_id],[Zone],[CountryName],[CountryPriority],[IsVisible])           
select [AirportCode],[AirportName],[CityCode],[CityName],[StateCode],[CountryCode],[Longitude],[Latitude]
           ,[TimeZoneCode],[IsDomestic],[Preference],[AirPriority],[AirStatus],[GMT_offset],[DST_offset],[Time_zone_id],[Zone],[CountryName],[CountryPriority],[IsVisible] FROM AirporLookUpUpdate 
 
 
 

END
GO
