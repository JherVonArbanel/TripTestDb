SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 08/24/2011
-- Description:	Get Airline Carriage Link as per airline codes
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetAirlineCarriageLink] 
@airlinecodes nvarchar(MAX)
AS

BEGIN
	IF(@airLinecodes<> '')
	BEGIN
	 select DISTINCT  airline , conditionOfCarriageLink,AVL.ShortName from AirlineCarriageLink 
	 INNER JOIN vault..AirVendorLookup AS AVL ON AirlineCarriageLink.airline = AVL.AirlineCode
	 inner join Vault.dbo.ufn_CSVToTable(@airLinecodes) tmp1 on airline = tmp1.String 
	 ORDER BY AVL.ShortName
	END
	ELSE 
	BEGIN
	 select DISTINCT airline , conditionOfCarriageLink, AVL.ShortName from AirlineCarriageLink 
	 INNER JOIN vault..AirVendorLookup AS AVL ON AirlineCarriageLink.airline = AVL.AirlineCode
	 ORDER BY AVL.ShortName 
	END
END
GO
