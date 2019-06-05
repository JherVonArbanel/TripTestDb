SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Insert Records into Trip table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_UpdatePurchasedInsurance]
	@OrderID as varchar(50),	
	@ProductID as varchar(50),	
	@tripKey As int,
	@amount as varchar(50)
  
AS
BEGIN
 
 INSERT INTO [dbo].[TripPurchasedInsurance] 
		([OrderID],[ProductID],[tripKey],[amount]) 
	VALUES 
		(@OrderID,@ProductID,@tripKey,@amount) 
		
	SELECT Scope_Identity()

END
GO
