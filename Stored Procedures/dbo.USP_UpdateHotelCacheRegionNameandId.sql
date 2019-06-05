SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateHotelCacheRegionNameandId]
	@destination varchar(3)
AS
BEGIN
	
	update HR
	set HR.RegionId = RM.RegionId , HR.RegionName = PR.RegionName
	from Trip..HotelCacheRegionMapping HR 
	inner join HotelContent..RegionHotelIDMapping RM on HR.HotelId = RM.HotelId 
	left outer join HotelContent..ParentRegionList PR on PR.RegionID = RM.RegionId and PR.RegionType = 'Neighborhood'
	where HR.CityCode = @destination
END
GO
