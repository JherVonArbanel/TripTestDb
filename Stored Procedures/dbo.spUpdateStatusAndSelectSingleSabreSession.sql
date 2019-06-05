SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[spUpdateStatusAndSelectSingleSabreSession]  
(  
    @ConnectionId    INT,  
    @CurrentStatus    NVARCHAR(16),  
    @ToSetStatus    NVARCHAR(16)  
    --@SID int = 0  
)  
AS  
  Begin 
  
    SET NOCOUNT ON  
--    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE  
 Begin Tran  
  EXEC sp_getapplock @Resource = 'UpdateStatusAndSelectSingleSabreSession',   
              @LockMode = 'Exclusive',@LockOwner = 'Transaction';  
    --BEGIN TRANSACTION T1  
    DECLARE @Id [INT]   
--if(@SID > 0 )  
--BEGIN  
  
--select @Id = (select top 1 SessionId from sabresession with (XLOCK) where status = '' + @CurrentStatus + '' and [ConnectionId]  
--= @ConnectionId and DATEDIFF( MINUTE,LastAccessDate , GETDATE() ) <= 10  
--order by LastAccessDate asc )  
--    if  
--        (@Id is null)  
--        begin  
--            Rollback Transaction T1  
--        end  
--    else  
--        begin  
--            update sabresession set status ='' + @ToSetStatus + '', [LastAccessDate] = getdate() where SessionId = @Id  
--            SELECT [SessionID] ,  
--            [ConnectionID],  
--            [Token],  
--            [Status],[LastAccessDate], [ConversationId] FROM[SabreSession] WHERE [SessionID] = @Id  
--            Commit             Transaction T1  
--        END  
--END  
--ELSE  
  
      
  
        SELECT @Id = (SELECT TOP 1 SessionId FROM sabresession WITH (READPAST) WHERE STATUS = '' + @CurrentStatus + ''  
                        AND [ConnectionId] = @ConnectionId AND DATEDIFF(MINUTE, LastAccessDate, GETDATE()) <= 10  
                        ORDER BY LastAccessDate ASC ,[AAAPCC] ASC)  
    --IF (@Id IS NULL)  
    --BEGIN  
    --    ROLLBACK TRANSACTION T1  
    --END  
    --ELSE  
    BEGIN  
        UPDATE sabresession   WITH (ROWLOCK)  
        SET status ='' + @ToSetStatus + '', [LastAccessDate] = GETDATE()   
        WHERE SessionId = @Id  
         
        SELECT [SessionID], [ConnectionID], [Token], [Status], [LastAccessDate], [ConversationId] , [AAAPCC]  
        FROM[SabreSession] WHERE [SessionID] = @Id  
         
        --COMMIT TRANSACTION T1  
    END  
  
  EXEC sp_releaseapplock @Resource = 'UpdateStatusAndSelectSingleSabreSession';   
 Commit Tran  
END  
GO
