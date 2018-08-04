SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [wrk].[sp_Account_Custom]
AS 

-------------------------------------------------------------------------------

-- Author name:		Kaitlyn Nelson
-- Created date:	2016
-- Purpose:			Define logic for CRM account fields and populate fields in
--					dbo.Account_Custom to push in outbound integration
-- Copyright © 2016, SSB, All Rights Reserved

-------------------------------------------------------------------------------

-- Modification History --
-- 2018-06-11:		Kaitlyn Nelson
-- Change notes:	Added logic to add custom fields for football and men's
--					basketball seat selections, women's basketball seat selection
--					times, and market locations

-- Peer reviewed by:	Keegan Schmitt
-- Peer review notes:
-- Peer review date:	2018-06-11

-- Deployed by:
-- Deployment date:
-- Deployment notes:

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

BEGIN

MERGE INTO dbo.Account_Custom Target
USING dbo.Account source
ON source.[SSB_CRMSYSTEM_ACCT_ID] = target.[SSB_CRMSYSTEM_ACCT_ID]
WHEN NOT MATCHED BY TARGET THEN
INSERT ([SSB_CRMSYSTEM_ACCT_ID]) VALUES (source.[SSB_CRMSYSTEM_ACCT_ID])
WHEN NOT MATCHED BY SOURCE THEN
DELETE ;

EXEC dbo.sp_CRMProcess_ConcatIDs 'Account'


UPDATE a
SET SSID_Winner = b.[SSID]
	, SSB_CRMSYSTEM_Phone_Home__c = b.PhoneHome
	, SSB_CRMSYSTEM_Phone_Cell__c = b.PhoneCell
--, SSB_CRMSYSTEM_Company_Name__c = b.CompanyName
FROM [dbo].Account_Custom a
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON b.[SSB_CRMSYSTEM_ACCT_ID] = [a].[SSB_CRMSYSTEM_ACCT_ID]




--Last Ticket Purchase Date--
UPDATE a
SET a.SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c = MaxPurchaseDate
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, CAST(MAX(dd.CalDate) AS DATE) MaxPurchaseDate
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.DimCustomerId
	JOIN SouthCarolina.dbo.dimdate dd ON fts.DimDateId_OrigSale = dd.dimdateid
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Last Donation Date--
UPDATE a
SET a.SSB_CRMSYSTEM_Last_Donation_Date__c = MaxDonationDate
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, CAST(MAX(don.donation_paid_datetime) AS DATE) MaxDonationDate
	FROM (SELECT * FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId WHERE SourceSystem = 'TM') dc
	JOIN SouthCarolina.ods.TM_Donation don ON dc.AccountId = don.apply_to_acct_id
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Donor Warning Flag--
UPDATE a
SET a.SSB_CRMSYSTEM_Donor_Warning__c = b.Donor
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID
		, MAX(CASE WHEN don.apply_to_acct_id IS NOT NULL OR dfl.[Booster No ] IS NOT NULL THEN 1
			ELSE 0 END) AS Donor
	FROM southcarolina.dbo.vwDimCustomer_ModAcctId dc
	LEFT JOIN SouthCarolina.ods.TM_Donation don ON dc.accountid = don.apply_to_acct_id
	LEFT JOIN SouthCarolina.dbo.DonorFlagList dfl ON dc.AccountId = dfl.[Booster No ]
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Total Priority Points--
UPDATE a
SET a.SSB_CRMSYSTEM_Total_Priority_Points__c = b.PriorityPoints
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, SUM(tc.[points_itd]) PriorityPoints
    FROM (SELECT * FROM SouthCarolina.dbo.dimcustomerssbid WHERE SourceSystem = 'TM' and SSB_CRMSYSTEM_PRIMARY_FLAG = 1) dc
	JOIN SouthCarolina.dbo.dimcustomer d ON dc.DimCustomerId = d.DimCustomerId
	JOIN SouthCarolina.ods.TM_Cust tc ON d.AccountId = tc.acct_id
	WHERE ISNUMERIC(tc.[points_itd]) = 1
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Football STH--
UPDATE a
SET a.SSB_CRMSYSTEM_Football_STH__c = (CASE WHEN b.STH = 1 THEN 1 ELSE 0 END)
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, MAX(STH) STH
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN (
		SELECT dimcustomerid, MAX(CASE WHEN dimtickettypeid = 1 THEN 1 ELSE 0 END) AS STH
		FROM SouthCarolina.dbo.FactTicketSales fts
		JOIN SouthCarolina.dbo.dimseason ds ON fts.DimSeasonId = ds.dimseasonid
		WHERE seasonname LIKE '%football%'
		GROUP BY dimcustomerid
		) tt ON dc.DimCustomerId = tt.DimCustomerId
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	)b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Football Partial--
UPDATE a
SET a.SSB_CRMSYSTEM_Football_Partial__c = (CASE WHEN b.STH = 1 THEN 1 ELSE 0 END)
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, MAX(STH) STH
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN (
		SELECT dimcustomerid, MAX(CASE WHEN dimtickettypeid IN (2, 5, 6, 7) THEN 1 ELSE 0 END) AS STH
		FROM SouthCarolina.dbo.FactTicketSales fts
		JOIN SouthCarolina.dbo.dimseason ds ON fts.DimSeasonId = ds.dimseasonid
		WHERE seasonname LIKE '%football%'
		GROUP BY dimcustomerid
		) tt ON dc.DimCustomerId = tt.DimCustomerId
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	)b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Football Rookie--
SELECT DISTINCT dc.SSB_CRMSYSTEM_ACCT_ID, 1 AS active INTO #FBActiveSTH
FROM SouthCarolina.dbo.FactTicketSales fts
JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON fts.DimCustomerId = dc.DimCustomerId
JOIN SouthCarolina.dbo.dimseason ds ON fts.dimseasonid = ds.DimSeasonId
WHERE ds.Active = 1 AND ds.SeasonCode LIKE 'FB%' AND fts.DimTicketTypeId = 1


