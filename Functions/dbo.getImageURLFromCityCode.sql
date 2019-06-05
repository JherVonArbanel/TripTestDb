SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create FUNCTION [dbo].[getImageURLFromCityCode]
(
	@CityCode varchar(5)
)
RETURNS varchar(200)
AS
BEGIN	
	declare @imagepath varchar(100)
	
	-- Return the result of the function
	select @imagepath = (select top 1 ImageURL FROM [CMS].[dbo].[DestinationImages] 
						where DestinationId = (select top 1 DestinationId from CMS..Destination where AptCode= @CityCode))
			
	--if(ISNULL(@imagepath, '') = '')
	--	set @imagepath = '/this/is/default'
		
	return @imagepath
END
GO
