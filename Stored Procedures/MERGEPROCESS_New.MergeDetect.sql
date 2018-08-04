SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [MERGEPROCESS_New].[MergeDetect] -- 'SouthCarolina'
--exec [MERGEPROCESS_New].[MergeDetect]  'SouthCarolina'
	@Client VARCHAR(100) 
AS
--DECLARE @client VARCHAR(100) = 'SouthCarolina'
Declare @Date Date = (select cast(getdate() as date));
DECLARE @Account varchar(100) = (Select CASE WHEN @client = 'SouthCarolina' THEN 'SouthCarolina PC_SFDC Account' ELSE Concat(@client,' PC_SFDC Account' ) END);
DECLARE @Contact varchar(100) = (Select CASE WHEN @client = 'SouthCarolina' THEN 'SouthCarolina PC_SFDC Contact' ELSE Concat(@client,' PC_SFDC Contact' ) END );

IF OBJECT_ID('tempdb..#KeyAccounts_CRMAccounts') IS NOT NULL
    DROP TABLE #KeyAccounts_CRMAccounts
SELECT *
INTO #KeyAccounts_CRMAccounts
FROM SouthCarolina.dbo.vw_KeyAccounts_CRMAccounts

IF OBJECT_ID('tempdb..#KeyAccounts_CRMContacts') IS NOT NULL
    DROP TABLE #KeyAccounts_CRMContacts
SELECT *
INTO #KeyAccounts_CRMContacts
FROM SouthCarolina.dbo.vw_KeyAccounts_CRMContacts;

With MergeAccount as (
select SSB_CRMSYSTEM_ACCT_ID, count(1) CountAccounts, max(CASE WHEN b.DimCustomerID is not null then 1 else 0 END) Key_Related
	, CASE WHEN c.RecordTypeId = '01241000000aNV9AAM' THEN c.RecordTypeId ELSE 1 END AS RecordType
FROM dbo.vwDimCustomer_ModAcctID a WITH (NOLOCK)
LEFT JOIN #KeyAccounts_CRMAccounts b WITH (NOLOCK) on a.dimcustomerid = b.dimcustomerid
JOIN SouthCarolina_Reporting.prodcopy.vw_Account c WITH (NOLOCK) ON a.ssid = c.Id
where SourceSystem =  'SouthCarolina PC_SFDC Account'
group by SSB_CRMSYSTEM_ACCT_ID, (CASE WHEN c.RecordTypeId = '01241000000aNV9AAM' THEN c.RecordTypeId ELSE 1 END)
having count(1) > 1), 

 MergeContact as (
select SSB_CRMSYSTEM_CONTACT_ID, count(1) CountContacts, max(CASE WHEN b.ID is not null then 1 else 0 END) Key_Related
FROM dbo.vwDimCustomer_ModAcctID a  WITH (NOLOCK)
left join (select cc.ID, cc.AccountId
			FROM SouthCarolina_Reporting.prodcopy.vw_Contact cc WITH (NOLOCK)
			JOIN #KeyAccounts_CRMContacts bb WITH (NOLOCK) on cc.Id = bb.SSID
			) b	on a.SSID = b.ID
where SourceSystem = @Contact
group by SSB_CRMSYSTEM_CONTACT_ID
having count(1) > 1),


 MergeAdminAccount as (
select SSB_CRMSYSTEM_CONTACT_ID, count(1) CountContacts, max(CASE WHEN b.ID is not null then 1 else 0 END) Key_Related
FROM dbo.vwDimCustomer_ModAcctID a  WITH (NOLOCK)
left join (select cc.ID
			FROM SouthCarolina_Reporting.prodcopy.vw_Contact cc WITH (NOLOCK)
			JOIN #KeyAccounts_CRMContacts bb WITH (NOLOCK) on cc.Id = bb.SSID
			) b	on a.SSID = b.ID
INNER JOIN prodcopy.vw_Contact pcc WITH (NOLOCK) ON pcc.id = a.SSID
INNER JOIN prodcopy.vw_Account pca WITH (NOLOCK) ON pca.id = pcc.AccountId
where SourceSystem = @Contact
AND pca.RecordTypeId = '01241000000aNV9AAM'
group by SSB_CRMSYSTEM_CONTACT_ID
having count(1) > 1)

--Select 'Account' MergeType, SSB_CRMSYSTEM_ACCT_ID SSBID, CASE WHEN Key_Related = 0 THEN 1 ELSE 0 END AutoMerge, @Date DetectedDate, CountAccounts NumRecords FROM MergeAccount
--		UNION ALL
--		Select 'Contact' MergeType, SSB_CRMSYSTEM_Contact_ID SSBID, CASE WHEN Key_Related = 0 THEN 1 ELSE 0 END AutoMerge, @Date DetectedDate, CountContacts NumRecords FROM MergeContact
--		UNION ALL
--		SELECT 'AdmnAct' MergeType,  SSB_CRMSYSTEM_Contact_ID SSBID, CASE WHEN Key_Related = 0 THEN 1 ELSE 0 END AutoMerge, @Date DetectedDate, CountContacts NumRecords FROM MergeAdminAccount
--		;

