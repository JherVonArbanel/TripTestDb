SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Manoj Kumar Naik  
-- Create date: 29-09-2016  
-- Description: Update RoomRate Details of Rate Winner in PreCheckInHotelBooked table.  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_UpdateRateWinnerDetailsInPreCheckInHotelBooked]  
 @hotelresponseKey uniqueIdentifier,  
 @PNR varchar(10)  
AS  
BEGIN  
  
 CREATE TABLE #TmpHotelResponseDetail    
 (    
  [hotelResponseDetailKey] [uniqueidentifier] NULL,    
  [hotelResponseKey] [uniqueidentifier] NULL,    
  [hotelDailyPrice] [float] NULL,    
  [supplierId] [varchar](200)  NULL,      
  [hotelTotalPrice] [float] NULL,      
  [hotelTaxRate] [float] NULL,    
  [touricoNetRate] [float] NULL,    
  [touricoCalculatedBar] [float] NULL,  
  [EANBar] float NULL,  
  [RoomDescription] nvarchar(MAX) NULL,  
  [CancellationPolicy] nvarchar(MAX) NULL,  
  [RatePlanCode] [varchar](200)  NULL,       
  [RoomTypeCode] [varchar](200)  NULL,  
  [PNR] [varchar](200)  NULL  
 )    
   
 INSERT INTO #TmpHotelResponseDetail    
    (  
        hotelResponseDetailKey,  
  hotelResponseKey,  
  hotelDailyPrice,    
  supplierId,     
  hotelTotalPrice,      
  hotelTaxRate,  
  touricoNetRate,    
     touricoCalculatedBar,  
  EANBar,  
  RoomDescription,  
  CancellationPolicy,  
  RatePlanCode,  
  RoomTypeCode,  
  PNR  
    )   
  --  VALUES  
  --  (  
  --      @hotelResponseDetailKey,  
  --@hotelResponseKey,  
  --@hotelDailyPrice,    
  --@supplierId,     
  --@hotelTotalPrice,      
  --@hotelTaxRate,  
  --@touricoNetRate,    
  --@touricoCalculatedBar,  
  --@EANBar,  
  --@RoomDescription,  
  --@CancellationPolicy,  
  --@RatePlanCode  
  --@RoomTypeCode  
      
  --  )  
  
 SELECT   
        hotelResponseDetailKey,  
  hotelResponseKey,  
  TH.hotelDailyPrice,    
  TH.supplierId,     
  hotelTotalPrice,      
  hotelTaxRate,  
  touricoNetRate,    
     TH.touricoCalculationBarRate,  
  CASE TH.supplierId  
    WHEN 'HotelsCom'  
    THEN TH.hotelDailyPrice  
    ELSE   
       0   
  END AS EANBar,  
  RoomDescription,  
  CancellationPolicy,  
  hotelRatePlanCode,  
  hotelRoomTypeCode,  
  @PNR  
  FROM  [Trip].[dbo].[HotelResponseDetail]  TH INNER JOIN (  
   SELECT * FROM (  
      SELECT hotelDailyPrice, SupplierId,  
       ROW_Number() OVER(PARTITION BY SupplierId ORDER BY hotelDailyPrice ASC) AS rowNumber  
      FROM [Trip].[dbo].[HotelResponseDetail]    
      WHERE hotelResponseKey = @hotelresponseKey  
       ) A WHERE A.rowNumber=1  
         
 ) TH2 ON TH.hotelDailyPrice = TH2.hotelDailyPrice AND TH.supplierId = TH2.supplierId AND TH.supplierId <> 'SABRE'  
 AND  hotelResponseKey = @hotelresponseKey  
   
 DECLARE @operatingCost float, @operatingCostPercentage float  
   
   
   
  SELECT @operatingCost = OperatingCost, @operatingCostPercentage = OperatingCostPer  
     FROM Vault.dbo.MARKETPLACEVARIABLES    
     WHERE IsActive = 1    
   

 IF EXISTS (SELECT * FROM #TmpHotelResponseDetail WHERE supplierId ='TOURICO')  
 BEGIN 
PRINT 'IF....'  
	  UPDATE PB   
	  SET   
		PB.[Status] =1,  
		PB.[Source] ='TOURICO',  
		PB.[TouricoNet] = TD.touricoNetRate,  
		PB.[TouricoCalaculationBarRate] = TD.touricoCalculatedBar,  
		PB.[TouricoCostBasisRate] = TD.touricoNetRate + (PB.Rate * @operatingCostPercentage/100) + @operatingCost,  
		PB.[RoomDescription] = TD.RoomDescription,  
		PB.[RatePlanCode]  = TD.RatePlanCode,  
		PB.[RoomTypeCode] = TD.RoomTypeCode,  
		PB.[SourceCancellationPolicy] = TD.CancellationPolicy  
	  FROM Trip.dbo.PreCheckInHotelBooked AS PB  
	  INNER JOIN  #TmpHotelResponseDetail  TD   
		 ON TD.PNR = PB.PNR   
	  WHERE TD.supplierId = 'TOURICO'   
	    
	    
	  UPDATE PB   
	  SET   
		PB.[EANBar] =  TD.hotelDailyPrice  
	  FROM Trip.dbo.PreCheckInHotelBooked AS PB  
	  INNER JOIN  #TmpHotelResponseDetail  TD   
		 ON TD.PNR = PB.PNR   
	  WHERE TD.supplierId = 'HOTELSCOM'   
	    
	  --Update savings---  
	  UPDATE PB   
	  --SET PB.SavingsTourico = CASE  
	  --                      WHEN (CAST(PB.Rate As Float) - CAST(PB.TouricoCalaculationBarRate As float)) >0 THEN CAST(PB.Rate As Float) - CAST(PB.TouricoCalaculationBarRate As float)  
	  --                      ELSE CAST(PB.Rate As Float) - CAST(PB.TouricoCalaculationBarRate As float)   
	  --                      END,  
			 --PB.SavingsEAN  = CASE  
			 --               WHEN (CAST(PB.Rate AS FLOAT) - CAST(PB.EANBar AS Float)) >0 THEN CAST(PB.Rate AS FLOAT) - CAST(PB.EANBar AS Float)  
			 --               ELSE CAST(PB.Rate AS FLOAT) - CAST(PB.EANBar AS Float)      
			 --               END    
	  SET PB.SavingsTourico =  CAST(PB.Rate As Float) - CAST(PB.TouricoCalaculationBarRate As float),
		  PB.SavingsEAN  =   CAST(PB.Rate AS FLOAT) - CAST(PB.EANBar AS Float) 
	  FROM  Trip.dbo.PreCheckInHotelBooked PB                                      
	  INNER JOIN  #TmpHotelResponseDetail  TD   
		 ON TD.PNR = PB.PNR   
	    
	    
	  UPDATE PB   
	  SET PB.Savings = CASE  
							WHEN (PB.SavingsEAN IS NOT NULL) AND (PB.SavingsTourico IS NOT NULL) AND (PB.SavingsTourico > PB.SavingsEAN) THEN PB.SavingsTourico  
							WHEN (PB.SavingsEAN IS NOT NULL) AND (PB.SavingsTourico IS NOT NULL) AND (PB.SavingsEAN > PB.SavingsTourico) THEN PB.SavingsEAN  
							WHEN (PB.SavingsTourico IS NOT NULL) THEN PB.SavingsTourico
							WHEN (PB.SavingsEAN IS NOT NULL) THEN PB.SavingsEAN
							ELSE 0
							END,  
				PB.Source = CASE  
							WHEN (PB.SavingsEAN IS NOT NULL) AND (PB.SavingsTourico IS NOT NULL) AND (PB.SavingsTourico > PB.SavingsEAN) THEN 'TOURICO'  
							WHEN (PB.SavingsEAN IS NOT NULL) AND (PB.SavingsTourico IS NOT NULL) AND (PB.SavingsEAN > PB.SavingsTourico) THEN 'HOTELSCOM' 
							WHEN (PB.SavingsTourico IS NOT NULL) THEN 'TOURICO' 
							WHEN (PB.SavingsEAN IS NOT NULL) THEN 'HOTELSCOM' 
							ELSE ''  
							END                          
	  FROM  Trip.dbo.PreCheckInHotelBooked PB                                      
	  INNER JOIN  #TmpHotelResponseDetail  TD   
		 ON TD.PNR = PB.PNR   
 END  
 ELSE  
 BEGIN  
PRINT 'ELSE.........' 
    UPDATE PB   
  SET   
    PB.[Status] =1,  
    PB.[Source] ='HOTELSCOM',  
    --PB.[RoomDescription] = TD.RoomDescription,  
    PB.[RatePlanCode]  = TD.RatePlanCode,  
    PB.[RoomTypeCode] = TD.RoomTypeCode,  
    --PB.[SourceCancellationPolicy] = TD.CancellationPolicy,  
    PB.[EANBar] = TD.hotelDailyPrice,
    --PB.SavingsEAN  = CASE  
    --                    WHEN (CAST(PB.Rate AS FLOAT) - CAST(PB.EANBar AS Float)) >0 THEN CAST(PB.Rate AS FLOAT) - CAST(PB.EANBar AS Float)  
    --                    ELSE  CAST(PB.Rate AS FLOAT) - CAST(PB.EANBar AS Float)   
    --                    END ,   
    --PB.Savings  = CASE  
    --                    WHEN (CAST(PB.Rate AS FLOAT) - CAST(PB.EANBar AS Float)) >0 THEN CAST(PB.Rate AS FLOAT) - CAST(PB.EANBar AS Float)  
    --                    ELSE  CAST(PB.Rate AS FLOAT) - CAST(PB.EANBar AS Float)    
    --                    END           
    
  PB.SavingsEAN  = CAST(PB.Rate AS FLOAT) - CAST(TD.hotelDailyPrice AS Float),
  PB.Savings  = CAST(PB.Rate AS FLOAT) - CAST(TD.hotelDailyPrice AS Float)
  FROM Trip.dbo.PreCheckInHotelBooked AS PB  
  INNER JOIN  #TmpHotelResponseDetail  TD   
     ON TD.PNR = PB.PNR   
  WHERE TD.supplierId = 'HOTELSCOM'   
 END  
      
  DROp Table #TmpHotelResponseDetail  
END
GO
