SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Records Insert into TripAirResponse table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_TripAirResponse]
	 @airResponseKey As uniqueidentifier ,
	 @tripKey As int ,
	 @searchAirPrice As float,
	 @searchAirTax As float,
	 @actualAirPrice As float,
	 @actualAirTax As float,
	 @CurrencyCodeKey As nvarchar(20),
	 @bookingcharges As float,
	 @appliedDiscount As float
AS
BEGIN
 
INSERT INTO [TripAirResponse]
		([airResponseKey],[tripKey],[searchAirPrice],[searchAirTax],[actualAirPrice],[actualAirTax],[CurrencyCodeKey],[bookingcharges],[appliedDiscount]) 
	VALUES
		(@airResponseKey , @tripKey, @searchAirPrice ,@searchAirTax  ,@actualAirPrice ,@actualAirTax,@CurrencyCodeKey,@bookingcharges,@appliedDiscount) 
		
	SELECT Scope_Identity()

END

GO
