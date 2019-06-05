SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Vaibhav Mehta>
-- Create date: <04-01-2019>
-- Description:	<Multicity - unification logic for primary and additional fares>
-- =============================================
CREATE   Procedure [dbo].[usp_UnifyResultsForMultiCity](@airBundledRequest int, @airPublishedFareRequest int,@airrequestkey int)
as
begin

 INSERT INTO #normal (airresponsekey,airsubrequestkey,leg1flightnumber,leg1airlines,leg1Connection,airPriceTotal,airLegBrandName,refundable)

 SELECT n1.airresponsekey,n1.airsubrequestkey,n1.flightNumber , n1.airlines,n1.airLegConnections ,A.airpricebaseTotal + A.airpriceTaxTotal,n1.airLegBrandName,a.refundable
 --,n3.flightNumber , n3.airlines,n3.airLegConnections 
 FROM NormalizedAirResponses N1 WITH (NOLOCK) INNER JOIN AirResponse A WITH (NOLOCK) on N1.airresponsekey = A.airresponsekey
WHERE (n1.airsubrequestkey =@airBundledRequest or n1.airSubrequestkey = @airPublishedFareRequest) and airlegnumber =1 
ORDER BY (A.airpricebaseTotal + A.airpriceTaxTotal) ASC , N1.airsubrequestkey,N1.airresponsekey

---Leg2
UPDATE  N SET leg2flightNUMBER = flightNumber , leg2Airlines = N1.airlines, leg2Connection = N1.airLegConnections FROM #normal N INNER JOIN NormalizedAirResponses N1 WITH (NOLOCK)ON N.airresponsekey = N1.airresponsekey AND N1.airlegnumber = 2 
UPDATE  N SET leg3flightNUMBER = flightNumber , leg3Airlines = N1.airlines, leg3Connection = N1.airLegConnections FROM #normal N INNER JOIN NormalizedAirResponses N1 WITH (NOLOCK) ON N.airresponsekey = N1.airresponsekey AND N1.airlegnumber = 3 
UPDATE  N SET leg4flightNUMBER = flightNumber , leg4Airlines = N1.airlines, leg4Connection = N1.airLegConnections FROM #normal N INNER JOIN NormalizedAirResponses N1 WITH (NOLOCK) ON N.airresponsekey = N1.airresponsekey AND N1.airlegnumber = 4 

UPDATE  N SET leg5flightNUMBER = flightNumber , leg5Airlines = N1.airlines, leg5Connection = N1.airLegConnections FROM #normal N INNER JOIN NormalizedAirResponses N1 WITH (NOLOCK) ON N.airresponsekey = N1.airresponsekey AND N1.airlegnumber = 5 
--leg6
UPDATE  N SET leg6flightNUMBER = flightNumber , leg6Airlines = N1.airlines, leg6Connection = N1.airLegConnections FROM #normal N INNER JOIN NormalizedAirResponses N1 WITH (NOLOCK) ON N.airresponsekey = N1.airresponsekey AND N1.airlegnumber = 6 

 

  --STEP 10 DELETE DUPLICATE KEEPING UNIQUES OPTIONS 
DELETE FROM #Normal 
WHERE ID not in 
(
SELECT min(ID)  FROM #normal 
group by leg1FlightNumber,leg1Airlines,leg1Connection ,leg2FlightNumber,leg2Airlines,leg2Connection,leg3FlightNumber,leg3Airlines,leg3Connection ,leg4FlightNumber,leg4Airlines,leg4Connection,leg5FlightNumber,leg5Airlines,leg5Connection,leg6FlightNumber,leg6Airlines,leg6Connection,airLegBrandName,refundable
 )


 insert into #ResultToMergeResponseKey
	 SELECT STUFF((
			SELECT ('|' + (cast(arm1.airresponsekey as nvarchar(512)))) 
			from #normal arm1  
			WHERE isnull(arm1.leg1FlightNumber,'')=isnull(dt.leg1FlightNumber,'') AND isnull(arm1.leg2FlightNumber,'')=isnull(dt.leg2FlightNumber,'') and isnull(arm1.leg3FlightNumber,'')=isnull(dt.leg3FlightNumber,'')  AND isnull(arm1.leg4FlightNumber,'')=isnull(dt.leg4FlightNumber,'') and isnull(arm1.leg5FlightNumber,'')=isnull(dt.leg5FlightNumber,'')  AND isnull(arm1.leg6FlightNumber,'')=isnull(dt.leg6FlightNumber,'') 
			FOR XML PATH('')), 1, 1, '') 
			from (SELECT
				  leg1FlightNumber,leg1Airlines,leg1Connection ,leg2FlightNumber,leg2Airlines,leg2Connection,leg3FlightNumber,leg3Airlines,leg3Connection ,leg4FlightNumber,leg4Airlines,leg4Connection,leg5FlightNumber,leg5Airlines,leg5Connection,leg6FlightNumber,leg6Airlines,leg6Connection, COUNT(*) AS CountOf
				  FROM #normal
				  GROUP BY leg1FlightNumber,leg1Airlines,leg1Connection ,leg2FlightNumber,leg2Airlines,leg2Connection,leg3FlightNumber,leg3Airlines,leg3Connection ,leg4FlightNumber,leg4Airlines,leg4Connection,leg5FlightNumber,leg5Airlines,leg5Connection,leg6FlightNumber,leg6Airlines,leg6Connection
				  HAVING COUNT(*)>1
				  ) dt 





