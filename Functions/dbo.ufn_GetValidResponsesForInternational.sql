SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Function [dbo].[ufn_GetValidResponsesForInternational]  
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
		declare @totalPrice as float 
		declare @currentlegAirlines as varchar(100)
			 declare @currentlegBookingClass as varchar(100)
			 declare @currentLegConnections as varchar(100)
		set @airRequestKey =( select top 1 airRequestKey  from AirSubRequest where airSubRequestKey = @airSubRequestKey )  
  
     --declare @gdsSourcekey as int 
     --set @gdsSourcekey = (Select gdssourcekey from Airresponse where airresponsekey = @selectedResponseKey)
     
		if   @airLegNumber = 2   
		begin   

		select @flightNumberOne= flightnumber ,@airlineNameOne=Airlines , @airLegBookingClasses =airLegBookingClasses   from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1  

			--insert into @ResultTable (airresponseKey)  
			--(  
			--select airresponsekey  from NormalizedAirResponses n inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey   
			--where airrequestkey =@airRequestKey and airLegnumber = 1 and flightnumber =  @flightnumberOne and @Airlines = @airlineNameOne   and  @airLegBookingClasses =airLegBookingClasses
			--)  

		declare @Airlines as varchar ( 200)   
		declare @airLegConnections as varchar(200)   
		declare @secondAirLegConnections as varchar(200)   declare @thirdAirLegConnections as varchar(200)   
		declare @fourthAirLegConnections as varchar(200)   declare @fifthAirLegConnections as varchar(200)   
		 	 
set @totalPrice = ( select airpricebase + airpricetax from airresponse where airResponseKey = @selectedResponseKey )

		if (( ( select gdsSourcekey from airresponse where airresponsekey =@selectedResponseKey ) <> 9 ) )
		begin 
			set @Airlines =( select top 1 airlines  from NormalizedAirResponses where airResponsekey =@selectedResponseKey and airLegnumber = 1 )  
			set @airLegConnections = (select top 1  airlegConnections from NormalizedAirResponses where airResponsekey =@selectedResponseKey and airLegnumber = 1 )  
			set @airLegBookingClasses  = (select top 1  airLegBookingClasses from NormalizedAirResponses where airResponsekey =@selectedResponseKey and airLegnumber = 1 )  
		 
		 
			 insert into @ResultTable (airresponseKey)  
			(  
			select n.Airresponsekey from NormalizedAirResponses n 
			inner join airresponse r on n.airresponsekey = r.airResponseKey  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey   
			where airrequestkey =@airRequestKey 
			and airlines   = @airlines  
			 and flightNumber =@flightNumberOne 
		  and airlegBookingClasses = @airlegBookingClasses   
		 and airLegConnections = @airLegConnections
		  and airLegnumber = 1 and s.airSubRequestLegIndex = -1     
		  )
		  
		  	select   @currentlegAirlines=Airlines  ,@currentlegBookingClass =airLegBookingClasses,@currentLegConnections= airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 2
			
			insert into @ResultTable (airresponseKey)  
			(  
			select n.Airresponsekey from NormalizedAirResponses n 
			inner join airresponse r on n.airresponsekey = r.airResponseKey  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey   
			where airrequestkey =@airRequestKey and Airlines  = @airlines  
			--and flightNumber =@flightNumberOne 
		  and airlegBookingClasses = @airlegBookingClasses   
	--  and airLegConnections = @airLegConnections
	 and airLegnumber = 1 and s.airSubRequestLegIndex = -1     and (airpricebase + airpricetax) = @totalPrice 
		  
		  intersect 
		  	 select n.Airresponsekey from NormalizedAirResponses n 
			inner join airresponse r on n.airresponsekey = r.airResponseKey  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey   
			where airrequestkey =@airRequestKey and Airlines  = @currentlegAirlines   
			--and flightNumber =@flightNumberOne 
		  and airlegBookingClasses =    @currentlegBookingClass 
	--  and airLegConnections = @currentLegConnections
		  and airLegnumber = 2 and s.airSubRequestLegIndex = -1     and (airpricebase + airpricetax) = @totalPrice 
		  
		  )
		 
		end 
		else 
		begin
		--  set @airLegBookingClasses  = (select top 1  airLegBookingClasses from NormalizedAirResponses where airResponsekey =@selectedResponseKey and airLegnumber = 1 )  

			select @flightNumberOne= flightnumber ,@airlineNameOne=Airlines  ,@airLegBookingClasses =airLegBookingClasses  from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
			insert into @ResultTable (airresponseKey)
			(
			select airresponsekey  from NormalizedAirResponses  n  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey  where airrequestkey  = @airrequestkey  and airLegnumber = 1 and flightnumber =  @flightnumberOne and Airlines = @airlineNameOne      and airlegBookingClasses = @airlegBookingClasses   

			)
		end 

		end   
    
  
  if  @airLegnumber = 3 
 			begin
 			if ( @selectedResponseKeySecond is null ) 
 			BEGIN
 			set @selectedResponseKeySecond =   @selectedResponseKey
 			END 
 				 
