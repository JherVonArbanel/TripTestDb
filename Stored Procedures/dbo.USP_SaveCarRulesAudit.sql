SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_SaveCarRulesAudit]  
 @carResponseKey uniqueidentifier,  
 @carRules varchar(2000)  
AS  
BEGIN  
 Update TripCarResponse  
 set  
 carRules=@carRules  
 where carResponseKey=@carResponseKey  
   
END
GO
