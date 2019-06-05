SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE  Procedure  [dbo].[USP_InsertBFMCompletionStatus] 
(
@airrequestId int ,
@BFMCallIndex int,
@IsSuccessfullBFM bit = 1 
)
AS
BEGIN 

INSERT BFMRequestCompletion( AirRequestId,BFMCallIndex,IsSuccessfullBFM ) 
VALUES ( @airrequestId,@BFMCallIndex, @IsSuccessfullBFM)
END
GO
