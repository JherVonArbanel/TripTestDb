SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
-- =============================================  
-- Author:  Manoj Kumar Naik  
-- Create date: 9/4/2018 4:24pm  
-- Description: Get Seat Map JSON Response by segmentID  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_GetSeatMapResponseBySegmentID]  
  
@airSegmentKey uniqueIdentifier, @FFNumber nvarchar(20)  
  
AS  
BEGIN  
  
     --SELECT TOP 1 airSeatMapResponseJSON FROM Trip..AirSeatMapResponse WHERE airSegmentKey = @airSegmentKey and (@FFNumber IS NULL OR FFNumber = @FFNumber  )
  SELECT '' as airSeatMapResponseJSON 
END
GO
