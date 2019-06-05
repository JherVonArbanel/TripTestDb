SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_UpdateoldSaveSabreCarResponseDetails]
 @NoOfDays int ,
 @carresponsekey uniqueidentifier 
 
AS
BEGIN
 
update carresponse set NoOfDays=@NoOfDays where carresponsekey=@carresponsekey
 	 
END
GO
