SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[USP_GetAirlinesBySiteKey] --6,''    
(      
 @siteKey int,      
 @allowedAirliness nvarchar(500) = ''    
  --@case nvarchar(20) = ''      
)      
      
as        
      
  IF(@allowedAirliness <> '')    
  Begin    
 declare @allowedAirlines as table ( airlinecode varchar (20),ShortName varchar(100))
INSERT @allowedAirlines 
 select airlineCode, ShortName as 'AirlineName' from AirVendorLookup where AirlineCode in     
 (select * from ufn_CSVSplitString(@allowedAirliness)) 
 select airlineCode, ShortName as 'AirlineName' from AirVendorLookup where AirlineCode in        
(   
  select distinct(airSegmentMarketingAirlineCode) as 'AirlineCode'      
 from TripAirSegments tas   
 inner join    @allowedAirlines a on tas.airSegmentMarketingAirlineCode=a.airlinecode 
 inner join TripAirResponse tar      
  on tar.airResponseKey = tas.airResponseKey       
 inner join Trip t      
  on tar.tripKey = t.tripKey        
 and airSegmentMarketingAirlineCode <> ''      
 and t.siteKey = @siteKey      
) order by ShortName     
  
  End    
  Else      
Begin    
select airlineCode, ShortName as 'AirlineName' from AirVendorLookup where AirlineCode in        
(      
 select distinct(airSegmentMarketingAirlineCode) as 'AirlineCode'      
 from TripAirSegments tas      
 inner join TripAirResponse tar      
  on tar.airResponseKey = tas.airResponseKey       
 inner join Trip t      
  on tar.tripKey = t.tripKey        
 and airSegmentMarketingAirlineCode <> ''      
 and t.siteKey = @siteKey      
) order by ShortName     
End

GO
