SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [MERGEPROCESS_New].[vw_Queue_Account]
AS
 
SELECT q.FK_MergeID, q.ObjectType,
q.Winning_ID AS Master_SFID,
q.Losing_ID AS Slave_SFID 
 FROM MERGEProcess_new.Queue q
WHERE ObjectType = 'Account'
	--AND 	q.Losing_ID =  '0014100000L3ad2AAB' and q.Winning_ID = '0014100000IEdazAAD'



GO
