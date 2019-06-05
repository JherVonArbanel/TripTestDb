SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
--Exec USP_GetTripSavedDealHotelSearchParamByGroupId 64  
  
CREATE PROCEDURE [dbo].[USP_GetTripSavedDealHotelSearchParamByGroupId]  
 -- Add the parameters for the stored procedure here  
 @PkGroupId int  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT OFF;  
   
 --BEGIN TRY  
   
  Declare @pkId int  
    ,@ExtraChildrenCount int  
    ,@ChildrenCount int  
    ,@GuestCount int -- For Sabre  
  
      
  Set @pkId = (Select Top 1 PkId From HotelRequestTripSavedDeal With (NoLock) Where IsSearched = 0 and PkGroupId = @PkGroupId and ISNULL(NoOfTotalTraveler,0) > 0)  
    
  Update HotelRequestTripSavedDeal Set IsSearched = 1 Where PkGroupId = @PkGroupId  
  
  Set @ChildrenCount = (Select ISNULL(TripInfantCount,0) + ISNULL(TripChildCount,0) From HotelRequestTripSavedDeal With (NoLock) Where PkId = @pkId)  
  
  If(@ChildrenCount > 2) -- For Sabre  
   Begin  
    Set @ExtraChildrenCount = (@ChildrenCount - 2)  
    Set @GuestCount = (Select ISNULL(TripAdultsCount,0) + ISNULL(TripSeniorsCount,0) + ISNULL(TripYouthCount,0) + @ExtraChildrenCount  
    From HotelRequestTripSavedDeal With (NoLock) Where PkId = @pkId)  
   End  
  Else  
   Begin  
    Set @GuestCount = (Select ISNULL(TripAdultsCount,0) + ISNULL(TripSeniorsCount,0) + ISNULL(TripYouthCount,0) + ISNULL(@ChildrenCount,0)  
    From HotelRequestTripSavedDeal With (NoLock) Where PkId = @pkId)  
   End  
  
  Select PkId,TripKey,TripRequestKey,NoOfDays,NoOfRooms,HotelCityCode = originalSearchToCity,CheckInDate,CheckOutDate  
      ,AdultsCount = (ISNULL(TripAdultsCount,0) + ISNULL(TripSeniorsCount,0))  
      ,ChildCount = (ISNULL(TripYouthCount,0) + ISNULL(TripChildCount,0) + ISNULL(TripInfantCount,0)),NoOfTotalTraveler  
      ,GuestCount = @GuestCount,Rating  
  From HotelRequestTripSavedDeal With (NoLock) Where PkId = @pkId  
   
 --END TRY  
 --BEGIN CATCH  
 -- DECLARE @ErrorMessage NVARCHAR(4000);  
 -- SET @ErrorMessage = ERROR_MESSAGE();  
 -- --RAISERROR (@ErrorMessage, 16, 1);  
 -- INSERT INTO TripSavedDealLog (ErrorMessage, ErrorStack) Values ('Error in stored procedure USP_GetTripSavedDealHotelSearchParamByGroupId. Group ID : ' + CONVERT(varchar,@PkGroupId), @ErrorMessage)  
 --END CATCH;  
   
END
GO
