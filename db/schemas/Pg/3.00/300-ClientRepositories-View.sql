
create or replace view ClientRepositories
as
SELECT c.id AS client_id
       c.guid,
       c.secret,
       c.target AS client_target,
       c.hostname,
       c.regtype,
       c.lastcontact
       p.product,
       p.version,
       p.rel,
       p.arch,
       pr.optional,
       rp.id AS crepository_id,
       rp.name AS repository_name,
       rp.description AS repository_description,
       rp.target AS repository_target,
       rp.localpath,
       rp.repotype,
       rp.autorefresh,
       rp.domirror,
       rp.mirrorable
  FROM Clients c
  JOIN Registration r ON r.client_id = c.id
  JOIN Products p ON p.id = r.product_id
  JOIN ProductRepositories pr ON pr.product_id = p.id
  JOIN Repositories rp ON rp.id = pr.repository_id
;
