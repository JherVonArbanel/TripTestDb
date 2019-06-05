SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_GetCarMatrixDetails]  
(  
 @CarRequestKey NVARCHAR(1000)  
)  
AS  
 Select Top 10 * from vw_CarResponseDetail where   
 CarRequestKey = @CarRequestKey order by minRate
GO
