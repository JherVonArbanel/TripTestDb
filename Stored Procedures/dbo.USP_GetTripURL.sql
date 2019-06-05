SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[USP_GetTripURL](      
--DECLARE 
	@recordLocator   VARCHAR(10)
)AS      
BEGIN 
	--SELECT @recordLocator = 'URXYWU'

--SELECT TOP 10 * FROM Trip..Trip WHERE recordLocator = 'URXYWU' SiteKey = 51 AND subSiteKey = 53 Order By 1 DESC
	DECLARE @AttendeeGUID VARCHAR(80) = NULL, @meetingCodeKey INT = NULL, @GroupKey INT = NULL, @CompanyKey INT = NULL
	
	SELECT @AttendeeGUID = AttendeeGUID, @meetingCodeKey = T.EventKey, @Groupkey = T.GroupKey, @CompanyKey = M.CompanyKey
	FROM Trip..Trip T
		LEFT OUTER JOIN Vault..Meeting M ON T.EventKey = M.MeetingCodeKey 
	WHERE RecordLocator = @recordLocator
	
	SELECT @meetingCodeKey MeetingCodeKey, @AttendeeGUID AttendeeGUID,@GroupKey GroupKey, @CompanyKey CompanyKey
	
END
GO
