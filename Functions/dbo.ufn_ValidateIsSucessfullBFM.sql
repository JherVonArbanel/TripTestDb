SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE function [dbo].[ufn_ValidateIsSucessfullBFM] (@airRequestKey int)
ReturnS bit as 

begin
Declare @operationCompleted Bit = 1  

IF(select COUNT(*) from BFMRequestCompletion where AirRequestID= @airRequestKey and IsSuccessfullBFM = 0) > 0 
beGIN

SET @operationCompleted = 0 
END

RETURN @operationCompleted


end
GO