SELECT DISTINCT dc.SSB_CRMSYSTEM_ACCT_ID, 1 AS prev INTO #FBPrevSTH
FROM SouthCarolina.dbo.FactTicketSales fts
JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON fts.DimCustomerId = dc.DimCustomerId
JOIN SouthCarolina.dbo.dimseason ds ON fts.dimseasonid = ds.DimSeasonId
WHERE ds.Active = 0 AND ds.SeasonCode LIKE 'FB%' AND fts.DimTicketTypeId = 1

UPDATE a
SET a.SSB_CRMSYSTEM_Football_Rookie__c = b.Rookie
FROM dbo.Account_Custom a
JOIN (
	SELECT tt.SSB_CRMSYSTEM_ACCT_ID, MAX(rookie) AS Rookie
	FROM(
		SELECT cc.SSB_CRMSYSTEM_ACCT_ID, CASE WHEN a.SSB_CRMSYSTEM_ACCT_ID IS NOT NULL AND p.SSB_CRMSYSTEM_ACCT_ID IS NULL THEN 1 ELSE 0 END AS rookie
		FROM dbo.Account_Custom cc
		LEFT JOIN #FBActiveSTH a ON cc.SSB_CRMSYSTEM_ACCT_ID = a.SSB_CRMSYSTEM_ACCT_ID
		LEFT JOIN #FBPrevSTH p ON cc.SSB_CRMSYSTEM_ACCT_ID = p.SSB_CRMSYSTEM_ACCT_ID
		) tt
	GROUP BY tt.SSB_CRMSYSTEM_ACCT_ID
	)b ON b.SSB_CRMSYSTEM_ACCT_ID = a.SSB_CRMSYSTEM_ACCT_ID




