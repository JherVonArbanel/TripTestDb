SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[udf_GetAirResponses1](@airResponseKey  uniqueIdentifier,@airlegnumber  int,  @gdssourcekey int) RETURNS @t TABLE(  
            Airresponsekey uniqueidentifier  ,airSubRequestLegIndex int   
              )   
    BEGIN   
    declare @airRequestKey as int   
      
   set @airRequestkey = (select distinct airrequestkey  from airsubrequest subReq inner join airresponse resp on subreq.airSubRequestkey = resp.airSubRequestkey where airresponsekey = @airResponseKey) 
   declare @flightNumber as varchar(50) 
   set @flightNumber =(select flightnumber from NormalizedAirResponses where airresponsekey = @airResponseKey  and airLegNumber =@airlegnumber )  
   declare @airLines as varchar(50) 
   set @airLines =(select airlines from NormalizedAirResponses where airresponsekey = @airResponseKey and airLegNumber =  @airlegnumber ) 
 --  (select airrequestkey from airSubrequest where airSubRequestkey = (select airsubRequestkey from airresponse where  airResponseKey=@airResponseKey))  
    INSERT INTO @T ( Airresponsekey,airSubRequestLegIndex)
      
    select    n.airResponseKey,r.airSubRequestLegIndex   from  NormalizedAirResponses n   
    inner join airResponse  resp on n.airResponseKey=resp.airResponseKey  
    inner join AirSubRequest r on n.airsubrequestkey = r.airSubRequestKey  where  airRequestKey = @airRequestKey and  airlegnumber = @airlegnumber and 
        flightNumber =@flightNumber   
         AND AIRLINES = @airLines 
and isnull(gdsSourcekey ,2 ) = @gdsSourcekey  
      
    RETURN   
    END  
GO
