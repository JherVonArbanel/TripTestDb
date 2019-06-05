SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_CheckCarVendorCodeInCityByTripRequestKey]
	-- Add the parameters for the stored procedure here
	@tripRequestKey INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @isVendorExist BIT = 1
    DECLARE @isAirportExist BIT = 1
    
    
    IF NOT EXISTS
	(SELECT 1
	FROM TripRequest T INNER JOIN 
	[CarContent].[dbo].[SabreLocations] SL ON SL.[LocationAirportCode] = T.TripTo1)  
		BEGIN
			SET @isAirportExist = 0
			SET @isVendorExist = 0
		END
	ELSE
		BEGIN	
			IF NOT EXISTS
			(SELECT 1
			FROM TripRequest T INNER JOIN TripRequest_car TC ON T.tripRequestKey = TC.tripRequestKey AND T.tripRequestKey = @tripRequestKey
								INNER JOIN CarResponse CR ON TC.carRequestKey = CR.carRequestKey
								INNER JOIN CarResponseDetail CRD ON CR.CarResponseKey = CRD.CarResponseKey
								INNER JOIN [CarContent].[dbo].[SabreLocations] SL ON SL.[LocationAirportCode] = T.TripTo1  AND SL.[VendorCode] = CRD.carVendorKey)
							BEGIN
							SET @isVendorExist = 0
							END
		END			
	SELECT @isVendorExist,@isAirportExist
					
END
GO
