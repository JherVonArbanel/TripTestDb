SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetExpriedConnection] 
@ConnectionID Int = 0 
AS  

BEGIN 
   
   IF(@ConnectionID >0 )
   BEGIN
   With TmpSession AS 
			( 
				SELECT ROW_NUMBER() OVER(partition by SS.ConnectionID order by SessionID ) AS ROW, 
				SessionID, SS.ConnectionID, Token, Status, MinimumSession,
				LastAccessDate, ConversationId, SC.MaximumSession  , SS.AAAPCC 
				FROM SabreSession SS  
					INNER JOIN SabreConnection SC ON SS.ConnectionID = SC.ConnectionID  
			) 
	 
	 
	 	 SELECT * FROM 
			( 
			SELECT SessionID, ConnectionID, Token, Status, LastAccessDate, ConversationId,  AAAPCC 
			FROM SabreSession  
			WHERE DATEDIFF(mi, LastAccessDate, GETDATE()) > 10 --AND  UPPER(Status) = 'AVAILABLE' 
			UNION  
			SELECT T.SessionID, T.ConnectionID, T.Token, T.Status, T.LastAccessDate, T.ConversationId , T.AAAPCC 
			FROM TmpSession  T inner join SabreConnection s on T.connectionID = S.ConnectionID
			Where Row > T.MinimumSession 
									AND  UPPER(Status) = 'AVAILABLE'  
									AND T.ConnectionID  = @ConnectionID 
									 AND DATEDIFF(mi, LastAccessDate, GETDATE()) > 3 
			) as tblExpried
			Order by ConnectionID
   
   END
   ELSE
   BEGIN
		With TmpSession AS 
			( 
				SELECT ROW_NUMBER() OVER(partition by SS.ConnectionID order by SessionID ) AS ROW, 
				SessionID, SS.ConnectionID, Token, Status, MinimumSession,
				LastAccessDate, ConversationId, SC.MaximumSession  , SS.AAAPCC 
				FROM SabreSession SS  
					INNER JOIN SabreConnection SC ON SS.ConnectionID = SC.ConnectionID  
			) 
	 
	 SELECT * FROM 
			( SELECT SessionID, ConnectionID, Token, Status, LastAccessDate, ConversationId  , AAAPCC 
			FROM SabreSession  
			WHERE DATEDIFF(mi, LastAccessDate, GETDATE()) > 10 --AND  UPPER(Status) = 'AVAILABLE' 
			UNION  
			SELECT T.SessionID, T.ConnectionID, T.Token, T.Status, T.LastAccessDate, T.ConversationId , T.AAAPCC
			FROM TmpSession  T inner join SabreConnection s on T.connectionID = S.ConnectionID
			Where Row > T.MinimumSession 
							AND  UPPER(Status) = 'AVAILABLE' 
							 AND DATEDIFF(mi, LastAccessDate, GETDATE()) > 3 
			) as tblExpried
			Order by ConnectionID
 
	END 
   END
GO
