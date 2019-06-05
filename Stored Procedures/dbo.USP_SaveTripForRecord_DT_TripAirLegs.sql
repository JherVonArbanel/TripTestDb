SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into [TripAirLegs] table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_TripAirLegs]
	 @airResponseKey As uniqueidentifier,
	 @gdsSourceKey As int, 
	 @selectedBrand As varchar(50) ,
	 @recordLocator As varchar(50) , 
	 @airLegNumber As int ,
	 @tripKey As int 
	 
	 
AS
BEGIN
 
INSERT INTO [TripAirLegs] 
			([airResponseKey] ,[gdsSourceKey],[selectedBrand]
            ,[recordLocator],[airLegNumber] ,[tripKey])
		Values 
			(@airResponseKey, @gdsSourceKey, @selectedBrand
			,@recordLocator, @airLegNumber, @tripKey) 
			
		SELECT Scope_Identity()
                    
END


GO
