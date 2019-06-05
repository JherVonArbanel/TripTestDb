SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [dbo].[USP_GetProgramDetails] 
(  
  @AirLineCode varchar(3)=null
 )  
AS  
BEGIN  
 SELECT
 ID,     
  AirLineCode,
ProgramCode,
HaulType,
BrandCode,
IsActive 
 FROM ProgramDetails WHERE IsActive =1  
 END
GO
