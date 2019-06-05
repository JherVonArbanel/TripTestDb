SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Anupam Patel
-- Create date: 20/Apr/2015
-- Description:	It is used for getting Time line groups
-- Exec USP_GetTimeLineGroups
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTimeLineGroups]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [Name], LastUpdated
	From TimeLineGroups
	
END
GO
