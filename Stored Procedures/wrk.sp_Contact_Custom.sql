SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [wrk].[sp_Contact_Custom]
AS 



-------------------------------------------------------------------------------

-- Author name:		Kaitlyn Nelson
-- Created date:	2016
-- Purpose:			Define logic for CRM custom fields and populate fields in
--					dbo.Contact_Custom to push in outbound integration
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

MERGE INTO dbo.Contact_Custom Target
USING dbo.Contact source
ON source.[SSB_CRMSYSTEM_CONTACT_ID] = target.[SSB_CRMSYSTEM_CONTACT_ID]
WHEN NOT MATCHED BY TARGET THEN
INSERT ([SSB_CRMSYSTEM_ACCT_ID], [SSB_CRMSYSTEM_CONTACT_ID]) VALUES (source.[SSB_CRMSYSTEM_ACCT_ID], Source.[SSB_CRMSYSTEM_CONTACT_ID])
WHEN NOT MATCHED BY SOURCE THEN
DELETE ;

EXEC dbo.sp_CRMProcess_ConcatIDs 'Contact'

DECLARE @CurrentFootballSeasonCode NVARCHAR(255) = 'FB18'
DECLARE @CurrentDriveYear NVARCHAR(50) = '2018'


UPDATE a
SET SSID_Winner = b.[SSID]
	, HomePhone = b.PhoneHome
	, MobilePhone = b.PhoneCell	 
	, SSB_CRMSYSTEM_Company_Name__c = b.CompanyName
	, a.SSB_CRMSYSTEM_Account_Type__c = b.AccountType
FROM [dbo].Contact_Custom a (NOLOCK)
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]


--------------------------------------------------Athletics Ticketing--------------------------------------------------

--Ticket Purchase Date--
UPDATE a
SET a.SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c = MaxPurchaseDate
, a.SSB_CRMSYSTEM_Group_Buyer__c = GroupPurchaseDate
FROM dbo.Contact_Custom a (NOLOCK)
JOIN (
	SELECT SSB_CRMSYSTEM_CONTACT_ID
	, MAX(MaxPurchaseDate) MaxPurchaseDate
	, MAX(GroupPurchaseDate) GroupPurchaseDate
	FROM (SELECT dc.SSB_CRMSYSTEM_CONTACT_ID
			, CAST(MAX(dd.CalDate) AS DATE) MaxPurchaseDate
			, CASE WHEN DimTicketTypeId = 4 THEN CAST(MAX(dd.CalDate) AS DATE) END AS GroupPurchaseDate
			FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
			JOIN SouthCarolina.dbo.FactTicketSales fts (NOLOCK)
				 ON dc.DimCustomerId = fts.DimCustomerId
			JOIN SouthCarolina.dbo.dimdate dd (NOLOCK)
				ON fts.DimDateId_OrigSale = dd.dimdateid
			GROUP BY dc.ssb_crmsystem_contact_id, DimTicketTypeId
			) x 
	GROUP BY x.SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID




--Total Priority Points--
UPDATE a
SET a.SSB_CRMSYSTEM_Total_Priority_Points__c = b.PriorityPoints
FROM dbo.Contact_Custom a (NOLOCK)
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, SUM(tc.[points_itd]) PriorityPoints
    FROM (SELECT * 
			FROM SouthCarolina.dbo.dimcustomerssbid (NOLOCK)
			WHERE SourceSystem = 'TM' and SSB_CRMSYSTEM_PRIMARY_FLAG = 1
			) dc
	JOIN SouthCarolina.dbo.dimcustomer d (NOLOCK) 
		ON dc.DimCustomerId = d.DimCustomerId
	JOIN SouthCarolina.ods.TM_Cust tc (NOLOCK)
		ON d.AccountId = tc.acct_id
	WHERE ISNUMERIC(tc.[points_itd]) = 1
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID




--Football STH--
UPDATE a
SET a.SSB_CRMSYSTEM_Football_STH__c = (CASE WHEN b.STH = 1 THEN 1 ELSE 0 END)
FROM dbo.Contact_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, MAX(STH) STH
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN (
		SELECT dimcustomerid, MAX(CASE WHEN dimtickettypeid = 1 THEN 1 ELSE 0 END) AS STH
		FROM SouthCarolina.dbo.FactTicketSales fts (NOLOCK)
		JOIN SouthCarolina.dbo.dimseason ds (NOLOCK)
			ON fts.DimSeasonId = ds.dimseasonid
		WHERE ds.SeasonCode = @CurrentFootballSeasonCode
		GROUP BY dimcustomerid
		) tt ON dc.DimCustomerId = tt.DimCustomerId
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	)b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID




