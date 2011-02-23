--
-- drop table JobResults
--
drop table JobResults;

--
-- remove flags from JobQueue
--
ALTER TABLE JobQueue DROP COLUMN UPSTREAM;
ALTER TABLE JobQueue DROP COLUMN CACHERESULT;
