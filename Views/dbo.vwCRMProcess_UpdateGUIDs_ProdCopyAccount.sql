SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create VIEW [dbo].[vwCRMProcess_UpdateGUIDs_ProdCopyAccount]
AS
SELECT DISTINCT b.SSID Id, b.SSB_CRMSYSTEM_ACCT_ID SSB_CRMSYSTEM_ACCT_ID__c
--, REPLACE(REPLACE(c.[new_ssbcrmsystemcontactid],'{',''),'}','')
FROM dbo.vwDimCustomer_ModAcctId b
INNER JOIN ProdCopy.vw_Account c WITH(NOLOCK) ON b.SSID = c.id
WHERE c.SSB_CRMSYSTEM_ACCT_ID__c IS NULL OR c.SSB_CRMSYSTEM_ACCT_ID__c <> b.[SSB_CRMSYSTEM_Acct_ID]

GO