-- create additonal fares from #ResultToMergeResponseKey

    insert into #AdditionalFares
	select arm1.airresponsekey,'00000000-0000-0000-0000-000000000000',arm1.airLegBrandName,arm1.airPriceTotal,arm1.airPriceTotal,arm1.airresponsekey,arm1.refundable,'NONE',
	STUFF((
    SELECT ',' + airLegBookingClasses 
	from NormalizedAirResponses arm2 
    WHERE (arm2.airresponsekey = arm1.airresponsekey) 
    FOR XML PATH('')), 1, 1, '')  as airResBookDesigCode,0,@airRequestKey
	 from #normal arm1  
	 --inner join NormalizedAirResponses nar on nar.airresponsekey = arm1.airresponsekey
        inner join (SELECT
                        max(airPriceTotal) as maxtotal,leg1FlightNumber,leg1Airlines,leg1Connection ,leg2FlightNumber,leg2Airlines,leg2Connection,leg3FlightNumber,leg3Airlines,leg3Connection ,leg4FlightNumber,leg4Airlines,leg4Connection,leg5FlightNumber,leg5Airlines,leg5Connection,leg6FlightNumber,leg6Airlines,leg6Connection, COUNT(*) AS CountOf
                        FROM #normal
                        GROUP BY leg1FlightNumber,leg1Airlines,leg1Connection ,leg2FlightNumber,leg2Airlines,leg2Connection,leg3FlightNumber,leg3Airlines,leg3Connection ,leg4FlightNumber,leg4Airlines,leg4Connection,leg5FlightNumber,leg5Airlines,leg5Connection,leg6FlightNumber,leg6Airlines,leg6Connection
                        HAVING COUNT(*)>1
                    ) dt  on  isnull(arm1.leg1FlightNumber,'')=isnull(dt.leg1FlightNumber,'') AND isnull(arm1.leg2FlightNumber,'')=isnull(dt.leg2FlightNumber,'') and isnull(arm1.leg3FlightNumber,'')=isnull(dt.leg3FlightNumber,'')  AND isnull(arm1.leg4FlightNumber,'')=isnull(dt.leg4FlightNumber,'') and isnull(arm1.leg5FlightNumber,'')=isnull(dt.leg5FlightNumber,'')  AND isnull(arm1.leg6FlightNumber,'')=isnull(dt.leg6FlightNumber,'') AND
					 isnull(arm1.leg1Airlines,'')=isnull(dt.leg1Airlines,'') AND isnull(arm1.leg2Airlines,'')=isnull(dt.leg2Airlines,'') and isnull(arm1.leg3Airlines,'')=isnull(dt.leg3Airlines,'')  AND isnull(arm1.leg4Airlines,'')=isnull(dt.leg4Airlines,'') and isnull(arm1.leg5Airlines,'')=isnull(dt.leg5Airlines,'')  AND isnull(arm1.leg6Airlines,'')=isnull(dt.leg6Airlines,'')  AND
					 isnull(arm1.leg1Connection,'')=isnull(dt.leg1Connection,'') AND isnull(arm1.leg2Connection,'')=isnull(dt.leg2Connection,'') and isnull(arm1.leg3Connection,'')=isnull(dt.leg3Connection,'')  AND isnull(arm1.leg4Connection,'')=isnull(dt.leg4Connection,'') and isnull(arm1.leg5Connection,'')=isnull(dt.leg5Connection,'')  AND isnull(arm1.leg6Connection,'')=isnull(dt.leg6Connection,'')  
					 and arm1.airPriceTotal = dt.maxtotal

-- delete the created additional fares from #normal
DELETE FROM #Normal 
WHERE airresponsekey  in 
(
  SELECT airresponsekey from #AdditionalFares
)



end
GO
