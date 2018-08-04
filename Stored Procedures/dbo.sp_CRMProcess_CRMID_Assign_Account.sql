SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CRMProcess_CRMID_Assign_Account]
as

/*remove salesforce_ids that are not in prodcopy - wait 1 day to be sure they get picked up by prodcopy*/
UPDATE a
SET crm_id = a.SSB_CRMSYSTEM_ACCT_ID
--SELECT COUNT(*)
FROM dbo.account a
LEFT JOIN prodcopy.vw_Account b
ON a.[crm_id] = b.id
where b.id IS NULL

UPDATE a
SET [crm_id] = b.id
--SELECT COUNT(*)
FROM dbo.account a
INNER JOIN prodcopy.vw_account b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID__C
LEFT JOIN (SELECT crm_id FROM dbo.account WHERE crm_id <> SSB_CRMSYSTEM_ACCT_ID) c ON b.id = c.[crm_id]
WHERE isnull(a.[crm_id], '') != b.id
AND c.[crm_id] IS null
AND b.isdeleted = 0


UPDATE a
SET crm_ID =  b.ssid 
--SELECT COUNT(*)
FROM dbo.account a
INNER JOIN dbo.vwDimCustomer_ModAcctId b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID
LEFT JOIN (SELECT crm_id FROM dbo.account WHERE crm_id <> SSB_CRMSYSTEM_ACCT_ID) c ON b.ssid = c.[crm_id]
WHERE b.SourceSystem = 'southcarolina PC_SFDC Account' AND ISNULL(a.crm_id, '') != b.ssid
AND c.[crm_id] IS NULL 
AND b.isdeleted = 0
--AND a.crm_ID = a.SSB_CRMSYSTEM_ACCT_ID
--and a. ssb_CRMSYSTEM_ACCT_ID = '72C5A993-A611-4E4C-A2A2-6B9355E080A6'


GO
