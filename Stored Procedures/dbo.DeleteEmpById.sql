SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[DeleteEmpById]  
(  
   @Id int  
)  
as   
begin  
   Delete from Employee_Info where Id=@Id  
End
GO
