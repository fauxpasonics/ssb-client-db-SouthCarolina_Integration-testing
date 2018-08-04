SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CRMLoad_SaveResults_Contact]
as
--Fix Problems with SFID mapping with Contact GUID MATCH
UPDATE a
SET [a].[crm_id] = [a].[SSB_CRMSYSTEM_CONTACT_ID]
--SELECT *
FROM dbo.Contact a 
INNER JOIN dbo.[Contact_CRMResults] b ON [a].[SSB_CRMSYSTEM_CONTACT_ID] = b.[SSB_CRMSYSTEM_CONTACT_ID__c]
WHERE a.[crm_id] <> b.[SalesForceId]
AND [b].[LoadType] = 'Upsert'
--AND a.[crm_id] = a.[SSB_CRMSYSTEM_ACCT_ID]
--AND [ResultDateTime] = '2016-03-29 21:58:56.510'
--[a].[SSB_CRMSYSTEM_CONTACT_ID] <> b.[SSB_CRMSYSTEM_CONTACT_ID__c]

--Fix Problems with SFID mapping with SFID MATCH
UPDATE a
SET [a].[crm_id] = [a].[SSB_CRMSYSTEM_CONTACT_ID]
--SELECT *
FROM dbo.Contact a 
INNER JOIN dbo.[Contact_CRMResults] b ON [a].[crm_id] = b.[SalesForceId]
WHERE [a].[SSB_CRMSYSTEM_CONTACT_ID] <> b.[SSB_CRMSYSTEM_CONTACT_ID__c]
AND [b].[LoadType] = 'Upsert'
--AND b.id IN (SELECT [salesforce_ID] FROM dbo.[Contact])

-- Regular Update of SFIDs to Contact
UPDATE a
SET [a].[crm_id] = Case when b.[SalesForceId] is null then a.[crm_id] else b.[SalesForceId] End,
CRM_LoadDate = Getdate()
,LastCRMLoad_Error = b.ErrorDescription
,LastCRMLoad_AttemptDate = GetDate()
--SELECT DISTINCT a.[SSB_CRMSYSTEM_CONTACT_ID], Case when b.id is null then a.[crm_id] else b.id END, b.*
FROM dbo.[Contact] a
INNER JOIN dbo.[Contact_CRMResults] b ON a.[SSB_CRMSYSTEM_CONTACT_ID] = b.[SSB_CRMSYSTEM_CONTACT_ID__c]
WHERE [b].[LoadType] = 'Upsert'
--AND [ResultDateTime] = '2016-03-29 21:58:56.510'

GO
