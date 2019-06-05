SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--select * from AirLineBaggageLink
CREATE procedure [dbo].[USP_GetAirVendors]     
@airLinecodes nvarchar(MAX)      
AS      
BEGIN      
IF 1<>1 --IF(@airLinecodes<> '')      
	BEGIN      
	 select  airLinecode , shortname, AirlineProgrammes from AirVendorLookup     
	 inner join Vault.dbo.ufn_CSVToTable(@airLinecodes) tmp1 on airLinecode = tmp1.String       
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
