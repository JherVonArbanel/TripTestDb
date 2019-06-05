SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 21-01-2016 15:26pm
-- Description:	Get all trips alerts information by UserId
-- =============================================
-- EXEC USP_GetTripAlertsByUserId 560799, 30, 1
CREATE PROCEDURE [dbo].[USP_GetTripAlertsByUserId] 
	@userKey bigint,
	@limit int = 30,
    @pageNumber int =1
AS
BEGIN
	
	IF @limit > 0
	BEGIN
		SELECT  *, TP.tripStatusKey AS TripStatus FROM 
		(
			SELECT ROW_NUMBER() OVER (Partition By TripKey ORDER BY tripKey DESC) AS RowNum,ROW_NUMBER() OVER ( Order by TripKey DESC) As PageNo, * 
			FROM Trip..TimeLine 
			WHERE userKey =@userKey and tripKey > 0 AND showAlert=1 

		) AS RowNumbering
		INNER JOIN Trip..Trip TP ON Tp.tripKey = RowNumbering.tripKey and TP.userKey = @userKey AND TP.isUserCreatedSavedTrip = 1 AND TP.tripStatusKey not in (1,4,5,15)
		WHERE RowNum = 1  and PageNo >= @limit * (@pageNumber - 1) + 1 AND PageNo <= @pageNumber * @limit 
	END
	ELSE
	BEGIN
		SELECT  *, TP.tripStatusKey AS TripStatus FROM 
		(
			SELECT ROW_NUMBER() OVER (Partition By TripKey ORDER BY tripKey DESC) AS RowNum, * 
			FROM Trip..TimeLine 
			WHERE userKey =@userKey and tripKey > 0  AND showAlert=1

		) AS RowNumbering
		INNER JOIN Trip..Trip TP ON Tp.tripKey = RowNumbering.tripKey and TP.userKey = @userKey AND TP.isUserCreatedSavedTrip = 1 AND TP.tripStatusKey not in (1,4,5,15)
		WHERE RowNum = 1 
	END
	
END
GO