--Football Partial--
UPDATE a
SET a.SSB_CRMSYSTEM_Football_Partial__c = (CASE WHEN b.STH = 1 THEN 1 ELSE 0 END)
FROM dbo.Contact_Custom a (NOLOCK)
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, MAX(STH) STH
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN (
		SELECT dimcustomerid, MAX(CASE WHEN dimtickettypeid IN (2, 5, 6, 7) THEN 1 ELSE 0 END) AS STH
		FROM SouthCarolina.dbo.FactTicketSales fts (NOLOCK)
		JOIN SouthCarolina.dbo.dimseason ds (NOLOCK)
			ON fts.DimSeasonId = ds.dimseasonid
		WHERE ds.SeasonCode = @CurrentFootballSeasonCode
		GROUP BY dimcustomerid
		) tt ON dc.DimCustomerId = tt.DimCustomerId
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	)b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID




--Football Rookie--
SELECT DISTINCT dc.SSB_CRMSYSTEM_CONTACT_ID, 1 AS active INTO #FBActiveSTH
FROM SouthCarolina.dbo.FactTicketSales fts (NOLOCK)
JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc 
	ON fts.DimCustomerId = dc.DimCustomerId
JOIN SouthCarolina.dbo.dimseason ds (NOLOCK)
	ON fts.dimseasonid = ds.DimSeasonId
WHERE ds.Active = 1 AND ds.SeasonCode LIKE 'FB%' AND fts.DimTicketTypeId = 1


SELECT DISTINCT dc.SSB_CRMSYSTEM_CONTACT_ID, 1 AS prev INTO #FBPrevSTH
FROM SouthCarolina.dbo.FactTicketSales fts (NOLOCK)
JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc 
	ON fts.DimCustomerId = dc.DimCustomerId
JOIN SouthCarolina.dbo.dimseason ds (NOLOCK)
	ON fts.dimseasonid = ds.DimSeasonId
WHERE ds.Active = 0 AND ds.SeasonCode LIKE 'FB%' AND fts.DimTicketTypeId = 1

UPDATE a
SET a.SSB_CRMSYSTEM_Football_Rookie__c = b.Rookie
FROM dbo.Contact_Custom a (NOLOCK)
JOIN (
	SELECT tt.SSB_CRMSYSTEM_CONTACT_ID, MAX(rookie) AS Rookie
	FROM(
		SELECT cc.SSB_CRMSYSTEM_CONTACT_ID, CASE WHEN a.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL AND p.SSB_CRMSYSTEM_CONTACT_ID IS NULL THEN 1 ELSE 0 END AS rookie
		FROM dbo.Contact_Custom cc
		LEFT JOIN #FBActiveSTH a ON cc.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID
		LEFT JOIN #FBPrevSTH p ON cc.SSB_CRMSYSTEM_CONTACT_ID = p.SSB_CRMSYSTEM_CONTACT_ID
		) tt
	GROUP BY tt.SSB_CRMSYSTEM_CONTACT_ID
	)b ON b.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID




--Basketball STH--
UPDATE a
SET a.SSB_CRMSYSTEM_Mens_Basketball_STH__c = (CASE WHEN b.STH = 1 THEN 1 ELSE 0 END)
FROM dbo.Contact_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, MAX(STH) STH
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN (
		SELECT dimcustomerid, MAX(CASE WHEN dimtickettypeid = 1 THEN 1 ELSE 0 END) AS STH
		FROM SouthCarolina.dbo.FactTicketSales fts
		JOIN SouthCarolina.dbo.dimseason ds ON fts.DimSeasonId = ds.dimseasonid
		WHERE seasonname LIKE '% Men%' AND seasonname LIKE '%Basketball%'
		GROUP BY dimcustomerid
		) tt ON dc.DimCustomerId = tt.DimCustomerId
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	)b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID




--Basketball Partial--
UPDATE a
SET a.SSB_CRMSYSTEM_Mens_Basketball_Partial__c = (CASE WHEN b.STH = 1 THEN 1 ELSE 0 END)
FROM dbo.Contact_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, MAX(STH) STH
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN (
		SELECT dimcustomerid, MAX(CASE WHEN dimtickettypeid IN (2, 5, 6, 7) THEN 1 ELSE 0 END) AS STH
		FROM SouthCarolina.dbo.FactTicketSales fts
		JOIN SouthCarolina.dbo.dimseason ds ON fts.DimSeasonId = ds.dimseasonid
		WHERE seasonname LIKE '% Men%' AND seasonname LIKE '%Basketball%'
		GROUP BY dimcustomerid
		) tt ON dc.DimCustomerId = tt.DimCustomerId
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	)b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID




