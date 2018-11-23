CREATE PROC [Webtrends].[PagesCampaignIDFix]
AS
BEGIN
    update a
    set CampaignID = null
    from Staging.PageViews a
    left join
                (
                select SessionID, CampaignID, min(EventSequenceNumber) as StartEventSequence
                from Staging.PageViews
                where SessionID in (    -- So we're only considering sessions which have a CampaignID somewhere in them
                                    select sessionid
                                    from Staging.PageViews
                                    where CampaignID is not null group by SessionID )
                      and datediff(d, EventDateTime, getdate()) <= 5
                group by SessionID, CampaignID
                having CampaignID is not null
                ) b on a.SessionID = b.SessionID and a.EventSequenceNumber = b.StartEventSequence
    where datediff(d, a.EventDateTime, getdate()) <= 5
      and b.StartEventSequence is null;
end