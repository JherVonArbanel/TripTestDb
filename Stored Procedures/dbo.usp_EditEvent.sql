SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Keyur Sheth
-- Create date: 23rd July 2014
-- Description:	This stored procedure is used to save event in case of changed data
-- =============================================
CREATE PROCEDURE [dbo].[usp_EditEvent]
(
	 @eventName VARCHAR(50)
	,@eventDesc VARCHAR(1000)
	,@startDate DATETIME
	,@endDate DATETIME
	,@viewershipType INT
	,@isInviteAllowed BIT
	,@eventkey BIGINT
	,@IsRecommendingHotel BIT = 0
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE 
		[Trip].[dbo].[Events]
    SET
       [eventName] = @eventName
      ,[eventDescription] = @eventDesc
      ,[eventStartDate] = @startDate
      ,[eventEndDate] = @endDate
      ,[eventViewershipType] = @viewershipType
      ,[isInviteFromAttendeeAllowed] = @isInviteAllowed
      ,[IsRecommendingHotel] =@IsRecommendingHotel
      ,[modifiedDate] = GETDATE()
   WHERE
		[eventKey] = @eventkey
END


GO
