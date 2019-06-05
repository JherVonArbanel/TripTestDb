SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetAlterHotelForTrip] 
(    
@PNR NVARCHAR(100)    
)    
AS 
BEGIN
	IF OBJECT_ID('tempdb..#tblHotelAudits') IS NOT NULL          
		drop table #tblHotelAudits          

	CREATE TABLE #tblHotelAudits          
	(          
		PNR NVARCHAR(100),
		Properyty_Id int,           
		HotelAmount decimal(18,2),
		CreatedDate datetime,
		HotelType NVARCHAR(100),
		HotelDescription NVARCHAR(1000),
		HotelFinderId int,
		
	)  
	DECLARE @TEMPHOTEL TABLE          
	(          
		PNR NVARCHAR(100),           
		Properyty_Id int,
		HotelAmount decimal(18,2),
		CreatedDate datetime, 
		HotelType NVARCHAR(100),
		HotelDescription NVARCHAR(1000),
		HotelFinderId int 
	)  
	
	DECLARE @TEMPHOTEL1 TABLE          
	( 
		Properyty_Id int,
		HotelAmount decimal(18,2),		
		HotelFinderId int 
	)  

	BEGIN          
		INSERT INTO #tblHotelAudits          
			SELECT tr.pnr,fw.property_id,fw.rate,fw.creation_date,fw.Type,fw.Description,fw.hotelFinder_id 
			FROM  AI.dbo.hotelfinder fw          
			Left outer JOIN ai.dbo.trip tr ON fw.trip_id=tr.trip_id           
			WHERE fw.creation_date in (SELECT Max(creation_date) FROM AI.dbo.hotelfinder GROUP BY trip_id,property_id)          
			--GROUP BY fw.property_id,  
				
		INSERT INTO @TEMPHOTEL1
		SELECT A.Properyty_Id,A.MinRate, MIN(HF.HotelFinderId) FROM #tblHotelAudits HF
		INNER JOIN
		(
			SELECT Properyty_Id,PNR, min(HotelAmount) MinRate FROM #tblHotelAudits 			
			GROUP BY Properyty_Id,PNR
		)A ON HF.PNR = A.PNR AND HF.Properyty_Id = A.Properyty_Id AND A.MinRate = HF.HotelAmount
		GROUP BY A.Properyty_Id, A.PNR, A.MinRate
				
		
		INSERT INTO @TEMPHOTEL	
		SELECT TF.* FROM #tblHotelAudits TF
		INNER JOIN  @TEMPHOTEL1 TH ON TH.HotelFinderId=TF.HotelFinderId
		WHERE  DATEADD(day, DATEDIFF(day, 0, CreatedDate), 0) in(DATEADD(day, DATEDIFF(day, 0,  GETDATE()), 0)) or DATEADD(day, DATEDIFF(day, 0, CreatedDate), 0) in(DATEADD(day, DATEDIFF(day, 0,  GETDATE()-1), 0))
				
		DELETE FROM #tblHotelAudits
		
		INSERT INTO #tblHotelAudits		
		SELECT * FROM @TEMPHOTEL WHERE PNR=@PNR
			
		
		--SELECT * FROM #tblHotelAudits	
		
	END       
	                         
	BEGIN

		SELECT *--,HA.HotelType 
		FROM [HotelContent].[dbo].[SupplierHotels1] SH
		INNER  JOIN [HotelContent].[dbo].[Hotels] HT ON SH.hotelId=HT.hotelId		
		INNER JOIN #tblHotelAudits HA ON HA.Properyty_Id=Supplierhotelid
		WHERE SH.Supplierfamily='Sabre'	
		--AND SH.Supplierhotelid=2832 	   
	   
	END  
END
GO
