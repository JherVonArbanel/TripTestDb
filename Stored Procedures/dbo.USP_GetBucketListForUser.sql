SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec USP_GetBucketListForUser 560799
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetBucketListForUser]  
	(@userKey INT = 0 )
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @tbl TABLE (TripTo VARCHAR(50), CityName VARCHAR(150), Hashtag varchar(150),  TotalSavings FLOAT DEFAULT(0), UserSelected bit DEFAULT 0, PrefVacationId INT DEFAULT 0, IsCustom bit default 0 )
	
	-- get all destination having totalsavings 
	insert into @tbl(TripTo, TotalSavings)
	SELECT TD.tripTo,
			SUM
		(
			CASE WHEN ISNULL(latestDealAirSavingsPerPerson,0) < 0 THEN 0 ELSE ISNULL(latestDealAirSavingsPerPerson,0) END
			+ CASE WHEN ISNULL(latestDealCarSavingsPerPerson,0) < 0 THEN 0 ELSE ISNULL(latestDealCarSavingsPerPerson,0) END
			+ CASE WHEN ISNULL(latestDealHotelSavingsPerPerson,0) < 0 THEN 0 ELSE ISNULL(latestDealHotelSavingsPerPerson,0) END
		) 
	FROM TRIP..TripDetails TD WITH (NOLOCK)
	INNER JOIN Trip..Trip T WITH (NOLOCK) ON T.tripKey = TD.tripKey 
	WHERE 
	T.tripStatusKey <> 17   
	AND TD.tripTo IS NOT NULL
	AND TD.tripStartDate > DATEADD(D,2, GetDate())
	AND T.PrivacyType <>2          
	AND T.IsWatching = 1 AND T.isUserCreatedSavedTrip =1 
	And 0 = (Select
				CASE             
					WHEN T1.tripComponentType = 1 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 )THEN 1 -- 'Air'            
					WHEN T1.tripComponentType = 2 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 ) THEN 1 -- 'Car'            
					WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR  ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0) THEN 1 --  'Air,Car'            
					WHEN T1.tripComponentType = 4 AND (ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0 )THEN 1 -- 'Hotel'            
					WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Hotel'        
				        
					WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Car,Hotel'         
				    
					WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Car,Hotel'                
					ELSE 0     End
				FROM Trip t1 inner join TripDetails td on t1.tripKey = td.tripKey  Where t1.tripKey = T.tripKey)
	GROUP BY TD.tripTo ORDER BY  2 DESC
    
    UPDATE t SET CityName = AL.CityName, Hashtag =  LOWER(REPLACE(AL.CityName ,' ',''))
	FROM @tbl t 
		INNER JOIN trip..AirportLookup AL WITH (NOLOCK) ON t.TripTo = AL.AirportCode 
    
	
	
	update T SET T.PrefVacationId = vm.PrefVacationId ,
		T.UserSelected = (CASE 
			WHEN vMap.PrefVacationId IS NOT NULL 
			THEN 1 
			ELSE 0 
		END )
	FROM    
 		Loyalty..PreferredVacationMaster AS vm LEFT OUTER JOIN
		Loyalty..PreferredVacationMapping AS vMap ON vm.PrefVacationId = vMap.PrefVacationId 
		INNER JOIN @tbl T ON T.Hashtag = LOWER(Replace(vm.Description,'#',''))
		AND vMap.UserId = @userKey
		
	update T SET 
		T.PrefVacationId = PFC.ID, 
		T.UserSelected =  PFC.IsSelected,
		T.IsCustom = '1' 
	FROM Loyalty..PreferedVacationCustom PFC 
	INNER JOIN @tbl T ON T.Hashtag = LOWER(Replace(PFC.Description,'#',''))
	WHERE PFC.UserId = @userKey
	
	SELECT *  FROM @tbl
END
GO
