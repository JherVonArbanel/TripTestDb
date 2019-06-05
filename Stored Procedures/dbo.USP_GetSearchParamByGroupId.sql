SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec USP_GetSearchParamByGroupId 1
CREATE PROCEDURE [dbo].[USP_GetSearchParamByGroupId]
	-- Add the parameters for the stored procedure here
	@PkGroupId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
    Declare @pkId int
    Set @pkId = (Select top 1 PkId from AirRequestForBid where IsSearched = 0 and PkGroupId = @PkGroupId)
    
    update AirRequestForBid set IsSearched = 1 where PkGroupId = @PkGroupId
    
	select PkId,PkGroupId,AirRequestType,TripRequestKey,TripKey,IsInternationalTrip,ClassLevel
	,Adults,Children,Seniors from AirRequestForBid where PkId = @pkId
	
	select AirRequestType,DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,LegIndex1
	,DepartureAirportLeg2,ArrivalAirportLeg2,DepartureDateLeg2,LegIndex2
	,DepartureAirportLeg3,ArrivalAirportLeg3,DepartureDateLeg3,LegIndex3
	,DepartureAirportLeg4,ArrivalAirportLeg4,DepartureDateLeg4,LegIndex4
	,DepartureAirportLeg5,ArrivalAirportLeg5,DepartureDateLeg5,LegIndex5
	,DepartureAirportLeg6,ArrivalAirportLeg6,DepartureDateLeg6,LegIndex6
	from AirRequestForBid where PkId = @pkId
	
END
GO