--Basketball Rookie--
SELECT DISTINCT dc.SSB_CRMSYSTEM_CONTACT_ID, 1 AS active INTO #MBActiveSTH
FROM SouthCarolina.dbo.FactTicketSales fts
JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON fts.DimCustomerId = dc.DimCustomerId
JOIN SouthCarolina.dbo.dimseason ds ON fts.dimseasonid = ds.DimSeasonId
WHERE ds.Active = 1 AND ds.SeasonCode LIKE 'MB%' AND fts.DimTicketTypeId = 1


SELECT DISTINCT dc.SSB_CRMSYSTEM_CONTACT_ID, 1 AS prev INTO #MBPrevSTH
FROM SouthCarolina.dbo.FactTicketSales fts
JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON fts.DimCustomerId = dc.DimCustomerId
JOIN SouthCarolina.dbo.dimseason ds ON fts.dimseasonid = ds.DimSeasonId
WHERE ds.Active = 0 AND ds.SeasonCode LIKE 'MB%' AND fts.DimTicketTypeId = 1

UPDATE a
SET a.SSB_CRMSYSTEM_Mens_Basketball_Rookie__c = b.Rookie
FROM dbo.Contact_Custom a
JOIN (
	SELECT tt.SSB_CRMSYSTEM_CONTACT_ID, MAX(rookie) AS Rookie
	FROM(
		SELECT cc.SSB_CRMSYSTEM_CONTACT_ID, CASE WHEN a.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL AND p.SSB_CRMSYSTEM_CONTACT_ID IS NULL THEN 1 ELSE 0 END AS rookie
		FROM dbo.Contact_Custom cc
		LEFT JOIN #MBActiveSTH a ON cc.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID
		LEFT JOIN #MBPrevSTH p ON cc.SSB_CRMSYSTEM_CONTACT_ID = p.SSB_CRMSYSTEM_CONTACT_ID
		) tt
	GROUP BY tt.SSB_CRMSYSTEM_CONTACT_ID
	)b ON b.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID


--------------------------------------------------Colonial Life Arena--------------------------------------------------

--CLA Pac Group Buyer
UPDATE a
SET a.SSB_CRMSYSTEM_CLA_CC11_16_Group_Buyer__c = GroupBuyer
FROM dbo.Contact_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, MAX(CASE WHEN p.name LIKE '%GROUP%' AND p.[name] NOT LIKE '%Groupon%' THEN 1 ELSE 0 END) AS GroupBuyer
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.dbo.TK_ODET o ON dc.ssid = o.CUSTOMER
	JOIN SouthCarolina.dbo.TK_PRTYPE p ON o.I_PT = p.PRTYPE
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID




--CLA Pac Premium Buyer
UPDATE a
SET a.SSB_CRMSYSTEM_CLA_CC11_16_Premium_Buyer__c = PremiumBuyer
FROM dbo.Contact_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID
		, MAX(CASE WHEN p.name LIKE '%Suite%' THEN 1
			WHEN de.EventCode LIKE 'CL%' AND de.EventName LIKE 'STE%' THEN 1
			ELSE 0
			END) AS PremiumBuyer
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	LEFT JOIN SouthCarolina.dbo.TK_ODET o ON dc.ssid = o.CUSTOMER
	JOIN SouthCarolina.dbo.TK_PRTYPE p ON o.I_PT = p.PRTYPE
	LEFT JOIN SouthCarolina.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.dimcustomerid
	LEFT JOIN SouthCarolina.dbo.DimEvent de ON fts.DimEventId = de.DimEventId
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID




--CLA Pac Total Spend
SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, SUM(I_PAY) AS TotalSpend
INTO #totalspend
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.TK_ODET o ON dc.ssid = o.CUSTOMER
GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	UNION ALL
SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, SUM(fts.TotalRevenue) AS TotalSpend
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.DimCustomerId
JOIN SouthCarolina.dbo.DimEvent de ON fts.DimEventId = de.DimEventId
WHERE de.EventCode LIKE 'CL%'
GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID

