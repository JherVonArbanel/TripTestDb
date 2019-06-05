SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Hemali Desai
-- Create date: 05-Apr-2013
-- Description:	Update Children Age
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateChildrenAge]
	-- Add the parameters for the stored procedure here
	    @TripRequestKey INT,
        @PassengerTypeKey INT,
        @PassengerAge INT,
        @TripKey INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	
	SET NOCOUNT ON;

	 IF NOT EXISTS(SELECT 1 FROM PassengerAge WHERE TripRequestKey= @TripRequestKey AND  PassengerTypeKey = @PassengerTypeKey AND PassengerAge = @PassengerAge) 
		BEGIN
			INSERT INTO  PassengerAge(TripRequestKey , PassengerTypeKey,PassengerAge, TripKey) VALUES (@TripRequestKey , @PassengerTypeKey,@PassengerAge, @TripKey) 
		END
	ELSE 
		BEGIN
			UPDATE PassengerAge SET TripKey=@TripKey WHERE TripRequestKey= @TripRequestKey AND  PassengerTypeKey = @PassengerTypeKey AND PassengerAge = @PassengerAge
		END
END
GO
