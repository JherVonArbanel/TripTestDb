SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 13th March 2015
-- Description:	Checks if savetrip exist and if user id is null or zero then it updates the user id
-- =============================================
CREATE PROCEDURE [dbo].[USP_CheckAndUpdateSaveTrip] 
	
	@tripKey INT
	,@userKey INT
	
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @isSuccess BIT = 0
			,@tripSavedKey UNIQUEIDENTIFIER
			,@oldUserKey INT = 0
	
	IF EXISTS(SELECT tripKey FROM Trip WITH(NOLOCK) WHERE tripKey = @tripKey)
	BEGIN
	
		SELECT @tripSavedKey = tripSavedKey 
		,@oldUserKey = ISNULL(userKey, 0)
		FROM Trip WITH(NOLOCK) 
		WHERE tripKey = @tripKey		
		
		IF EXISTS(SELECT tripSavedKey FROM TripSaved WITH(NOLOCK) WHERE tripSavedKey = @tripSavedKey)
		BEGIN
			IF(@oldUserKey = 0)
			BEGIN
				UPDATE Trip
				SET userKey = @userKey
				WHERE tripKey = @tripKey
				
				UPDATE TripSaved
				SET userKey = @userKey
				WHERE tripSavedKey = @tripSavedKey
				
				UPDATE TripDetails
				SET userKey = @userKey
				WHERE tripKey = @tripKey
			END
			SET @isSuccess = 1
		END
    END
    
	SELECT isSuccess = @isSuccess
	
END
GO
