SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Pradeep Gupta>
-- Create date: <13-Jan-16>
-- Description:	<this is used to get all the hash tag based on user's search >
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetHashTagForAutoComplete]
	@HashTag varchar(10)
AS
BEGIN

--select distinct REPLACE(HashTag,'#','') as [HashTag] from Trip.dbo.TripHashTagMapping where HashTag like '%'+@HashTag+'%' or HashTag like '%'+REPLACE(@HashTag,' ','')+'%' order by 1 
 
SELECT distinct REPLACE(THM.HashTag,'#','') as [HashTag] from Trip.dbo.TripHashTagMapping THM
inner join  Trip..Trip T on t.tripKey = THM.TripKey and t.tripStatusKey not in (5,6,17) and t.privacyType=1
where THM.HashTag like '%'+@HashTag+'%' or THM.HashTag like '%'+REPLACE(@HashTag,' ','')+'%' 
order by 1
 
 
END
GO
