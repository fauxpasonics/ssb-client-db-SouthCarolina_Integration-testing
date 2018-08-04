SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [MERGEPROCESS_New].[vw_Cust_Account_ColumnLogic]
AS
SELECT  ID,
		Losing_ID AS Losing_ID
FROM    ( SELECT    Winning_ID AS ID ,
					Losing_ID AS Losing_ID                
          FROM      ( SELECT    *
                      FROM      ( SELECT    'Winning' xtype ,
                                            a.Winning_ID ,
											a.Losing_ID ,					
                                            b.*
                                  FROM      [MERGEPROCESS_New].[Queue] a
                                            JOIN Prodcopy.vw_Account b ON a.Winning_ID = b.ID
											WHERE a.ObjectType = 'Account'
                                  UNION ALL
                                  SELECT    'Losing' xtype ,
                                            a.Winning_ID ,
											a.Losing_ID ,					
                                            b.*
                                  FROM      [MERGEPROCESS_New].[Queue] a
                                            JOIN Prodcopy.vw_Account b ON a.Losing_ID = b.ID
											WHERE a.ObjectType = 'Account'
                                ) x
                    ) dta
          GROUP BY  Winning_ID ,
					Losing_ID					
        ) aa

		--WHERE (aa.Losing_ID =  '0014100000L3ad2AAB' AND aa.ID = '0014100000IEdazAAD')





GO
