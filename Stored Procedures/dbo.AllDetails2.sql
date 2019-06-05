SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[AllDetails2]
(  
  
   @EmpCode varchar(50) 
   
)  
as   
begin  
   select EMP1.Id,EMP1.EmpCode,EMP1.EmpName,EMP1.Gender,EMP1.Mobile,EMP1.Email,EMP2.EmpSal,EMP2.DateOfJoining,EMP2.DoB
   from Employee_Info EMP1 
   inner join Emp_Tbl EMP2 on EMP1.EmpCode = EMP2.EmpCode
   where EMP1.EmpCode=@EmpCode 
End
GO
