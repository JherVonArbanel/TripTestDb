SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[GetAllEmpInfo]  
as  
begin  
   select *from Employee_Info  
End
GO
