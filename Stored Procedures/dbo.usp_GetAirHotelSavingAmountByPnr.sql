SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
  
  
CREATE PROCEDURE [dbo].[usp_GetAirHotelSavingAmountByPnr]      
@pnr NVARCHAR(100),      
@lineType NVARCHAR(100)      
AS      
BEGIN      
    
    
 DECLARE @TEMPAIR TABLE            
 (              
  PNR NVARCHAR(100),      
  lineType NVARCHAR(100),      
  AirAmount decimal(18,2),      
  ff2_data NVARCHAR(4000),    
  CreatedDate Datetime      
 )     
     
 DECLARE @TEMPHOTEL TABLE              
 (              
  PNR NVARCHAR(100),       
  HotelAmount decimal(18,2),    
  CreatedDate Datetime,  
  Property_id int      
 )                  
  IF OBJECT_ID('tempdb..#tblAirAudits') IS NOT NULL      
  DROP TABLE #tblAirAudits      
       
   CREATE TABLE #tblAirAudits      
   (      
    PNR NVARCHAR(100),      
    lineType NVARCHAR(100),      
    AirAmount decimal(18,2),      
    ff2_data NVARCHAR(4000),    
    CreatedDate Datetime      
   )          
         
  IF OBJECT_ID('tempdb..#tblHotelAudits') IS NOT NULL      
  DROP TABLE #tblHotelAudits      
        
 CREATE TABLE #tblHotelAudits      
 (      
  PNR NVARCHAR(100),       
  HotelAmount decimal(18,2),    
  CreatedDate Datetime,  
  Property_id int          
 )    
     
  BEGIN              
  INSERT INTO #tblAirAudits              
  SELECT pnr,line_type,amount,ff2_data,ff_work_timestamp  FROM  AI.dbo.ff_work fw WHERE  ff_work_timestamp in (SELECT max(ff_work_timestamp) FROM AI.dbo.ff_work fw GROUP BY pnr,line_type)                     
      
  INSERT INTO @TEMPAIR    
  SELECT * FROM #tblAirAudits      
  WHERE  DATEADD(day, DATEDIFF(day, 0, CreatedDate), 0) in(DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)) or DATEADD(day, DATEDIFF(day, 0, CreatedDate), 0) in(DATEADD(day, DATEDIFF(day, 0, GETDATE()-1), 0))    
      
  DELETE FROM #tblAirAudits    
      
  INSERT INTO #tblAirAudits      
  SELECT * FROM @TEMPAIR    
      
  SELECT * FROM #tblAirAudits WHERE PNR=@pnr and lineType=@lineType     
  END        
  BEGIN              
  INSERT INTO #tblHotelAudits              
 SELECT distinct  tr.pnr,min(fw.rate),max(fw.creation_date),max(fw.Property_Id)  
 FROM  AI.dbo.hotelfinder fw            
 Left outer JOIN ai.dbo.trip tr ON fw.trip_id=tr.trip_id             
 WHERE CONVERT(VARCHAR(10), fw.creation_date, 103) in (SELECT Max(CONVERT(VARCHAR(10), creation_date, 103)) FROM AI.dbo.hotelfinder GROUP BY trip_id)            
 GROUP BY tr.pnr    
     
    
  INSERT INTO @TEMPHOTEL     
  SELECT * FROM #tblHotelAudits    
  WHERE  DATEADD(day, DATEDIFF(day, 0, CreatedDate), 0) in(DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)) or DATEADD(day, DATEDIFF(day, 0, CreatedDate), 0) in(DATEADD(day, DATEDIFF(day, 0, GETDATE()-1), 0))    
      
  DELETE FROM #tblHotelAudits    
      
  INSERT INTO #tblHotelAudits      
  SELECT * FROM @TEMPHOTEL    
      
  SELECT * FROM #tblHotelAudits WHERE pnr=@pnr        
      
 END        
     
END
GO
