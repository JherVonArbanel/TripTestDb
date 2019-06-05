SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[udf_ProperCase]
(
@InputParam VARCHAR(4000) 
)
 RETURNS VARCHAR(4000)
 AS
 BEGIN
  DECLARE @Counter INT
  DECLARE @Char CHAR(1)
  DECLARE @Result VARCHAR(255)
  SET @Result = LOWER(@InputParam)
  SET @Counter = 2
  SET @Result =
  STUFF(@Result, 1, 1,UPPER(SUBSTRING(@InputParam,1,1)))
  WHILE @Counter <= LEN(@InputParam)
  BEGIN
   SET @Char = SUBSTRING(@InputParam, @Counter, 1)
   IF @Char IN (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&','''','(')
   IF @Counter + 1 <= LEN(@InputParam)
   BEGIN
    IF @Char != ''''
    OR
    UPPER(SUBSTRING(@InputParam, @Counter + 1, 1)) != 'S'
    SET @Result =
    STUFF(@Result, @Counter + 1, 1,UPPER(SUBSTRING(@InputParam, @Counter + 1, 1)))
   END
   SET @Counter = @Counter + 1
 END
 RETURN ISNULL(@Result,'')
 END
GO
