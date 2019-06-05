SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--Exec [USP_GetNightlyCarSearchParamByGroupId] 1
CREATE PROCEDURE [dbo].[USP_GetTripSavedDealCarSearchParamByGroupId]
	-- Add the parameters for the stored procedure here
	@PkGroupId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Declare @pkId int
    Set @pkId = (Select top 1 PkId from CarRequestTripSavedDeal where IsSearched = 0 and PkGroupId = @PkGroupId)
    
    update CarRequestTripSavedDeal set IsSearched = 1 where PkGroupId = @PkGroupId
    
	select PkId,TripKey,TripRequestKey,NoOfDays = ISNULL(NoOfDays,0),NoOfCars = ISNULL(NoOfCars,1),PickupCityCode,DropOffCityCode,PickupDate,DropOffDate 
	from CarRequestTripSavedDeal where PkId = @pkId
END
GO
