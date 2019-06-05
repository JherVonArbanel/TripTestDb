SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_CheckAirSearchCompleted]
 ( @airRequestKey as int )
 AS
declare @isInternationalTrip as bit 
 
DECLARE @airRequestType as int
SELECT @isInternationalTrip = isInternationalTrip , @airRequestType = airRequestTypeKey  
FROM AirRequest  WHERE airRequestKey = @airRequestKey 
DECLARE @operationCompleted as bit = 0  
DECLARE @noOfRequestMade  as INT = (SELECT NoOFRequestSentToGDS from TripRequest_Air WITH (NOLOCK)
								    WHERE airRequestKey = @airRequestKey  )

if (@airRequestType = 1 ) --One Way
BEGIN 
--IF ( SELECT COUNT(*) FROM AirResponse AR INNER JOIN AirSubRequest SUB on AR.airSubRequestKey = SUB.airSubRequestKey WHERE airRequestKey =@airRequestKey ) >0 
IF( SELECT COUNT(*) FROM BFMRequestCompletion 
	WITH (NOLOCK)
	WHERE AirRequestID = @airRequestKey) >=(Case WHEN  @noOfRequestMade > 0 then @noOfRequestMade else 1  END) 
	BEGIN 
		--PRINT ('One Way')
		SET @operationCompleted = 1 
	END
END 
ELSE  IF  (@airRequestType = 2 ) --Round Trip
BEGIN
IF ( @isInternationalTrip = 0 ) ---Domestic
	BEGIN 
	--IF( SELECT COUNT(DISTINCT SUB.AirSubRequestkey ) FROM AirResponse AR INNER JOIN AirSubRequest SUB on AR.airSubRequestKey = SUB.airSubRequestKey WHERE airRequestKey =@airRequestKey ) = 3 
	IF( SELECT COUNT(*) FROM BFMRequestCompletion
		WITH (NOLOCK)
		WHERE AirRequestID= @airRequestKey) >=(Case WHEN  @noOfRequestMade > 0 then @noOfRequestMade else 3 END) 
		BEGIN 
		--	PRINT ('ROUNDTRIP DOMESTIC')
		SET @operationCompleted = 1 
		END
	END 
	ELSE ---International
		BEGIN 
	---	IF ( SELECT COUNT(DISTINCT AR.AirSubRequestkey ) FROM AirResponse AR INNER JOIN AirSubRequest SUB on AR.airSubRequestKey = SUB.airSubRequestKey WHERE airRequestKey =@airRequestKey ) = 1
	IF ( SELECT COUNT(*) FROM BFMRequestCompletion 
		WITH (NOLOCK)
		WHERE AirRequestID = @airRequestKey ) >=(Case WHEN  @noOfRequestMade > 0 then @noOfRequestMade else 4 END )  
		BEGIN 
			--PRINT ('ROUNDTRIP INTERNATIONAL')
			SET @operationCompleted = 1 
		END
	END 

END
 
  
ELSE IF ( @airRequestType = 3) --multicity
BEGIN 
  
 
--IF ( SELECT COUNT(*) FROM AirResponse AR INNER JOIN AirSubRequest SUB on AR.airSubRequestKey = SUB.airSubRequestKey WHERE airRequestKey =@airRequestKey and airSubRequestLegIndex = -1 ) >0 
IF( SELECT COUNT(*) FROM BFMRequestCompletion
	WITH (NOLOCK)
	WHERE AirRequestID= @airRequestKey ) >=(Case WHEN  @noOfRequestMade > 0 then @noOfRequestMade else 6 END)
	BEGIN 
	--PRINT ('MULTICITY')
		SET @operationCompleted = 1 
	END
END 

SELECT @operationCompleted

GO
