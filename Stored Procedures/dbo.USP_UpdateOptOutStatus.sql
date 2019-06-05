SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[USP_UpdateOptOutStatus]
@IsCar bit,
@IsHotel bit,
@IsAir bit,
@tripKey int 
as

if(@IsAir = 1)
begin 
update TripAirResponse set [status] = 11 where tripKey = @tripKey
end

if(@IsCar = 1)
begin 
update TripAirResponse set [status] = 11 where tripKey = @tripKey
end


if(@IsHotel = 1)
begin 
update TripAirResponse set [status] = 11 where tripKey = @tripKey
end


if(@IsAir = 1 and @IsCar = 1 and @IsHotel = 1)
begin
Update trip set tripStatusKey = 11 where tripKey = @tripKey
end
GO
