SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwCRMLoad_Account_Std_Upsert] AS
SELECT 
SSB_CRMSYSTEM_ACCT_ID__c, Name, --CONVERT(NVARCHAR(300), Name, 1252) Name,
 BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, [LoadType], internalid
--SELECT max(len(Phone))
--select CONVERT(NVARCHAR(300), Name, 1252)
FROM [dbo].[vwCRMLoad_Account_Std_Prep]-- where SSB_CRMSYSTEM_ACCT_ID__c = '00F67322-05A7-403C-BBED-443EDA56D772'
WHERE LoadType = 'Upsert'
GO
