SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Function [dbo].[ufn_GetValidResponsesForMultiCity] 
 (@airLegNumber  as int,@airSubRequestKey as int , @selectedResponseKey as uniqueidentifier ,@selectedResponseKeySecond as uniqueIdentifier ,@selectedResponseKeyThird as uniqueidentifier ,@selectedResponseKeyFourth as uniqueIdentifier,@selectedResponseKeyFifth as uniqueIdentifier  )
 
 	 
	 
 
RETURNS @ResultTable table 
	(
   airresponseKey uniqueidentifier )
	 
		 
AS
	 begin 
	 
	  declare @flightNumberOne as varchar(200) 
	 declare @airlineNameOne as varchar(200) 
	 	  declare @flightNumberTwo as varchar(200) 
	 declare @airlineNameTwo as varchar(200) 
	 	  declare @flightNumberThree as varchar(200) 
	 declare @airlineNameThree  as varchar(200) 
	 	  declare @flightNumberFour as varchar(200) 
	 declare @airlineNameFour as varchar(200) 	 	  
	  declare @flightNumberFive as varchar(200) 
	 declare @airlineNameFive as varchar(200)
	 
 	declare @airRequestKey AS INT= (SELECT AirRequestKEY from  AirSubRequest where airSubRequestKey = @airSubRequestKey )
 
	DECLARE @subRequestTables AS TABLE (airSubRequestKey   INT)
	INSERT INTO @subRequestTables  
	SELECT  AirSubRequestKey From AirSubRequest where airRequestKey =@airRequestKey and airSubRequestLegIndex = -1  

	  if   @airLegNumber = 2 
	 begin 
	 
	 
	 select @flightNumberOne= flightnumber ,@airlineNameOne=airlines  
	  from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	
			   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses N
			INNER JOIN AirSubRequest subreq On N.airsubrequestkey =subreq.airSubRequestKey
			INNER JOIN @subRequestTables tmpRQ on subreq.airSubRequestKey =tmpRQ.airSubRequestKey 
			where  airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne  
			 )
 			end 
 			
 			if  @airLegnumber = 3 
 			begin
 			
 			if ( @selectedResponseKeySecond is null ) 
 			BEGIN
 			set @selectedResponseKeySecond =   @selectedResponseKey
 			END 
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond and    airLegnumber = 2
	   insert into @ResultTable (airresponseKey)
			 (
			
			select airresponsekey  from NormalizedAirResponses  N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where  airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne 
intersect 
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where      airLegnumber = 2  and flightnumber =  @flightnumberTwo and airlines = @airlineNameTwo 
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
 			
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond  and airLegnumber = 2
		 select @flightNumberThree= flightnumber ,@airlineNameThree=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKeyThird  and airLegnumber = 3
   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where   airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne 
intersect 
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where   airLegnumber = 2  and flightnumber =  @flightnumberTwo and airlines = @airlineNameTwo 
 	intersect 
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where   airLegnumber = 3  and flightnumber =  @flightnumberThree and airlines = @airlineNameThree
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
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond  and airLegnumber = 2
		 select @flightNumberThree= flightnumber ,@airlineNameThree=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKeyThird  and airLegnumber = 3
		 select @flightNumberFour= flightnumber ,@airlineNameFour=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKeyFourth  and airLegnumber = 4
   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where  airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne 
intersect 
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where   airLegnumber = 2  and flightnumber =  @flightnumberTwo and airlines = @airlineNameTwo 
 	intersect 
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where   airLegnumber = 3  and flightnumber =  @flightnumberThree and airlines = @airlineNameThree
 			intersect 
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where   airLegnumber = 4  and flightnumber =  @flightnumberFour  and airlines = @airlineNameFour
	 )
		 
 			end 
 			
 			if  @airLegnumber =6
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
 			if ( @selectedResponseKeyFifth  is null ) 
 			BEGIN
 			set @selectedResponseKeyFifth =   @selectedResponseKey
 			END  
 		 
 			 select @flightNumberOne= flightnumber ,@airlineNameOne=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKey  and airLegnumber = 1
	 select @flightNumberTwo= flightnumber ,@airlineNameTwo=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKeySecond  and airLegnumber = 2
		 select @flightNumberThree= flightnumber ,@airlineNameThree=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKeyThird  and airLegnumber = 3
		 select @flightNumberFour= flightnumber ,@airlineNameFour=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKeyFourth  and airLegnumber = 4
		 	 select @flightNumberFive= flightnumber ,@airlineNameFive=airlines   from NormalizedAirResponses where airresponsekey = @selectedResponseKeyFifth  and airLegnumber = 5
   insert into @ResultTable (airresponseKey)
			 (
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where  airLegnumber = 1 and flightnumber =  @flightnumberOne and airlines = @airlineNameOne 
intersect 
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where  airLegnumber = 2  and flightnumber =  @flightnumberTwo and airlines = @airlineNameTwo 
 	intersect 
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where  airLegnumber = 3  and flightnumber =  @flightnumberThree and airlines = @airlineNameThree
 			intersect 
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where   airLegnumber = 4  and flightnumber =  @flightnumberFour  and airlines = @airlineNameFour
			intersect 
			select airresponsekey  from NormalizedAirResponses N INNER JOIN @subRequestTables tmpRQ on N.airSubRequestKey =tmpRQ.airSubRequestKey  where   airLegnumber = 5  and flightnumber =  @flightnumberFive  and airlines = @airlineNameFive
	 )
		 
 			end 
 			
 			return   
 end
GO
