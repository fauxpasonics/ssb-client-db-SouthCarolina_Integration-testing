SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CRMLoad_TicketTransactions_Prep]
AS 

TRUNCATE TABLE stg.CRMLoad_TicketTransactions

INSERT INTO stg.CRMLoad_TicketTransactions
SELECT * 
FROM southcarolina.[dbo].[vwCRMLoad_TicketTransactions] t WITH (NOLOCK)--updateme
WHERE t.OrderDate__c > DATEADD(YEAR, -1, GETDATE())--updateme

TRUNCATE TABLE dbo.TicketTrans_ErrorOutput


GO
