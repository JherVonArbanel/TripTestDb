SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create FUNCTION [dbo].[getImageURLFromUserKey]
(
	@UserKey int
)
RETURNS varchar(200)
AS
BEGIN	
	declare @imagepath varchar(100)
	
	
	
	-- Return the result of the function
	select @imagepath = ImageURL from Loyalty..UserMap where UserId=@UserKey
	
	--if(ISNULL(@imagepath, '') = '')
	--	set @imagepath = '/this/is/default'
			
	return @imagepath
END
GO
