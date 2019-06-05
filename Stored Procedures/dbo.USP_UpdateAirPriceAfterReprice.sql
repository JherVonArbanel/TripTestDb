SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[USP_UpdateAirPriceAfterReprice]
(
@airresponseKey uniqueidentifier, 
@priceTye varchar(20),
@tripAdultBase float,
@tripAdultTax float,
@tripSeniorBase float,
@tripSeniorTax float,
@tripYouthBase float,
@tripYouthTax float,
@tripChildBase float,
@tripChildTax float,
@tripInfantBase float,
@tripInfantTax float,
@creationDate dateTime , 
@totalPrice float ,
@totalTax float
)
AS 
BEGIN

declare @tripAirPriceKey int 
if ( @priceTye ='search' ) 
BEGIN 
SET @tripAirPriceKey = ( SELECT CASE WHEN @priceTye ='search' then searchAirPriceBreakupKey 
WHEN @priceTye ='reprice' THEN repricedAirPriceBreakupKey 
WHEN @priceTye ='actual' THEN actualAirPriceBreakupKey  
ELSE searchAirPriceBreakupKey END 

 from TripAirResponse where airResponseKey = @airresponseKey )


UPDATE  TripAirPrices 
   SET tripAdultBase = @tripAdultBase
      ,tripAdultTax = @tripAdultTax
      ,tripSeniorBase = @tripSeniorBase
      ,tripSeniorTax = @tripSeniorTax
      ,tripYouthBase = @tripYouthBase
      ,tripYouthTax = @tripYouthTax
      ,tripChildBase = @tripChildBase
      ,tripChildTax = @tripChildTax
      ,tripInfantBase = @tripInfantBase
      ,tripInfantTax = @tripInfantTax
      ,creationDate = @creationDate 
 WHERE   tripAirPriceKey =@tripAirPriceKey
 
if ( @priceTye = 'search'  ) 
BEGIN 
UPDATE TripAirResponse  SET  searchAirPrice = @totalPrice , searchAirTax = @totalTax where airResponseKey =@airresponseKey 
END 
ELSE IF( @priceTye = 'reprice'  ) 
BEGIN 
UPDATE TripAirResponse  SET  repricedAirPrice = @totalPrice , repricedAirTax = @totalTax where airResponseKey =@airresponseKey 
END
ELSE IF( @priceTye = 'actual'  ) 
BEGIN 
UPDATE TripAirResponse  SET  actualAirPrice = @totalPrice , actualAirTax = @totalTax where airResponseKey =@airresponseKey 

END

 END
 
 END
GO
