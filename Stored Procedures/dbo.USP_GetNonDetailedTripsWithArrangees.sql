SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
exec USP_GetNonDetailedTripsWithArrangees @userKey=25,@companyKey=1000,@fromDate='1900-01-01 00:00:00',@toDate='9999-12-31 00:00:00'
Created by :Dharmendra 
Created On :12 july 2011
discription: This SP use in Current trip/Past trip/trip detail pages. 
			 Getting "Trip Name" to user with arrangees.
*/

CREATE PROCEDURE [dbo].[USP_GetNonDetailedTripsWithArrangees]
(
	@userKey	INT,
	@companyKey as int = null,
	@fromDate   DateTime,
    @toDate   DateTime
)
AS
BEGIN
/*
declare @userkey int 
declare @companyKey int
declare @fromDate   DateTime
declare @toDate   DateTime
set @userkey=25
set @companyKey = 1000
--set @fromDate = '2011-07-14 12:14:07' ---currenttrips
--set @toDate = '9999-12-31 00:00:00'   ---currenttrips
set @toDate = '2011-07-14 12:14:07'		---pasttrips
set @fromDate = '1900-01-01 00:00:00'	---pasttrips
--set @fromDate = '1900-01-01 00:00:00' ---Detialtrip
--set @toDate = '9999-12-31 00:00:00'	---Detialtrip
*/
CREATE TABLE #tblUser  
(  
 UserKey Int  
)  

BEGIN  
 INSERT INTO #tblUser  
 SELECT DISTINCT userKey from Vault.dbo.GetAllArrangees(@userkey,@companyKey )  
END
BEGIN
IF @toDate= '9999-12-31 00:00:00' and @fromDate <> '1900-01-01 00:00:00'
	BEGIN	
		SELECT tripkey, tripname from Trip WITH(NOLOCK) 
		INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) on trip.userKey =  U.UserKey   
		INNER JOIN #tblUser TU ON U.userKey = TU.userKey 
		where dbo.IsTripStatusAsPerType(ISNULL(null,Trip.tripStatusKey),'currenttrips') = 1 AND   
		recordlocator IS NOT NULL AND recordlocator <> '' AND  trip.endDate >= GETDATE() order by tripkey desc  
	END
ELSE IF @fromDate= '1900-01-01 00:00:00' and @toDate <> '9999-12-31 00:00:00'
	BEGIN	
		SELECT trip.tripkey, trip.tripname,* from Trip WITH(NOLOCK) 
		INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) on trip.userKey =  U.UserKey   
		INNER JOIN #tblUser TU ON U.userKey = TU.userKey 
		where dbo.IsTripStatusAsPerType(ISNULL(null,Trip.tripStatusKey),'pasttrips') = 1 AND   
		recordlocator IS NOT NULL AND recordlocator <> '' AND trip.endDate < GETDATE() order by trip.tripkey desc  
	END
ELSE IF @fromDate= '1900-01-01 00:00:00' and @toDate= '9999-12-31 00:00:00'
	BEGIN	
		SELECT tripkey, tripname from Trip WITH(NOLOCK) 
		INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) on trip.userKey =  U.UserKey   
		INNER JOIN #tblUser TU ON U.userKey = TU.userKey 
		order by tripkey desc  
	END
ELSE 
	BEGIN	
		SELECT tripkey, tripname from Trip WITH(NOLOCK) 
		INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) on trip.userKey =  U.UserKey   
		INNER JOIN #tblUser TU ON U.userKey = TU.userKey where  recordlocator IS NULL OR recordlocator = '' order by tripkey desc  
	END
END

drop table #tblUser
END
GO
