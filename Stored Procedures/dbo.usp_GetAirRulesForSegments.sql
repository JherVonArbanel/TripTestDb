SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_GetAirRulesForSegments] 
(
@segmentIds varchar(2000)
)
AS
BEGIN 

DECLARE @Segments as Table 
(
 segmentId varchar(100)
)


INSERT INTO @Segments  select * From ufn_CSVSplitString(@segmentIds) 


SELECT * FROM AirTripRule ATR inner join @Segments S on ATR.airSegmentKey =S.segmentId 



END
GO
