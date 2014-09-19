ALTER TABLE testmgr_testplan
  DROP CONSTRAINT IF EXISTS testplan_check_targettype;
ALTER TABLE testmgr_testplan
  ADD CONSTRAINT testplan_check_targettype CHECK (target_type IN ('DS', 'IDP', 'SP'));
SELECT pg_catalog.setval('testmgr_testplan_id_seq', 1, true);


--
CREATE OR REPLACE FUNCTION update_testplan_count() RETURNS TRIGGER AS $update_testplan_count$
BEGIN
	IF TG_OP = 'INSERT' THEN
		UPDATE testmgr_samlprofile SET testplan_count = testplan_count + 1 WHERE id = NEW.samlprofile_id;
	ELSIF TG_OP = 'DELETE' THEN
		UPDATE testmgr_samlprofile SET testplan_count = testplan_count - 1 WHERE id = OLD.samlprofile_id;
	ELSIF TG_OP = 'UPDATE' AND NEW.samlprofile_id <> OLD.samlprofile_id THEN
		UPDATE testmgr_samlprofile SET testplan_count = testplan_count - 1 WHERE id = OLD.samlprofile_id;
		UPDATE testmgr_samlprofile SET testplan_count = testplan_count + 1 WHERE id = NEW.samlprofile_id;
	END IF;
  RETURN NULL;
END;
$update_testplan_count$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS  update_testplan_count_on_samlprofile ON testmgr_testplan;
CREATE TRIGGER update_testplan_count_on_samlprofile
AFTER INSERT OR DELETE OR UPDATE ON testmgr_testplan FOR EACH ROW
	EXECUTE PROCEDURE update_testplan_count();

-- add initial data
SELECT 'testmgr_testplan.sql: load data';
INSERT INTO testmgr_testplan(id, name, version, target_type, samlprofile_id, owner)
            VALUES (1, 'PVP2-S 2.1 Basis IDP', '0.1', 'IDP', 1, 'rhoerbe');
INSERT INTO testmgr_testplan(id, name, version, target_type, samlprofile_id, owner)
            VALUES (2, 'PVP2-S 2.1 Basis SP', '0.1', 'SP', 1, 'rhoerbe');



