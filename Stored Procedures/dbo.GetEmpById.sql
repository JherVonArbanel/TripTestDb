SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[GetEmpById]  
(
	@Id int 
)
as  
begin  
   select *from Employee_Info where Id = @Id  
End
GO
