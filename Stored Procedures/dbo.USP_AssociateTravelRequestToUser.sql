SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,Update  TripRequest table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_AssociateTravelRequestToUser]
	@userKey		INT,
	@tripRequestKey INT
AS
BEGIN
 
	UPDATE TripRequest 
	SET userkey = @userKey 
	WHERE tripRequestKey = @tripRequestKey

END
GO
