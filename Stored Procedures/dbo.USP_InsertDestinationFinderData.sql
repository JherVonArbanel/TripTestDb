SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_InsertDestinationFinderData] 
(	
@Origin varchar(5),
@CacheData nvarchar(max),
@FilteredCacheData nvarchar(max)
)
AS
BEGIN

	IF EXISTS(select 1 from DestinationFinderData where (Origin = @Origin))
		BEGIN
			UPDATE DestinationFinderData
			SET CacheData = @CacheData,FilteredCacheData = @FilteredCacheData,CreatedDate = GETDATE()
			WHERE Origin = @Origin
			SELECT 1
		END
	ELSE
		BEGIN
			SELECT 0
		END
END
GO
