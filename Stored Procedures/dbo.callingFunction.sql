SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[callingFunction]
(
	@FirstNumber int,
	@SecondNumber int
)
AS
begin
declare @setval int
select  dbo.[Add_Two_Num](@FirstNumber, @SecondNumber) as int
end
GO
