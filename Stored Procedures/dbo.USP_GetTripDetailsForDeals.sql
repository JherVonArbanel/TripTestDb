SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Anupam Patel
-- Create date: 27/04/2015
-- Description:	It is used to get trip details for timeline
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripDetailsForDeals]
	@tripKey INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT
      [tripStartDate]
      [fromCountryCode]
      ,[fromCountryName]
      ,[fromStateCode]
      ,[fromCityName]
      ,[toCountryCode]
      ,[toCountryName]
      ,[toStateCode]
      ,[toCityName]
      ,[tripEndDate]
      ,[LatestAirLineCode]
      ,[LatestHotelChainCode]
      ,[LatestCarVendorName]
      ,[CrowdId]
  FROM [Trip].[dbo].[TripDetails]
  WHERE tripKey = @tripKey	
END
GO
