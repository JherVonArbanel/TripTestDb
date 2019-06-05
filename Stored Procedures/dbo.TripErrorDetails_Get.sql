SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TripErrorDetails_Get]
@RequestKey INT,
@tripComponentType SMALLINT,
@Category VARCHAR(10)
AS
BEGIN
	SELECT TOP 1 ErrorDescription 
	FROM [Trip].[dbo].[TripErrorDetails]
	WHERE tripComponentType = @tripComponentType AND Category = @Category AND RequestKey = @RequestKey 
	ORDER BY CreatedDate DESC
END
GO
