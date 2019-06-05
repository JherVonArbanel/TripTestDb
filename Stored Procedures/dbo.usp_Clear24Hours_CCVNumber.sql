SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[usp_Clear24Hours_CCVNumber]
AS
BEGIN
		IF OBJECT_ID('tempdb..#ClearCCVNumber') IS NOT NULL
		DROP TABLE #ClearCCVNumber

		CREATE Table #ClearCCVNumber
		(
		  tripKey bigint
		)

		INSERT INTO #ClearCCVNumber
		SELECT T.tripKey
		FROM TRIP..Trippassengercreditcardinfo PS
		INNER JOIN TRIP..Trip T ON PS.TripKey=T.tripKey
		WHERE PS.PTACode IS NOT NULL AND DATEDIFF(HOUR,T.CREATEDDATE,GETDATE())>24

		MERGE TRIP..Trippassengercreditcardinfo PS
		USING #ClearCCVNumber T--TRIP..Trip T
		ON(PS.tripkey=T.tripkey)
		WHEN MATCHED THEN
		UPDATE SET PS.PTACODE=NULL;
END


GO
