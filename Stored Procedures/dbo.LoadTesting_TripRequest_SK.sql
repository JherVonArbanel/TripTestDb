SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--select getdate()

create PROCEDURE [dbo].[LoadTesting_TripRequest_SK]
(
	@userKey INT =0,
	@tripRequestCreated DATETIME
)
AS
BEGIN
		SELECT
			 tripRequestKey
			,userKey
			,tripTypeKey
			,tripRequestCreated
			,tripAdultsCount
			,tripSeniorsCount
			,tripChildrenCount
			,tripInfantCount
			,tripYouthCount
			,tripTotalTravlersCount
			,tripComponentType
			,tripFrom1
			,tripTo1
			,tripFromDate1
			,tripToDate1
			,tripToHotelGroupId
			,cityId
			,SITEKEY
			,ParentId
			,ArrivalIsParent
			,DepartureIsParent
			,ArrivalRegionId
			,DepartureRegionId
			,tripInfantWithSeatCount
		FROM TripRequest WITH(NOLOCK)
		where userKey=@userKey and tripRequestCreated>=@tripRequestCreated
		order by 1 desc
END

GO
