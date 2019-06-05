SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDeleteSabreConnection] 
(
	@ConnectionID INT
)
AS

	SET NOCOUNT ON

	DELETE FROM [SabreConnection]
	WHERE [ConnectionID] = @ConnectionID
GO
