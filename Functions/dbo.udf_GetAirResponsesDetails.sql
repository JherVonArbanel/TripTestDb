SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[udf_GetAirResponsesDetails](@airsubRequestkey int,@airlegnumber  int ) RETURNS @t TABLE(
            Airresponsekey uniqueidentifier, 
            airsegmentFlightNumber VARCHAR(40), 
            noOFFlights int ,
            airSegmentMarketingAirlineCode VARCHAR(8000) ) 
    BEGIN 
     INSERT @t (airresponsekey, airsegmentFlightNumber, airSegmentMarketingAirlineCode,noOFFlights) 
     SELECT seg.airresponsekey, MIN(airSegmentFlightNumber),  MIN(airSegmentMarketingAirlineCode)  ,count(*)
       FROM airsegments  seg  inner join airresponse resp on seg.airresponsekey = resp.airresponsekey where airsubrequestkey = @airsubRequestkey and airlegnumber = @airlegnumber
       
      GROUP BY seg.airresponsekey  
  --  WHILE ( SELECT COUNT(Product) FROM @t ) > 0 BEGIN 
        UPDATE t 
           SET airsegmentFlightNumber = airsegmentFlightNumber + COALESCE(
                         ( SELECT ', ' + convert(varchar(20),MIN( airSegmentFlightNumber ) )
                             FROM Airsegments 
                            WHERE Airsegments.airresponsekey = t.airresponsekey and airlegnumber = @airlegnumber 
                              AND airsegmentFlightNumber > t.airsegmentFlightNumber), ''), 
               airSegmentMarketingAirlineCode = airSegmentMarketingAirlineCode + COALESCE( ( SELECT ', ' + MIN(airSegmentMarketingAirlineCode) 
                             FROM Airsegments 
                            WHERE Airsegments.airresponsekey = t.airresponsekey  and airlegnumber = @airlegnumber 
                              AND Airsegments.airSegmentMarketingAirlineCode > t.airSegmentMarketingAirlineCode ) ,'')
          FROM @t t where noOFFlights > 1 --END 
    RETURN 
    END
GO
