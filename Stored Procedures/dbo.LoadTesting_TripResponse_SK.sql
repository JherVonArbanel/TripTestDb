SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[LoadTesting_TripResponse_SK]
(
	@TripRequestKeyFrom INT=0,
	@TripRequestKeyTo INT=0
)
AS
BEGIN
;WITH CTE as 
(
SELECT 
		TIP.tripRequestKey tripRequestKey,
		COUNT(A.airSubRequestKey) Resp,
		'Air' Resp_Type
FROM	AirResponse A WITH(NOLOCK)
		INNER JOIN AirSubRequest AR WITH(NOLOCK) on A.airSubRequestKey = AR.airSubRequestKey
		INNER JOIN AirRequest AIR WITH(NOLOCK) on AIR.airRequestkey = AR.airRequestKey
		INNER JOIN TripRequest_air TIP WITH(NOLOCK) on TIP.airRequestKey = AIR.airRequestkey
		INNER JOIN TripRequest tr WITH(NOLOCK) on tr.tripRequestKey=tip.tripRequestKey
WHERE TIP.tripRequestKey BETWEEN @TripRequestKeyFrom and @TripRequestKeyTo
GROUP BY TIP.tripRequestKey
UNION ALL
SELECT 
		tr.tripRequestKey tripRequestKey,
		COUNT(H_Resp.hotelRequestKey) Resp,
		'Hotel' Resp_Type
FROM	TripRequest tr  WITH(NOLOCK)
		INNER JOIN TripRequest_hotel  C WITH(NOLOCK) on tr.tripRequestKey=C.tripRequestKey
		INNER JOIN HotelResponse H_Resp WITH(NOLOCK) on c.hotelRequestKey=H_Resp.hotelRequestKey
WHERE tr.tripRequestKey BETWEEN @TripRequestKeyFrom and @TripRequestKeyTo
GROUP BY tr.tripRequestKey	
UNION ALL
SELECT 
		tr.tripRequestKey tripRequestKey,
		COUNT(C_Resp.carRequestKey) Resp,
		'Car' Resp_Type
FROM	TripRequest tr WITH(NOLOCK)
		INNER JOIN TripRequest_car  D WITH(NOLOCK) on tr.tripRequestKey=D.tripRequestKey
		INNER JOIN CarResponse C_Resp WITH(NOLOCK) on d.carRequestKey=C_Resp.carRequestKey
WHERE tr.tripRequestKey BETWEEN @TripRequestKeyFrom and @TripRequestKeyTo
GROUP BY tr.tripRequestKey
)
SELECT  TripRequestKey,[Air],[Hotel],[Car]
FROM CTE
 PIVOT
(
      sum(Resp)
       FOR Resp_Type in([Air],[Hotel],[Car])
	   
) AS P
ORDER BY tripRequestKey DESC
END
GO