--Basketball STH--
UPDATE a
SET a.SSB_CRMSYSTEM_Mens_Basketball_STH__c = (CASE WHEN b.STH = 1 THEN 1 ELSE 0 END)
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, MAX(STH) STH
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN (
		SELECT dimcustomerid, MAX(CASE WHEN dimtickettypeid = 1 THEN 1 ELSE 0 END) AS STH
		FROM SouthCarolina.dbo.FactTicketSales fts
		JOIN SouthCarolina.dbo.dimseason ds ON fts.DimSeasonId = ds.dimseasonid
		WHERE seasonname LIKE '% Men%' AND seasonname LIKE '%Basketball%'
		GROUP BY dimcustomerid
		) tt ON dc.DimCustomerId = tt.DimCustomerId
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	)b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Basketball Partial--
UPDATE a
SET a.SSB_CRMSYSTEM_Mens_Basketball_STH__c = (CASE WHEN b.STH = 1 THEN 1 ELSE 0 END)
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, MAX(STH) STH
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN (
		SELECT dimcustomerid, MAX(CASE WHEN dimtickettypeid IN (2, 5, 6, 7) THEN 1 ELSE 0 END) AS STH
		FROM SouthCarolina.dbo.FactTicketSales fts
		JOIN SouthCarolina.dbo.dimseason ds ON fts.DimSeasonId = ds.dimseasonid
		WHERE seasonname LIKE '% Men%' AND seasonname LIKE '%Basketball%'
		GROUP BY dimcustomerid
		) tt ON dc.DimCustomerId = tt.DimCustomerId
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	)b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Basketball Rookie--
SELECT DISTINCT dc.SSB_CRMSYSTEM_ACCT_ID, 1 AS active INTO #MBActiveSTH
FROM SouthCarolina.dbo.FactTicketSales fts
JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON fts.DimCustomerId = dc.DimCustomerId
JOIN SouthCarolina.dbo.dimseason ds ON fts.dimseasonid = ds.DimSeasonId
WHERE ds.Active = 1 AND ds.SeasonCode LIKE 'MB%' AND fts.DimTicketTypeId = 1


SELECT DISTINCT dc.SSB_CRMSYSTEM_ACCT_ID, 1 AS prev INTO #MBPrevSTH
FROM SouthCarolina.dbo.FactTicketSales fts
JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON fts.DimCustomerId = dc.DimCustomerId
JOIN SouthCarolina.dbo.dimseason ds ON fts.dimseasonid = ds.DimSeasonId
WHERE ds.Active = 0 AND ds.SeasonCode LIKE 'MB%' AND fts.DimTicketTypeId = 1

UPDATE a
SET a.SSB_CRMSYSTEM_Mens_Basketball_Rookie__c = b.Rookie
FROM dbo.Account_Custom a
JOIN (
	SELECT tt.SSB_CRMSYSTEM_ACCT_ID, MAX(rookie) AS Rookie
	FROM(
		SELECT cc.SSB_CRMSYSTEM_ACCT_ID, CASE WHEN a.SSB_CRMSYSTEM_ACCT_ID IS NOT NULL AND p.SSB_CRMSYSTEM_ACCT_ID IS NULL THEN 1 ELSE 0 END AS rookie
		FROM dbo.Account_Custom cc
		LEFT JOIN #MBActiveSTH a ON cc.SSB_CRMSYSTEM_ACCT_ID = a.SSB_CRMSYSTEM_ACCT_ID
		LEFT JOIN #MBPrevSTH p ON cc.SSB_CRMSYSTEM_ACCT_ID = p.SSB_CRMSYSTEM_ACCT_ID
		) tt
	GROUP BY tt.SSB_CRMSYSTEM_ACCT_ID
	)b ON b.SSB_CRMSYSTEM_ACCT_ID = a.SSB_CRMSYSTEM_ACCT_ID




--Current Year Donation Level--
DECLARE @CYFund NVARCHAR(100)
DECLARE @CYLifetime NVARCHAR(100)

SET @CYFund = CONCAT('GC',CAST(YEAR(GETDATE()) AS NVARCHAR(5)))
SET @CYLifetime = CONCAT('LFPY',RIGHT(CAST(YEAR(GETDATE()) AS NVARCHAR(5)),2));


WITH MaxLevel (SSB_CRMSYSTEM_ACCT_ID, Qual_Amount)
AS (
	SELECT DISTINCT dc.SSB_CRMSYSTEM_ACCT_ID, MAX(dl.qual_amount) Qual_Amount
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.TM_CustDonorLevel dl ON dc.AccountId = dl.acct_id
		AND dc.SourceSystem = 'TM'
	WHERE dl.drive_year = dl.current_drive_year
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
)

