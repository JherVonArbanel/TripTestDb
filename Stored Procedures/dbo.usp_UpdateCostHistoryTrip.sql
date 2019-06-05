SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[usp_UpdateCostHistoryTrip]
@PNR varchar(50),
@TripHistoryKey uniqueidentifier
AS 
Begin


Update Trip_History
set 

tripTotalBaseCost  = T.tripTotalBaseCost, 
tripTotalTaxCost  = T.tripTotalTaxCost, 
tripAdultsCount = T.tripAdultsCount, 
tripSeniorsCount =  T.tripSeniorsCount, 
tripChildCount = T.tripChildCount , 
tripInfantCount = T.tripInfantCount,
tripYouthCount = T.tripInfantCount
From Trip_History TH inner join Trip T  on TH.recordLocator = T.recordLocator 
Where TH.TripHistoryKey = @TripHistoryKey and T.recordLocator = @PNR




End
GO
