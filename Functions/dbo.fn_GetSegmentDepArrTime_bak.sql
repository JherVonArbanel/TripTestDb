SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- SELECT [dbo].[fn_GetSegmentDepArrTime]('FB525425-8D5D-4DC8-B5E4-7145CE02B4C3', 'ARR')
CREATE function [dbo].[fn_GetSegmentDepArrTime_bak]
( 
	@airresponsekey AS UNIQUEIDENTIFIER
	,@Time VARCHAR(15)
)  
RETURNS VARCHAR (4000)   
AS BEGIN

	DECLARE @Results VARCHAR(MAX)
	SELECT @Results = ''

	IF @Time = 'DEP' 
	BEGIN
		SELECT @Results = CONVERT(TIME, MAX(TAS.airSegmentDepartureDate), 103)
		FROM TripAirSegments  TAS
			INNER JOIN TripAirLegs legs ON ( TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
				   AND TAS.airLegNumber = legs.airLegNumber  )
		WHERE TAS.airResponseKey = @airresponsekey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
			AND TAS.airLegNumber = 1
	END
	ELSE
	BEGIN
		SELECT @Results = CONVERT(TIME, MIN(TAS.airSegmentDepartureDate), 103)
		FROM TripAirSegments  TAS
			INNER JOIN TripAirLegs legs ON ( TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
				   AND TAS.airLegNumber = legs.airLegNumber  )
		WHERE TAS.airResponseKey = @airresponsekey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
			AND TAS.airLegNumber = 2
	END

	RETURN( @Results  )
 
END
GO
