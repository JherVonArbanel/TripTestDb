SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_AMADEUS_UPDATE_OFFSET_TIME] 
--Declare
	-- Add the parameters for the stored procedure here
	@airRequestKey VARCHAR(20)
AS /*
set @airRequestKey = 1590
-- */
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @AIRSUBREQUEST TABLE(AIRSUBREQUESTKEY INT)
	
	INSERT INTO @AIRSUBREQUEST
	SELECT ASR.AIRSUBREQUESTKEY FROM AIRSUBREQUEST ASR WHERE ASR.AIRREQUESTKEY = @airRequestKey
	--select AIRSUBREQUESTKEY from @AIRSUBREQUEST
	
	DECLARE @AIRRESPONSE TABLE(AIRRESPONSEKEY UNIQUEIDENTIFIER)
	
	INSERT INTO @AIRRESPONSE
	SELECT AR.AIRRESPONSEKEY FROM AIRRESPONSE AR WHERE AR.AIRSUBREQUESTKEY IN (SELECT AIRSUBREQUESTKEY FROM @AIRSUBREQUEST)

    
    --SELECT * FROM AIRSEGMENTS A WHERE A.AIRRESPONSEKEY IN (select AIRRESPONSEKEY from @AIRRESPONSE)
    
    UPDATE SEG_DEP 
    SET SEG_DEP.airSegmentDepartureOffset = ARL_DEP.gmt_offset
	FROM AirSegments  SEG_DEP 
		LEFT OUTER JOIN AirportLookup ARL_DEP ON (ARL_DEP.AirportCode = SEG_DEP.airSegmentDepartureAirport)
	WHERE SEG_DEP.AIRRESPONSEKEY IN (SELECT AIRRESPONSEKEY FROM @AIRRESPONSE)

	UPDATE SEG_ARV 
	SET SEG_ARV.airSegmentArrivalOffset = ARL.gmt_offset
	FROM AirSegments  SEG_ARV 
		LEFT OUTER JOIN AirportLookup ARL ON (ARL.AirportCode = SEG_ARV.airSegmentArrivalAirport)
	WHERE SEG_ARV.airResponseKey IN (SELECT AIRRESPONSEKEY FROM @AIRRESPONSE)
    
	--SELECT * FROM AIRSEGMENTS A WHERE A.AIRRESPONSEKEY IN (select AIRRESPONSEKEY from @AIRRESPONSE)
	
END
GO
