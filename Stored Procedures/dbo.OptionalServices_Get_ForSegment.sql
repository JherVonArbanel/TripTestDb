SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[OptionalServices_Get_ForSegment]  
(  
	@airSegmentKey	UNIQUEIDENTIFIER, 
	@subcode		VARCHAR(4000)  
)  
AS 
BEGIN  
  
	IF @subcode IS NOT NULL AND @subcode <> ''  
	BEGIN  
		PRINT('1')
		
		SELECT * FROM AirSegmentOptionalServices WHERE airSegmentKey = @airSegmentKey AND subcode IN (@subcode) 
	END  
	ELSE  
	BEGIN  
		PRINT('2')

		SELECT * FROM AirSegmentOptionalServices WHERE airSegmentKey = @airSegmentKey 
	END  
   
END
GO
