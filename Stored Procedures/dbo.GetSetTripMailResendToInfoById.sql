SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetSetTripMailResendToInfoById]  
(  
    @TripId int
   ,@Action varchar(5) -- g:get , s:set
   ,@ResendEmail varchar(max) = null
   ,@IsResendWithPrice bit = 0
   ,@userId int = null
)  
AS   
BEGIN
	IF @Action = 'g'
	BEGIN  
	   SELECT Id
			, TripKey
			, ResendEmailWithPrice_ToEmailAddress
			, ResendEmailWithoutPrice_ToEmailAddress
			, ResendEmailWithPrice_SentBy
			, ResendEmailWithPrice_SentOn 
			, ResendEmailWithOutPrice_SentBy
			, ResendEmailWithOutPrice_SentOn 
	   FROM TripInfo WHERE TripKey=@TripId
	END 

	ELSE IF @Action = 's'
	BEGIN
			IF EXISTS(SELECT * from TripInfo where TripKey = @TripId)
				BEGIN
					IF @IsResendWithPrice = 1
						BEGIN
							UPDATE TripInfo
							SET ResendEmailWithPrice_ToEmailAddress = @ResendEmail
							   ,ResendEmailWithPrice_SentBy = @userId
							   ,ResendEmailWithPrice_SentOn = GETDATE()
							WHERE TripKey = @TripId
						END
					ELSE
						BEGIN
							UPDATE TripInfo
							SET ResendEmailWithoutPrice_ToEmailAddress = @ResendEmail
							   ,ResendEmailWithOutPrice_SentBy = @userId
							   ,ResendEmailWithOutPrice_SentOn = GETDATE()
						    WHERE TripKey = @TripId
						END
				END
				ELSE
					BEGIN
						IF @IsResendWithPrice = 1
							BEGIN
								INSERT INTO TripInfo(TripKey,ResendEmailWithPrice_ToEmailAddress,ResendEmailWithPrice_SentBy,ResendEmailWithPrice_SentOn)
									   VALUES (@TripId,@ResendEmail,@userId,GETDATE())
							END
						ELSE
							BEGIN
							INSERT INTO TripInfo(TripKey,ResendEmailWithoutPrice_ToEmailAddress,ResendEmailWithOutPrice_SentBy,ResendEmailWithOutPrice_SentOn)
									   VALUES (@TripId,@ResendEmail,@userId,GETDATE())
							END
					END
	END
		
END
GO
