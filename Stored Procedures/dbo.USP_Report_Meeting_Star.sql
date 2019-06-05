SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Exec [dbo].[USP_Report_Meeting_Star] 'LH07A33,LH08A33,SN16S13,LH09A33,LH10A33,LH06A71,LH04A71,SN02A62,SN03A62,SN06A62,SN07A62' 
CREATE PROCEDURE [dbo].[USP_Report_Meeting_Star]     (     
--DECLARE 
@meetingCodes AS VARCHAR(4000)
)
as
--SELECT @meetingCodes = 'LH07A33,LH08A33,SN16S13,LH09A33,LH10A33,LH06A71,LH04A71,SN02A62,SN03A62,SN06A62,SN07A62' 

		-- Create table for MIA-ORD-FRA-MIA as City,Airlines as Vendor    
		declare @sortType varchar(20)     
		declare @sortColumn varchar(100)     

		IF OBJECT_ID('tempdb..#tblMeetingCodes') IS NOT NULL
			DROP TABLE #tblMeetingCodes
			
		CREATE TABLE #tblMeetingCodes 
		(          
			meetingCode VARCHAR(10)
		)		    
		
		INSERT INTO #tblMeetingCodes 
		SELECT [String] From [ufn_DelimiterToTable](@meetingCodes, ',')

--Select meetingCode From #tblMeetingCodes 
Select meetingCode,meetingName,meetingVenue,meetingFromDate,meetingToDate,meetingAirportCd,ParticipatingAirlines,createdOn,[Status] from Vault..Meeting where meetingCode in (Select meetingCode From #tblMeetingCodes )
Select meetingCodeKey,recordLocator,TSL.tripStatusName,TAR.[actualAirPrice],CurrencyCodeKey--,* 
from	trip..Trip  T
left outer join TripStatusLookup TSL on TSL.tripStatusKey = T.tripStatusKey 
LEFT OUTER JOIN [Trip].[dbo].[TripAirResponse] TAR ON TAR.tripKey = T.tripKey
where meetingCodeKey in (Select meetingCode From #tblMeetingCodes )
GO
