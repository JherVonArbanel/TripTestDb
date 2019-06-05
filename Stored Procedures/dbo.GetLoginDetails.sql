SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetLoginDetails]
(
 @Username varchar(50),
 @Password varchar(50)
)
as
begin
select * from Login_Tbl where Username=@Username and Password=@Password
end
GO
