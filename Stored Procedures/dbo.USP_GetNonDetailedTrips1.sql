SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[USP_GetNonDetailedTrips1]
(
	@userKey	INT,
	@companyKey	INT,
    @fromDate   DateTime,
    @toDate   DateTime	
)
AS
BEGIN

		CREATE TABLE #tblUser  
		(  
		 UserKey Int  
		)  

		BEGIN  
		 INSERT INTO #tblUser  
		 SELECT DISTINCT userKey from Vault.dbo.GetAllArrangees(@userkey,@companyKey )  
		END

	    SELECT tripKey, tripName FROM trip WITH(NOLOCK) 
			INNER JOIN #tblUser TU ON trip.userKey = TU.userKey   WHERE trip.endDate < GETDATE() AND recordlocator IS NOT NULL AND recordlocator <> ''  ORDER BY tripKey DESC
	
END



GO
