SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create   Procedure [dbo].[usp_CheckCompletionStatusLegWiseForRedeem](@travelRequestId int,@legNumber int,@travelComponent int=1)
as 
begin

declare @airRequestKey int=0
declare @subRequestCount int=0
declare @subRequestCompletionCount int=0
if(@travelComponent=1)
begin

select @airRequestKey =AirRequestkey from TripRequest_air where TripRequest_air.tripRequestKey = @travelRequestId

select @subRequestCount=count(*) from AirSubRequest where airRequestKey=@airRequestKey and airSubRequestLegIndex=@legNumber

select @subRequestCompletionCount=count(*) from AirSubRequest where airRequestKey=@airRequestKey and airSubRequestLegIndex=@legNumber and IsSubRequestCompleted=1


end


if(@subRequestCompletionCount =@subRequestCount and  isnull(@airRequestKey,0)>0 and @subRequestCount>0)
select cast(1 as bit) 
else select cast(0 as bit)
end
GO
