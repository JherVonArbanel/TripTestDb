SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--EXEC USP_GetIncompleteTripAttachmentByTripID 339909
CREATE PROCEDURE  [dbo].[USP_GetIncompleteTripAttachmentByTripID]
	 @TripRequestKey INT
AS
BEGIN
	SELECT WSName, XmlData
	FROM LOG..AuditLogs
	WHERE TripRequestkey = @TripRequestKey 
	AND [TYPE] = 'PURCHASE' 
	AND LogLevelKey = 6
	ORDER BY AuditKey 
END
GO
