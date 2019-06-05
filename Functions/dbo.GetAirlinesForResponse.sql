SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [dbo].[GetAirlinesForResponse]
( @airresponsekey as uniqueidentifier ,@airLegNumber int)  
returns varchar (1000)   
as begin
-- DECLARE  
--@AllValues VARCHAR(4000)   
--SELECT  
--@AllValues = COALESCE(@AllValues + ',', '')+ CONVERT(varchar(20),airSegmentMarketingAirlineCode )  
--FROM  
--AirSegments  
 
--WHERE  airResponseKey =@airresponsekey and  airLegNumber =@airLegNumber 
--if   @AllValues is null select @AllValues =''  
--return ( @AllValues )  

 DECLARE @AllValues VARCHAR(MAX)='' ;
         --  SET @AllValues = '' ;
         SELECT @AllValues = @AllValues + case when @AllValues = '' then '' else ',' end  + convert(varchar(100),airSegmentMarketingAirlineCode)  
          FROM AirSegments 
         WHERE airResponseKey = @airresponsekey and airLegnumber = @airLegNumber order by airSegmentDepartureDate ;
		return( @AllValues )
 
end
GO
