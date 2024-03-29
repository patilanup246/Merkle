USE [CEM]
GO
/****** Object:  UserDefinedFunction [Migration].[SplitStringForLocation]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Migration].[SplitStringForLocation]
(
    @string        NVARCHAR(MAX),
	@seqno         INTEGER,
	@identifer     INTEGER,
	@qualifier     UNIQUEIDENTIFIER,
    @delimiter     NVARCHAR(5),
	@outboundind   BIT
)  
RETURNS TABLE
AS
RETURN
(
	SELECT TOP 1 ID,Value
    FROM [Staging].[SplitStringToTable] (@string,@delimiter)
    WHERE ID > (SELECT COUNT(1)
                FROM Migration.MSD_SalesOrderJourney
                WHERE salesorderid = @qualifier
                AND   leg_seqno < @seqno
				AND   leg_outboundind =  @outboundind
                AND   SUBSTRING(leg_rsid,1,2) = 'GR')
)

GO
