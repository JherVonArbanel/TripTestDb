SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CruiseFareResponses_GET]    
( 
  @CruiseFareResponseKey UNIQUEIDENTIFIER= NULL   
 )    
AS    
BEGIN    

	SELECT [CruiseFareResponseKey]
           ,[CruiseResponseKey]
           ,[FareCode]
           ,[FareDesc]
           ,[Remark]
           ,[StatusCode]
		   ,[ModeOfTransportation]
	       ,[MOTCity] 
           ,[DiningLabel]
	       ,[DiningStatus]
	       ,[CurrencyQualifier]
	       ,[CurrencyISOCode]
      FROM CruiseFareResponse
      WHERE CruiseFareResponseKey =  @CruiseFareResponseKey
      AND StatusCode = 'AVL'
	 
 END
GO
