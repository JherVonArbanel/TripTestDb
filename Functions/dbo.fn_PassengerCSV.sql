SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- SELECT [dbo].[fn_GetOWAirRoutes]('FB525425-8D5D-4DC8-B5E4-7145CE02B4C3', 'DEP')
CREATE FUNCTION [dbo].[fn_PassengerCSV]
( 
	@tripKey AS INT,
	@Opt AS VARCHAR(5)
)  
RETURNS VARCHAR (MAX)   
AS BEGIN

	DECLARE @PassName VARCHAR(MAX)
	SET @PassName = ''
	
	IF @Opt = 'Pass'  
	BEGIN
		SELECT @PassName = @PassName + PassengerFirstName + ' ' + PassengerLastName + ', ' 
		FROM  TripPassengerInfo TPI WITH(NOLOCK) 
		WHERE TPI.TripKey = @tripKey AND TPI.Active = 1 

		SET @PassName = ( SUBSTRING(@PassName, 1, LEN(@PassName)-1) )
	END
	ELSE IF @Opt = 'UDID' 
	BEGIN
		SELECT @PassName = @PassName + '(UDID - ' + CONVERT(VARCHAR, TCVP.CompanyUDIDNumber) + '/' + TCVP.PassengerUDIDValue + ')' + ', ' 
		FROM  TripPassengerUDIDInfo TCVP WITH(NOLOCK) 
			INNER JOIN TripPassengerInfo TPI WITH(NOLOCK) ON TCVP.TripKey = TPI.TripKey AND TCVP.PassengerKey = TPI.PassengerKey 
		WHERE TPI.TripKey = @tripKey AND TPI.Active = 1 
	
		SET @PassName = ( SUBSTRING(@PassName, 1, LEN(@PassName)-1) )
	END
	RETURN @PassName
	
END
GO
