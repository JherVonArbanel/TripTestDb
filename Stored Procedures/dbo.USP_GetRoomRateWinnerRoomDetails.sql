SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 29-09-2016
-- Description:	Get RoomRate Winner room details
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetRoomRateWinnerRoomDetails]
	@hotelresponseKey uniqueIdentifier,
	@PNR varchar(10)
AS
BEGIN

	CREATE TABLE #TmpHotelResponseDetail  
	(  
		[hotelResponseDetailKey] [uniqueidentifier] NULL,  
		[hotelResponseKey] [uniqueidentifier] NULL,  
		[hotelDailyPrice] [float] NULL,  
		[supplierId] [varchar](20)  NULL,    
		[hotelTotalPrice] [float] NULL,    
		[hotelTaxRate] [float] NULL,  
		[touricoNetRate] [float] NULL,  
		[touricoCalculatedBar] [float] NULL,
		[EANBar] float NULL,
		[RoomDescription] nvarchar(200) NULL,
		[CancellationPolicy] nvarchar(200) NULL,
		[RatePlanCode]	[varchar](20)  NULL,    	
		[RoomTypeCode]	[varchar](20)  NULL,
		[PNR] [varchar](20)  NULL
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
	
	IF EXISTS (SELECT * FROM #TmpHotelResponseDetail WHERE supplierId ='TOURICO')
	BEGIN
		UPDATE PB 
		SET 
		  PB.[Status] =1,
		  PB.[Source] ='TOURICO',
		  PB.[TouricoNet] = TD.touricoNetRate,
		  PB.[TouricoCalculationBarRate] = TD.touricoCalculatedBar,
		  PB.[TouricoCostBasis] = '',
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
	END
	ELSE
	BEGIN
	   UPDATE PB 
		SET 
		  PB.[Status] =1,
		  PB.[Source] ='HOTELSCOM',
		  PB.[RoomDescription] = TD.RoomDescription,
		  PB.[RatePlanCode]  = TD.RatePlanCode,
		  PB.[RoomTypeCode] = TD.RoomTypeCode,
		  PB.[SourceCancellationPolicy] = TD.CancellationPolicy,
		  PB.[EANBar] = TD.hotelDailyPrice
		FROM Trip.dbo.PreCheckInHotelBooked AS PB
		INNER JOIN  #TmpHotelResponseDetail  TD 
		   ON TD.PNR = PB.PNR 
		WHERE TD.supplierId = 'HOTELSCOM' 
	END
    

END
GO
