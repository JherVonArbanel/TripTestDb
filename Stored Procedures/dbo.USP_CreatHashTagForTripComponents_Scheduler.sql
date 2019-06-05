SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Pradeep Gupta>
-- Create date: <25-jan-2016>
-- Description:	<used to craete hash tags for #air,#hotel,#car for already created trip's >
-- =============================================

CREATE PROCEDURE [dbo].[USP_CreatHashTagForTripComponents_Scheduler]

AS
BEGIN

with tmpEventHashTagMapping (TripKey,Components, ComponentsKey) as
(
	select distinct T.tripKey, 
		CASE                       
		WHEN T.tripComponentType = 1 THEN 'Air'                      
		WHEN T.tripComponentType = 2 THEN 'Car'                      
		WHEN T.tripComponentType = 3 THEN 'Air,Car,Package'                      
		WHEN T.tripComponentType = 4 THEN 'Hotel'                      
		WHEN T.tripComponentType = 5 THEN 'Air,Hotel,Package'                      
		WHEN T.tripComponentType = 6 THEN 'Car,Hotel,Package'                      
		WHEN T.tripComponentType = 7 THEN 'Air,Car,Hotel,Package'                      
		END AS tripComponents 
	,T.tripComponentType 
		from (
			select distinct TripKey from trip..TripHashTagMapping 
		) TP 
	inner join Trip..Trip T on T.TripKey = TP.tripKey
	inner join trip..TripHashTagMapping TH on T.tripKey = TH.TripKey
	--order by t.tripKey asc
	
)


--select * from tmpEventHashTagMapping
------------------------ split using comma

INSERT INTO [Trip].[dbo].[TripHashTagMapping]([TripKey],[HashTag],[EventKey])
--(
	SELECT distinct TripKey,
	'#'+ LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS HashTag , 0
	FROM
	(
		SELECT TripKey,CAST('<XMLRoot><RowData>' + REPLACE(Components,',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
		FROM   tmpEventHashTagMapping 
		--where ComponentsKey in (3,5,6,7)
	)t
	CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)
	order by TripKey,HashTag
--)


END
GO
