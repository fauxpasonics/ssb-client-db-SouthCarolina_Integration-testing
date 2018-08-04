SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwCRMLoad_Account_Std_Prep]
AS 
SELECT
	  a.[SSB_CRMSYSTEM_ACCT_ID] SSB_CRMSYSTEM_ACCT_ID__c
      ,[FullName] Name
      ,[AddressPrimaryStreet] BillingStreet
      ,[AddressPrimaryCity] BillingCity
      ,[AddressPrimaryState] BillingState
      ,[AddressPrimaryZip] BillingPostalCode
      ,[AddressPrimaryCountry] BillingCountry
      ,[Phone] Phone
      ,[crm_id] Id
	  ,c.[LoadType]
	  ,internalid
  FROM [dbo].[Account] a 
INNER JOIN dbo.[CRMLoad_Account_ProcessLoad_Criteria] c ON [c].[SSB_CRMSYSTEM_ACCT_ID] = [a].[SSB_CRMSYSTEM_ACCT_ID]

GO
