SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[GetAllEmployees]  
as  
begin  
   select *from Employee  
End
GO
