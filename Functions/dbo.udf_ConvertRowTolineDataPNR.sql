SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[udf_ConvertRowTolineDataPNR]
(
@TrackingLogID VARCHAR(4000) 
)
 RETURNS VARCHAR(4000)
 AS
 BEGIN
  DECLARE @listStr VARCHAR(MAX)
  SELECT @listStr = COALESCE(@listStr+',' ,'') + [recordLocator]
  FROM [Trip].[dbo].[Trip] where [TrackingLogID]= @TrackingLogID
  RETURN ISNULL(@listStr,'')
 END 

GO
