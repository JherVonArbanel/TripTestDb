SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetTripsforSendingEmails] 	
AS
BEGIN	
	SET NOCOUNT ON;   
	
	SELECT  top 50
		   tripkey, 
	       userkey,
		   recordLocator, 
		   tripStatusKey, 
		   triprequestkey,
		   siteKey, 
		   GroupKey
	INTO #EmailTemp
	FROM [Trip].[dbo].[Trip]
	WHERE tripStatusKey<>17 
	AND IsEmailSend_Require = 1 
	AND 
	NOT EXISTS (SELECT tripkey 
				FROM TripEmailProcessing P 
				WHERE  [Trip].tripkey=P.tripkey 
				AND P.status=1)

	INSERT INTO TripEmailProcessing(tripkey,status,CreateDate)
	select tripkey,1, GETDATE()
	FROM #EmailTemp

	SELECT tripkey, 
	       userkey,
		   recordLocator, 
		   tripStatusKey, 
		   triprequestkey,
		   siteKey, 
		   GroupKey 
	FROM #EmailTemp
		
END
GO
