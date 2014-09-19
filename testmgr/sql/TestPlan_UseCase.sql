--

ALTER TABLE testmgr_testplan_usecase
ADD COLUMN relevance VARCHAR(6) DEFAULT 'MUST';


ALTER TABLE testmgr_testplan_usecase
  ADD CONSTRAINT testplan_usecase_relevance CHECK (relevance IN ('MUST', 'SHOULD', 'MAY', 'N/A'));


--
-- Add Triggers/Rules to make v_testplan_usecase behave like a table with respect to inters/delete
--

CREATE FUNCTION v_testplan_usecase_dml() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   DECLARE
         ctl_id INTEGER;
   BEGIN
      IF TG_OP = 'UPDATE' THEN
         UPDATE testmgr_testplan_usecase SET relevance=NEW.relevance
                WHERE id=OLD.id;
         RETURN NEW;
      END IF;
      RETURN NEW;
    END;
$$;




CREATE TRIGGER v_testplan_usecase_dml_trig INSTEAD OF UPDATE ON v_testmgr_testplan_usecase FOR EACH ROW EXECUTE PROCEDURE v_testplan_usecase_dml();

CREATE RULE v_testmgr_testplan_usecase_del AS ON DELETE TO v_testmgr_testplan_usecase
    DO INSTEAD
    DELETE FROM testmgr_testplan_usecase
     WHERE id = OLD.id;