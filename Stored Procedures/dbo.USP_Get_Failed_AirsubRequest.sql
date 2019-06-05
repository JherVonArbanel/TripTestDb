SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_Get_Failed_AirsubRequest]       
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
 
 declare @superSetAirlinesTable as  Table ( airline varchar(10)  )
  declare @allowedOperatingAirlinesTable as  Table ( airline varchar(10)  )

IF  @SuperSetairLines is null   
 SET @SuperSetairLines =''  
 
 IF   @SuperSetairLines =''  
 BEGIN 
  INSERT INTO  @superSetAirlinesTable  
   
    select Distinct seg.airSegmentMarketingAirlineCode From AirSegments Seg INNER JOIN  AirResponse resp   on Seg.airresponsekey = resp.airresponsekey INNER JOIN AirSubrequest subReq on resp.airSubrequestkey =subReq.airSubrequestkey where airrequestkey =@AirRequestKey  
 END 
 ELSE 
 BEGIN 
  INSERT into @superSetAirlinesTable  SELECT * FROM  ufn_CSVSplitString(@SuperSetairLines) 

 END
 
 IF  @allowedOperatingAirlines is null   
 SET @allowedOperatingAirlines =''  
 
  IF  @allowedOperatingAirlines =''  
 BEGIN 
  INSERT INTO @allowedOperatingAirlinesTable   SELECT DISTINCT seg.airSegmentOperatingAirlineCode FROM AirSegments Seg INNER JOIN  AirResponse resp   on Seg.airresponsekey = resp.airresponsekey INNER JOIN AirSubrequest subReq on resp.airSubrequestkey =subReq.airSubrequestkey 
where airrequestkey =@AirRequestKey  
 END 
 ELSE 
 BEGIN 
  INSERT INTO @allowedOperatingAirlinesTable  SELECT * FROM  ufn_CSVSplitString(@allowedOperatingAirlines) 

 END
 
  Declare @isInternational as bit 
 Declare @airRequestType as int 
   SET @isInternational = (Select isInternationalTrip  from AirRequest where airRequestKey= @AirRequestKey )
  SET @airRequestType = (Select airRequestTypeKey   from AirRequest where airRequestKey= @AirRequestKey )
  DECLARE @airSubRequestKey INT,@airRequestDepartureAirport varchar(50),@airRequestArrivalAirport varchar(50),@airSubRequestLegIndex int    
DECLARE @getFailedAirSubRequest CURSOR 
declare @isInternationalRoundtrip as bit = 0 
if ( @isInternational =1 AND @airRequestType=2 ) 
BEGIN 
SET @isInternationalRoundtrip = 1 
END


IF   ( @isInternationalRoundtrip = 0)
BEGIN
print ('all')
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
 inner join  @SuperSetairLinesTable Airlines on  Airlines.Airline = AirSeg.airSegmentMarketingAirlineCode       
 inner join  @allowedOperatingAirlinesTable  OpAirlines on  OpAirlines.Airline = AirSeg.airSegmentOperatingAirlineCode       
where airRequestKey = @airRequestKey  and airLegNumber=@airSubRequestLegIndex    
-- AirRes.airSubRequestKey= @airSubRequestKeyMinus1LegIndex and airLegNumber=@airSubRequestLegIndex    
and AirRes.airResponseKey not in ((SELECT Distinct s.airResponseKey from AirSegments s inner join AirResponse resp on s.airResponseKey =resp.airResponseKey 
				 inner join AirSubRequest subReq on resp.airSubRequestKey =subReq.airSubRequestKey  where 
				 
				  airRequestKey = @airRequestKey and airLegNumber=@airSubRequestLegIndex     and airSegmentMarketingAirlineCode not in (SELECT * FROM  @SuperSetairLinesTable )
				 union
				 (SELECT Distinct s.airResponseKey from AirSegments s inner join AirResponse resp on s.airResponseKey =resp.airResponseKey 
				 inner join AirSubRequest subReq on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and airLegNumber=@airSubRequestLegIndex     and airSegmentOperatingAirlineCode not in (SELECT * FROM  @allowedOperatingAirlinesTable) )))
  

    
FETCH NEXT    
FROM @getFailedAirSubRequest INTO @airSubRequestKey,@airRequestDepartureAirport,@airRequestArrivalAirport,@airSubRequestLegIndex    
END 
CLOSE @getFailedAirSubRequest    
DEALLOCATE @getFailedAirSubRequest    
   
select  * from @AIRSUBREQUEST WHERE airFlightDataCount=0       
print ('end')

END 
ELSE 
BEGIN 
print ('international')
SET @getFailedAirSubRequest = CURSOR FOR    
select airSubRequestKey,airRequestDepartureAirport,airRequestArrivalAirport,airSubRequestLegIndex from AirSubRequest       
 where airRequestKey = @AirRequestKey --and airSubRequestLegIndex <> -1    
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
 inner join  @SuperSetairLinesTable Airlines on  Airlines.Airline = AirSeg.airSegmentMarketingAirlineCode       
 inner join  @allowedOperatingAirlinesTable  OpAirlines on  OpAirlines.Airline = AirSeg.airSegmentOperatingAirlineCode       
where airRequestKey = @airRequestKey  and airLegNumber=@airSubRequestLegIndex    
-- AirRes.airSubRequestKey= @airSubRequestKeyMinus1LegIndex and airLegNumber=@airSubRequestLegIndex    
and AirRes.airResponseKey not in ((SELECT Distinct s.airResponseKey from AirSegments s inner join AirResponse resp on s.airResponseKey =resp.airResponseKey 
				 inner join AirSubRequest subReq on resp.airSubRequestKey =subReq.airSubRequestKey  where 
				 
				  airRequestKey = @airRequestKey and airLegNumber=@airSubRequestLegIndex     and airSegmentMarketingAirlineCode not in (SELECT * FROM  @SuperSetairLinesTable )
				 union
				 (SELECT Distinct s.airResponseKey from AirSegments s inner join AirResponse resp on s.airResponseKey =resp.airResponseKey 
				 inner join AirSubRequest subReq on resp.airSubRequestKey =subReq.airSubRequestKey  where airRequestKey = @airRequestKey and airLegNumber=@airSubRequestLegIndex     and airSegmentOperatingAirlineCode not in (SELECT * FROM  @allowedOperatingAirlinesTable) )))
  
 
 
    
FETCH NEXT    
FROM @getFailedAirSubRequest INTO @airSubRequestKey,@airRequestDepartureAirport,@airRequestArrivalAirport,@airSubRequestLegIndex    
END    
CLOSE @getFailedAirSubRequest    
DEALLOCATE @getFailedAirSubRequest    
   
select  top 1* from @AIRSUBREQUEST WHERE airFlightDataCount=0    
END

     
       
END 
GO
