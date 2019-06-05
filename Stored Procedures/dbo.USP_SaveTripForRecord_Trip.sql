SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Insert Records into Trip table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_Trip]
	 @tripName As nvarchar(100) ,
	 @userKey As int ,
	 @recordLocator As varchar(50) ,
	 @tripStatusKey As int ,
	 @agencyKey As int ,
	 @tripComponentType As smallint ,
	 @tripRequestKey As int ,
	 @meetingCodeKey As varchar(50) ,
	 @siteKey As int
  
AS
BEGIN
 
 INSERT INTO [dbo].[Trip] 
		([tripName],[userKey],[recordLocator],[tripStatusKey],[agencyKey],[tripComponentType],[tripRequestKey],[meetingCodeKey],[sitekey]) 
	VALUES 
		(@tripName, @userKey, @recordLocator, @tripStatusKey, @agencyKey, @tripComponentType, @tripRequestKey, @meetingCodeKey, @siteKey) 
		
	SELECT Scope_Identity()

END



GO
