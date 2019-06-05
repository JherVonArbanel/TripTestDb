SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[udf_GetAirResponsesBasedOnAirline](@airResponseKey  uniqueIdentifier,@airlegnumber  int, @airline varchar(10),@gdsSourcekey int ) RETURNS @t TABLE(
            Airresponsekey uniqueidentifier 
            -- ,
            --airline varchar(100),
            --airLegnumber int ,airPriceBase float 
              ) 
    BEGIN 
    declare @airRequestKey as int 
    declare @airSUbRequestkey as int 
    
   set @airRequestkey = (select airrequestkey from airSubrequest where airSubRequestkey = (select airsubRequestkey from airresponse where  airResponseKey=@airResponseKey))
   set @airSUbRequestkey =(select airSubRequestkey from airsubrequest where airrequestkey =@airRequestkey and airSubRequestLegIndex = @airlegnumber )
     INSERT INTO @T ( Airresponsekey )
    select   top 1 n.airResponseKey    from  NormalizedAirResponses n 
    inner join airResponse  resp on n.airResponseKey=resp.airResponseKey
    inner join AirSubRequest r on n.airsubrequestkey = r.airSubRequestKey  where n.airSubRequestKey = @airSUbRequestkey and  airlegnumber = @airlegnumber
    
        AND AIRLINES =  @airline  and isnull(gdsSourcekey ,2 ) = @gdsSourcekey
    order by airPriceBase 
    RETURN 
    END
GO
