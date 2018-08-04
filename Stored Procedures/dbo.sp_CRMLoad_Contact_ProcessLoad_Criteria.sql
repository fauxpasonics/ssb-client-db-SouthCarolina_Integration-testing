SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_CRMLoad_Contact_ProcessLoad_Criteria]
AS 
-- Assign CRM IDs in dbo.Account
--EXEC dbo.sp_CRMProcess_CRMID_Assign_Account

TRUNCATE TABLE dbo.[CRMLoad_Contact_ProcessLoad_Criteria]

INSERT INTO dbo.[CRMLoad_Contact_ProcessLoad_Criteria]
        ( [SSB_CRMSYSTEM_CONTACT_ID] ,
          LoadType
        )
SELECT b.[SSB_CRMSYSTEM_CONTACT_ID]
, CASE WHEN 1=1 --b.accountid IS NULL 
AND b.[SSB_CRMSYSTEM_CONTACT_ID] = b.[crm_id] THEN 'Upsert' ELSE 'Update' END LoadType
FROM dbo.Contact b 
--LEFT JOIN ProdCopy.[vw_Account] b ON a.[SSB_CRMSYSTEM_ACCT_ID] = b.[new_ssbcrmsystemacctid]
--WHERE [a].[IsBusinessAccount] = 1

--Dont load SFDC Acounts as Contact
DELETE 
--SELECT * 
FROM dbo.CRMLoad_Contact_ProcessLoad_Criteria 
WHERE SSB_CRMSYSTEM_Contact_ID IN (
	SELECT SSB_CRMSYSTEM_Contact_ID FROM dbo.vwDimCustomer_ModAcctId a
		WHERE SSB_CRMSYSTEM_Contact_ID IN (SELECT DISTINCT SSB_CRMSYSTEM_Contact_ID FROM dbo.vwDimCustomer_ModAcctId WHERE SourceSystem LIKE '%SFDC_Contact%')
	GROUP BY SSB_CRMSYSTEM_Contact_ID
HAVING COUNT(DISTINCT SourceSystem) = 1
) 
AND LoadType = 'Upsert'



DELETE b
--SELECT COUNT(*)
FROM dbo.vwDimCustomer_ModAcctId a 
INNER JOIN dbo.CRMLoad_Contact_ProcessLoad_Criteria b ON b.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID
WHERE 1=1
AND SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG = 1
AND (SourceSystem LIKE '%SFDC%' OR SourceSystem LIKE '%CRM%')
AND LoadType = 'Upsert'

DELETE [b]
-- SELECT [a].[crm_id] id
FROM dbo.Contact a 
INNER JOIN dbo.[CRMLoad_Contact_ProcessLoad_Criteria] b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID
WHERE ISNULL([AddressPrimaryStreet],'')  + ISNULL([EmailPrimary],'') = ''
AND LoadType = 'Upsert'


DELETE [b]
-- SELECT [a].[crm_id] id
FROM dbo.Contact a 
INNER JOIN dbo.[CRMLoad_Contact_ProcessLoad_Criteria] b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID
WHERE ISNULL(Firstname,'')  + ISNULL(lastname,'') = ''
AND LoadType = 'Upsert'


GO
