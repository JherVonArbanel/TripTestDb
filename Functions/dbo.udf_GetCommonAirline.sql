SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  FUNCTION [dbo].[udf_GetCommonAirline]( @airRequestKey as int ) RETURNS @ResultTable TABLE(  airline varchar(100))   
AS  
    BEGIN   
       
DECLARE @subRequestCount AS INT   
  
Declare @airRequestTypeKey as int   
set @airRequestTypeKey = (select airRequestTypeKey  from airrequest WITH (NOLOCK) where airRequestKey  =@airRequestKey )  
if ( @airRequestTypeKey = 3 )   
begin   
  SET @subRequestCount = (SELECT  COUNT(*) FROM AirSubRequest WITH (NOLOCK)  WHERE airRequestKey = @airRequestKey AND airSubRequestLegIndex <> -1  )  
  INSERT @ResultTable   
SELECT AIRLINES FROM   
(  select   SUBSTRING(airlines ,1,2) AIRLINES  from NormalizedAirResponses N   WITH (NOLOCK) 
  INNER JOIN AirSubRequest S WITH (NOLOCK)  ON S.airSubRequestKey = N.airsubrequestkey   
    where airRequestKey  =@airRequestKey GROUP BY SUBSTRING(airlines ,1,2)  ,N.airsubrequestkey ) AS t GROUP BY AIRLINES HAVING COUNT(*) = @subRequestCount   
    end   
    else   
    begin  
    INSERT @ResultTable   
    select  distinct  SUBSTRING(airlines ,1,2) AIRLINES  from NormalizedAirResponses N   WITH (NOLOCK) 
  INNER JOIN AirSubRequest S  WITH (NOLOCK) ON S.airSubRequestKey = N.airsubrequestkey   
    where airRequestKey  =@airRequestKey    
     end   
    RETURN   
    END
GO
