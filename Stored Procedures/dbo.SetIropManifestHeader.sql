SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SetIropManifestHeader]
(
	@SiteKey int
	, @AirlineCode char(2)
	, @FlightNumber char(50)
	, @DepartureDate datetime
	, @ScheduledTime varchar(10)
	, @IROPAirportCode char(3)
	, @IROPAgentName char(100)
	, @IROPReason char(100)
	, @IROPDate datetime
	, @NumberOfPax int
	, @isAllowedHotel bit
	, @UploadByUserKey int
	, @UploadOn datetime
	, @IsAllowVoucher bit
	, @VoucherLimit int
	, @GroupId int
	, @carrier int
	, @EarliestReaccom varchar(10)
	, @PrefArrivalDate datetime
	, @ArriveByTime varchar(100)
	, @SecondGroupId int
	, @ThirdGroupId int
	, @SortOrderBy1 int
	, @SortOrderBy2 int
	, @SortOrderBy3 int
	, @isInstantPurchCarr bit
)
AS
BEGIN
--select * from trip..tblIROP
--select * from trip..tblIROP_Manifest
INSERT INTO Trip..tblIROP(SiteKey, AirlineCode, FlightNumber, DepartureDate, ScheduledTime, IROPAirportCode, IROPAgentName, IROPReason, IROPDate, NumberOfPax, isAllowedHotel, UploadByUserKey, UploadOn, IsAllowVoucher, VoucherLimit, GroupId, carrier, Earliest_Reaccom, PrefArrivalDate, Arrivebytime, SecondGroupId, ThirdGroupId, SortOrderBy1, SortOrderBy2, SortOrderBy3,IncludeInstantPurchCarr)
VALUES(@SiteKey 
	, @AirlineCode 
	, @FlightNumber
	, @DepartureDate 
	, @ScheduledTime 
	, @IROPAirportCode 
	, @IROPAgentName 
	, @IROPReason 
	, @IROPDate 
	, @NumberOfPax 
	, @isAllowedHotel 
	, @UploadByUserKey
	, @UploadOn 
	, @IsAllowVoucher 
	, @VoucherLimit 
	, @GroupId 
	, @carrier
	, @EarliestReaccom
	, @PrefArrivalDate
	, @ArriveByTime
	, @SecondGroupId
	, @ThirdGroupId
	, @SortOrderBy1
	, @SortOrderBy2
	, @SortOrderBy3
	,@isInstantPurchCarr)
select scope_identity() AS HeaderId
END
GO
