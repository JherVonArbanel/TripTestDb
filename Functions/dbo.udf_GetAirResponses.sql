SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[udf_GetAirResponses](@airResponseKey  uniqueIdentifier,@airlegnumber  int,  @gdssourcekey int) RETURNS @t TABLE(
            Airresponsekey uniqueidentifier  ,airSubRequestLegIndex int 
              ) 
    BEGIN 
    declare @airRequestKey as int 
    
   set @airRequestkey = (select airrequestkey from airSubrequest where airSubRequestkey = (select airsubRequestkey from airresponse where  airResponseKey=@airResponseKey))
    INSERT INTO @T ( Airresponsekey,airSubRequestLegIndex)
    select    n.airResponseKey,r.airSubRequestLegIndex   from  NormalizedAirResponses n 
    inner join airResponse  resp on n.airResponseKey=resp.airResponseKey
    inner join AirSubRequest r on n.airsubrequestkey = r.airSubRequestKey  where  airRequestKey = @airRequestKey and  airlegnumber = @airlegnumber and flightNumber =(select flightnumber from NormalizedAirResponses where airresponsekey = @airResponseKey  and airLegNumber =@airlegnumber )   AND AIRLINES = (select airlines from NormalizedAirResponses where airresponsekey = @airResponseKey and airLegNumber =  @airlegnumber ) and isnull(gdsSourcekey ,2 ) = @gdsSourcekey
    
    RETURN 
    END
GO
