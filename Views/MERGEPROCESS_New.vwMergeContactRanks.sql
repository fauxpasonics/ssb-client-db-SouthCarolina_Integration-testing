SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [MERGEPROCESS_New].[vwMergeContactRanks]

AS

SELECT a.SSBID
	, c.ID
	--Add in custom ranking here
	,ROW_NUMBER() OVER(PARTITION BY SSBID ORDER BY CASE WHEN d.FirstName = 'SSB' THEN 0 WHEN d.IsActive = 0 THEN 1 ELSE 99 END DESC, c.createddate) xRank
FROM MERGEPROCESS_New.DetectedMerges a
JOIN dbo.vwDimCustomer_ModAcctID b 
	ON a.SSBID = b.SSB_CRMSYSTEM_Contact_ID
	AND a.MergeType = 'Contact'
JOIN Prodcopy.vw_Contact c
	ON b.SSID = ID
JOIN [ProdCopy].[User] d
	ON c.OwnerId = d.Id
WHERE MergeComplete = 0;
GO
