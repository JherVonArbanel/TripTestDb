SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 30-12-2015
-- Description:	Getting TimeLineGroup Count by UserId.
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTimeLineGroupCountByUserId]
	-- Add the parameters for the stored procedure here
	@userKey bigint
AS
BEGIN
	 -- SET NOCOUNT ON added to prevent extra result sets from
	 -- interfering with SELECT statements.
	 SET NOCOUNT ON;

	 SELECT COUNT(*) as timeLineGroupCount, timeLineGroupKey   
	 FROM Trip..TimeLine  
	 WHERE userKey = @userKey  
	 GROUP BY TimeLineGroupKey

END
GO
