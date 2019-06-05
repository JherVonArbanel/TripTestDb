SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [dbo].[GetFlightNumbersForResponse]
( @airresponsekey as uniqueidentifier ,
@airLegNumber int

)  
returns varchar (1000)   
as begin
-- DECLARE  
--@AllValues VARCHAR(4000)   
--SELECT  
--@AllValues = COALESCE(@AllValues + '|', '')+ CONVERT(varchar(20),airSegmentFlightNumber )  
--FROM  
--AirSegments  
 
--WHERE  airResponseKey =@airresponsekey and airLegnumber = @airLegNumber order by airSegmentDepartureDate 
--if   @AllValues is null select @AllValues =''  
--return ( @AllValues )  
 DECLARE @p VARCHAR(MAX)='' ;
         --  SET @p = '' ;
         SELECT @p = @p + case when @p = '' then '' else ',' end  + convert(varchar(100),airSegmentFlightNumber)  
          FROM AirSegments 
         WHERE airResponseKey = @airresponsekey and airLegnumber = @airLegNumber order by airSegmentDepartureDate ;
		return( @p )
end
GO
