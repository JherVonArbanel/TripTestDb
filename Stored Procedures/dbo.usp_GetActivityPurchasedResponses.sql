SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--EXEC usp_GetActivityPurchasedResponses 6554
CREATE PROC [dbo].[usp_GetActivityPurchasedResponses]
(
	@tripKey INT
)
AS 
BEGIN 

	SELECT 
			--ActivityId, 
			ISNULL(ConfirmationNumber, '')as ConfirmationNumber, 
			ISNULL(RecordLocator, '') as RecordLocator, 
			ISNULL(ActivityType, '') as ActivityType, 
			ISNULL(ActivityTitle, '') as ActivityTitle, 
			ISNULL(ActivityText, '') as ActivityText, 
			ActivityDate, 
			ISNULL(VoucherURL, '') as VoucherURL, 
			ISNULL(CancellationFormURL, '') as CancellationFormURL,
			NoOfAdult,
			NoOfChild,
			NoOfYouth,
			NoOfInfant,
			NoOfSenior,
			TotalPrice, 
			ISNULL(Link, '') as Link
						  
	FROM 
			TripActivityResponse
	WHERE 
			TripKey = @tripKey


END 

GO
