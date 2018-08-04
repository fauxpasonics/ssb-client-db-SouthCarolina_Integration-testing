SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [MERGEPROCESS_New].[vw_Queue_Contact]
AS
SELECT q.FK_MergeID, q.ObjectType,
q.Winning_ID AS Master_SFID,
q.Losing_ID AS Slave_SFID 
FROM MERGEProcess_new.Queue q
INNER JOIN prodcopy.vw_Contact win
ON win.id = q.Winning_ID
INNER JOIN prodcopy.vw_Contact lose
ON lose.id = q.Losing_ID
WHERE ObjectType = 'Contact'
--AND 		(q.Losing_ID =  '0034100000PtQYWAA3' AND q.Winning_ID = '0034100000M6gZ3AAJ')






GO
