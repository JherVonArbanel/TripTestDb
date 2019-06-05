SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Created Procedure by ANUPAM(7/Jun/2012)

*/
CREATE PROCEDURE [dbo].[USP_AddTripTicketInfo]

@tripKey	INT,
@recordLocator	VARCHAR(10),
@isExchanged	BIT,
@isVoided	BIT,
@isRefunded	BIT,
@oldTicketNumber	VARCHAR(20),
@newTicketNumber	VARCHAR(20),
@issuedDate	DATETIME,
@currency	VARCHAR(10),
@oldFare	FLOAT,
@newFare	FLOAT,
@addCollectFare	FLOAT,
@serviceCharge	FLOAT,
@residualFare	FLOAT,
@TotalFare Float = 0,
@ExchangeFee Float = 0,
@TripHistoryKey uniqueidentifier = null,
@BaseFare Float = 0,
@TaxFare Float = 0,
@IsHostStatusTicketed BIT = 1
AS
BEGIN

	/* Condition for same ticket is exist or not */
	IF(SELECT COUNT(*) FROM TripTicketInfo WITH(NOLOCK)
	WHERE tripKey = @tripKey 
	AND isExchanged = @isExchanged
	AND isVoided = @isVoided
	AND isRefunded = @isRefunded
	AND oldTicketNumber = @oldTicketNumber) = 0

		BEGIN

		INSERT INTO TripTicketInfo
		(tripKey,recordLocator,isExchanged,isVoided,isRefunded,oldTicketNumber,newTicketNumber,createdDate,
		issuedDate,currency,oldFare,newFare,addCollectFare,serviceCharge,residualFare,TotalFare,ExchangeFee,TripHistoryKey,BaseFare,TaxFare,IsHostStatusTicketed)
		VALUES
		(@tripKey,@recordLocator,@isExchanged,@isVoided,@isRefunded,@oldTicketNumber,@newTicketNumber,GetDate(),
		@issuedDate,@currency,@oldFare,@newFare,@addCollectFare,@serviceCharge,@residualFare,@TotalFare,@ExchangeFee,
		@TripHistoryKey,@BaseFare,@TaxFare,@IsHostStatusTicketed
		
		)

		END

		else 
		begin
		update TripTicketInfo set IsHostStatusTicketed=@IsHostStatusTicketed 
		WHERE tripKey = @tripKey 
		AND isExchanged = @isExchanged
		AND isVoided = @isVoided
		AND isRefunded = @isRefunded
		AND oldTicketNumber = @oldTicketNumber
		end

END
GO
