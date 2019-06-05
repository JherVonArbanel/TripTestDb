SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE Function [dbo].[ufn_GetValidResponsesForMultiCityInternationalTest]  
 (@airLegNumber  as int,@airSubRequestKey as int , @selectedResponseKey as uniqueidentifier ,@selectedResponseKeySecond as uniqueIdentifier ,@selectedResponseKeyThird as uniqueidentifier ,@selectedResponseKeyFourth as uniqueIdentifier ,@selectedResponseKeyFifth as uniqueIdentifier )  
   
   
RETURNS @ResultTable table   
 (  
   airresponseKey uniqueidentifier )  
     
AS  
  begin   
    
		declare @flightNumberOne as varchar(200)   
		declare @airlineNameOne as varchar(200)   
		declare @airRequestKey  as int   

		declare @flightNumberTwo as varchar(200) 
		declare @airlineNameTwo as varchar(200) 
		declare @flightNumberThree as varchar(200) 
		declare @airlineNameThree  as varchar(200) 
		declare @flightNumberFour as varchar(200) 
		declare @airlineNameFour as varchar(200) 	 	
		declare @airLegBookingClasses as varchar(50)      
		declare @airLegSecondBookingClasses as varchar(50)  
		declare @airLegThirdBookingClasses as varchar(50)  
		declare @airLegFourthBookingClasses as varchar(50) 
		declare @flightNumberFive as varchar (200) 
		declare @airlineNameFive as varchar(200) 
		declare @airLegFifthBookingClasses as varchar (50) 
		
		
		set @airRequestKey =( select top 1 airRequestKey  from AirSubRequest where airSubRequestKey = @airSubRequestKey )  
 DECLARE @subRequestTables AS TABLE (airSubRequestKey   INT)
	INSERT INTO @subRequestTables  
	SELECT  AirSubRequestKey From AirSubRequest where airRequestKey =@airRequestKey and airSubRequestLegIndex = -1  
     --declare @gdsSourcekey as int 
     --set @gdsSourcekey = (Select gdssourcekey from Airresponse where airresponsekey = @selectedResponseKey)
     
		if   @airLegNumber = 2   
		begin   

		select @flightNumberOne= flightnumber ,@airlineNameOne=airlines, @airLegBookingClasses =airLegBookingClasses  
		 from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1  

			--insert into @ResultTable (airresponseKey)  
			--(  
			--select airresponsekey  from NormalizedAirResponses n inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey   
			--where airrequestkey =@airRequestKey and airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne   and  @airLegBookingClasses =airLegBookingClasses
			--)  

		declare @airlines as varchar ( 200)   
		declare @airLegConnections as varchar(200)   


		if (( ( select gdsSourcekey from airresponse where airresponsekey =@selectedResponseKey ) <> 9 ) or (( select gdsSourcekey from airresponse where airresponsekey =@selectedResponseKey ) <> 2))
		begin 
			set @airlines =( select top 1 airlines  from NormalizedAirResponses where airResponsekey =@selectedResponseKey and airLegnumber = 1 )  
			set @airLegConnections = (select top 1  airlegConnections from NormalizedAirResponses where airResponsekey =@selectedResponseKey and airLegnumber = 1 )  
			set @airLegBookingClasses  = (select top 1  airLegBookingClasses from NormalizedAirResponses where airResponsekey =@selectedResponseKey and airLegnumber = 1 )  
			insert into @ResultTable (airresponseKey)  
			(  
			select Airresponsekey from NormalizedAirResponses n  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey   
			INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
			where airrequestkey =@airRequestKey and airlines  = @airlines  and flightNumber =@flightNumberOne 
			and airlegBookingClasses = @airlegBookingClasses    
			and airLegnumber = 1)   
		end 
		else 
		begin
		--  set @airLegBookingClasses  = (select top 1  airLegBookingClasses from NormalizedAirResponses where airResponsekey =@selectedResponseKey and airLegnumber = 1 )  

			select @flightNumberOne= flightnumber ,@airlineNameOne=airlines  ,@airLegBookingClasses =airLegBookingClasses  from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
			insert into @ResultTable (airresponseKey)
			(
			select airresponsekey  from NormalizedAirResponses  n  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey
			INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
			where airrequestkey  = @airrequestkey  and airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne      and airlegBookingClasses = @airlegBookingClasses   
			 
			)
		end 

		end   
    
  
  if  @airLegnumber = 3 
 			begin
 			if ( @selectedResponseKeySecond is null ) 
 			BEGIN
 			set @selectedResponseKeySecond =   @selectedResponseKey
 			END 
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=airlines,@airLegBookingClasses=airLegBookingClasses   from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=airlines ,@airLegSecondBookingClasses= airLegBookingClasses  from NormalizedAirResponses  where airresponsekey = @selectedResponseKeySecond and    airLegnumber = 2
	   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses  n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey  
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne  and airLegBookingClasses =@airLegBookingClasses
    
intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey 
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
   where airrequestkey  = @airrequestkey  and airLegnumber = 2  and flightnumber =  @flightnumberTwo and airlines = @airlineNameTwo  and airLegBookingClasses = @airLegSecondBookingClasses
   
 			 )
 			end 
 			if  @airLegnumber = 4
 			begin
 			 if ( @selectedResponseKeySecond is null ) 
 			BEGIN
 			set @selectedResponseKeySecond =   @selectedResponseKey
 			END 
 			if ( @selectedResponseKeyThird is null ) 
 			BEGIN
 			set @selectedResponseKeyThird =   @selectedResponseKey
 			END 
 			
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=airlines ,@airLegBookingClasses=airLegBookingClasses  from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=airlines,@airLegSecondBookingClasses=airLegBookingClasses   from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond  and airLegnumber = 2
		 select @flightNumberThree= flightnumber ,@airlineNameThree=airlines ,@airLegThirdBookingClasses=airLegBookingClasses  from NormalizedAirResponses where airresponsekey = @selectedResponseKeyThird  and airLegnumber = 3
   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey  
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne  and airLegBookingClasses =@airLegBookingClasses 
 intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey 
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 2  and flightnumber =  @flightnumberTwo and airlines = @airlineNameTwo and airLegBookingClasses =@airLegSecondBookingClasses 
  	intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey 
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
   where airrequestkey  = @airrequestkey  and airLegnumber = 3  and flightnumber =  @flightnumberThree and airlines = @airlineNameThree and airLegBookingClasses =@airLegThirdBookingClasses  
  			 )
		 
 			end 
 			
 			if  @airLegnumber = 5
 			begin
 			 if ( @selectedResponseKeySecond is null ) 
 			BEGIN
 			set @selectedResponseKeySecond =   @selectedResponseKey
 			END 
 			if ( @selectedResponseKeyThird is null ) 
 			BEGIN
 			set @selectedResponseKeyThird =   @selectedResponseKey
 			END 
 			if ( @selectedResponseKeyFourth is null ) 
 			BEGIN
 			set @selectedResponseKeyFourth =   @selectedResponseKey
 			END 
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=airlines ,@airLegBookingClasses=airLegBookingClasses  from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=airlines ,@airLegSecondBookingClasses=airLegBookingClasses  from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond  and airLegnumber = 2
		 select @flightNumberThree= flightnumber ,@airlineNameThree=airlines ,@airLegThirdBookingClasses=airLegBookingClasses  from NormalizedAirResponses where airresponsekey = @selectedResponseKeyThird  and airLegnumber = 3
		 select @flightNumberFour= flightnumber ,@airlineNameFour=airlines   ,@airLegFourthBookingClasses=airLegBookingClasses from NormalizedAirResponses where airresponsekey = @selectedResponseKeyFourth  and airLegnumber = 4
   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey  
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne and airLegBookingClasses =@airLegBookingClasses
 intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey 
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 2  and flightnumber =  @flightnumberTwo and airlines = @airlineNameTwo and airLegBookingClasses = @airLegSecondBookingClasses
  	intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey 
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 3  and flightnumber =  @flightnumberThree and airlines = @airlineNameThree and airLegBookingClasses =@airLegThirdBookingClasses
  			intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey 
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 4  and flightnumber =  @flightnumberFour  and airlines = @airlineNameFour and airLegBookingClasses = @airLegFourthBookingClasses 
 	 )
		 
 			end 
 			
 				if  @airLegnumber = 6
 			begin
 			 if ( @selectedResponseKeySecond is null ) 
 			BEGIN
 			set @selectedResponseKeySecond =   @selectedResponseKey
 			END 
 			if ( @selectedResponseKeyThird is null ) 
 			BEGIN
 			set @selectedResponseKeyThird =   @selectedResponseKey
 			END 
 			if ( @selectedResponseKeyFourth is null ) 
 			BEGIN
 			set @selectedResponseKeyFourth =   @selectedResponseKey
 			END 
 			if ( @selectedResponseKeyFifth is null ) 
 			BEGIN
 			set @selectedResponseKeyFifth =   @selectedResponseKey
 			END 
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=airlines ,@airLegBookingClasses=airLegBookingClasses  from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=airlines ,@airLegSecondBookingClasses=airLegBookingClasses  from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond  and airLegnumber = 2
		 select @flightNumberThree= flightnumber ,@airlineNameThree=airlines ,@airLegThirdBookingClasses=airLegBookingClasses  from NormalizedAirResponses where airresponsekey = @selectedResponseKeyThird  and airLegnumber = 3
		 select @flightNumberFour= flightnumber ,@airlineNameFour=airlines   ,@airLegFourthBookingClasses=airLegBookingClasses from NormalizedAirResponses where airresponsekey = @selectedResponseKeyFourth  and airLegnumber = 4
		 		 select @flightNumberFive = flightnumber ,@airlineNameFive=airlines   ,@airLegFifthBookingClasses=airLegBookingClasses from NormalizedAirResponses where airresponsekey = @selectedResponseKeyFifth  and airLegnumber = 5

   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey  
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne and airLegBookingClasses =@airLegBookingClasses
  
intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey 
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 2  and flightnumber =  @flightnumberTwo and airlines = @airlineNameTwo and airLegBookingClasses = @airLegSecondBookingClasses
  	intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey 
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 3  and flightnumber =  @flightnumberThree and airlines = @airlineNameThree and airLegBookingClasses =@airLegThirdBookingClasses
 			intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey 
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 4  and flightnumber =  @flightnumberFour  and airlines = @airlineNameFour and airLegBookingClasses = @airLegFourthBookingClasses 
             intersect  
  	select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey 
  INNER JOIN  @subRequestTables tmpS on S.airsubrequestkey = tmps.airSubRequestKey 
  where airrequestkey  = @airrequestkey  and airLegnumber = 5  and flightnumber =  @flightNumberFive   and airlines = @airlineNameFive  and airLegBookingClasses = @airLegFifthBookingClasses 
 	 )
		 
 			end 
        
        
      
    return     
 end
GO
