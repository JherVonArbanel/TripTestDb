SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Add_Two_Numbers]
(
	@num1 int,
	@num2 int
)
RETURNS int 
AS
BEGIN
	DECLARE @result int
	SELECT @result = @num1 + @num2
	RETURN @result   
END
GO
