SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[WordFormatting] ( @InputString varchar(4000) ) 
RETURNS VARCHAR(4000)
AS
BEGIN

DECLARE @Index          INT
DECLARE @Char           CHAR(1)
DECLARE @PrevChar       CHAR(1)
DECLARE @OutputString   VARCHAR(4000)
set @InputString = Lower(@InputString)
SET @OutputString = @InputString
if( CharIndex(' ', @InputString,1) > 0)
Begin
		SET @Index = 1
		WHILE @Index <= LEN(@InputString)
		BEGIN
			SET @Char     = SUBSTRING(@InputString, @Index, 1)
			if(@PrevChar = ' ' or @Index = 1) 
			Begin
				SET @InputString = STUFF(@InputString, @Index, 1, UPPER(@Char))
			End
			SET @Index = @Index + 1
			SET @PrevChar = CASE WHEN  @Char = ' ' or @Index = 1 THEN ' '
								 ELSE '!'
							END
		END

		set @OutputString =  @InputString
END
ELSE
BEGIN
	SET @OutputString = STUFF(@InputString, 1, 1, UPPER(SUBSTRING(@InputString,1,1)))
END

Return @OutputString
END
GO
