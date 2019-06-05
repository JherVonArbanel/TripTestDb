SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spSelectAllSabreConnection]
AS

	SET NOCOUNT ON

	SELECT [ConnectionID], [UserName], [Password], [URL], [Ipcc], [Domain], [FromPartyId], [ToPartyId], [MessageId]
	FROM [SabreConnection]
GO
