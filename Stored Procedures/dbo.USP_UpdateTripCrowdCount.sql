SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 23rd July 2014
-- Description:	Updates crowd count in trip table
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateTripCrowdCount]
	
	@tripKey INT
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @tripSavedKey UNIQUEIDENTIFIER
			,@FollowersCount INT
	
	SELECT @tripSavedKey = tripSavedKey FROM Trip WITH(NOLOCK)
	WHERE tripKey = @tripKey
	
	SET @FollowersCount = dbo.udf_GetCrowdCount(@tripSavedKey)
	
	UPDATE Trip SET CrowdCount = @FollowersCount
	WHERE tripKey IN 
	(
		SELECT tripKey FROM Trip WITH(NOLOCK) 
		WHERE tripSavedKey = @tripSavedKey
	)
    
END
GO
