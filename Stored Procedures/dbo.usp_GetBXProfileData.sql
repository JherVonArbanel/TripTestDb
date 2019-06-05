SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[usp_GetBXProfileData](@travelRequestKey int=0,@airRequestKey int=0,@userKey int=0,@awardCode nvarchar(100)='')
as 
begin

select ProfileRemarks from BXProfileDetails where (@travelRequestKey=0 or TravelRequestKey = @travelRequestKey)
and (@airRequestKey=0 or AirRequestKey = @airRequestKey) and (@userKey=0 or UserKey = @userKey) and (@awardCode='' or awardcode=@awardCode)
end

GO
