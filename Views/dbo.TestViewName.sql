SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TestViewName] 
AS
SELECT trip.recordLocator, trip.endDate
FROM Trip 
WHERE tripStatusKey = '1'
GO
