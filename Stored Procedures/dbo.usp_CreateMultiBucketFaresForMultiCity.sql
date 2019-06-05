SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Vaibhav Mehta>
-- Create date: <04-01-2019>
-- Description:	<Multi bucket - addtional fare logic>
-- =============================================
CREATE   Procedure [dbo].[usp_CreateMultiBucketFaresForMultiCity](@airBundledRequest int, @airPublishedFareRequest int,@MaxFareTotal float, @IsHideFare bit,@HighFareTotal float,@IsHighFareTotal bit,@LowFareThreshold float,@IsLowFareThreshold bit,@LowestPrice float,@isTotalPriceSort bit,@isOutOfPolicyResultsPresent bit output)
as
begin
	insert into #AdditionalFares
	select arm.airResponseKey as airresponsekey,
	arm.airResponseMultiBrandKey as airresponseMultiBrandkey,
	narmb.airlegbrandname as airLegBrandName,
	cast((arm.airPriceBase+arm.airPriceTax) as decimal(12,2)) as TotalAllPaxPriceToDisplay,
	cast((arm.airPriceBase+arm.airPriceTax) as decimal(12,2)) as TotalPriceToDisplay,
	arm.airResponseKey as  childresponsekey,
	arm.refundable as isRefundable,
	'NONE' as ReasonCode,
      STUFF((
    SELECT ',' + airLegBookingClasses 
	from NormalizedAirResponsesMultiBrand arm1 
    WHERE (arm1.airResponseMultiBrandKey = arm.airResponseMultiBrandKey) 
    FOR XML PATH('')), 1, 1, '')     as airResBookDesigCode,
	0 as IsSuppressed,
	0 as airRequestKey
	from AirResponseMultiBrand arm 
	inner join NormalizedAirResponsesMultiBrand narmb on arm.airResponseMultiBrandKey=narmb.airresponseMultiBrandkey
	 WHERE arm.airSubRequestKey  = @airBundledRequest   OR arm.airSubRequestKey =@airPublishedFareRequest
	group by  arm.airresponsekey,arm.airresponseMultiBrandkey,narmb.airLegBrandName,arm.airPriceBase,arm.airPriceTax,arm.refundable

	--select * from #AdditionalFares where airResponseKey='B771F8C8-E7CA-41E2-AE01-9124CB904C07'
-- TODO: hide oops policy check
	IF ((@MaxFareTotal != 0) and (@IsHideFare = 1))
	BEGIN
		IF EXISTS(SELECT 1 FROM #AdditionalFares WHERE airresponsekey IN (SELECT A.airResponseKey from #AdditionalFares A WHERE a.TotalPriceToDisplay> @MaxFareTotal))
		BEGIN
		SET @isOutOfPolicyResultsPresent = 1
		END

		DELETE FROM #AdditionalFares 
		WHERE airresponsekey IN (SELECT A.airResponseKey 
								 from #AdditionalFares A 
								  WHERE ROUND(A.TotalPriceToDisplay,2) > ROUND(@MaxFareTotal,2))
	END


	 IF (@HighFareTotal != 0 AND @IsHighFareTotal = 1)
		BEGIN
		IF (@MaxFareTotal !=0)
		BEGIN
			UPDATE #AdditionalFares 
			SET ReasonCode = 'High' 
			WHERE airResponsekey IN (SELECT A.airResponseKey 
										FROM #AdditionalFares A 
										WHERE ROUND(A.TotalPriceToDisplay,2) > ROUND(@HighFareTotal,2)
										AND ROUND(A.TotalPriceToDisplay,2) <=  ROUND(@MaxFareTotal,2))
		END
		ELSE
		BEGIN
			UPDATE #AdditionalFares 
			SET ReasonCode = 'High' 
			WHERE airResponsekey IN (SELECT A.airResponseKey 
										FROM #AdditionalFares A 
										WHERE ROUND(A.TotalPriceToDisplay,2) > ROUND(@HighFareTotal,2))
		END
	END

	
	IF (( @IsLowFareThreshold =1) AND (@LowFareThreshold > 0))
	BEGIN
		SELECT @LowestPrice = (CASE WHEN @isTotalPriceSort = 0 THEN (MIN (TotalPriceToDisplay)) ELSE  min(TotalPriceToDisplay) end ) FROM #AdditionalFares

		if (@HighFareTotal != 0) 
		BEGIN
			UPDATE #AdditionalFares 
			SET ReasonCode = 'OOP' 
			WHERE airResponsekey IN (SELECT A.airResponseKey 
										FROM #AdditionalFares A 
										WHERE ROUND(A.TotalPriceToDisplay,2) > ROUND((@LowestPrice + @LowFareThreshold),2)
										AND ROUND(A.TotalPriceToDisplay,2) <= ROUND(@HighFareTotal,2))
		END
		ELSE
		BEGIN
			UPDATE #AdditionalFares 
			SET ReasonCode = 'OOP' 
			WHERE airResponsekey IN (SELECT A.airResponseKey 
										FROM #AdditionalFares A 
										WHERE ROUND(A.TotalPriceToDisplay,2) > ROUND((@LowestPrice + @LowFareThreshold),2))
		END
	END
--end hide policy check

	update #SortedResultSet 
	SET multiBrandFaresInfo = (
	SELECT airresponseMultiBrandkey,airLegBrandName,TotalPriceToDisplay,childresponsekey,isRefundable,ReasonCode,airResBookDesigCode, IsSuppressed,airRequestKey
	FROM #AdditionalFares A
	where (A.airresponsekey = #SortedResultSet.airresponsekey and (#SortedResultSet.airLegBrandName != A.airLegBrandName or #SortedResultSet.isRefundable!=A.isRefundable))
	or (((select responseKeysWithBrandName from #ResultToMergeResponseKey where  responseKeysWithBrandName like '%'+cast(#SortedResultSet.airResponseKey as nvarchar(200))+'%' ) like '%'+A.airresponsekey+'%') 
	and (#SortedResultSet.airLegBrandName != A.airLegBrandName or #SortedResultSet.isRefundable!=A.isRefundable)) 
	FOR XML PATH('AdditionalFare'), ROOT('AdditionalFaresInfo')
	)

	--	update #SortedResultSet 
	--SET multiBrandFaresInfo = (
	--SELECT airresponseMultiBrandkey,airLegBrandName,TotalPriceToDisplay,childresponsekey,isRefundable,ReasonCode,airResBookDesigCode, IsSuppressed,airRequestKey
	--FROM #AdditionalFares A
	--where (A.airresponsekey = #SortedResultSet.airresponsekey )
	--or (((select responseKeysWithBrandName from #ResultToMergeResponseKey where  responseKeysWithBrandName like '%'+cast(#SortedResultSet.airResponseKey as nvarchar(200))+'%' ) like '%'+A.airresponsekey+'%') )
	----and (#SortedResultSet.airLegBrandName != A.airLegBrandName or #SortedResultSet.isRefundable!=A.isRefundable)) 
	--FOR XML PATH('AdditionalFare'), ROOT('AdditionalFaresInfo')
	--)

end
GO
