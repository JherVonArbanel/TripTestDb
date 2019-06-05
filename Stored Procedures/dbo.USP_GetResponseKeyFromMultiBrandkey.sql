SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetResponseKeyFromMultiBrandkey]
(
@multiBrandResponseKey UNIQUEIDENTIFIER = null
)
AS
BEGIN
IF (@multiBrandResponseKey IS NOT NULL AND @multiBrandResponseKey <> '{00000000-0000-0000-0000-000000000000}')  
	BEGIN  
		SELECT airResponseKey FROM AirResponseMultiBrand WHERE airResponseMultiBrandKey = @multiBrandResponseKey  
	END 
END
GO
