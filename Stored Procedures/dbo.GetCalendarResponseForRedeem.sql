SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[GetCalendarResponseForRedeem](@tripRequestKey int=0,@airRequestKey int,@legIndex int=1,@awardCode nvarchar(50)='')
as
begin


if(@tripRequestKey>0)
begin
select @airRequestKey = airrequestkey from Trip..TripRequest_air where tripRequestKey=@tripRequestKey
end

DECLARE @json NVARCHAR(MAX)
select @json= redeemPoints from trip..AirRequest where airRequestKey=@airRequestKey 

	select * into #bxrule from(SELECT *,'planahead' as RuleType  
	FROM OPENJSON(@json)  
	  WITH (Excludes nvarchar(50) 'strict $.Excludes',  
	  IsUSTransCodeExcluded bit '$.IsUSTransCodeExcluded',
	  planahead nvarchar(max) '$.PlanAhead'as json )
	  outer apply openjson(PlanAhead)
	  with(AwardCode nvarchar(50) '$.AwardCode', Points int '$.Points',AwardType nvarchar(50) '$.AwardType' ) as b
	  union
	  SELECT *,'anytime' as RuleType  
	FROM OPENJSON(@json)  
	  WITH (Excludes nvarchar(50) 'strict $.Excludes',  
	  IsUSTransCodeExcluded bit '$.IsUSTransCodeExcluded',
	  anytime nvarchar(max) '$.Anytime'as json )
	  outer apply openjson(Anytime)
	  with(AwardCode nvarchar(50) '$.AwardCode', Points int '$.Points',AwardType nvarchar(50) '$.AwardType' ) as c) as temp

	  declare @filteredBXRule table (Excludes nvarchar(50), IsUSTransCodeExcluded bit,planahead nvarchar(max),AwardCode varchar(50),Points int,AwardType nvarchar(50),RuleType nvarchar(50))


	  if(ISNULL(@awardCode,'')='')
	  begin
	   Insert into @filteredBXRule 
	   Select * from #bxrule where excludes = 'non-stop' and AwardCode is not null and  awardcode<>''

			if((select count(*) from @filteredBXRule)=0)
		  begin
		   Insert into @filteredBXRule 
		   Select * from #bxrule where AwardCode is not null and  awardcode<>''
		  end

	     select *from @filteredBXRule order by Points

	  	  declare @calendarResponse table (airRequestKey int,
		  airSubRequestKey int,legIndex int,weekIndex int,dayDate datetime,dayText nvarchar(50),Points int,AwardType nvarchar(50),RuleType nvarchar(50),isDefault bit,awardCode nvarchar(50))

		  declare @calendarFilteredResponse table (airRequestKey int,
		  airSubRequestKey int,legIndex int,weekIndex int,dayDate datetime,dayText nvarchar(50),Points int,AwardType nvarchar(50),RuleType nvarchar(50),isDefault bit,awardCode nvarchar(50))


		  insert into @calendarResponse
		  select AirRequestKey,AirSubRequestKey,LegIndex,WeekIndex,DayDate,DayText,
		  0,
		  case AwardTypeName when 'EconomyMilesaver' then 'Economy'
		  when 'EconomyAnytime' then 'Economy'
		  when 'BusinessMilesaver' then 'Business'
		  when 'BusinessAnytime' then 'Business'
		  when 'FirstAnytime' then 'First'
		  when 'FirstMilesaver' then 'First'
		  end as AwardType,
		  case AwardTypeName when 'EconomyMilesaver' then 'planahead'
		  when 'EconomyAnytime' then 'anytime'
		  when 'BusinessMilesaver' then 'planahead'
		  when 'BusinessAnytime' then 'anytime'
		  when 'FirstAnytime' then 'anytime'
		  when 'FirstMilesaver' then 'planahead'
		  end as RuleType,0 as isDefault,'' as AwardCode
		  from trip..AirRedeemCalendarResponse where AirRequestKey=@airRequestKey and LegIndex=@legIndex

		   update @calendarResponse set Points =bxRule.Points,awardCode = bxRule.AwardCode
		  from @calendarResponse res inner join @filteredBXRule bxRule
		  on res.AwardType = bxRule.AwardType  and res.RuleType = bxRule.RuleType

		  update @calendarResponse set Points =bxRule.Points,awardCode = bxRule.AwardCode
		  from @calendarResponse res inner join @filteredBXRule bxRule
		  on CHARINDEX(res.AwardType,bxRule.AwardType) >0
		  and res.RuleType = bxRule.RuleType and res.awardCode=''
		   
		--  insert into @calendarFilteredResponse 
		--Select t.airRequestKey,t.airSubRequestKey,t.legIndex,t.weekIndex,t.dayDate,t.dayText,t.Points,t.AwardType,t.RuleType,t.isDefault,t.awardCode from 
		-- @calendarResponse t 
		--  inner join 
		--	(   Select dayDate, min(Points) as points
		--		from @calendarResponse 
		--		where Points>0
		--		group by dayDate
		--	 ) xx 
		--	on t.dayDate = xx.dayDate and t.Points = xx.points
		--	order by t.weekIndex asc



			update @calendarResponse set isDefault = 1
			where dayDate = (select airrequestDepartureDate from trip..AirSubRequest where airSubRequestKey = (select top 1 airSubRequestKey from @calendarResponse))
			
			select distinct dayDate,dayText,isDefault,weekIndex from @calendarResponse

			select * from @calendarResponse where Points>0 order by weekIndex,dayDate,Points
			drop table #bxrule

	  end
	  else
	  begin
	    
			Insert into @filteredBXRule 
			select * from #bxrule
			where Excludes =
			(select Excludes from #bxrule where Awardcode=@awardCode) and IsUStransCodeExcluded = (select IsUStransCodeExcluded from #bxrule where Awardcode=@awardCode)
			and AwardCode is not null and  awardcode<>''

			  select *from @filteredBXRule order by Points

			  insert into @calendarResponse
			  select AirRequestKey,AirSubRequestKey,LegIndex,WeekIndex,DayDate,DayText,
			  0,
			  case AwardTypeName when 'EconomyMilesaver' then 'Economy'
			  when 'EconomyAnytime' then 'Economy'
			  when 'BusinessMilesaver' then 'Business'
			  when 'BusinessAnytime' then 'Business'
			  when 'FirstAnytime' then 'First'
			  when 'FirstMilesaver' then 'First'
			  end as AwardType,
			  case AwardTypeName when 'EconomyMilesaver' then 'planahead'
			  when 'EconomyAnytime' then 'anytime'
			  when 'BusinessMilesaver' then 'planahead'
			  when 'BusinessAnytime' then 'anytime'
			  when 'FirstAnytime' then 'anytime'
			  when 'FirstMilesaver' then 'planahead'
			  end as RuleType,0 as isDefault,'' as AwardCode
			  from trip..AirRedeemCalendarResponse where AirRequestKey=@airRequestKey and LegIndex=@legIndex
			  

			    update @calendarResponse set Points =bxRule.Points,awardCode = bxRule.AwardCode
		  from @calendarResponse res inner join @filteredBXRule bxRule
		  on res.AwardType = bxRule.AwardType  and res.RuleType = bxRule.RuleType

				update @calendarResponse set Points =bxRule.Points,awardCode = bxRule.AwardCode
				from @calendarResponse res inner join @filteredBXRule bxRule
				on CHARINDEX(res.AwardType,bxRule.AwardType) >0 --and bxRule.AwardCode=@awardCode
				and res.RuleType = bxRule.RuleType and res.awardCode=''

			  --insert into @calendarFilteredResponse
			  --select * from  @calendarResponse where awardCode<>''

	

			--	  	  declare @calendarResponseNotFoundForAward table (airRequestKey int,
		 -- airSubRequestKey int,legIndex int,weekIndex int,dayDate datetime,dayText nvarchar(50),Points int,AwardType nvarchar(50),RuleType nvarchar(50),isDefault bit,awardCode nvarchar(50))

		 -- Insert into @calendarResponseNotFoundForAward
			--select * from  @calendarResponse where awardCode='' and dayDate not in (select dayDate from  @calendarFilteredResponse)

			--update @calendarResponseNotFoundForAward set Points =bxRule.Points,awardCode = bxRule.AwardCode
			--	from @calendarResponseNotFoundForAward res inner join @filteredBXRule bxRule
			--	on CHARINDEX(res.AwardType,bxRule.AwardType) >0 
			--	and res.RuleType = bxRule.RuleType

  --insert into @calendarFilteredResponse 
		--Select t.airRequestKey,t.airSubRequestKey,t.legIndex,t.weekIndex,t.dayDate,t.dayText,t.Points,t.AwardType,t.RuleType,t.isDefault,t.awardCode from 
		-- @calendarResponseNotFoundForAward t 
		--  inner join 
		--	(   Select dayDate, min(Points) as points
		--		from @calendarResponseNotFoundForAward 
		--		where Points>0
		--		group by dayDate
		--	 ) xx 
		--	on t.dayDate = xx.dayDate and t.Points = xx.points
		--	order by t.weekIndex asc

			update @calendarResponse set isDefault = 1
			where dayDate = (select airrequestDepartureDate from trip..AirSubRequest where airSubRequestKey = (select top 1 airSubRequestKey from @calendarResponse))
			
			select distinct dayDate,dayText,isDefault,weekIndex from @calendarResponse
			
			select * from @calendarResponse where Points>0 order by weekIndex,dayDate,Points
			
				drop table #bxrule		
	  end
	
end


--exec GetCalendarResponseForRedeem 0,367597,1,'BX6B'
GO
