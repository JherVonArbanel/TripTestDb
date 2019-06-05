SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UpdateSecondLegOneWayResponse] ( @airrequestkey int ) 
AS
  /**Code for halfing the price for second leg ***/
	DECLARE @temp AS TABLE 
	(
		airresponsekey   UNIQUEIDENTIFIER, 
		price   FLOAT 
	)
-- insert @temp ( airresponsekey ,price)
--select a.airresponsekey , b.airPriceBase /2    from 
--(select n.*,r.airPriceBase  from NormalizedAirResponses n 
--inner join AirResponse r on n.airresponsekey =r.airResponseKey 
--inner join AirSubRequest s  on n.airsubrequestkey = s.airSubRequestKey 
-- where  AirRequestkey = @airrequestkey and airSubRequestLegIndex = 2 ) as a ,
 
-- (
-- select n.*,r.airPriceBase  from NormalizedAirResponses n 
--inner join AirResponse r on n.airresponsekey =r.airResponseKey 
--inner join AirSubRequest s  on n.airsubrequestkey = s.airSubRequestKey 
-- where  AirRequestkey = @airrequestkey and airSubRequestLegIndex = -1 )  as b where a.flightNumber = b.flightNumber 

	DECLARE @secondLegRequest AS INT =(SELECT airSubRequestKey FROM AirSubRequest WHERE airRequestKey = @airrequestkey AND airSubRequestLegIndex = 2) 
	DECLARE @roundTripRequest AS INT =(SELECT airSubRequestKey FROM AirSubRequest WHERE airRequestKey = @airrequestkey AND airSubRequestLegIndex = -1) 

	IF(SELECT COUNT(*) FROM NormalizedAirResponses WHERE airsubrequestkey = @roundTripRequest ) > 0 
	BEGIN 
		INSERT @temp (airresponsekey, price)
		SELECT DISTINCT a.airresponsekey, b.airPriceBase / 2    
		FROM 
		(
			SELECT n.*,r.airPriceBase  
			FROM NormalizedAirResponses n 
				INNER JOIN AirResponse r on n.airresponsekey =r.airResponseKey 
				INNER JOIN AirSubRequest s  on n.airsubrequestkey = s.airSubRequestKey 
			WHERE  AirRequestkey = @airrequestkey AND airSubRequestLegIndex = 2 
		) AS a, 
		(
			SELECT n.*,r.airPriceBase  
			FROM NormalizedAirResponses n 
				INNER JOIN AirResponse r ON n.airresponsekey = r.airResponseKey 
				INNER JOIN AirSubRequest s ON n.airsubrequestkey = s.airSubRequestKey 
			WHERE AirRequestkey = @airrequestkey AND airSubRequestLegIndex = -1 
		) AS b WHERE a.airlines = b.airlines AND b.airLegNumber = 2

		DECLARE @airPrice AS FLOAT 
		SET @airPrice =((SELECT MAX(airPriceBase) FROM AirResponse r INNER JOIN AirSubRequest s ON r.airsubrequestkey = s.airSubRequestKey 
						 WHERE AirRequestkey = @airrequestkey AND airSubRequestLegIndex = -1) / 2)
 
		INSERT @temp (airresponsekey, price)
		(SELECT airresponsekey, @airPrice FROM NormalizedAirResponses WHERE airsubrequestkey = @secondLegRequest AND airlines NOT IN (SELECT airlines FROM NormalizedAirResponses WHERE airsubrequestkey = @roundTripRequest AND airLegNumber = 2))

		UPDATE AirResponse SET airPriceBase = price FROM AirResponse r INNER JOIN @temp t ON r.airResponseKey = t.airresponsekey 
END 
/*****/
GO
