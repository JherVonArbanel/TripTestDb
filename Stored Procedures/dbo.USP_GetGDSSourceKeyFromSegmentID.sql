SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetGDSSourceKeyFromSegmentID]
(
@airSegmentkey UNIQUEIDENTIFIER
)
AS
BEGIN
SELECT gdsSourceKey FROM AirResponse where airResponseKey IN (SELECT airResponseKey FROM AirSegments 
where airSegmentKey = @airSegmentkey)
END
GO
