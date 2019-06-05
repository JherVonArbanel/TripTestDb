SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 05-10-2016
-- Description:	Get latest pre checkin scheduler status and change the status.
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetStatusOfPreCheckInHotelScheduler] 
	
AS
BEGIN
     DECLARE @Status bit
     
     
     SELECT * FROM Trip..PreCheckInHotelSchedulerStatus
     
      SELECT @Status = Status FROM Trip..PreCheckInHotelSchedulerStatus
      
      IF(@Status = 0)
      BEGIN
        Update Trip..PreCheckInHotelSchedulerStatus SET [Status] = 1, [Description] = 'Running', CreatedDate = GETDATE()
      END
      ELSE
      BEGIN
         Update Trip..PreCheckInHotelSchedulerStatus SET [Status] = 0, [Description] = 'Not Running', CreatedDate = GETDATE()
      END
      
      
END
GO
