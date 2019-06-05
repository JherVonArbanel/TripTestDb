SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[AddProcedure]
(
	@FirstNum int,
	@SecondNum int
)
AS
begin
declare @val int
select dbo.[Add_Two_Numbers](@FirstNum,@SecondNum)

end
GO
