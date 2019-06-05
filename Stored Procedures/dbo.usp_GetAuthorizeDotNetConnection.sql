SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- EXEC usp_GetViatorConnection 1
CREATE PROC [dbo].[usp_GetAuthorizeDotNetConnection]
(
	@ConnectionId INT
)
AS
BEGIN

	SELECT 
		ISNULL(ConnectionId,0) as ConnectionId,
		ISNULL(UserId, '') as UserId,
		ISNULL([Password],'') as Password,
		ISNULL(Environment,'') as Environment
	FROM 
		AuthorizeDotNetConnection
	WHERE 
		ConnectionId = @ConnectionId

END
GO
