SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[usp_UpdateApproverForTrip](@tripKey int,@approvalStatus nvarchar(100),@approver nvarchar(100),@approvalReason nvarchar(1024))
as 
begin

declare @tripStatus int
select @tripStatus = tripStatusKey from trip..Trip where tripKey=@tripKey

if(@tripStatus=8)
begin

Update Trip..Trip
set ApprovalStatus =@approvalStatus,ApprovalReason=@ApprovalReason,Approver= @approver,ModifiedDateTime=GETDATE()
where tripKey=@tripKey
select cast(1 as bit)
end
else
begin
select cast(0 as bit)
end

end
GO
