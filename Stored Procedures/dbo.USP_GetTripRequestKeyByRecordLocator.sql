SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetTripRequestKeyByRecordLocator]
(
	@RecordLocator VARCHAR(10)
)
AS
BEGIN
	SELECT TOP 1 
			tripRequestKey 
	FROM	trip..trip
	WHERE	recordLocator=@RecordLocator
	UNION ALL 
	SELECT 0
	WHERE NOT EXISTS (SELECT TOP 1 
			tripRequestKey 
	FROM	trip..trip
	WHERE	recordLocator=@RecordLocator)
END
GO
