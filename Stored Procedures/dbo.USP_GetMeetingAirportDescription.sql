SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- EXEC [USP_GetMeetingAirportDescription] 'dfw,las'
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 09/28/2011 11:56:36
-- Description:	Meeting Destination Airport Description.
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetMeetingAirportDescription] 
	-- Add the parameters for the stored procedure here
	@meetingAirportCode		VARCHAR(100)
AS
BEGIN
	
	select CityName + '-' + AirportName + ' [' + AirportCode + '],' + CountryCode 
			as meetingAirportDescription from AirportLookup airport
			inner join  Vault.dbo.ufn_CSVToTable_SortByID (@meetingAirportCode)  
			AS Filter
			on airport.AirportCode = Filter.string
		order by Filter. CSVToTableID
END
GO
