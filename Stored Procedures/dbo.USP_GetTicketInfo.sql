SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* ----- Created By Anupam (2/Jun/2012)------ 
Description - It is used to get exchanged,refunded,voided Ticketing info.
Exec USP_GetTicketInfo 0,1,-1,1
*/
CREATE PROCEDURE [dbo].[USP_GetTicketInfo]
(
	@tripKey INT,
	@isExchanged SMALLINT,
	@isRefunded SMALLINT,
	@isVoided SMALLINT
)
AS
BEGIN

SELECT *
FROM TripTicketInfo WITH(NOLOCK)
WHERE (@tripKey = 0 OR tripKey = @tripKey)
AND (@isExchanged = -1 OR isExchanged = @isExchanged)
AND (@isVoided = -1 OR isVoided = @isVoided)
AND (@isRefunded = -1 OR isRefunded = @isRefunded)


END
GO
