SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[usp_GetCachedDestinationFinderData] 
(	
@strSearchString varchar(5)
)
AS
BEGIN
SELECT FilteredCacheData from DestinationFinderData where Origin = @strSearchString
END
GO
