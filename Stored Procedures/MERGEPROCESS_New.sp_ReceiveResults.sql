SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [MERGEPROCESS_New].[sp_ReceiveResults]
  @PK_QueueID VARCHAR(50)
  , @ErrorCode varchar(8000)
  , @ErrorDescription varchar(8000)
  ,@Master_ID varchar(50)
  ,@Slave_ID varchar(50)
AS 
BEGIN
--MergeProcess.sp_ReceiveResults 42952, '',''

INSERT INTO MergeProcess_New.[RecieveResults]
        ( [PK_MergeID] ,
          [ErrorCode] ,
          [ErrorDescription] ,
          [DateInserted],
		  Winning_ID
		  ,Losing_ID
        )
VALUES  ( @PK_QueueID , -- PK_QueueID - int
          @ErrorCode , -- ErrorCode - varchar(8000)
          @ErrorDescription , -- ErrorDescription - varchar(8000)
          GETDATE()  -- DateInserted - datetime
		  ,@Master_ID
		  ,@Slave_ID
        )

UPDATE a
SET MergeComplete = 1
,MergeComment = 'Merge Completed by SSB ' + CAST(CAST(GETDATE() as DATE) as varchar)
FROM [MERGEProcess_New].[DetectedMerges] a with (nolock)
JOIN [MERGEProcess_New].[Queue] b with (nolock) on a.PK_MergeID =b.FK_MergeID
WHERE b.Winning_ID = @Master_ID
AND b.Losing_ID = @Slave_ID 
AND ISNULL(@ErrorCode,'') = ''







END




GO
