SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwCRMLoad_Account_Std_Update] AS
SELECT a.SSB_CRMSYSTEM_ACCT_ID__c, a.Name, a.BillingStreet, a.BillingCity, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.Phone, a.Id, [LoadType]
FROM [dbo].[vwCRMLoad_Account_Std_Prep] a
left join prodcopy.Account c on a.Id = c.ID
WHERE LoadType = 'Update'
AND  (HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.Name as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.Name as varchar(max)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.BillingStreet as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.BillingStreet as varchar(max)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.BillingCity as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.BillingCity as varchar(max)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.BillingState as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.BillingState as varchar(max)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.BillingPostalCode as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.BillingPostalCode as varchar(max)))),'')) 
	or HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.BillingCountry as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.BillingCountry as varchar(max)))),'')) 
	Or HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.Phone as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.Phone as varchar(max)))),'')) 
	--Or HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.emailaddress1 as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.emailaddress1 as varchar(max)))),'')) 
	)


GO
