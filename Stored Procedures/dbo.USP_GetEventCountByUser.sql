SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Rajkumar
-- Create date: 07-Dec-2015
-- Description:	Get Crowd Count of the User
-- =============================================

CREATE PROCEDURE [dbo].[USP_GetEventCountByUser]
	@UserId int
	--@SiteKey int
AS
BEGIN
	
	SET NOCOUNT ON;

	Select Count(*) as EventCount
    FROM [dbo].[Events] E 
	WHERE  E.IsDeleted = 0 and E.userKey = @UserId

END
GO
