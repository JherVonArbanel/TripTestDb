SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetAgentwareConnection]
(
	@ConnectionId INT
)
AS
BEGIN
	SELECT 
		ISNULL(ConnectionId,0) as ConnectionId,
		ISNULL(URL, '') as URL,
		ISNULL(UserId, '') as UserId,
		ISNULL([Password],'') as Password,
		ISNULL(Environment,'') as Environment
	FROM 
		AgentwareConnection
	WHERE 
		ConnectionId = @ConnectionId
END
GO