UPDATE a
SET a.SSB_CRMSYSTEM_CLA_CC11_16_Total_Spend__c = TotalSpend
FROM dbo.Contact_Custom a
JOIN (
	SELECT SSB_CRMSYSTEM_CONTACT_ID, SUM(TotalSpend) TotalSpend
	FROM #totalspend
	GROUP BY SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID




--CLA Potential Suite Upgrade - Family Show
SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, SUM(Total_EPay) AS SuiteUpgrade
INTO #UpgradesFamily
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.TK_TRANS_ITEM_EVENT tie ON dc.SSID = tie.CUSTOMER
LEFT JOIN SouthCarolina.dbo.TK_EVENT te ON tie.[EVENT] = te.[event]
WHERE te.CLASS = 'Family Show'
GROUP BY dc.SSB_CRMSYSTEM_contact_ID
	UNION ALL
SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, SUM(fts.TotalRevenue) AS SuiteUpgrade
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.DimCustomerId
LEFT JOIN SouthCarolina.dbo.DimEvent de ON fts.DimEventId = de.DimEventId
WHERE de.EventClass = 'Family Show'
AND de.EventCode LIKE 'CL%'
GROUP BY dc.SSB_CRMSYSTEM_contact_ID

UPDATE a
SET a.SSB_CRMSYSTEM_CLA_CC11_16_Suite_Prospect__c = SuiteUpgrade
FROM dbo.Contact_Custom a
JOIN (
	SELECT SSB_CRMSYSTEM_CONTACT_ID
		, CASE WHEN SUM(SuiteUpgrade) > 400 THEN 1
			ELSE 0
			END AS SuiteUpgrade
	FROM #UpgradesFamily
	GROUP BY SSB_CRMSYSTEM_Contact_ID
	) b ON a.SSB_CRMSYSTEM_Contact_ID = b.SSB_CRMSYSTEM_Contact_ID




--CLA Potential Suite Upgrade - Concert
SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, SUM(Total_EPay) AS SuiteUpgrade
INTO #UpgradesConcert
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.TK_TRANS_ITEM_EVENT tie ON dc.SSID = tie.CUSTOMER
LEFT JOIN SouthCarolina.dbo.TK_EVENT te ON tie.[EVENT] = te.[event]
WHERE te.CLASS = 'Concert'
GROUP BY dc.SSB_CRMSYSTEM_contact_ID
	UNION ALL
SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, SUM(fts.TotalRevenue) AS SuiteUpgrade
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
LEFT JOIN SouthCarolina.dbo.FactTicketSales fts ON dc.DimCustomerId = fts.DimCustomerId
LEFT JOIN SouthCarolina.dbo.DimEvent de ON fts.DimEventId = de.DimEventId
WHERE de.EventClass = 'Concert'
AND de.EventCode LIKE 'CL%'
GROUP BY dc.SSB_CRMSYSTEM_contact_ID

UPDATE a
SET a.SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c = SuiteUpgrade
FROM dbo.Contact_Custom a
JOIN (
	SELECT SSB_CRMSYSTEM_CONTACT_ID
		, CASE WHEN SUM(SuiteUpgrade) > 1100 THEN 1
			ELSE 0
			END AS SuiteUpgrade
	FROM #UpgradesConcert
	GROUP BY SSB_CRMSYSTEM_Contact_ID
	) b ON a.SSB_CRMSYSTEM_Contact_ID = b.SSB_CRMSYSTEM_Contact_ID;



--------------------------------------------------Student Fields--------------------------------------------------
UPDATE a
SET   SSB_CRMSYSTEM_Student_Class_Standing__c = s.other_info_9
	, SSB_CRMSYSTEM_Student_Completed_Hours__c = s.other_info_10
	, SSB_CRMSYSTEM_Student_Semester_Hours__c = s.other_info_13
	, SSB_CRMSYSTEM_Student_College__c = s.other_info_17
	, SSB_CRMSYSTEM_Student_Housing__c = s.other_info_18
FROM dbo.Contact_Custom a (NOLOCK)
INNER JOIN (
		SELECT dc.SSB_CRMSYSTEM_CONTACT_ID
		, CASE WHEN c.Other_info_9 = '' THEN NULL 
			   ELSE c.Other_info_9 
			   END AS Other_info_9
		, CASE WHEN c.Other_info_10 = '' THEN NULL
					ELSE c.Other_info_10 END AS Other_info_10
		, CASE WHEN c.Other_info_13 = '' THEN NULL
			   ELSE c.Other_info_13 END  AS Other_info_13
		, CASE WHEN c.Other_info_17 = '' THEN NULL ELSE c.Other_info_17 END AS Other_info_17
		, CASE WHEN c.Other_info_18 = '' THEN NULL ELSE c.Other_info_18 END AS Other_info_18
		FROM SouthCarolina.ods.TM_CUST c (NOLOCK)
		INNER JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc 
			ON c.acct_id = dc.AccountId AND dc.SourceSystem = 'TM' AND dc.CustomerType = 'Primary'
		WHERE dc.AccountType = 'Student'
		AND dc.SSB_CRMSYSTEM_PRIMARY_FLAG = '1'
		) s ON a.SSB_CRMSYSTEM_CONTACT_ID = s.SSB_CRMSYSTEM_CONTACT_ID;

--------------------------------------------------Turnkey--------------------------------------------------

----Turnkey 
--WITH MaxDate
--AS (
--	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, MAX(a.TurnkeyStandardBundleDate) TurnkeyStandardBundleDate
--	FROM SouthCarolina.ods.Turnkey_Acxiom a (NOLOCK)
--	JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON a.ProspectID = dc.SSID AND dc.SourceSystem = 'SouthCarolina_Turnkey'
--	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
--)

UPDATE a
SET a.SSB_CRMSYSTEM_Personicx_Cluster__c = b.PersonicxCluster
, a.SSB_CRMSYSTEM_PresenceofChildren__c = b.PresenceofChildren
, a.household_income__c = b.Income_EstimatedHousehold
, a.SSB_CRMSYSTEM_Net_Worth__c = b.NetWorth
, a.[SSB_CRMSYSTEM_Football_Priority__c] = b.FootballPriority
, a.[SSB_CRMSYSTEM_Football_Priority_Date__c] = CASE WHEN b.FootballPriorityDate = '1900-01-01' THEN NULL ELSE b.FootballPriorityDate END
FROM dbo.Contact_Custom a (NOLOCK)
JOIN (
	SELECT DISTINCT dc.SSB_CRMSYSTEM_CONTACT_ID, a.PersonicxCluster
	, a.PresenceofChildren, a.Income_EstimatedHousehold, a.NetWorth
	, models.FootballPriority, CAST(models.FootballPriorityDate AS DATE) FootballPriorityDate
	,ROW_NUMBER() OVER (PARTITION BY dc.SSB_CRMSYSTEM_CONTACT_ID ORDER BY a.TurnkeyStandardBundleDate DESC) RN
	FROM SouthCarolina.ods.Turnkey_Acxiom a (NOLOCK)
	LEFT JOIN SouthCarolina.[ods].[Turnkey_Models] models (NOLOCK)
		ON a.AbilitecId = models.AbilitecID
	JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc ON a.ProspectID = dc.SSID AND dc.SourceSystem = 'SouthCarolina_Turnkey'
	--JOIN MaxDate md ON a.TurnkeyStandardBundleDate = a.TurnkeyStandardBundleDate AND md.SSB_CRMSYSTEM_CONTACT_ID = dc.SSB_CRMSYSTEM_CONTACT_ID
	WHERE ISNULL(a.AbilitecId, '') != ''
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID AND b.RN = '1'





--------------------------------------------------Donations--------------------------------------------------
--Last Donation Date--
UPDATE a
SET a.SSB_CRMSYSTEM_Last_Donation_Date__c = MaxDonationDate
, a.SSB_CRMSYSTEM_First_Donation_Date__c = FirstDonationDate
FROM dbo.Contact_custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID
	, CAST(MAX(don.donation_paid_datetime) AS DATE) MaxDonationDate
	, CAST(MIN(don.donation_paid_datetime) AS DATE) FirstDonationDate
	FROM (SELECT * FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId WHERE SourceSystem = 'TM') dc
	JOIN SouthCarolina.ods.TM_Donation don (NOLOCK)
		ON dc.AccountId = don.apply_to_acct_id
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID



/*
--Donor Warning Flag--
UPDATE a
SET a.SSB_CRMSYSTEM_Donor_Warning__c = b.Donor
FROM dbo.Contact_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID
		, MAX(CASE	WHEN don.apply_to_acct_id IS NOT NULL
							--OR dfl.[Booster No ] IS NOT NULL
						THEN 1
					ELSE 0
					END) AS Donor
	FROM southcarolina.dbo.vwDimCustomer_ModAcctId dc
	LEFT JOIN (
			SELECT *
			FROM SouthCarolina.ods.TM_Donation (NOLOCK)
			WHERE drive_year = 2018--@CurrentDriveYear
		) don ON dc.accountid = don.apply_to_acct_id
			AND dc.SourceSystem = 'TM' AND dc.CustomerType = 'Primary'
	--LEFT JOIN SouthCarolina.dbo.DonorFlagList dfl (NOLOCK)
	--	ON dc.AccountId = dfl.[Booster No ]
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID
*/

--Donor Warning Flag--
UPDATE a
SET a.SSB_CRMSYSTEM_Donor_Warning__c = ISNULL(b.Donor, 0)
FROM dbo.Contact_Custom a
LEFT JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, 1 AS Donor
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN (
			SELECT *
			FROM SouthCarolina.dbo.DonorFlagList_2018
		) don ON dc.accountid = don.[Booster No]
			AND dc.SourceSystem = 'TM' AND dc.CustomerType = 'Primary'
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID


--Consecutive years as a booster
UPDATE a
SET a.SSB_CRMSYSTEM_Consecutive_Years__c = b.ConsecutiveYears
FROM dbo.Contact_Custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, MAX(TRY_CAST(tc.other_info_3 AS DECIMAL(20,2))) ConsecutiveYears
    FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.TM_Cust tc (NOLOCK)
		ON dc.AccountId = tc.acct_id
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID



--Millennium ID
SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, ta.alt_acct_id MilleniumID
INTO #MilleniumID
FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
JOIN SouthCarolina.ods.TM_AltId ta ON dc.accountid = ta.acct_id
WHERE ta.alt_id_type = 'MLL'


UPDATE a
SET a.SSB_CRMSYSTEM_Millenium_ID__c = d.MilleniumID
FROM dbo.Contact_Custom a
JOIN (
	SELECT DISTINCT b.SSB_CRMSYSTEM_CONTACT_ID, 
		SUBSTRING(
			(
				SELECT ','+ a.MilleniumID  AS [text()]
				FROM #MilleniumID a
				WHERE a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID
				ORDER BY a.SSB_CRMSYSTEM_CONTACT_ID
				FOR XML PATH ('')
			), 2, 1000) [MilleniumID]
	FROM #MilleniumID b
	) d ON a.SSB_CRMSYSTEM_CONTACT_ID = d.SSB_CRMSYSTEM_CONTACT_ID

UPDATE a
SET a.[SSB_CRMSYSTEM_CY_Donation_Level__c] = ISNULL(don.Current_Donor_Level, 'NOT_CURRENT')
, a.[SSB_CRMSYSTEM_CY_Donation_Amount__c] = ISNULL(don.Current_Donor_Amount, 0)
, a.[SSB_CRMSYSTEM_CY_Donation_Upsell__c] = ISNULL(don.Upsell_Amount, 0)
FROM dbo.Contact_Custom a
LEFT JOIN (
	SELECT DISTINCT dc.SSB_CRMSYSTEM_CONTACT_ID, dc.SSB_CRMSYSTEM_PRIMARY_FLAG, dc.FirstName, dc.LastName
	, dl.acct_id
	, current_donor_level AS Current_Donor_Level
	, qual_amount AS Current_Donor_Amount
	, amount_to_next_donor_Level AS Upsell_Amount
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.TM_CustDonorLevel dl (NOLOCK)
		ON dc.AccountId = dl.acct_id
		AND dc.SourceSystem = 'TM' 
		AND dc.CustomerType = 'Primary'
	WHERE (dl.drive_year = dl.current_drive_year AND drive_year = '2018')
	OR (donor_level_set_name = 'Lifetime' AND drive_year IS NOT NULL)
	AND dc.SSB_CRMSYSTEM_PRIMARY_FLAG = '1'
			) don ON a.SSB_CRMSYSTEM_CONTACT_ID = don.SSB_CRMSYSTEM_CONTACT_ID


-- Contact Email --
/*	Since Emma and Salesforce are synced, if an Emma contact updates their email address on the
	front end that email address needs to remain on the contact and not be overwritten if there
	is a different email in the EmailPrimary field on mdm.CompositeRecord.
*/
UPDATE a
SET a.EmailPrimary = b.Email
--SELECT *
FROM dbo.Contact a
JOIN (
		SELECT DISTINCT ssbid.SSB_CRMSYSTEM_CONTACT_ID, pc.Email, 1 AS EmailIsUpdated
			, RANK() OVER(PARTITION BY ssbid.SSB_CRMSYSTEM_CONTACT_ID ORDER BY pc.Email_LastModifiedDate__c DESC, pc.CreatedDate) xRank
		FROM SouthCarolina_Reporting.prodcopy.Contact pc (NOLOCK)
		JOIN SouthCarolina.dbo.DimCustomer dc (NOLOCK)
			ON pc.Id = dc.SSID
			AND dc.SourceSystem = 'SouthCarolina PC_SFDC Contact'
		JOIN SouthCarolina.dbo.dimcustomerssbid ssbid (NOLOCK)
			ON dc.DimCustomerId = ssbid.DimCustomerId
		WHERE pc.Email_LastModifiedDate__c IS NOT NULL
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID
		AND b.xRank = 1



--------------------------------------------------Miscellaneous--------------------------------------------------
SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID, MIN(xrank.ranking) ContactRank
INTO #ContactRanks
FROM SouthCarolina.dbo.DimCustomerSSBID ssbid
JOIN SouthCarolina.mdm.PrimaryFlagRanking_Contact xrank
	ON ssbid.DimCustomerId = xrank.dimcustomerid
WHERE xrank.sourcesystem = 'TM'
GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID, xrank.sourcesystem


--Men's Basketball Seat Selection--
UPDATE a
SET a.SSB_Mens_Basketball_Seat_Selection = b.other_info_1
FROM dbo.Contact_Custom a
LEFT JOIN (
		SELECT contrank.SSB_CRMSYSTEM_CONTACT_ID, cust.other_info_1
		FROM SouthCarolina.mdm.PrimaryFlagRanking_Contact contrank (NOLOCK)
		JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc (NOLOCK)
			ON contrank.dimcustomerid = dc.DimCustomerId
		JOIN SouthCarolina.ods.TM_Cust cust (NOLOCK)
			ON dc.SSID = CONCAT(cust.acct_id, ':', cust.cust_name_id)
			AND dc.SourceSystem = 'TM'
		JOIN #ContactRanks xrank
			ON xrank.SSB_CRMSYSTEM_CONTACT_ID = contrank.SSB_CRMSYSTEM_CONTACT_ID
			AND xrank.ContactRank = contrank.ranking		
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID


--Football First Seat Selection--
UPDATE a
SET a.SSB_Football_First_Seat_Selection = b.other_info_4
FROM dbo.Contact_Custom a
LEFT JOIN (
		SELECT contrank.SSB_CRMSYSTEM_CONTACT_ID, cust.other_info_4
		FROM SouthCarolina.mdm.PrimaryFlagRanking_Contact contrank (NOLOCK)
		JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc (NOLOCK)
			ON contrank.dimcustomerid = dc.DimCustomerId
		JOIN SouthCarolina.ods.TM_Cust cust (NOLOCK)
			ON dc.SSID = CONCAT(cust.acct_id, ':', cust.cust_name_id)
			AND dc.SourceSystem = 'TM'
		JOIN #ContactRanks xrank
			ON xrank.SSB_CRMSYSTEM_CONTACT_ID = contrank.SSB_CRMSYSTEM_CONTACT_ID
			AND xrank.ContactRank = contrank.ranking		
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID



--Football Second Seat Selection--
UPDATE a
SET a.SSB_Football_Second_Seat_Selection = b.other_info_5
FROM dbo.Contact_Custom a
LEFT JOIN (
		SELECT contrank.SSB_CRMSYSTEM_CONTACT_ID, cust.other_info_5
		FROM SouthCarolina.mdm.PrimaryFlagRanking_Contact contrank (NOLOCK)
		JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc (NOLOCK)
			ON contrank.dimcustomerid = dc.DimCustomerId
		JOIN SouthCarolina.ods.TM_Cust cust (NOLOCK)
			ON dc.SSID = CONCAT(cust.acct_id, ':', cust.cust_name_id)
			AND dc.SourceSystem = 'TM'
		JOIN #ContactRanks xrank
			ON xrank.SSB_CRMSYSTEM_CONTACT_ID = contrank.SSB_CRMSYSTEM_CONTACT_ID
			AND xrank.ContactRank = contrank.ranking		
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID



--Football Parking Selection--
UPDATE a
SET a.SSB_Football_Parking_Selection = b.other_info_6
FROM dbo.Contact_Custom a
LEFT JOIN (
		SELECT contrank.SSB_CRMSYSTEM_CONTACT_ID, cust.other_info_6
		FROM SouthCarolina.mdm.PrimaryFlagRanking_Contact contrank (NOLOCK)
		JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc (NOLOCK)
			ON contrank.dimcustomerid = dc.DimCustomerId
		JOIN SouthCarolina.ods.TM_Cust cust (NOLOCK)
			ON dc.SSID = CONCAT(cust.acct_id, ':', cust.cust_name_id)
			AND dc.SourceSystem = 'TM'
		JOIN #ContactRanks xrank
			ON xrank.SSB_CRMSYSTEM_CONTACT_ID = contrank.SSB_CRMSYSTEM_CONTACT_ID
			AND xrank.ContactRank = contrank.ranking		
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID



--Women's Basketball Times--
UPDATE a
SET a.SSB_Womens_Basketball_Times = b.other_info_14
FROM dbo.Contact_Custom a
LEFT JOIN (
		SELECT contrank.SSB_CRMSYSTEM_CONTACT_ID, cust.other_info_14
		FROM SouthCarolina.mdm.PrimaryFlagRanking_Contact contrank (NOLOCK)
		JOIN SouthCarolina.dbo.vwDimCustomer_ModAcctId dc (NOLOCK)
			ON contrank.dimcustomerid = dc.DimCustomerId
		JOIN SouthCarolina.ods.TM_Cust cust (NOLOCK)
			ON dc.SSID = CONCAT(cust.acct_id, ':', cust.cust_name_id)
			AND dc.SourceSystem = 'TM'
		JOIN #ContactRanks xrank
			ON xrank.SSB_CRMSYSTEM_CONTACT_ID = contrank.SSB_CRMSYSTEM_CONTACT_ID
			AND xrank.ContactRank = contrank.ranking		
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID


--SSB Market--
UPDATE a
SET a.SSB_Market = b.AddressPrimaryCBSA
FROM dbo.Contact_Custom a
LEFT JOIN (
		SELECT SSB_CRMSYSTEM_CONTACT_ID, AddressPrimaryCBSA
		FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId
		WHERE SSB_CRMSYSTEM_PRIMARY_FLAG = 1	
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID


/******** OLD DONOR FIELD SETUP - commented out 3/30/2018 AMEITIN

--Current Year Donation Level--
DECLARE @CYFund NVARCHAR(100)
DECLARE @CYLifetime NVARCHAR(100)

SET @CYFund = CONCAT('GC',CAST(YEAR(GETDATE()) AS NVARCHAR(5)))
SET @CYLifetime = CONCAT('LFPY',RIGHT(CAST(YEAR(GETDATE()) AS NVARCHAR(5)),2));


WITH MaxLevel (SSB_CRMSYSTEM_CONTACT_ID, Qual_Amount)
AS (
	SELECT DISTINCT dc.SSB_CRMSYSTEM_CONTACT_ID, MAX(dl.qual_amount) Qual_Amount
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.TM_CustDonorLevel dl ON dc.AccountId = dl.acct_id
		AND dc.SourceSystem = 'TM'
	WHERE dl.drive_year = dl.current_drive_year
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
)

UPDATE a
SET a.SSB_CRMSYSTEM_CY_Donation_Level__c = b.donor_level
FROM dbo.Contact_Custom a
JOIN (
	SELECT DISTINCT dc.SSB_CRMSYSTEM_CONTACT_ID, COALESCE(dl.honorary_donor_level, dl.donor_level) donor_level
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.TM_CustDonorLevel dl ON dc.AccountId = dl.acct_id
		AND dc.SourceSystem = 'TM'
	JOIN MaxLevel ml ON dc.SSB_CRMSYSTEM_CONTACT_ID = ml.SSB_CRMSYSTEM_CONTACT_ID
		AND dl.qual_amount = ml.Qual_Amount
	WHERE dl.drive_year = dl.current_drive_year
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID


--Current Year Donation Amount--
UPDATE a
SET a.SSB_CRMSYSTEM_CY_Donation_Amount__c = ISNULL(b.DonationAmount, 0)
FROM dbo.contact_custom a
LEFT JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, SUM(donation_paid_amount) DonationAmount
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.tm_donation donor (NOLOCK)
		ON dc.AccountId = donor.apply_to_acct_id
	WHERE fund_name IN (@CYFund, @CYLifetime)
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.ssb_crmsystem_contact_id = b.SSB_CRMSYSTEM_CONTACT_ID


--Current Year Donation Upsell
DECLARE @PYFund NVARCHAR(100)
DECLARE @PYLifetime NVARCHAR(100)

SET @PYFund = CONCAT('GC',CAST(YEAR(GETDATE())-1 AS NVARCHAR(5)))
SET @PYLifetime = CONCAT('LFPY',RIGHT(CAST(YEAR(GETDATE())-1 AS NVARCHAR(5)),2))


UPDATE a
SET a.SSB_CRMSYSTEM_CY_Donation_Upsell__c = b.DonationUpsell
FROM dbo.contact_custom a
JOIN (
	SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, (SUM(d1.pledge_amount-d1.owed_amount) - SUM(d2.pledge_amount - d2.owed_amount)) DonationUpsell
	FROM SouthCarolina.dbo.vwDimCustomer_ModAcctId dc
	JOIN SouthCarolina.ods.tm_donation d1 ON dc.AccountId = d1.apply_to_acct_id
	JOIN SouthCarolina.ods.tm_donation d2 ON dc.AccountId = d2.apply_to_acct_id
	WHERE d1.fund_desc IN (@CYFund, @CYLifetime)
	AND d2.fund_desc IN (@PYFund, @PYLifetime)
	GROUP BY dc.SSB_CRMSYSTEM_CONTACT_ID
	) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID

************/



EXEC  [dbo].[sp_CRMLoad_Contact_ProcessLoad_Criteria];

END

GO
