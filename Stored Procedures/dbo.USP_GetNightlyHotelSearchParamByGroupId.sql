SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--Exec [USP_GetNightlyHotelSearchParamByGroupId] 3
Create PROCEDURE [dbo].[USP_GetNightlyHotelSearchParamByGroupId]
	-- Add the parameters for the stored procedure here
	@PkGroupId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Declare @pkId int
    Set @pkId = (Select Top 1 PkId From HotelRequestNightly Where IsSearched = 0 and PkGroupId = @PkGroupId)
    
    Update HotelRequestNightly Set IsSearched = 1 Where PkGroupId = @PkGroupId
    
	Select PkId,TripKey,TripRequestKey,NoOfDays,NoOfRooms,HotelCityCode,CheckInDate,CheckOutDate
	From HotelRequestNightly Where PkId = @pkId
	
END
GO
