SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TripErrorDetails_Insert]
@RequestKey INT,
@tripComponentType SMALLINT,
@ErrorDescription VARCHAR(MAX),
@Category VARCHAR(10)
AS
BEGIN
	INSERT INTO [Trip].[dbo].[TripErrorDetails]
   ([RequestKey]
   ,[tripComponentType]
   ,[ErrorDescription]
   ,[Category]
   ,[CreatedDate])
    VALUES (@RequestKey,@tripComponentType,@ErrorDescription,@Category,GETDATE())
END
GO
