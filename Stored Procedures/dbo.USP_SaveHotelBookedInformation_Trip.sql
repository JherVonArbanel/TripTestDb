SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,INSERT INTO  Trip table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveHotelBookedInformation_Trip]
@tripName nvarchar(50), 
@userKey int,
 @recordLocator varchar(50), 
 @tripStatusKey int, 
 @agencyKey int

AS
BEGIN
 
INSERT INTO  Trip( tripName , userKey , recordLocator, tripStatusKey, agencyKey )VALUES (@tripName , @userKey , @recordLocator, @tripStatusKey, @agencyKey ) SELECT Scope_Identity()

END
GO
