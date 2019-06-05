SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[GetEmployeeById]  
(  
   @Id int  
)  
as   
begin  
   Select * from Employee_Info where Id=@Id  
End
GO
