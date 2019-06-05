SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetSabreSessionCountByConnectionId] 
(
	@ConnectionID INT
)

AS

	SET NOCOUNT ON

	SELECT COUNT(1) AS 'Count' FROM [SabreSession] WHERE [ConnectionID] = @ConnectionID 
GO
