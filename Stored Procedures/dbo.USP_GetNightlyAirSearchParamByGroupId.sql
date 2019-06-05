SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec [USP_GetNightlyAirSearchParamByGroupId] 3
CREATE PROCEDURE [dbo].[USP_GetNightlyAirSearchParamByGroupId]
	-- Add the parameters for the stored procedure here
	@PkGroupId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
    Declare @pkId int
    Set @pkId = (Select top 1 PkId from AirRequestNightly where IsSearched = 0 and PkGroupId = @PkGroupId)
    
    Update AirRequestNightly Set IsSearched = 1 Where PkGroupId = @PkGroupId
    
	Select PkId,PkGroupId,AdultCount,SeniorCount,ChildCount,InfantCount,YouthCount,TotalTraveler,AirRequestTypeKey 
	,ClassLevel = 1,TripRequestKey,TripKey
	From AirRequestNightly Where PkId = @pkId
	
	Select DepartureAirportLeg1,ArrivalAirportLeg1,DepartureDateLeg1,LegIndex1
	,DepartureAirportLeg2,ArrivalAirportLeg2,DepartureDateLeg2,LegIndex2,AirRequestTypeKey
	From AirRequestNightly Where PkId = @pkId
	
END
GO
