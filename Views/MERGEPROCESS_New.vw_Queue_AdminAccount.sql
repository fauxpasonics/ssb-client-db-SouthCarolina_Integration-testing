SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [MERGEPROCESS_New].[vw_Queue_AdminAccount]
AS
SELECT q.FK_MergeID, 'Account' AS ObjectType,
q.Winning_ID AS Master_SFID,
q.Losing_ID AS Slave_SFID 
FROM MERGEProcess_new.Queue q
INNER JOIN prodcopy.vw_Account win
ON win.id = q.Winning_ID
INNER JOIN prodcopy.vw_Account lose
ON lose.id = q.Losing_ID
WHERE ObjectType = 'AdmnAct'
--AND 		(q.Losing_ID =  '0014100000L3ad2AAB' AND q.Winning_ID = '0014100000IEdazAAD')







GO
