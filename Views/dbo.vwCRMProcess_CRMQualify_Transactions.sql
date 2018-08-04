SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwCRMProcess_CRMQualify_Transactions]
AS
SELECT b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, DimCustomerId
, [b].[SourceSystem]
, MAX(a.MaxTransDate) MaxTransDate
--SELECT a.SSID, a.MaxTransDate, a.Team
--SELECT * 
FROM [stg].[CRMProcess_RecentTrans_SSIDs] a 
INNER JOIN [dbo].[vwDimCustomer_ModAcctId] b ON b.SSID = a.SSID
WHERE b.SSB_CRMSYSTEM_ACCT_ID IS NOT NULL
GROUP BY b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, DimCustomerId
, b.Sourcesystem

GO
