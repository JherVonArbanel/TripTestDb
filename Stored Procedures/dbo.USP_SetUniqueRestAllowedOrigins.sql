SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Ashima Gupta>
-- Create date: <13 May 2016>
-- Description:	<Set Unique Origins which are allowed in REST API>
-- =============================================
--exec [USP_SetUniqueRestAllowedOrigins]
CREATE PROCEDURE [dbo].[USP_SetUniqueRestAllowedOrigins]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	TRUNCATE TABLE DestinationFinderData
	INSERT INTO DestinationFinderData(Origin,CreatedDate)
	SELECT DISTINCT OriginAirportCode,GETDATE()
	FROM Vault..CityPairsLookup;
END
GO
