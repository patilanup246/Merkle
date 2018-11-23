CREATE ROLE [db_executor]
    AUTHORIZATION [dbo];




GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\ssisproxy_vtwctest];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\vtwc_ms_developer_operator];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\vtwc_ms_qa_administrator];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\nbutler];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\usinari];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\rwjackson];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\vtwc_ms_developer_administrator];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\vtwc_ms_campaign_administrator];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\dmani];


--GO
--ALTER ROLE [db_executor] ADD MEMBER [VTWC_API];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\jdiaz];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\sforster];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\jezcox];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\mlynd];


GO
ALTER ROLE [db_executor] ADD MEMBER [PCLC0\gnewsome];


GO
ALTER ROLE [db_executor] ADD MEMBER [VTWC_API];

