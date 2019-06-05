SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Records Insert into TripAirResponseTax table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_TripAirResponseTax]
	 @airResponseKey As uniqueidentifier ,
	 @amount As float ,
	 @designator As nvarchar(100),
	 @nature As nvarchar(100),
	 @description As nvarchar(100)
AS
BEGIN
 
INSERT INTO [TripAirResponseTax]
		([airResponseKey],[amount],[designator],[nature],[description]) 
	VALUES
		(@airResponseKey ,@amount, @designator, @nature, @description )

END



GO
