SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Temp_UpdateResponse]
@airRequestKey int
as
begin


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[airresponse_bak]') AND type in (N'U'))
DROP TABLE airresponse_bak


select * into airresponse_bak from AirResponse where airSubRequestKey = 17

alter table airresponse_bak add  airResponseKeytemp uniqueidentifier


declare @cnt uniqueidentifier
declare c cursor for select  airResponseKey from airresponse_bak

open c

fetch next from c into @cnt

while @@FETCH_STATUS = 0 begin
update airresponse_bak set airResponseKeytemp =NEWID() where airResponseKey = @cnt
fetch next from c into @cnt
end 
close c
deallocate c


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[airsegments_bak]') AND type in (N'U'))
DROP TABLE [dbo].[airsegments_bak]


select * into airsegments_bak from AirSegments where airResponseKey in(select airResponseKey from airresponse_bak)

update airsegments_bak set airsegments_bak.airresponsekey = airresponse_bak.airResponseKeytemp 
from airresponse_bak
where airsegments_bak.airresponsekey = airresponse_bak.airresponsekey


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NormalizedAirResponses_bak]') AND type in (N'U'))
DROP TABLE [dbo].[NormalizedAirResponses_bak]



select * into NormalizedAirResponses_bak from NormalizedAirResponses where airResponseKey in(select airResponseKey from airresponse_bak)

update NormalizedAirResponses_bak set NormalizedAirResponses_bak.airresponsekey = airresponse_bak.airResponseKeytemp 
from airresponse_bak
where NormalizedAirResponses_bak.airresponsekey = airresponse_bak.airresponsekey

update  airresponse_bak set  airSubRequestKey =@airRequestKey

alter table airresponse_bak drop column airResponseKeytemp
end
GO
