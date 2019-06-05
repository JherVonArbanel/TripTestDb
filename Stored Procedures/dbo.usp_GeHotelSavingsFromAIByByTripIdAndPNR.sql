SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_GeHotelSavingsFromAIByByTripIdAndPNR] 
@tripkey int,   
@pnr NVARCHAR(100)    
    
AS    

BEGIN

IF OBJECT_ID('tempdb..#tblTripHotel') IS NOT NULL          
	drop table #tblTripHotel          

	CREATE TABLE #tblTripHotel          
	(
	TripHotelId NVARCHAR(100)   
	) 

INSERT INTO #tblTripHotel 
SELECT ths.supplierHotelKey FROM TRIP trip 
INNER JOIN TRIPHOTELRESPONSE ths ON tripGUIDKey=(case when trip.trippurchasedkey is not null then trip.trippurchasedkey else trip.tripsavedkey end )  
where trip.TRIPKEY=@tripkey


IF OBJECT_ID('tempdb..#tblHotelAudits') IS NOT NULL          
	drop table #tblHotelAudits          

	CREATE TABLE #tblHotelAudits          
	(          
		PNR NVARCHAR(100),           
		HotelAmount decimal(18,2),
		CreatedDate datetime,
		Property_Id NVARCHAR(100)   
	) 
	
DECLARE @TEMPHOTEL TABLE          
(          
	PNR NVARCHAR(100),           
	HotelAmount decimal(18,2),	
	CreatedDate datetime,
	Property_Id NVARCHAR(100)  
)       	                 

INSERT INTO #tblHotelAudits   
SELECT distinct  tr.pnr,fw.rate,fw.creation_date,fw.Property_Id
FROM  AI.dbo.hotelfinder fw          
Left outer JOIN ai.dbo.trip tr ON fw.trip_id=tr.trip_id           
WHERE fw.creation_date in (SELECT Max(creation_date) FROM AI.dbo.hotelfinder  GROUP BY trip_id,property_id)
and tr.pnr=@pnr          
--GROUP BY tr.pnr			

--SELECT * FROM #tblHotelAudits 

INSERT INTO @TEMPHOTEL	
SELECT PNR,max(HOTELAMOUNT),max(CREATEDDATE),PROPERTY_ID FROM #tblHotelAudits GROUP BY PNR,Property_Id 

DELETE FROM #tblHotelAudits

INSERT INTO #tblHotelAudits
SELECT * FROM @TEMPHOTEL
WHERE  DATEADD(day, DATEDIFF(day, 0, CreatedDate), 0) in(DATEADD(day, DATEDIFF(day, 0,  GETDATE()), 0)) or DATEADD(day, DATEDIFF(day, 0, CreatedDate), 0) in(DATEADD(day, DATEDIFF(day, 0,  GETDATE()-1), 0))

SELECT * FROM #tblHotelAudits THA
LEFT OUTER JOIN #tblTripHotel TTH ON THA.Property_Id=TTH.TripHotelId


END
GO
