SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[CruiseCabinResponses_GET]        
(     
  @CruiseCabinResponseKey UNIQUEIDENTIFIER= NULL       
 )        
AS        
BEGIN        
    
 SELECT TOP 1000 [CruiseCabinResponseKey]
      ,[CruiseCategoryResponseKey]
      ,[cabinNbr]
      ,[remark]
      ,[positionInShip]
      ,[maxOccupancy]
      ,[deckId]
      ,[bedType]
      ,[bedConfiguration]
      ,[cabinStatus]
  FROM [Trip].[dbo].[CruiseCabinResponse]
      WHERE CruiseCabinResponseKey =  @CruiseCabinResponseKey  and cabinStatus='AVL'  
      
 END 
 
 --Select * from sys.objects where name like '%cabin%'
GO
