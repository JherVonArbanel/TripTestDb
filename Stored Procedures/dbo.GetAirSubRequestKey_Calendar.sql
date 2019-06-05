SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[GetAirSubRequestKey_Calendar] 
(
	@airRequestKey INT
)
AS              
BEGIN 
	SELECT * FROM trip..AirSubRequest 
	WHERE airRequestKey = @airRequestKey 
	and groupKey = 3 
END
 
GO
