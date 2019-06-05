SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetIncludedServices]
(  
	@airSegmentKey	UNIQUEIDENTIFIER, 
	@icons			VARCHAR(50),
	@withIcon		VARCHAR(3)
)AS  
  
BEGIN  

	IF @withIcon = 'YES'
	BEGIN

		SELECT * FROM AirSegmentOptionalServices WHERE airSegmentKey = @airSegmentKey AND icon IN (@icons) 
	
	END
	ELSE
	BEGIN
	
		SELECT * FROM AirSegmentOptionalServices WHERE airSegmentKey = @airSegmentKey
	
	END

END  

GO
