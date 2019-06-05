SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec USP_GetAirResponsesAlternateDate 361504

	CREATE PROCEDURE [dbo].[USP_GetAirResponsesAlternateDate] 
	(	
	@airSubRequestKey int,
	@selectedDepartureDate DateTime,
	@airRequestTypeKey int=1
	)
	AS
	BEGIN
	-- Declaring Variables
	DECLARE @DepartureDate AS DATETIME,@ReturnDate AS DATETIME, @airsubrequestLegIndex AS INT
	DECLARE @ReturnDateMinus3 AS DATETIME,@ReturnDateMinus2 AS DATETIME,@ReturnDateMinus1 AS DATETIME,
	@ReturnDateAdd3 AS DATETIME,@ReturnDateAdd2 AS DATETIME,@ReturnDateAdd1 AS DATETIME
	DECLARE @tblAlternateFares AS TABLE ( OriginDate DateTime,ReturnDate DateTime,PriceTotal float,OriginDay varchar(10),ReturnDay varchar(10) )  
	-- End of Declaring Variables

	-- Getting Original Departure Date And Original Return Date
	SELECT @DepartureDate = airRequestDepartureDate,@ReturnDate = airRequestArrivalDate, @airsubrequestLegIndex = airSubRequestLegIndex
	FROM AirSubRequest 
	where airSubRequestKey = @airSubRequestKey

	IF ( @airRequestTypeKey = 1 ) 
		BEGIN
		IF (@airsubrequestLegIndex=1)
		BEGIN
			INSERT INTO  @tblAlternateFares( OriginDate,ReturnDate,PriceTotal,OriginDay,ReturnDay)
			SELECT mt.airResponseAlternateDateOriginDate,mt.airResponseAlternateDateReturnDate,mt.airResponseAlternateDatePriceTotal,DATENAME(DW,mt.airResponseAlternateDateOriginDate) AS OriginDay,DATENAME(DW,mt.airResponseAlternateDateReturnDate) AS ReturnDay
			FROM AirResponseAlternateDate mt
			WHERE mt.airResponseAlternateDateOriginDate <> @DepartureDate
			AND airSubRequestKey = @airSubRequestKey
			ORDER BY mt.airResponseAlternateDateOriginDate
			select * from @tblAlternateFares
		END
		ELSE
		BEGIN
		SET @ReturnDate = CONVERT(date, @ReturnDate)
		declare @duration int
		set @duration = datediff(day,@DepartureDate,@ReturnDate)
		INSERT INTO  @tblAlternateFares( OriginDate,ReturnDate,PriceTotal,OriginDay,ReturnDay)
			SELECT mt.airResponseAlternateDateOriginDate,mt.airResponseAlternateDateReturnDate,mt.airResponseAlternateDatePriceTotal,DATENAME(DW,mt.airResponseAlternateDateOriginDate) AS OriginDay,DATENAME(DW,mt.airResponseAlternateDateReturnDate) AS ReturnDay
			FROM AirResponseAlternateDate mt
			WHERE datediff(day,mt.airResponseAlternateDateOriginDate,mt.airResponseAlternateDateReturnDate)=@duration
			--mt.airResponseAlternateDateReturnDate IN (@ReturnDate)
			AND mt.airResponseAlternateDateOriginDate <> @DepartureDate
			AND airSubRequestKey = @airSubRequestKey
			ORDER BY mt.airResponseAlternateDateOriginDate
			select * from @tblAlternateFares
		END
		END
	ELSE
		BEGIN
			SET @ReturnDateMinus3 = DATEADD(day,-3,@ReturnDate)
			SET @ReturnDateMinus2 = DATEADD(day,-2,@ReturnDate)
			SET @ReturnDateMinus1 = DATEADD(day,-1,@ReturnDate)
			SET @ReturnDateAdd3 = DATEADD(day,3,@ReturnDate)
			SET @ReturnDateAdd2 = DATEADD(day,2,@ReturnDate)
			SET @ReturnDateAdd1 = DATEADD(day,1,@ReturnDate)
			IF(@selectedDepartureDate = @DepartureDate)
				BEGIN
					INSERT INTO  @tblAlternateFares( OriginDate,ReturnDate,PriceTotal,OriginDay,ReturnDay)
					SELECT mt.airResponseAlternateDateOriginDate,mt.airResponseAlternateDateReturnDate,mt.airResponseAlternateDatePriceTotal,DATENAME(DW,mt.airResponseAlternateDateOriginDate) AS OriginDay,DATENAME(DW,mt.airResponseAlternateDateReturnDate) AS ReturnDay
					FROM AirResponseAlternateDate mt
					WHERE mt.airResponseAlternateDateOriginDate = @selectedDepartureDate and
					mt.airResponseAlternateDateReturnDate IN 
					(@ReturnDateMinus3,@ReturnDateMinus2,@ReturnDateMinus1
					,@ReturnDateAdd3,@ReturnDateAdd2,@ReturnDateAdd1)
					AND airSubRequestKey = @airSubRequestKey
					ORDER BY mt.airResponseAlternateDateReturnDate
					select * from @tblAlternateFares
				END
			ELSE
				BEGIN
					INSERT INTO  @tblAlternateFares( OriginDate,ReturnDate,PriceTotal,OriginDay,ReturnDay)
					SELECT mt.airResponseAlternateDateOriginDate,mt.airResponseAlternateDateReturnDate,mt.airResponseAlternateDatePriceTotal,DATENAME(DW,mt.airResponseAlternateDateOriginDate) AS OriginDay,DATENAME(DW,mt.airResponseAlternateDateReturnDate) AS ReturnDay
					FROM AirResponseAlternateDate mt
					WHERE mt.airResponseAlternateDateOriginDate = @selectedDepartureDate and
					mt.airResponseAlternateDateReturnDate IN 
					(@ReturnDate,@ReturnDateMinus3,@ReturnDateMinus2,@ReturnDateMinus1
					,@ReturnDateAdd3,@ReturnDateAdd2,@ReturnDateAdd1)
					AND airSubRequestKey = @airSubRequestKey
					ORDER BY mt.airResponseAlternateDateReturnDate
					select * from @tblAlternateFares
				END	
		END
	END 


GO
