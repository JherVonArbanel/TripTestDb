SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GetTravelfusionConnection]
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
		ISNULL(XMLloginID,'') as XMLloginID,
		ISNULL(Environment,'') as Environment
	FROM 
		TravelfusionConnection
	WHERE 
		ConnectionId = @ConnectionId
END
GO