UPDATE a
SET a.SSB_CRMSYSTEM_CY_Donation_Level__c = b.donor_level
FROM dbo.Contact_Custom a
JOIN (
	SELECT DISTINCT dc.SSB_CRMSYSTEM_ACCT_ID, COALESCE(dl.honorary_donor_level, dl.donor_level) donor_level
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.TM_CustDonorLevel dl ON dc.AccountId = dl.acct_id
		AND dc.SourceSystem = 'TM'
	JOIN MaxLevel ml ON dc.SSB_CRMSYSTEM_ACCT_ID = ml.SSB_CRMSYSTEM_ACCT_ID
		AND dl.qual_amount = ml.Qual_Amount
	WHERE dl.drive_year = dl.current_drive_year
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID



--Current Year Donation Amount--
UPDATE a
SET a.SSB_CRMSYSTEM_CY_Donation_Amount__c = b.DonationAmount
FROM dbo.contact_custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, SUM(donor.pledge_amount - donor.owed_amount) DonationAmount
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.tm_donation donor ON dc.AccountId = donor.apply_to_acct_id
	WHERE fund_desc IN (@CYFund, @CYLifetime)
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Current Year Donation Upsell
DECLARE @PYFund NVARCHAR(100)
DECLARE @PYLifetime NVARCHAR(100)

SET @PYFund = CONCAT('GC',CAST(YEAR(GETDATE())-1 AS NVARCHAR(5)))
SET @PYLifetime = CONCAT('LFPY',RIGHT(CAST(YEAR(GETDATE())-1 AS NVARCHAR(5)),2))


UPDATE a
SET a.SSB_CRMSYSTEM_CY_Donation_Upsell__c = b.DonationUpsell
FROM dbo.contact_custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, (SUM(d1.pledge_amount-d1.owed_amount) - SUM(d2.pledge_amount - d2.owed_amount)) DonationUpsell
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.tm_donation d1 ON dc.AccountId = d1.apply_to_acct_id
	JOIN SouthCarolina.ods.tm_donation d2 ON dc.AccountId = d2.apply_to_acct_id
	WHERE d1.fund_desc IN (@CYFund, @CYLifetime)
	AND d2.fund_desc IN (@PYFund, @PYLifetime)
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID
	



--CLA Pac Group Buyer
UPDATE a
SET a.SSB_CRMSYSTEM_CLA_CC11_16_Group_Buyer__c = GroupBuyer
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID
		, MAX(CASE WHEN p.name LIKE '%GROUP%' AND p.[name] NOT LIKE '%Groupon%' 
		OR p.PRTYPE IN ('BCBS','BCBS-Y','BSOUTH','COC','COKE','COLA-Y','COLONIAL','COLONIAL-Y','G','G2','GCOLLEGE','GMIL','GMIL-Y'
			,'GPERK','GPERKY','GROUP','GY','GY','LCC','LCCY','LMC','LMC-Y','NEMO-G','PALMETTO','PALMH-Y','PROV-Y','RCG-Y','SCHOOl','SCOUT','UPS-Y'
			,'WACHOVIA','WACHOVIA-Y','YMCA','YMCA-Y','RCG','GR20') THEN 1 ELSE 0 END) AS GroupBuyer
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.dbo.TK_ODET o ON dc.ssid = o.CUSTOMER
	JOIN SouthCarolina.dbo.TK_PRTYPE p ON o.I_PT = p.PRTYPE
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--CLA Pac Premium Buyer
UPDATE a
SET a.SSB_CRMSYSTEM_CLA_CC11_16_Premium_Buyer__c = PremiumBuyer
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID
		, MAX(CASE WHEN p.name LIKE '%Suite%' THEN 1
			WHEN de.EventCode LIKE 'CL%' AND de.EventName LIKE 'STE%' THEN 1
			ELSE 0
			END) AS PremiumBuyer
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	LEFT JOIN SouthCarolina.dbo.TK_ODET o ON dc.ssid = o.CUSTOMER
	JOIN SouthCarolina.dbo.TK_PRTYPE p ON o.I_PT = p.PRTYPE
	LEFT JOIN SouthCarolina.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.dimcustomerid
	LEFT JOIN SouthCarolina.dbo.DimEvent de ON fts.DimEventId = de.DimEventId
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--CLA Pac Total Spend
SELECT dc.SSB_CRMSYSTEM_ACCT_ID, SUM(I_PAY) AS TotalSpend
INTO #totalspend
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.TK_ODET o ON dc.ssid = o.CUSTOMER
GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	UNION ALL
SELECT dc.SSB_CRMSYSTEM_ACCT_ID, SUM(fts.TotalRevenue) AS TotalSpend
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.DimCustomerId
JOIN SouthCarolina.dbo.DimEvent de ON fts.DimEventId = de.DimEventId
WHERE de.EventCode LIKE 'CL%'
GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID

UPDATE a
SET a.SSB_CRMSYSTEM_CLA_CC11_16_Total_Spend__c = TotalSpend
FROM dbo.Account_Custom a
JOIN (
	SELECT SSB_CRMSYSTEM_ACCT_ID, SUM(TotalSpend) TotalSpend
	FROM #totalspend
	GROUP BY SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--CLA Potential Suite Upgrade - Family Show
SELECT dc.SSB_CRMSYSTEM_ACCT_ID, SUM(Total_EPay) AS SuiteUpgrade
INTO #UpgradesFamily
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.TK_TRANS_ITEM_EVENT tie ON dc.SSID = tie.CUSTOMER
LEFT JOIN SouthCarolina.dbo.TK_EVENT te ON tie.[EVENT] = te.[event]
WHERE te.CLASS = 'Family Show'
GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	UNION ALL
SELECT dc.SSB_CRMSYSTEM_ACCT_ID, SUM(fts.TotalRevenue) AS SuiteUpgrade
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.DimCustomerId
LEFT JOIN SouthCarolina.dbo.DimEvent de ON fts.DimEventId = de.DimEventId
WHERE de.EventClass = 'Family Show'
AND de.EventCode LIKE 'CL%'
GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID

UPDATE a
SET a.SSB_CRMSYSTEM_CLA_CC11_16_Suite_Prospect__c = SuiteUpgrade
FROM dbo.Account_Custom a
JOIN (
	SELECT SSB_CRMSYSTEM_ACCT_ID
		, CASE WHEN SUM(SuiteUpgrade) > 400 THEN 1
			ELSE 0
			END AS SuiteUpgrade
	FROM #UpgradesFamily
	GROUP BY SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--CLA Potential Suite Upgrade - Concert
SELECT dc.SSB_CRMSYSTEM_ACCT_ID, SUM(Total_EPay) AS SuiteUpgrade
INTO #UpgradesConcert
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.TK_TRANS_ITEM_EVENT tie ON dc.SSID = tie.CUSTOMER
LEFT JOIN SouthCarolina.dbo.TK_EVENT te ON tie.[EVENT] = te.[event]
WHERE te.CLASS = 'Concert'
GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
	UNION ALL
SELECT dc.SSB_CRMSYSTEM_ACCT_ID, SUM(fts.TotalRevenue) AS SuiteUpgrade
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.DimCustomerId
LEFT JOIN SouthCarolina.dbo.DimEvent de ON fts.DimEventId = de.DimEventId
WHERE de.EventClass = 'Concert'
AND de.EventCode LIKE 'CL%'
GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID

UPDATE a
SET a.SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c = SuiteUpgrade
FROM dbo.Account_Custom a
JOIN (
	SELECT SSB_CRMSYSTEM_ACCT_ID
		, CASE WHEN SUM(SuiteUpgrade) >1100 THEN 1
			ELSE 0
			END AS SuiteUpgrade
	FROM #UpgradesConcert
	GROUP BY SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Consecutive years as booster
UPDATE a
SET a.SSB_CRMSYSTEM_Consecutive_Years__c = b.ConsecutiveYears
FROM dbo.Account_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, MAX(TRY_CAST(tc.other_info_3 AS DECIMAL(20,2))) ConsecutiveYears
    FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.TM_Cust tc ON dc.AccountId = tc.acct_id
	GROUP BY dc.SSB_CRMSYSTEM_Acct_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




--Millennium ID
SELECT dc.SSB_CRMSYSTEM_ACCT_ID, ta.alt_acct_id MilleniumID
INTO #MilleniumID
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
JOIN SouthCarolina.ods.TM_AltId ta ON dc.accountid = ta.acct_id
WHERE ta.alt_id_type = 'MLL'

UPDATE a
SET a.SSB_CRMSYSTEM_Millenium_ID__c = d.MilleniumID
FROM dbo.Account_Custom a
JOIN (
	SELECT DISTINCT b.SSB_CRMSYSTEM_ACCT_ID, 
		SUBSTRING(
			(
				SELECT ','+ a.MilleniumID  AS [text()]
				FROM #MilleniumID a
				WHERE a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID
				ORDER BY a.SSB_CRMSYSTEM_ACCT_ID
				FOR XML PATH ('')
			), 2, 1000) [MilleniumID]
	FROM #MilleniumID b
	) d ON a.SSB_CRMSYSTEM_ACCT_ID = d.SSB_CRMSYSTEM_ACCT_ID;



--------------------------------------------------Turnkey--------------------------------------------------

--Household Income
WITH MaxDate
AS (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, MAX(a.TurnkeyStandardBundleDate) TurnkeyStandardBundleDate
	FROM SouthCarolina.ods.Turnkey_Acxiom a
	JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON a.ProspectID = dc.SSID AND dc.SourceSystem = 'SouthCarolina_Turnkey'
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
)

UPDATE a
SET a.household_income__c = b.Income_EstimatedHousehold
FROM dbo.Contact_Custom a
JOIN (
	SELECT DISTINCT dc.SSB_CRMSYSTEM_ACCT_ID, a.Income_EstimatedHousehold
	FROM SouthCarolina.ods.Turnkey_Acxiom a
	JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON a.ProspectID = dc.SSID AND dc.SourceSystem = 'SouthCarolina_Turnkey'
	JOIN MaxDate md ON a.TurnkeyStandardBundleDate = a.TurnkeyStandardBundleDate AND md.SSB_CRMSYSTEM_ACCT_ID = dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID;




--Personicx Cluster
WITH MaxDate
AS (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, MAX(a.TurnkeyStandardBundleDate) TurnkeyStandardBundleDate
	FROM SouthCarolina.ods.Turnkey_Acxiom a
	JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON a.ProspectID = dc.SSID AND dc.SourceSystem = 'SouthCarolina_Turnkey'
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
)

UPDATE a
SET a.SSB_CRMSYSTEM_Personicx_Cluster__c = b.PersonicxCluster
FROM dbo.Contact_Custom a
JOIN (
	SELECT DISTINCT dc.SSB_CRMSYSTEM_ACCT_ID, a.PersonicxCluster
	FROM SouthCarolina.ods.Turnkey_Acxiom a
	JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON a.ProspectID = dc.SSID AND dc.SourceSystem = 'SouthCarolina_Turnkey'
	JOIN MaxDate md ON a.TurnkeyStandardBundleDate = a.TurnkeyStandardBundleDate AND md.SSB_CRMSYSTEM_ACCT_ID = dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID;




--Net Worth
WITH MaxDate
AS (
	SELECT dc.SSB_CRMSYSTEM_ACCT_ID, MAX(a.TurnkeyStandardBundleDate) TurnkeyStandardBundleDate
	FROM SouthCarolina.ods.Turnkey_Acxiom a
	JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON a.ProspectID = dc.SSID AND dc.SourceSystem = 'SouthCarolina_Turnkey'
	GROUP BY dc.SSB_CRMSYSTEM_ACCT_ID
)

UPDATE a
SET a.SSB_CRMSYSTEM_Net_Worth__c = b.NetWorth
FROM dbo.Contact_Custom a
JOIN (
	SELECT DISTINCT dc.SSB_CRMSYSTEM_ACCT_ID, a.NetWorth
	FROM SouthCarolina.ods.Turnkey_Acxiom a
	JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON a.ProspectID = dc.SSID AND dc.SourceSystem = 'SouthCarolina_Turnkey'
	JOIN MaxDate md ON a.TurnkeyStandardBundleDate = a.TurnkeyStandardBundleDate AND md.SSB_CRMSYSTEM_ACCT_ID = dc.SSB_CRMSYSTEM_ACCT_ID
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID



/*
----Football Priority
--UPDATE a
--SET a.SSB_CRMSYSTEM_Football_Priority__c = b.FootballPriority
--FROM dbo.Contact_Custom a
--JOIN (
--	SELECT c.SSB_CRMSYSTEM_ACCT_ID
--		, c.[Priority] FootballPriority
--	FROM dbo.vwDimCustomer_ModAcctId a
--	INNER JOIN ( SELECT
--			b.SSB_CRMSYSTEM_ACCT_ID
--						  ,models.*
--						  --,t.[TurnkeyStandardBundleDate]
--						  ,ROW_NUMBER() OVER (PARTITION BY b.SSB_CRMSYSTEM_ACCT_ID ORDER BY t.TurnkeyStandardBundleDate DESC) RN
--			FROM SouthCarolina.ods.Turnkey_Acxiom t 
--			INNER JOIN SouthCarolina.[ods].[Turnkey_Models] models ON t.AbilitecID = models.AbilitecID
--			INNER JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId b ON b.SSID = t.ProspectID AND b.SourceSystem = 'SouthCarolina_Turnkey' 
--			WHERE models.Sport = 'Football'
--		) c	ON a.SSB_CRMSYSTEM_ACCT_ID = c.SSB_CRMSYSTEM_ACCT_ID AND c.RN = 1 AND SourceSystem = 'SouthCarolina_Turnkey'
--	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




----Basketball Priority
--UPDATE a
--SET a.SSB_CRMSYSTEM_Basketball_Priority__c = b.BasketballPriority
--FROM dbo.Contact_Custom a
--JOIN (
--	SELECT c.SSB_CRMSYSTEM_ACCT_ID
--		, c.[Priority] BasketballPriority
--	FROM dbo.vwDimCustomer_ModAcctId a
--	INNER JOIN ( SELECT
--			b.SSB_CRMSYSTEM_ACCT_ID
--						  ,models.*
--						  --,t.[TurnkeyStandardBundleDate]
--						  ,ROW_NUMBER() OVER (PARTITION BY b.SSB_CRMSYSTEM_ACCT_ID ORDER BY t.TurnkeyStandardBundleDate DESC) RN
--			FROM SouthCarolina.ods.Turnkey_Acxiom t 
--			INNER JOIN SouthCarolina.[ods].[Turnkey_Models] models ON t.AbilitecID = models.AbilitecID
--			INNER JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId b ON b.SSID = t.ProspectID AND b.SourceSystem = 'SouthCarolina_Turnkey' 
--			WHERE models.Sport = 'Basketball'
--		) c	ON a.SSB_CRMSYSTEM_ACCT_ID = c.SSB_CRMSYSTEM_ACCT_ID AND c.RN = 1 AND SourceSystem = 'SouthCarolina_Turnkey'
--	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID
*/	


--------------------------------------------------Miscellaneous--------------------------------------------------
SELECT ssbid.SSB_CRMSYSTEM_ACCT_ID, MIN(xrank.ranking) AccountRank
INTO #AccountRanks
FROM SouthCarolina.dbo.DimCustomerSSBID ssbid
JOIN SouthCarolina.mdm.PrimaryFlagRanking_Account xrank
	ON ssbid.DimCustomerId = xrank.dimcustomerid
WHERE xrank.sourcesystem = 'TM'
GROUP BY ssbid.SSB_CRMSYSTEM_ACCT_ID, xrank.sourcesystem


--Men's Basketball Seat Selection--
UPDATE a
SET a.SSB_Mens_Basketball_Seat_Selection = b.other_info_1
FROM dbo.Account_Custom a
LEFT JOIN (
		SELECT acctrank.SSB_CRMSYSTEM_ACCT_ID, cust.other_info_1
		FROM SouthCarolina.mdm.PrimaryFlagRanking_Account acctrank (NOLOCK)
		JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc (NOLOCK)
			ON acctrank.dimcustomerid = dc.DimCustomerId
		JOIN SouthCarolina.ods.TM_Cust cust (NOLOCK)
			ON dc.SSID = CONCAT(cust.acct_id, ':', cust.cust_name_id)
			AND dc.SourceSystem = 'TM'
		JOIN #AccountRanks xrank
			ON xrank.SSB_CRMSYSTEM_ACCT_ID = acctrank.SSB_CRMSYSTEM_ACCT_ID
			AND xrank.AccountRank = acctrank.ranking		
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID


--Football First Seat Selection--
UPDATE a
SET a.SSB_Football_First_Seat_Selection = b.other_info_4
FROM dbo.Account_Custom a
LEFT JOIN (
		SELECT acctrank.SSB_CRMSYSTEM_ACCT_ID, cust.other_info_4
		FROM SouthCarolina.mdm.PrimaryFlagRanking_Account acctrank (NOLOCK)
		JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc (NOLOCK)
			ON acctrank.dimcustomerid = dc.DimCustomerId
		JOIN SouthCarolina.ods.TM_Cust cust (NOLOCK)
			ON dc.SSID = CONCAT(cust.acct_id, ':', cust.cust_name_id)
			AND dc.SourceSystem = 'TM'
		JOIN #AccountRanks xrank
			ON xrank.SSB_CRMSYSTEM_ACCT_ID = acctrank.SSB_CRMSYSTEM_ACCT_ID
			AND xrank.AccountRank = acctrank.ranking		
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID



--Football Second Seat Selection--
UPDATE a
SET a.SSB_Football_Second_Seat_Selection = b.other_info_5
FROM dbo.Account_Custom a
LEFT JOIN (
		SELECT acctrank.SSB_CRMSYSTEM_ACCT_ID, cust.other_info_5
		FROM SouthCarolina.mdm.PrimaryFlagRanking_Account acctrank (NOLOCK)
		JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc (NOLOCK)
			ON acctrank.dimcustomerid = dc.DimCustomerId
		JOIN SouthCarolina.ods.TM_Cust cust (NOLOCK)
			ON dc.SSID = CONCAT(cust.acct_id, ':', cust.cust_name_id)
			AND dc.SourceSystem = 'TM'
		JOIN #AccountRanks xrank
			ON xrank.SSB_CRMSYSTEM_ACCT_ID = acctrank.SSB_CRMSYSTEM_ACCT_ID
			AND xrank.AccountRank = acctrank.ranking		
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID



--Football Parking Selection--
UPDATE a
SET a.SSB_Football_Parking_Selection = b.other_info_6
FROM dbo.Account_Custom a
LEFT JOIN (
		SELECT acctrank.SSB_CRMSYSTEM_ACCT_ID, cust.other_info_6
		FROM SouthCarolina.mdm.PrimaryFlagRanking_Account acctrank (NOLOCK)
		JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc (NOLOCK)
			ON acctrank.dimcustomerid = dc.DimCustomerId
		JOIN SouthCarolina.ods.TM_Cust cust (NOLOCK)
			ON dc.SSID = CONCAT(cust.acct_id, ':', cust.cust_name_id)
			AND dc.SourceSystem = 'TM'
		JOIN #AccountRanks xrank
			ON xrank.SSB_CRMSYSTEM_ACCT_ID = acctrank.SSB_CRMSYSTEM_ACCT_ID
			AND xrank.AccountRank = acctrank.ranking		
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID



--Women's Basketball Times--
UPDATE a
SET a.SSB_Womens_Basketball_Times = b.other_info_14
FROM dbo.Account_Custom a
LEFT JOIN (
		SELECT acctrank.SSB_CRMSYSTEM_ACCT_ID, cust.other_info_14
		FROM SouthCarolina.mdm.PrimaryFlagRanking_Account acctrank (NOLOCK)
		JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc (NOLOCK)
			ON acctrank.dimcustomerid = dc.DimCustomerId
		JOIN SouthCarolina.ods.TM_Cust cust (NOLOCK)
			ON dc.SSID = CONCAT(cust.acct_id, ':', cust.cust_name_id)
			AND dc.SourceSystem = 'TM'
		JOIN #AccountRanks xrank
			ON xrank.SSB_CRMSYSTEM_ACCT_ID = acctrank.SSB_CRMSYSTEM_ACCT_ID
			AND xrank.AccountRank = acctrank.ranking		
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID


--SSB Market--
UPDATE a
SET a.SSB_Market = b.AddressPrimaryCBSA
FROM dbo.Account_Custom a
LEFT JOIN (
		SELECT SSB_CRMSYSTEM_ACCT_ID, AddressPrimaryCBSA
		FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId
		WHERE SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG = 1	
	) b ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID




EXEC  [dbo].[sp_CRMLoad_Account_ProcessLoad_Criteria];

END

GO
