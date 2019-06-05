SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetIropManifestHeader]
(
	@ManifestHeaderId INT = 0
	,@SiteKey INT
)
AS
BEGIN
--select * from trip..tblIROP
--select * from trip..tblIROP_Manifest
IF(ISNULL(@ManifestHeaderId,0) = 0)
BEGIN
	SELECT	
		header.pkId AS ManifestId
	,	header.SiteKey
	,	header.AirlineCode
	,	header.FlightNumber
	,	header.DepartureDate
	,	header.ScheduledTime
	,	header.IROPAirportCode
	,	header.IROPAgentName
	,	header.IROPReason
	,	header.IROPDate
	,	header.NumberOfPax
	,	header.isAllowedHotel
	,	header.UploadByUserKey
	,	header.UploadOn
	,	header.IsAllowVoucher
	,	header.VoucherLimit
	,	header.Carrier
	,	header.GroupId
	,	grp.groupName
	,	(SELECT (SELECT DISTINCT
		STUFF(
		(SELECT DISTINCT(',' + t2.departurecity +'-'+ t2.arrivalcity)
		FROM tblIROP_Manifest t2
		where t2.fk_IROPId=header.pkId
		FOR XML PATH (''))
		, 1, 1, '') 
		FROM tblIROP_Manifest t1 
		INNER JOIN tblIROP irop 
		ON t1.fk_IROPId = irop.pkId
		where t1.fk_IROPId=header.pkId
		)) AS Routing
	FROM tblIROP header Left Outer Join vault.dbo.[Group] grp 
	ON header.GroupId = grp.groupKey
	WHERE SiteKey = @SiteKey
END
ELSE
BEGIN
	SELECT	
		header.pkId AS ManifestId
	,	header.SiteKey
	,	header.AirlineCode
	,	header.FlightNumber
	,	header.DepartureDate
	,	header.ScheduledTime
	,	header.IROPAirportCode
	,	header.IROPAgentName
	,	header.IROPReason
	,	header.IROPDate
	,	header.NumberOfPax
	,	header.isAllowedHotel
	,	header.UploadByUserKey
	,	header.UploadOn
	,	header.IsAllowVoucher
	,	header.VoucherLimit
	,	header.Carrier
	,	header.GroupId
	,	grp.groupName
	,	(SELECT (SELECT DISTINCT
		STUFF(
		(SELECT DISTINCT(',' + t2.departurecity +'-'+ t2.arrivalcity)
		FROM tblIROP_Manifest t2
		where t2.fk_IROPId=header.pkId
		FOR XML PATH (''))
		, 1, 1, '') 
		FROM tblIROP_Manifest t1 
		INNER JOIN tblIROP irop 
		ON t1.fk_IROPId = irop.pkId
		where t1.fk_IROPId=header.pkId
		)) AS Routing
	FROM tblIROP header Left Outer Join vault.dbo.[Group] grp 
	ON header.GroupId = grp.groupKey
	Where header.pkId = @ManifestHeaderId
		AND SiteKey = @SiteKey
END
END
GO