set @totalPrice = ( select airpricebase + airpricetax from airresponse where airResponseKey = @selectedResponseKeySecond )
select   @currentlegAirlines=Airlines  ,@currentlegBookingClass =airLegBookingClasses,@currentLegConnections= airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond  and airLegnumber = 3
	
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=Airlines,@airLegBookingClasses=airLegBookingClasses ,  @airLegConnections =airLegConnections  from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=Airlines ,@airLegSecondBookingClasses= airLegBookingClasses,@secondAirLegConnections=airLegConnections   from NormalizedAirResponses  where airresponsekey = @selectedResponseKeySecond and    airLegnumber = 2
	   insert into @ResultTable (airresponseKey)
			 (
			select n.airresponsekey  from NormalizedAirResponses  n  			 
			inner join airresponse r on n.airresponsekey = r.airResponseKey  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey   
   where airrequestkey  = @airrequestkey  and airLegnumber = 1 and flightNumber =@flightNumberOne and    Airlines = @airlineNameOne  and airLegBookingClasses =@airLegBookingClasses  --and airLegConnections = @airLegConnections 
   
intersect 
			select n.airresponsekey  from NormalizedAirResponses n  
  inner join airresponse r on n.airresponsekey = r.airResponseKey  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey   and flightNumber =@flightNumbertwo  where airrequestkey  = @airrequestkey  and airLegnumber = 2  and   Airlines = @airlineNameTwo  and airLegBookingClasses = @airLegSecondBookingClasses --and airLegConnections = @secondAirLegConnections 
      
     )
	   
	   
	   insert into @ResultTable (airresponseKey)
			 (
			select n.airresponsekey  from NormalizedAirResponses  n  			 
			inner join airresponse r on n.airresponsekey = r.airResponseKey  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey   
   where airrequestkey  = @airrequestkey  and airLegnumber = 1 and  Airlines = @airlineNameOne  and airLegBookingClasses =@airLegBookingClasses  --and airLegConnections = @airLegConnections 
   and (airPriceBase + airPriceTax )= @totalPrice    
intersect 
			select n.airresponsekey  from NormalizedAirResponses n  
  inner join airresponse r on n.airresponsekey = r.airResponseKey  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey     where airrequestkey  = @airrequestkey  and airLegnumber = 2  and   Airlines = @airlineNameTwo  and airLegBookingClasses = @airLegSecondBookingClasses --and airLegConnections = @secondAirLegConnections 
     and (airPriceBase + airPriceTax )= @totalPrice 
     
     union 
      select n.Airresponsekey from NormalizedAirResponses n 
			inner join airresponse r on n.airresponsekey = r.airResponseKey  
			inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey   
			where airrequestkey =@airRequestKey and  Airlines  = @currentlegAirlines   
			--and flightNumber =@flightNumberOne 
		  and airlegBookingClasses =    @currentlegBookingClass 
		  and airLegConnections = @currentLegConnections
		  and airLegnumber = 3 and s.airSubRequestLegIndex = -1     and (airpricebase + airpricetax) = @totalPrice
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
 			
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=Airlines ,@airLegBookingClasses=airLegBookingClasses,@airLegConnections=airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=Airlines,@airLegSecondBookingClasses=airLegBookingClasses,@secondAirLegConnections= airLegConnections    from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond  and airLegnumber = 2
		 select @flightNumberThree= flightnumber ,@airlineNameThree=Airlines ,@airLegThirdBookingClasses=airLegBookingClasses,@thirdAirLegConnections =airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKeyThird  and airLegnumber = 3
   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey  where airrequestkey  = @airrequestkey  and airLegnumber = 1  and Airlines = @airlineNameOne  and airLegBookingClasses =@airLegBookingClasses  and s.airSubRequestLegIndex = -1  and airLegConnections =@airLegConnections 
intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey where airrequestkey  = @airrequestkey  and airLegnumber = 2   and Airlines = @airlineNameTwo and airLegBookingClasses =@airLegSecondBookingClasses and s.airSubRequestLegIndex = -1 and airLegConnections =@secondAirLegConnections   
 	intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey  where airrequestkey  = @airrequestkey  and airLegnumber = 3  and Airlines = @airlineNameThree and airLegBookingClasses =@airLegThirdBookingClasses  and s.airSubRequestLegIndex = -1 and airLegConnections =@thirdAirLegConnections 
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
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=Airlines ,@airLegBookingClasses=airLegBookingClasses,@airLegConnections =@airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=Airlines ,@airLegSecondBookingClasses=airLegBookingClasses,@secondAirLegConnections =airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond  and airLegnumber = 2
		 select @flightNumberThree= flightnumber ,@airlineNameThree=Airlines ,@airLegThirdBookingClasses=airLegBookingClasses,@thirdAirLegConnections=airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKeyThird  and airLegnumber = 3
		 select @flightNumberFour= flightnumber ,@airlineNameFour=Airlines   ,@airLegFourthBookingClasses=airLegBookingClasses,@fourthAirLegConnections=airLegConnections  from NormalizedAirResponses where airresponsekey = @selectedResponseKeyFourth  and airLegnumber = 4
   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey  where airrequestkey  = @airrequestkey  and airLegnumber = 1  and Airlines = @airlineNameOne and airLegBookingClasses =@airLegBookingClasses and airLegConnections =@airLegConnections and s.airSubRequestLegIndex = - 1
intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey where airrequestkey  = @airrequestkey  and airLegnumber = 2   and Airlines = @airlineNameTwo and airLegBookingClasses = @airLegSecondBookingClasses and airLegConnections =@secondairLegConnections   and s.airSubRequestLegIndex = - 1
 	intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey where airrequestkey  = @airrequestkey  and airLegnumber = 3   and Airlines = @airlineNameThree and airLegBookingClasses =@airLegThirdBookingClasses and airLegConnections =@thirdAirLegConnections  and s.airSubRequestLegIndex = - 1
 			intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey where airrequestkey  = @airrequestkey  and airLegnumber = 4  and Airlines = @airlineNameFour and airLegBookingClasses = @airLegFourthBookingClasses and airLegConnections =@fourthAirLegConnections  and s.airSubRequestLegIndex = - 1
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
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=Airlines ,@airLegBookingClasses=airLegBookingClasses,@airLegConnections =airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=Airlines ,@airLegSecondBookingClasses=airLegBookingClasses ,@secondAirLegConnections =airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond  and airLegnumber = 2
		 select @flightNumberThree= flightnumber ,@airlineNameThree=Airlines ,@airLegThirdBookingClasses=airLegBookingClasses,@thirdAirLegConnections =airLegConnections    from NormalizedAirResponses where airresponsekey = @selectedResponseKeyThird  and airLegnumber = 3
		 select @flightNumberFour= flightnumber ,@airlineNameFour=Airlines   ,@airLegFourthBookingClasses=airLegBookingClasses,@fourthAirLegConnections =airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKeyFourth  and airLegnumber = 4
		 		 select @flightNumberFive = flightnumber ,@airlineNameFive=Airlines   ,@airLegFifthBookingClasses=airLegBookingClasses,@fifthAirLegConnections =airLegConnections   from NormalizedAirResponses where airresponsekey = @selectedResponseKeyFifth  and airLegnumber = 5

   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey  where airrequestkey  = @airrequestkey  and airLegnumber = 1  and Airlines = @airlineNameOne and airLegBookingClasses =@airLegBookingClasses and airLegConnections =@airLegConnections  and s.airSubRequestLegIndex = - 1
intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey where airrequestkey  = @airrequestkey  and airLegnumber = 2  and Airlines = @airlineNameTwo and airLegBookingClasses = @airLegSecondBookingClasses and airLegConnections =@secondairLegConnections  and s.airSubRequestLegIndex = - 1
 	intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey where airrequestkey  = @airrequestkey  and airLegnumber = 3  and Airlines = @airlineNameThree and airLegBookingClasses =@airLegThirdBookingClasses and airLegConnections =@thirdairLegConnections  and s.airSubRequestLegIndex = - 1
 			intersect 
			select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey where airrequestkey  = @airrequestkey  and airLegnumber = 4 and Airlines = @airlineNameFour and airLegBookingClasses = @airLegFourthBookingClasses and airLegConnections =@fourthairLegConnections  and s.airSubRequestLegIndex = - 1
            intersect  
  	select airresponsekey  from NormalizedAirResponses n  
  inner join airsubrequest s on n.airsubrequestkey=s.airSubrequestkey where airrequestkey  = @airrequestkey  and airLegnumber = 5  and Airlines = @airlineNameFive  and airLegBookingClasses = @airLegFifthBookingClasses and airLegConnections =@fifthAirLegConnections  and s.airSubRequestLegIndex = - 1
	 )
		 
 			end 
        
        
      
    return     
 end  
GO
