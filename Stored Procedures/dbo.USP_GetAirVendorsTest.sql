SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--select * from AirLineBaggageLink
CREATE procedure [dbo].[USP_GetAirVendorsTest]     
	@airLinecodes NvarcharList READONLY     
AS      
BEGIN      
IF EXISTS (SELECT 1 FROM @airLineCodes)      
	BEGIN      
	 select  airLinecode , shortname, AirlineProgrammes from AirVendorLookup     
	 inner join @airLinecodes tmp1 on airLinecode = tmp1.Value       
	 Where isValidAirline = 1 
	 order by ShortName        
	END      

ELSE       

	BEGIN      
	 select AirVendorLookup.airLinecode,AirVendorLookup.shortname,AirVendorLookup.AirlineProgrammes from AirVendorLookup 
	LEFT OUTER join AirLineBaggageLink on AirVendorLookup.AirlineCode =AirLineBaggageLink.AirlineCode
	and AirLineBaggageLink.checkInLink Is Not Null and AirLineBaggageLink.checkInLink <> ''
	 Where AirVendorLookup.isValidAirline = 1 
	order by AirVendorLookup.shortname
	END      
      
END 
GO
