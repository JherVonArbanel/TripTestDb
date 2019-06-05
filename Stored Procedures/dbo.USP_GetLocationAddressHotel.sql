SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,SELECT AirportLookup table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_GetLocationAddressHotel]
@location  varchar(64)

AS
BEGIN
 
SELECT AirportName,CityName,StateCode,CountryCode,AirportCode FROM AirportLookup WHERE @location LIKE '% ' + CityName + '%'

END
GO
