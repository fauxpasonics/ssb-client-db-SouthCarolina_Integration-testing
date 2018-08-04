SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[HEDA_OrphanedAccountsReport]
AS

SELECT COUNT(*) AS OrphanedAccounts
INTO #needaccount
FROM	  southcarolina_reporting.prodcopy.Contact pcc
LEFT JOIN southcarolina_reporting.prodcopy.Account pca ON pcc.AccountId = pca.id
LEFT JOIN southcarolina_reporting.prodcopy.RecordType rt ON pca.RecordTypeId = rt.id
WHERE pcc.IsDeleted = 0 AND rt.name IS NULL


DECLARE @new_subject VARCHAR(255)
DECLARE @MessageBody VARCHAR(MAX)

SET @MessageBody = ''

SET @MessageBody = '<html><table border="1">
      <tr bgcolor="cccccc">
            <td>Orphaned Accounts</td>
            </tr>'

---this is where you create your subject for the e-mails
SET @new_subject = SUBSTRING(DB_NAME(),1,CHARINDEX('_',DB_NAME(),1)-1) + ' Orphaned Accounts' 

---this is where the column names from your output table go
SELECT @MessageBody = @MessageBody + '<tr>'
      + '<td>' +  CONVERT(VARCHAR(255),OrphanedAccounts)
      + '</td>'
FROM #needaccount

SET @MessageBody = @MessageBody  + '</tr></table></html>'

BEGIN
IF (SELECT orphanedaccounts FROM #needaccount) > 0  
EXEC [msdb].dbo.sp_send_dbmail
      @profile_name = 'Mandrill'
      ,@recipients = 'tfrancis@ssbinfo.com; ameitin@ssbinfo.com; chignite@ssbinfo.com'
      ,@subject = @new_subject
      ,@body = @MessageBody
      ,@body_format = 'HTML';

ELSE SELECT CURRENT_TIMESTAMP; 

END;


DROP TABLE #needaccount
GO
