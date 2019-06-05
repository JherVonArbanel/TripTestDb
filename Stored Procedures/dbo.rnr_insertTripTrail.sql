SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  proc [dbo].[rnr_insertTripTrail]
@componentType int 
,@page nvarchar(1000)
,@tripRequestKey bigint
,@Data nvarchar(1000)
, @CreatedDate datetime
,@Status bit 
,@SelectedData xml
AS 


BEgin
INSERT INTO TripTrail( componentType, page,tripRequestKey , Data,  CreatedDate,Status, SelectedData) 
VALUES (@componentType ,@page,@tripRequestKey,  @Data, @CreatedDate, @Status, @SelectedData)
Select  TripTrailID=  SCOPE_IDENTITY()


END 

GO
