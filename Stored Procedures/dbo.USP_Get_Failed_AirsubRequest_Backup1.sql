SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_Get_Failed_AirsubRequest_Backup1]       
@AirRequestKey int,      
@SuperSetairLines nvarchar(4000),      
@allowedOperatingAirlines nvarchar(4000)      
      
AS      
BEGIN      
      
 DECLARE @AIRSUBREQUEST AS TABLE      
 (      
  airSubRequestKey INT,      
  airRequestDepartureAirport VARCHAR(4000),      
  airRequestArrivalAirport VARCHAR(4000),      
  airSubRequestLegIndex INT,    
  airFlightDataCount int    
 )       
 Declare @airSubRequestKeyMinus1LegIndex int    
 select @airSubRequestKeyMinus1LegIndex = airSubRequestKey from AirSubRequest     
 where airRequestKey = @AirRequestKey     
     
 print @airSubRequestKeyMinus1LegIndex     
     
      
 DECLARE @airSubRequestKey INT,@airRequestDepartureAirport varchar(50),@airRequestArrivalAirport varchar(50),@airSubRequestLegIndex int    
DECLARE @getFailedAirSubRequest CURSOR    
SET @getFailedAirSubRequest = CURSOR FOR    
select airSubRequestKey,airRequestDepartureAirport,airRequestArrivalAirport,airSubRequestLegIndex from AirSubRequest       
 where airRequestKey = @AirRequestKey and airSubRequestLegIndex <> -1    
OPEN @getFailedAirSubRequest    
FETCH NEXT    
FROM @getFailedAirSubRequest INTO @airSubRequestKey,@airRequestDepartureAirport,@airRequestArrivalAirport,@airSubRequestLegIndex    
WHILE @@FETCH_STATUS = 0    
BEGIN    
Insert into @AIRSUBREQUEST      
 select @airSubRequestKey,@airRequestDepartureAirport,@airRequestArrivalAirport,@airSubRequestLegIndex,COUNT(*)    
 from AirSegments AirSeg      
 inner join AirResponse AirRes on AirRes.airResponseKey = AirSeg.airResponseKey   
 Inner join AirSubrequest sub on airres.airSubRequestKey =      sub.airSubRequestKey
 inner join ufn_CSVSplitString(@SuperSetairLines) Airlines on  Airlines.String = AirSeg.airSegmentMarketingAirlineCode       
 inner join ufn_CSVSplitString(@allowedOperatingAirlines) OpAirlines on  OpAirlines.String = AirSeg.airSegmentOperatingAirlineCode       
where airRequestKey = @airRequestKey  and airLegNumber=@airSubRequestLegIndex    
-- AirRes.airSubRequestKey= @airSubRequestKeyMinus1LegIndex and airLegNumber=@airSubRequestLegIndex    
and AirRes.airResponseKey not in ((SELECT Distinct s.airResponseKey from AirSegments s inner join AirResponse resp on s.airResponseKey =resp.airResponseKey 
				 inner join AirSubRequest subReq on resp.airSubRequestKey =subReq.airSubRequestKey  where 
				 
				  airRequestKey = @airRequestKey and airLegNumber=@airSubRequestLegIndex     and airSegmentMarketingAirlineCode not in (SELECT * FROM vault.dbo.ufn_CSVToTable(@SuperSetairLines) )
				 union
				 (SELECT Distinct s.airResponseKey from AirSegments s inner join AirResponse resp on s.airResponseKey =resp.airResponseKey 
				 inner join AirSubRequest subReq on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and airLegNumber=@airSubRequestLegIndex     and airSegmentOperatingAirlineCode not in (SELECT * FROM vault.dbo.ufn_CSVToTable(@allowedOperatingAirlines)) )))
  
 
 /*
select distinct resp.airResponseKey  from 
AirSegments seg inner join  
AirResponse resp on seg.airResponseKey =resp.airResponseKey 
 inner join AirSubRequest 
 subreq on resp.airSubRequestKey=subreq.airSubRequestKey where airRequestKey =2 
 and seg.airSegmentMarketingAirlineCode in (select * from ufn_CSVSplitString('CA,CO,FM,JK,JP,KF,LH,LO,OS,OU,OZ,SA,SK,SN,SQ,TG,TK,TP,UA,US')) 
 and seg.airSegmentOperatingAirlineCode in (select * From ufn_CSVSplitString ('JP,A3,AC,CA,NZ,NH,OZ,OS,KF,BD,SN,CO,OU,MS,LO,LH,SK,FM,SQ,SA,JK,LX,JJ,TP,TG,TK,UA,US'))
 
*/
--select AirSeg.*   
-- from AirSegments AirSeg      
-- inner join AirResponse AirRes on AirRes.airResponseKey = AirSeg.airResponseKey        
-- inner join ufn_CSVSplitString(@SuperSetairLines) Airlines on  Airlines.String = AirSeg.airSegmentMarketingAirlineCode       
-- inner join ufn_CSVSplitString(@SuperSetairLines) OpAirlines on  OpAirlines.String = AirSeg.airSegmentOperatingAirlineCode       
--where AirRes.airSubRequestKey= @airSubRequestKeyMinus1LegIndex and airLegNumber=@airSubRequestLegIndex    
    
FETCH NEXT    
FROM @getFailedAirSubRequest INTO @airSubRequestKey,@airRequestDepartureAirport,@airRequestArrivalAirport,@airSubRequestLegIndex    
END    
CLOSE @getFailedAirSubRequest    
DEALLOCATE @getFailedAirSubRequest    
   
select  * from @AIRSUBREQUEST WHERE airFlightDataCount=0    
  
      
END 
GO
