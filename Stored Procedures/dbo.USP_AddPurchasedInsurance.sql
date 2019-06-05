SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
-- =============================================  
-- Author:  <Anupam>  
-- Create date: <12Dec2012>  
-- Description: <Insert Records into Insurance table>  
-- =============================================  
CREATE PROCEDURE  [dbo].[USP_AddPurchasedInsurance]  
 @OrderID as varchar(50),   
 @ProductID as varchar(50),   
 @tripKey As int,  
 @amount as varchar(50),  
 @isOnlineBooking  BIT
    
AS  
BEGIN  
   
 INSERT INTO [dbo].[TripPurchasedInsurance]   
  ([OrderID],[ProductID],[tripKey],[amount],[isOnlineBooking])   
 VALUES   
  (@OrderID,@ProductID,@tripKey,@amount,@isOnlineBooking)   
    
 SELECT Scope_Identity()  
  
END
GO
