SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Anupam Patel
-- Create date: 23/Apr/2015
-- Description:	It is used for modified last updated Time of groups
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateTimeOfTimeLineGroups]
	@timeLineGroupKey INT,
	@updatedTime DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
	Update TimeLineGroups
	SET LastUpdated = @updatedTime
	WHERE timeLineGroupKey = @timeLineGroupKey
	
END

GO
