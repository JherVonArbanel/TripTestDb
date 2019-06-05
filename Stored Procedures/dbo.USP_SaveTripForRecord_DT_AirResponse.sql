SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into [TripAirResponse] table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_AirResponse]
	 @airResponseKey As uniqueidentifier,
	 @tripKey As int, 
	 @searchAirPrice As float ,
	 @searchAirTax As float , 
	 @actualAirPrice As float , 
	 @actualAirTax As float , 
	 @CurrencyCodeKey As nvarchar(10)
	 
AS
BEGIN
 
INSERT INTO [TripAirResponse]
			([airResponseKey],[tripKey],[searchAirPrice],[searchAirTax],[actualAirPrice],[actualAirTax],[CurrencyCodeKey])
		 VALUES
			(@airResponseKey ,@tripKey, @searchAirPrice  ,@searchAirTax, @actualAirPrice, @actualAirTax, @CurrencyCodeKey) 
			
SELECT Scope_Identity()
                    
END


GO
