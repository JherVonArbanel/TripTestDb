SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Jitendra Verma
-- Create date: 03-Aug-2015
-- Description:	It is used to get event attendee purchased list of event
-- USP_GetEventPurchasedAttendeesByEvent 1753
-- =============================================

CREATE PROCEDURE [dbo].[USP_GetEventPurchasedAttendeesByEvent]
	-- Add the parameters for the stored procedure here
	@EventKey INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @recommendedHotelId INT
			,@hostUserKey INT			
	
	DECLARE @PurchasedTable AS TABLE
	(
		EventAttendeeKey INT
		,TripKey INT
		,UserKey INT
	)
	
	DECLARE @PurchasedHotelDetails AS TABLE
	(
		SupplierId VARCHAR(15)
		,SupplierFamily VARCHAR(20)
		,UserKey INT
	)
	
	DECLARE @UserSamePurchasedHotel AS TABLE
	(	
		UserKey INT
	)
	
	SELECT @hostUserKey = userKey
	,@recommendedHotelId = eventRecommendedHotelId 
	FROM [Events] WITH(NOLOCK) 
	WHERE eventKey = @EventKey
	
	INSERT INTO @PurchasedTable
	(
		EventAttendeeKey
		,TripKey
		,UserKey
	)
	SELECT EA.eventAttendeeKey
	,ATD.attendeeTripKey
	,EA.userKey
	FROM EventAttendees EA WITH(NOLOCK)
	INNER JOIN AttendeeTravelDetails ATD WITH(NOLOCK)
	ON ATD.eventAttendeekey = EA.eventAttendeekey
	AND ATD.isPurchased = 1
	AND EA.eventKey = @EventKey
	AND EA.isHost = 0
	
	INSERT INTO @PurchasedHotelDetails
	(
		SupplierId
		,SupplierFamily
		,UserKey
	)
	SELECT THR.supplierHotelKey
	,THR.supplierId
	,T.userKey
	FROM Trip T WITH(NOLOCK)
	INNER JOIN @PurchasedTable PT
	ON PT.TripKey = T.tripKey
	INNER JOIN TripHotelResponse THR WITH(NOLOCK)
	ON THR.tripGUIDKey = T.tripSavedKey
	
	INSERT INTO @UserSamePurchasedHotel 
	(
		UserKey
	)
	SELECT PHD.UserKey
	FROM HotelContent.dbo.SupplierHotels1 SH WITH(NOLOCK)
	INNER JOIN @PurchasedHotelDetails PHD 
	ON PHD.SupplierFamily = SH.SupplierFamily
	AND PHD.SupplierId = SH.SupplierHotelId
	INNER JOIN HotelContent.dbo.Hotels H WITH(NOLOCK)
	ON H.HotelId = SH.HotelId
	AND H.HotelId = @recommendedHotelId
	
	INSERT INTO @UserSamePurchasedHotel
	(
		UserKey
	)
	VALUES (@hostUserKey)
	
		
	SELECT 
	u.userKey
	,u.userLogin
	,u.userFirstName
	,u.userLastName
	,um.ImageUrl 
	FROM  [Vault].[dbo].[User] u WITH(NOLOCK)
	INNER JOIN [Loyalty].[dbo].[UserMap] um WITH(NOLOCK) 
	ON um.userId = u.userKey 
	INNER JOIN @UserSamePurchasedHotel USP
	ON USP.UserKey = U.userKey	
	
	--SELECT u.userKey, u.userLogin, u.userFirstName, u.userLastName, um.ImageUrl 
	--	FROM  [Vault].[dbo].[User] u WITH(NOLOCK)
	--	INNER JOIN [Loyalty].[dbo].[UserMap] um WITH(NOLOCK) on um.userId = u.userKey 
	--	INNER JOIN [Trip].[dbo].[EventAttendees] ea WITH(NOLOCK) on ea.userKey = u.userKey 
	--	INNER JOIN [Trip].[dbo].[AttendeeTravelDetails] atd WITH(NOLOCK) on ea.eventAttendeeKey = atd.eventAttendeeKey
	--	Where ea.eventKey= 1753--@EventKey
	
END


GO
