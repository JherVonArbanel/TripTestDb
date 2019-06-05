SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  Procedure  [dbo].[USP_InsertRequestCompletionStatus]   
(  
@requestKey int ,  
@GDScallIndex int,  
@componentType int,  
@IsSuccessfullBFM bit = 1,
@searchType int =1 
)  
AS  
BEGIN   
  
  
INSERT RequestCompletionStatus( requestKey,GDScallIndex,componentType ,isSuccessfullBFM,searchType )   
VALUES (@requestKey,@GDScallIndex,@componentType ,@isSuccessfullBFM,@searchType)  
END  
  

GO
