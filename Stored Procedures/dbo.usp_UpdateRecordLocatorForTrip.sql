SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[usp_UpdateRecordLocatorForTrip](@tripKey int, @recordLocator nvarchar(100))
as 
begin
	if exists(select tripkey from trip..trip where tripKey=@tripKey)
	begin
		Update Trip set recordLocator=@recordLocator Where tripKey = @tripKey
	end
end
GO
