SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_InsertCarCacheData]
(	
@Origin varchar(5),
@Month varchar(15),
@CacheData nvarchar(max)
)
AS
BEGIN
	IF EXISTS(select 1 from CarCacheData where (Origin = @Origin AND [MONTH] LIKE @Month))
		BEGIN
			UPDATE CarCacheData
			SET CacheData = @CacheData,CreatedDate = GETDATE(),[Month]= @Month
			WHERE Origin = @Origin AND [MONTH] LIKE @Month
		END
	ELSE	 
		BEGIN
			INSERT INTO CarCacheData(Origin,CreatedDate,CacheData,[Month]) VALUES(@Origin,GETDATE(),@CacheData,@Month);
		END
END
GO
