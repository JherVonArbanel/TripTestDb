SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into Trip table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_Trip]
	 @tripName As nvarchar(50) ,
	 @userKey As int ,
	 @recordLocator As varchar(50),
	 @tripStatusKey As int ,
	 @agencyKey As int ,
	 @tripComponentType As smallint,
	 @tripRequestKey AS int
	 
AS
BEGIN
 
INSERT INTO [dbo].[Trip] 
			([tripName],[userKey],[recordLocator],[tripStatusKey] ,[agencyKey], tripComponentType, tripRequestKey) 
		VALUES 
			(@tripName, @userKey, @recordLocator, @tripStatusKey , @agencyKey, @tripComponentType, @tripRequestKey) 
		
		SELECT Scope_Identity()
                    
END


GO
