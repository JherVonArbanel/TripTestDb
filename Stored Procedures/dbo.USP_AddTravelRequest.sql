SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,INSERT INTO  TripRequesttable ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_AddTravelRequest]
	@userKey			INT,
	@tripTypeKey		INT, 
	@tripRequestCreated DATETIME
AS
BEGIN
 
	INSERT INTO TripRequest(userKey, tripTypeKey, tripRequestCreated) 
	VALUES (@userKey, @tripTypeKey, @tripRequestCreated) 
	
	SELECT SCOPE_IDENTITY()

END
GO
