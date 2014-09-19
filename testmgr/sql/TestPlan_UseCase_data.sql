CREATE OR REPLACE FUNCTION v_testplan_usecase_dml()
  RETURNS trigger AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION v_control_dml()
  OWNER TO rhoerbe;




INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 3);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 4);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 5);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 6);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 7);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 8);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 9);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 11);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 12);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 13);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 14);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 15);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 16);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 17);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 18);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 19);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 28);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 29);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 30);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 31);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 32);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 33);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 34);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 35);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 36);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 37);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 39);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 40);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 41);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 42);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 43);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 44);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 45);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 46);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 47);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 48);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 49);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 50);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 51);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 52);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 53);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 54);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 55);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 56);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 57);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 58);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 59);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 60);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 62);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 63);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 64);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 65);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 66);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 67);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 68);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 70);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 71);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 72);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 74);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 75);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 76);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 77);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 78);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 79);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 80);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 85);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 86);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 87);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 88);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 89);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 90);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 93);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 94);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 95);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 96);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 97);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 98);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 99);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 100);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 101);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 102);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 103);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 104);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 105);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 106);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 107);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 108);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 109);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 110);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 111);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 112);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 113);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 114);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 115);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 116);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 117);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 118);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 120);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 121);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 122);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 123);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 124);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 125);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 126);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 127);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 128);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 129);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 130);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 131);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 132);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 133);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 134);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 135);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 136);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 138);
INSERT INTO testplan_usecase(testplan_id, usecase_id) VALUES (1, 139);
