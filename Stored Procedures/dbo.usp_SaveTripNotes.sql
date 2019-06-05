SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[usp_SaveTripNotes]
 
 @TripKey int= 0,  
 @userKey int,  
 @AttendeeNotesLastModifiedOn datetime,  
 @OrganizerNotesLastModifiedOn datetime,
 @AttendeeNotes nvarchar(MAX) = '',  
 @OrganizerNotes nvarchar(MAX) = ''
AS

BEGIN  
DECLARE @StrOutput nvarchar(50)

IF EXISTS(select tripkey from Trip..TripNotes where TripKey= @TripKey)
BEGIN
UPDATE Trip..TripNotes SET AttendeeNotes = CASE WHEN ISNULL(@AttendeeNotes,'') <> '' THEN @AttendeeNotes END,
							OrganizerNotes = CASE WHEN ISNULL(@OrganizerNotes,'') <> '' THEN @OrganizerNotes END,
							AttendeeNotesLastModifiedOn = CASE WHEN ISNULL(@AttendeeNotes,'') <> '' THEN @AttendeeNotesLastModifiedOn END,
							AttendeeNotesLastModifiedBy = CASE WHEN ISNULL(@AttendeeNotes,'') <> '' THEN @userKey END,
							OrganizerNotesLastModifiedOn = CASE WHEN ISNULL(@OrganizerNotes,'') <> '' THEN OrganizerNotesLastModifiedOn END,
							OrganizerNotesLastModifiedBy = CASE WHEN ISNULL(@OrganizerNotes,'') <> '' THEN @userKey END
					WHERE TripKey = @TripKey
SET @StrOutput = 'Notes Updated Successfully.'
END
ELSE
BEGIN

INSERT INTO Trip..TripNotes (TripKey, AttendeeNotes, OrganizerNotes, AttendeeNotesLastModifiedOn, AttendeeNotesLastModifiedBy, OrganizerNotesLastModifiedOn, OrganizerNotesLastModifiedBy)
				  VALUES(@TripKey, @AttendeeNotes, @OrganizerNotes, CASE WHEN ISNULL(@AttendeeNotes,'') <> '' THEN @AttendeeNotesLastModifiedOn  END, CASE WHEN ISNULL(@AttendeeNotes,'') <> '' THEN @userKey  END
				  ,CASE WHEN ISNULL(@OrganizerNotes,'') <> '' THEN @OrganizerNotesLastModifiedOn  END, CASE WHEN ISNULL(@OrganizerNotes,'') <> '' THEN @userKey  END)
SET @StrOutput = 'Notes Added Successfully.'
END
SELECT @StrOutput AS dbOutput
END  
  

GO
