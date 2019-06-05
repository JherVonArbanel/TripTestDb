SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetHotelAirportLookup]     
AS    
BEGIN    
    
    DECLARE @currentDate INT = DAY(Getdate())
    DECLARE @priority  INT
    
    IF(@currentDate<8)
    BEGIN
    set @priority = 1
    END
    ELSE
    BEGIN
    set @priority = 2
    END
    
    SELECT * FROM [dbo].[HotelCacheAirportLookup] WHERE CityPriority=@priority
	AND [DAY] = @currentDate --DAY(Getdate())
    
    --SELECT * FROM [dbo].[HotelCacheAirportLookup] WHERE CityPriority=2      
	--and [DAY] in (12,13,14,15,16)      
	--AND [DAY] = DAY(Getdate())
END
GO
