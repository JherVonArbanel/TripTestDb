SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Manoj Kumar Naik  
-- Create date: 08/25/2011  
-- Description: Get Airline Carriage Link as per airline codes  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_GetAirlineBaggageLink1]   
@airlinecodes nvarchar(MAX)  
AS  
  
BEGIN  
 IF(@airLinecodes<> '')  
 BEGIN  
  select  abk.airlineCode , abk.airlineBaggageLink, avl.ShortName as airlineName from AirlineBaggageLink1 abk inner join Vault.dbo.ufn_CSVToTable(@airLinecodes) tmp1 on airlineCode = tmp1.String inner join vault.dbo.AirVendorLookup avl on avl.airlineCode =
 tmp1.String  
 END  
 ELSE   
 BEGIN  
  select  abk.airlineCode , abk.airlineBaggageLink , avl.ShortName as airlineName from AirlineBaggageLink1  abk inner join vault.dbo.AirVendorLookup avl on avl.airlineCode = abk.airlineCode  
 END  
END  
GO
