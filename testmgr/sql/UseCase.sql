--
CREATE OR REPLACE FUNCTION update_usecase_count_on_requirement() RETURNS TRIGGER AS $update_usecase_count_req$
BEGIN
  -- RAISE NOTICE 'update_usecase_count() 000';
	IF TG_OP = 'INSERT' THEN
		UPDATE requmgr_requirement SET usecase_count = usecase_count + 1 WHERE id = NEW.requirement_id;
	ELSIF TG_OP = 'DELETE' THEN
		UPDATE requmgr_requirement SET usecase_count = usecase_count - 1 WHERE id = OLD.requirement_id;
	ELSIF TG_OP = 'UPDATE' AND NEW.requirement_id <> OLD.requirement_id THEN
		UPDATE requmgr_requirement SET usecase_count = usecase_count - 1 WHERE id = OLD.requirement_id;
		UPDATE requmgr_requirement SET usecase_count = usecase_count + 1 WHERE id = NEW.requirement_id;
	END IF; --
  RETURN NULL; --
END; --
$update_usecase_count_req$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS  update_usecase_count_on_requirement ON testmgr_usecase;
CREATE TRIGGER update_usecase_count_on_requirement
AFTER INSERT OR DELETE OR UPDATE ON testmgr_usecase FOR EACH ROW
	EXECUTE PROCEDURE update_usecase_count_on_requirement();
