SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- EXEC usp_GetViatorConnection 1
CREATE PROC [dbo].[usp_GetViatorConnection]
(
	@ConnectionId INT
)
AS
BEGIN

	SELECT 
		ISNULL(ConnectionId,0) as ConnectionId,
		ISNULL(URL, '') as URL,
		ISNULL(Environment,'') as Environment
	FROM 
		ViatorConnection 
	WHERE 
		ConnectionId = @ConnectionId

END
GO
