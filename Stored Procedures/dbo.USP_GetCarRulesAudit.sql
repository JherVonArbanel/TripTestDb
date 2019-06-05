SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetCarRulesAudit]  
 @carResponseKey uniqueidentifier  
AS  
BEGIN  
 select carRules from TripCarResponse
 where carResponseKey=@carResponseKey  
END
GO
