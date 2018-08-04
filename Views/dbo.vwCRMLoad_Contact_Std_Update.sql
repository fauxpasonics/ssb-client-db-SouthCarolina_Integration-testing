SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwCRMLoad_Contact_Std_Update] AS
SELECT a.SSB_CRMSYSTEM_ACCT_ID__c, a.SSB_CRMSYSTEM_CONTACT_ID__c, a.Prefix, a.FirstName, a.LastName, a.Suffix, a.MailingStreet, a.MailingCity, a.MailingState, a.MailingPostalCode, a.MailingCountry, a.Phone, a.AccountId
, [LoadType] , a.Id
FROM [dbo].[vwCRMLoad_Contact_Std_Prep] a
LEFT JOIN  prodcopy.vw_contact c on a.Id = c.Id
WHERE LoadType = 'Update'
AND  ( HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.FirstName as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.FirstName as varchar(max)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.LastName as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.LastName as varchar(max)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.Suffix as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.Suffix as varchar(max)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.MailingStreet as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.MailingStreet as varchar(max)))),'')) 
	or HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.MailingCity as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.MailingCity as varchar(max)))),'')) 
	Or HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.MailingState as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.MailingState as varchar(max)))),'')) 
	Or HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.MailingPostalCode as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.MailingPostalCode as varchar(max)))),'')) 
	Or HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.MailingCountry as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.MailingCountry as varchar(max)))),'')) 
	Or HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( a.Phone as varchar(max)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Cast( c.Phone as varchar(max)))),'')) 
	)
	
GO
