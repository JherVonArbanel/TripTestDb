SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[usp_GetGDSRestCredentials] 
(
@sabreConnectionID Int=0,
@hotelsComConnectionID int=0,
@touricoConnectionID int =0  
)
AS
BEGIN

SELECT restAPIUserID,restAPISecret,restAPIbase64String FROM SabreConnection WITH(NOLOCK) WHERE ConnectionID = @sabreConnectionID 
SELECT cid,sig,apiKey FROM HotelsComConnection WITH(NOLOCK) WHERE connectionID = @hotelsComConnectionID
END
GO
