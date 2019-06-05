SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CheckCompletionStatusForRedeem](@subRequestId int,@tripRequestKey int,@legIndex int)  
as   
begin  
  
declare @subRequestCount int=0
declare @subRequestCompletionCount int=0
declare @airrequestKey int=0

if(@tripRequestKey>0)  
begin  
select @subRequestCount = count(*) from TripRequest_air tra  
inner join AirRequest ar on tra.airRequestKey=ar.airRequestKey  
inner join  AirSubRequest asr on asr.airRequestKey = ar.airRequestKey  
where tra.tripRequestKey = @tripRequestKey   

select @subRequestCompletionCount = count(*) from TripRequest_air tra  
inner join AirRequest ar on tra.airRequestKey=ar.airRequestKey  
inner join  AirSubRequest asr on asr.airRequestKey = ar.airRequestKey  
where tra.tripRequestKey = @tripRequestKey   and asr.IsSubRequestCompleted=1
end  
else  
begin  
select @airrequestKey= airRequestKey from  AirSubRequest where airSubRequestKey=@subRequestId 
select @subRequestCount = count(*) from AirSubRequest where AirRequestkey=@airrequestKey 
select @subRequestCompletionCount = count(*) from AirSubRequest where AirRequestkey=@airrequestKey  and IsSubRequestCompleted=1
end  

if(@subRequestCompletionCount =@subRequestCount)
select cast(1 as bit) 
else select cast(0 as bit)

end  
  
--exec usp_CheckCompletionStatusForRedeem 0,554018,1  
  
GO
