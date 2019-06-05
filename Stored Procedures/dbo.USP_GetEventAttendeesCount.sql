SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Rajkumar
-- Create date: 19-Nov-2015
-- Description:	Get EventAttendee count to show in Account page mobile
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetEventAttendeesCount] 
	@UserKey int
	--@SiteKey int
AS
BEGIN
	
	SET NOCOUNT ON;

   SELECT E.eventKey,E.EventName,
E.EventStartDate,--Estatus.eventAttendeeStatusDescription,
 --Count(EA.attendeeStatusKey) as StatusCount,Estatus.eventAttendeeStatusDescription,
 (select COUNT(1) From [Trip].[dbo].[EventAttendees] EAA Where EAA.eventkey = E.eventkey and attendeeStatuskey = 3 ) as Yes,
 (select COUNT(1) From [Trip].[dbo].[EventAttendees] EAA Where EAA.eventkey = E.eventkey and attendeeStatuskey = 2 ) as No,
 (select COUNT(1) From [Trip].[dbo].[EventAttendees] EAA Where EAA.eventkey = E.eventkey and attendeeStatuskey = 1 ) as Maybe,
 E.eventImageURL,Isnull((Select Top 1 isHost From [Trip].[dbo].[EventAttendees] EAA Where EAA.eventKey = E.eventKey and isHost=1),0) as IsHost
 --U.userFirstName,U.userLastName,
--EA.attendeeFirstName,EA.attendeeLastName
	FROM [Trip].[dbo].[Events] E 
	--LEFT JOIN [Vault].[dbo].[User] U WITH(NOLOCK) ON U.userKey = EA.UserKey 
	--INNER JOIN dbo.EventAttendeeStatusLookup EStatus on EA.attendeeStatusKey = EStatus.eventAttendeeStatusKey
	WHERE  E.IsDeleted = 0 and E.userKey = @UserKey
	Group by E.eventKey,E.EventName,E.EventStartDate,eventImageURL
	Order by E.eventKey desc
	
END
GO
