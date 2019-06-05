SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 06-06-2016 19:47
-- Description:	Updating HostUserId
-- =============================================
CREATE PROCEDURE [dbo].[CursorUpdatingHostUserId]
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @tripKey bigint
    DECLARE @tripSavedKey uniqueidentifier
    DECLARE @userKey bigint
    DECLARE @tripOriginalKey bigint
    

	DECLARE tripKey_cursor1 CURSOR FOR 
	SELECT  tripKey
	FROM [Trip].[dbo].[Trip] -- WHERE Preference = 1

	
	OPEN tripKey_cursor1

	FETCH NEXT FROM tripKey_cursor1 INTO @tripKey

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
	SELECT @tripSavedKey = TripsavedKey FROM Trip WITH(NOLOCK) where tripKey = @tripKey     
	SELECT @tripOriginalKey = (SELECT MIN(tripKey) FROM Trip WITH(NOLOCK) WHERE  tripSavedKey = @tripSavedKey) 
	SELECT @userKey=userkey FROM Trip..Trip WHERE tripKey=@tripOriginalKey
	UPDATE Trip..Trip SET HostUserId=@userKey WHERE tripKey=@tripOriginalKey

		FETCH NEXT FROM tripKey_cursor1 INTO @tripKey
		
	END

	CLOSE tripKey_cursor1
	DEALLOCATE tripKey_cursor1

END

GO
