SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into [tripAirResponseTax] table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_AirResponseTax]
	 @airResponseKey As uniqueidentifier,
	 @amount As float, 
	 @designator As nvarchar(50) ,
	 @nature As nvarchar(50) , 
	 @description As nvarchar(50) 
	 
AS
BEGIN
 
INSERT INTO [tripAirResponseTax]
			([airResponseKey],[amount],[designator],[nature],[description]) 
		VALUES
			(@airResponseKey, @amount, @designator, @nature, @description )
			
SELECT Scope_Identity()
                    
END


GO
