SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- SELECT [dbo].[fn_GetSegmentDepArrDates]('8A22B734-A65E-43A5-B8BC-DC82E2CD23E8', 'ARR')
CREATE function [dbo].[fn_GetSegmentDepArrDates_bak]
( 
	@airresponsekey AS UNIQUEIDENTIFIER
	,@Dep_Arr VARCHAR(15)
)  
RETURNS VARCHAR (4000)   
AS BEGIN

	DECLARE @Results VARCHAR(MAX)
	SELECT @Results = ''

	IF @Dep_Arr = 'DEP' 
	BEGIN
		SELECT @Results = CONVERT(DATE, MAX(TAS.airSegmentDepartureDate), 103)
		FROM TripAirSegments  TAS
			INNER JOIN TripAirLegs legs ON ( TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
				   AND TAS.airLegNumber = legs.airLegNumber  )
		WHERE TAS.airResponseKey = @airresponsekey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
			AND TAS.airLegNumber = 1
	END
	ELSE
	BEGIN
		SELECT @Results = CONVERT(DATE, MIN(TAS.airSegmentDepartureDate), 103)
		FROM TripAirSegments  TAS
			INNER JOIN TripAirLegs legs ON ( TAS.tripAirLegsKey = TAS.tripAirLegsKey AND TAS.airResponseKey = legs.airResponseKey 
				   AND TAS.airLegNumber = legs.airLegNumber  )
		WHERE TAS.airResponseKey = @airresponsekey AND ISNULL (TAS.ISDELETED,0) = 0 AND ISNULL (legs.ISDELETED,0) = 0 
			AND TAS.airLegNumber = 2
	END

	RETURN( @Results  )
 
END
GO
