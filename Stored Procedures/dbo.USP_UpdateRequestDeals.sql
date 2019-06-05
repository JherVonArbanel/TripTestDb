SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 23rd Oct 2012
-- Description:	For Nightly Robot Testing Tool
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateRequestDeals]
	-- Add the parameters for the stored procedure here
	@TripKey Varchar(10)
	,@Type Varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Declare @GroupID Int
    -- Insert statements for procedure here
	If(@Type = 'CAR')
	Begin
		Set @GroupID = (Select PkGroupId From CarRequestTripSavedDeal Where TripKey = @TripKey)
		Update CarRequestTripSavedDeal Set IsSearched = 1 Where PkGroupId <> @GroupID
		Update CarRequestTripSavedDeal Set IsSearched = 0 Where PkGroupId = @GroupID
	End
	
	Else If(@Type = 'AIR')
	Begin
		Set @GroupID = (Select PkGroupId From AirRequestTripSavedDeal Where TripKey = @TripKey)
		Update AirRequestTripSavedDeal Set IsSearched = 1 Where PkGroupId <> @GroupID
		Update AirRequestTripSavedDeal Set IsSearched = 0 Where PkGroupId = @GroupID
	End
	
	Else If(@Type = 'HOTEL')
	Begin
		Set @GroupID = (Select PkGroupId From HotelRequestTripSavedDeal Where TripKey = @TripKey)
		Update HotelRequestTripSavedDeal Set IsSearched = 1 Where PkGroupId <> @GroupID
		Update HotelRequestTripSavedDeal Set IsSearched = 0 Where PkGroupId = @GroupID
	End
	
	Select @GroupID
	
END
GO
