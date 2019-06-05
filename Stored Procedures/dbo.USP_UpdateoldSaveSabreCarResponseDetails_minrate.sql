SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,For update minrate ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_UpdateoldSaveSabreCarResponseDetails_minrate]
 @minrate float ,
 @carresponsekey uniqueidentifier 
 
AS
BEGIN
 
update carresponse set minrate =@minrate where carresponsekey=@carresponsekey
 	 
END
GO
