SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE	 VIEW [dbo].[vwCRMLoad_Custom_Transaction__c]
AS 

SELECT
'Ticket Order # ' + CAST(t.OrderNumber__c AS NVARCHAR(100)) AS Name 
,  t.Team__c
, t.TicketingAccountID__c
, t.SeasonName__c
, t.FactTicketSalesID__c
, t.OrderNumber__c
, t.OrderLine__c
, t.OrderDate__c
, t.Item__c
, t.ItemName__c
, t.EventDate__c
, t.PriceCode__c
, t.IsComp__c
, t.PromoCode__c
, t.QtySeat__c
, t.SectionName__c
, t.RowName__c
, t.Seat__c
, t.SeatPrice__c
, t.Total__c
, t.OwedAmount__c														 -- , pctt.OwedAmount__c
, t.PaidAmount__c														 -- , pctt.PaidAmount__c
, LEFT(t.SalesRep__c,255) AS SalesRep__c								 -- , pctt.SalesRep__c
, a.Id AS ContactID__c													 -- , pctt.contactid__c
, a.SSB_CRMSYSTEM_CONTACT_ID__c

--SELECT *
FROM stg.CRMLoad_TicketTransactions t
INNER JOIN dbo.[vwDimCustomer_ModAcctId] dimcust WITH (NOLOCK) ON t.TicketingAccountID__c = [dimcust].AccountId AND dimcust.CustomerType = 'Primary' AND [dimcust].[SourceSystem] = 'TM' --updateme
INNER JOIN dbo.vwCRMProcess_DeDupProdCopyContact_ByGUID a WITH (NOLOCK) ON dimcust.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID__c AND a.Rank = 1 
LEFT JOIN SouthCarolina_Reporting.prodcopy.Transaction__c pctt WITH (NOLOCK) ON pctt.FactTicketSalesID__c = t.FactTicketSalesID__c --updateme for TM_Transaction (only because Oregon had both Pac and TM)
			
--To catch up failures with missing fields
--INNER join dbo.TicketTrans_ErrorOutput e ON
--e.Order_Line_ID__c = t.Order_Line_ID__c
--AND e.Sequence__c =  t.Sequence__c
--AND e.account__c =   t.account__c

WHERE pctt.id IS NULL

	OR pctt.OwedAmount__c != t.OwedAmount__c
	OR pctt.PaidAmount__c != t.PaidAmount__c
	OR ISNULL(LEFT(pctt.SalesRep__c,255),'') != ISNULL(t.SalesRep__c,'')
	OR ISNULL(pctt.ContactID__c,'') != ISNULL(a.Id,'')
		OR ISNULL(pctt.SeasonName__c,'') != ISNULL(t.SeasonName__c,'')






GO
