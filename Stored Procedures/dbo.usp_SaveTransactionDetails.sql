SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[usp_SaveTransactionDetails]  
(  
   
 @Amount decimal,  
 @TransactionId varchar(50),  
 @TripId int,  
 @PaymentApproved bit,  
 @ResponseMessage varchar(100),
 @SiteKey int   
)  
AS   
BEGIN   
  
 INSERT INTO TransactionDetails  
 (    
  Amount,  
  TransactionId,  
  TripId,  
  PaymentApproved,  
  ResponseMessage,  
  CreatedDateTime,
  SiteKey  
   
 )  
 VALUES  
 (  
  @Amount,  
  @TransactionId,  
  @TripId,  
  @PaymentApproved,  
  @ResponseMessage,  
  GETDATE(),
  @SiteKey  
 )  
   
 SELECT SCOPE_IDENTITY()  
  
END
GO
