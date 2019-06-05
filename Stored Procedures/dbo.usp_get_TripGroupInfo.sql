SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[usp_get_TripGroupInfo]
@PNR varchar(20),
@TripKey bigint = 0,
@TripRequestKey bigint  = 0 
AS
BEGIN
	Declare @i_TripKey bigint, @i_EventKey bigint, @i_GroupKey bigint
	
	select @i_TripKey = tripKey  , @i_EventKey = EventKey 
	from trip 
	Where recordLocator = @PNR 
	
	select @i_GroupKey = GroupKey  
	from vault..groupeventmapping   
	Where MeetingCodeKey =@i_EventKey 
		
		
	select   g.* , ScopeValue = g.scopeTypeValue 
	from vault..[group]   G 
	Where groupKey = @i_GroupKey 
	 and g.GroupEmailAddress is not null 

	
		
		
		

END 
GO
