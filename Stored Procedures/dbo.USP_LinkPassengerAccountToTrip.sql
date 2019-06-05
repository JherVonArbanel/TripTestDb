SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Shrikant Sonawane>
-- Create date: <Create Date,,>
-- Description:	<to link user with trip in passenger info>
-- =============================================
CREATE PROCEDURE [dbo].[USP_LinkPassengerAccountToTrip] (
	@userKey BIGINT,
	@tripKey BIGINT,
	@userEmail Varchar(200)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE TripPassengerInfo SET PassengerKey = @userKey WHERE TripKey = @tripKey AND PassengerEmailID = @userEmail;
	
	SELECT COUNT(TripKey) as cnt From TripPassengerInfo WHERE TripKey = @tripKey AND PassengerEmailID = @userEmail;
	
END
GO