MERGE  MERGEPROCESS_New.DetectedMerges  as tar
using ( Select 'Account' MergeType, SSB_CRMSYSTEM_ACCT_ID SSBID, CASE WHEN Key_Related = 0     and MergeAccount.CountAccounts  = 2 THEN 1 ELSE 0 END AutoMerge, @Date DetectedDate, CountAccounts NumRecords FROM MergeAccount
		UNION ALL
		Select 'Contact' MergeType, SSB_CRMSYSTEM_Contact_ID SSBID, CASE WHEN Key_Related = 0  and MergeContact.CountContacts = 2 THEN 1 ELSE 0 END AutoMerge, @Date DetectedDate, CountContacts NumRecords FROM MergeContact
		UNION ALL
		SELECT 'AdmnAct' MergeType,  SSB_CRMSYSTEM_Contact_ID SSBID, CASE WHEN Key_Related = 0 and MergeAdminAccount.CountContacts = 2 THEN 1 ELSE 0 END AutoMerge, @Date DetectedDate, CountContacts NumRecords FROM MergeAdminAccount
		) as sour
	ON tar.MergeType = sour.MergeType
	AND tar.SSBID = sour.SSBID
WHEN MATCHED  AND (tar.DetectedDate <> sour.DetectedDate 
				OR sour.NumRecords <> tar.NumRecords
				OR MergeComplete =  1) THEN UPDATE 
	Set DetectedDate = @Date
	,NumRecords = sour.NumRecords
	,MergeComplete = 0 
WHEN Not Matched THEN Insert
	(MergeType
	,SSBID
	,AutoMerge
	,DetectedDate
	,NumRecords)
Values(
	 sour.MergeType
	,sour.SSBID
	,sour.AutoMerge
	,sour.DetectedDate
	,sour.NumRecords)
WHEN NOT MATCHED BY SOURCE AND tar.MergeComment IS NULL THEN UPDATE
	SET MergeComment = CASE WHEN tar.Mergecomplete = 1 then 'Merge Detection - Merge Successfully completed'
							WHEN tar.mergeComplete = 0 THEN 'Merge Detection - Merge not completed, but no longer detected' END
		,MergeComplete = 1

;

IF OBJECT_ID('mergeprocess_new.tmp_pcaccount', 'U') IS NOT NULL 
DROP TABLE mergeprocess_new.tmp_pcaccount; 

IF OBJECT_ID('mergeprocess_new.tmp_pccontact', 'U') IS NOT NULL 
DROP TABLE mergeprocess_new.tmp_pccontact;

IF OBJECT_ID('mergeprocess_new.tmp_dimcust', 'U') IS NOT NULL 
DROP TABLE mergeprocess_new.tmp_dimcust;

select * into mergeprocess_new.tmp_dimcust from dbo.vwdimcustomer_modacctid  where ssb_crmsystem_contact_id in (
select ssb_crmsystem_contact_id from dbo.vwdimcustomer_modacctid where sourcesystem = @Contact group by ssb_crmsystem_contact_id having count(*) > 1 )
and sourcesystem = @Contact
UNION ALL
select * from dbo.vwdimcustomer_modacctid where ssb_crmsystem_acct_id in (
select ssb_crmsystem_acct_id from dbo.vwdimcustomer_modacctid where sourcesystem = @Account group by ssb_crmsystem_acct_id having count(*) > 1 )
and sourcesystem = @Account
--1:04

create nonclustered index ix_tmp_dimcust_acct on mergeprocess_new.tmp_dimcust (sourcesystem, ssb_crmsystem_acct_id)
create nonclustered index ix_tmp_dimcust_contact on mergeprocess_new.tmp_dimcust (sourcesystem, ssb_crmsystem_contact_id)
create nonclustered index ix_tmp_dimcust_ssid on mergeprocess_new.tmp_dimcust (sourcesystem, ssid)
--0:05

select pcc.* into mergeprocess_new.tmp_pccontact from mergeprocess_new.tmp_dimcust dc
inner join prodcopy.vw_contact pcc on dc.ssid = pcc.id
where dc.sourcesystem = @Contact
--0:07

select pca.* into mergeprocess_new.tmp_pcaccount from mergeprocess_new.tmp_dimcust dc
inner join prodcopy.vw_account pca on dc.ssid = pca.id
where dc.sourcesystem = @Account
--0:08

alter table mergeprocess_new.tmp_pcaccount
alter column id varchar(200)
--0:03


alter table mergeprocess_new.tmp_pccontact
alter column id varchar(200)
--0:02

create nonclustered index ix_tmp_pcaccount on mergeprocess_new.tmp_pcaccount (id)
--0:05

create nonclustered index ix_tmp_pccontact on mergeprocess_new.tmp_pccontact (id)
--0:01

GO
