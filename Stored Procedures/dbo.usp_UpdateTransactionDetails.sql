SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SELECT * FROM TransactionDetails

CREATE PROC [dbo].[usp_UpdateTransactionDetails]
(
	@TripId INT,
	@PaymentId BIGINT
)
AS 
BEGIN 
	
	UPDATE TransactionDetails
	SET TripId = @TripId
	WHERE Id = @PaymentId

END
GO
