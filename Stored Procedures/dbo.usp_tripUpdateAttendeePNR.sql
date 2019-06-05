SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[usp_tripUpdateAttendeePNR]      
(      
 @SiteKey INT
,@PNR  NVARCHAR(20)
,@EmailAddress NVARCHAR(200)
,@MeetingCode NVARCHAR(50)
)      
AS    
BEGIN    
-- EXEC  usp_tripUpdateAttendeePNR 51,'QWYHBI','harsh.mehta@rinira.com','TGRP02' 
	/*
	From:Brian 

	When linking them up from any existing invites, I would like to:

	1)	link to ALL active PNRs (Purchased, not Cancelled status) - show 1, 2, 3, or more if there is more than one Purchased PNR -
	2)	If there is a Cancelled PNR but an active PNR for the same person, link to the active "Purchased" PNR
	3)	If there are two or more Cancelled PNRs for the same email address, link to the Purchased PNR
	4)	For any of these scenarios, if there are more than one Purchased PNRs, show them all (do not show Cancelled)
	5)	ONLY IF there is absolutely NO Purchased PNR for that traveler (only 1 or more Cancelled PNRs), link to the Cancelled PNR. 
		If there are more than 1 Cancelled PNRs, link to the MOST RECENTLY BOOKED Cancelled PNR       
	*/
	DECLARE @TripKEy INT, @AttendeeGuid NVARCHAR(100), @tripRequestKey INT, @GroupKey INt, @EventKey Int
	
	SELECT @GroupKey  = GM.GroupKey,@EventKey = m.meetingCodeKey
	FROM VAult..Meeting M 
		Left Outer JOIN VAult..groupEventMapping GM ON GM.MeetingCodeKey = M.MeetingCodeKey
	where M.MeetingCode = @MeetingCode AND M.SiteKey = @SiteKey


	--SELECT   @AttendeeGuid=T.AttendeeGuid 
	--FROM	TRIP..Trip  T
	--		LEFT OUTER JOIN TripPassengerInfo P ON P.TripKey =T .TripKey
	--WHERE		T.recordLocator = @PNR
	--		AND T.siteKey = @SiteKey
	--		AND T.meetingCodeKey = @MeetingCode
	--		AND P.PassengerEmailID = @EmailAddress
	--		AND T.tripStatusKey = 2

	SELECT  TOP 1 @AttendeeGuid=T.AttendeeGuid 
			,@tripRequestKey = T.tripRequestKey
			,@tripkey = T.TrIpKey
	FROM	TRIP..Trip  T
			LEFT OUTER JOIN TripPassengerInfo P ON P.TripKey =T .TripKey
	WHERE	T.recordLocator = @PNR
			AND T.siteKey = @SiteKey
			AND T.meetingCodeKey = @MeetingCode
			AND P.PassengerEmailID = @EmailAddress
			AND T.tripStatusKey = 2

			
	IF @AttendeeGuid IS NULL AND @tripRequestKey = 0 -- (This is offline PNR)
	BEGIN

		SELECT @AttendeeGuid = MA.AttendeesGuid  FROM Vault..Meeting_Attendees MA
			LEFT OUTER JOIN Vault..Meeting M ON MA.meetingCodeKey = M.MeetingCodeKey
		WHERE		M.siteKey = @SiteKey
				AND M.meetingCode = @MeetingCode
				AND MA.EmailAddress = @EmailAddress
				
		UPDATE TRIP..Trip   SET AttendeeGUID = @AttendeeGuid, GroupKey=@GroupKey, EventKey = @EventKey WHERE TripKey = @tripkey
	END


	SELECT  @TripKEy  = ISNULL(MAX(T.tripKey),0)
	FROM	TRIP..Trip  T
	WHERE		T.AttendeeGuid  = @AttendeeGuid
			AND T.siteKey = @SiteKey
			AND T.meetingCodeKey = @MeetingCode
			AND T.tripStatusKey = 2
			ANd T.tripRequestKey = 0
	GROUP BY T.AttendeeGuid 


	IF ISNULL(@TripKEy,0) > 0 
	BEGIN
	
		UPDATE Vault..Meeting_Attendees SET tripId = @TripKEy WHERE AttendeesGUID = @AttendeeGuid
	
	END 
	ELSE IF ISNULL(@TripKEy,0) = 0 
	BEGIN
	/*5)	ONLY IF there is absolutely NO Purchased PNR for that traveler (only 1 or more Cancelled PNRs), link to the Cancelled PNR. 
		If there are more than 1 Cancelled PNRs, link to the MOST RECENTLY BOOKED Cancelled PNR       
	*/
		SELECT  @TripKEy  = ISNULL(MAX(T.tripKey),0)
		FROM	TRIP..Trip  T
		WHERE		T.AttendeeGuid  = @AttendeeGuid
				AND T.siteKey = @SiteKey
				AND T.meetingCodeKey = @MeetingCode
				AND T.tripStatusKey = 5
		GROUP BY T.AttendeeGuid 	
		
		IF ISNULL(@TripKey,0) > 0
		BEGIN
		
			UPDATE Vault..Meeting_Attendees SET TripId = @TripKEy WHERE AttendeesGUID = @AttendeeGuid
			
		END

	END
	
END
GO
