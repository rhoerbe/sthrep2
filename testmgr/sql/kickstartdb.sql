BEGIN;
CREATE TABLE "featuregroup" (
    "id" serial NOT NULL PRIMARY KEY,
    "fg_id" varchar(6) NOT NULL UNIQUE,
    "name" varchar(50) NOT NULL UNIQUE
)
;
CREATE TABLE "feature" (
    "id" serial NOT NULL PRIMARY KEY,
    "f_id" varchar(8) NOT NULL,
    "name" varchar(50) NOT NULL,
    "featuregroup_id" integer NOT NULL REFERENCES "featuregroup" ("id") DEFERRABLE INITIALLY DEFERRED,
    UNIQUE ("featuregroup_id", "f_id")
)
;
CREATE TABLE "reference" (
    "id" serial NOT NULL PRIMARY KEY,
    "name" varchar(20) NOT NULL,
    "version" varchar(20) NOT NULL,
    UNIQUE ("name", "version")
)
;
CREATE TABLE "requirement" (
    "id" serial NOT NULL PRIMARY KEY,
    "name" varchar(250) NOT NULL,
    "feature_id" integer NOT NULL REFERENCES "feature" ("id") DEFERRABLE INITIALLY DEFERRED,
    "operation_count" integer NOT NULL,
    "reference_id" integer REFERENCES "reference" ("id") DEFERRABLE INITIALLY DEFERRED,
    "reference_location" varchar(40),
    UNIQUE ("feature_id", "name")
)
;
CREATE TABLE "samlprofile_requirements" (
    "id" serial NOT NULL PRIMARY KEY,
    "samlprofile_id" integer NOT NULL,
    "requirement_id" integer NOT NULL REFERENCES "requirement" ("id") DEFERRABLE INITIALLY DEFERRED,
    UNIQUE ("samlprofile_id", "requirement_id")
)
;
CREATE TABLE "samlprofile" (
    "id" serial NOT NULL PRIMARY KEY,
    "name" varchar(20) NOT NULL UNIQUE,
    "description" text,
    "samlprofileid" integer,
    "testplan_count" integer NOT NULL
)
;
ALTER TABLE "samlprofile_requirements" ADD CONSTRAINT "samlprofile_id_refs_id_e1449e4f" FOREIGN KEY ("samlprofile_id") REFERENCES "samlprofile" ("id") DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "samlprofile" ADD CONSTRAINT "samlprofileid_refs_id_ea28c785" FOREIGN KEY ("samlprofileid") REFERENCES "samlprofile" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE TABLE "testplan_operation" (
    "id" serial NOT NULL PRIMARY KEY,
    "testplan_id" integer NOT NULL,
    "operation_id" integer NOT NULL,
    UNIQUE ("testplan_id", "operation_id")
)
;
CREATE TABLE "testplan" (
    "id" serial NOT NULL PRIMARY KEY,
    "name" varchar(50) NOT NULL UNIQUE,
    "version" varchar(10) NOT NULL,
    "target_type" varchar(3) NOT NULL,
    "samlprofile_id" integer NOT NULL REFERENCES "samlprofile" ("id") DEFERRABLE INITIALLY DEFERRED,
    "owner" varchar(50) NOT NULL
)
;
ALTER TABLE "testplan_operation" ADD CONSTRAINT "testplan_id_refs_id_3235cf6f" FOREIGN KEY ("testplan_id") REFERENCES "testplan" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE TABLE "operation" (
    "id" serial NOT NULL PRIMARY KEY,
    "operation_id" varchar(10) NOT NULL UNIQUE,
    "name" varchar(250) NOT NULL UNIQUE,
    "version" varchar(10),
    "description" text,
    "target_type" varchar(3) NOT NULL,
    "expected_behavior" text NOT NULL,
    "requirement_id" integer NOT NULL REFERENCES "requirement" ("id") DEFERRABLE INITIALLY DEFERRED
)
;
ALTER TABLE "testplan_operation" ADD CONSTRAINT "operation_id_refs_id_baaa8636" FOREIGN KEY ("operation_id") REFERENCES "operation" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE TABLE "testplancaseassignment" (
    "id" serial NOT NULL PRIMARY KEY,
    "profiletestplan_id" integer NOT NULL REFERENCES "testplan" ("id") DEFERRABLE INITIALLY DEFERRED,
    "operation_id" integer NOT NULL REFERENCES "operation" ("id") DEFERRABLE INITIALLY DEFERRED,
    "relevance" varchar(6) NOT NULL,
    UNIQUE ("profiletestplan_id", "operation_id")
)
;
CREATE TABLE "testtargetinterface" (
    "id" serial NOT NULL PRIMARY KEY,
    "name" varchar(50) NOT NULL UNIQUE,
    "version" varchar(50) NOT NULL,
    "target_type" varchar(3) NOT NULL
)
;
CREATE TABLE "testclass" (
    "id" serial NOT NULL PRIMARY KEY,
    "name" varchar(50) NOT NULL UNIQUE,
    "version" varchar(50) NOT NULL,
    "code" text NOT NULL,
    "testtargetinterface_id" integer NOT NULL REFERENCES "testtargetinterface" ("id") DEFERRABLE INITIALLY DEFERRED
)
;
CREATE TABLE "pretest_testclasses" (
    "id" serial NOT NULL PRIMARY KEY,
    "pretest_id" integer NOT NULL,
    "testclass_id" integer NOT NULL REFERENCES "testclass" ("id") DEFERRABLE INITIALLY DEFERRED,
    UNIQUE ("pretest_id", "testclass_id")
)
;
CREATE TABLE "pretest" (
    "id" serial NOT NULL PRIMARY KEY,
    "version" varchar(10) NOT NULL,
    "operation_id" integer NOT NULL REFERENCES "operation" ("id") DEFERRABLE INITIALLY DEFERRED
)
;
ALTER TABLE "pretest_testclasses" ADD CONSTRAINT "pretest_id_refs_id_3c55f5e2" FOREIGN KEY ("pretest_id") REFERENCES "pretest" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE TABLE "samlrequest_testclasses" (
    "id" serial NOT NULL PRIMARY KEY,
    "samlrequest_id" integer NOT NULL,
    "testclass_id" integer NOT NULL REFERENCES "testclass" ("id") DEFERRABLE INITIALLY DEFERRED,
    UNIQUE ("samlrequest_id", "testclass_id")
)
;
CREATE TABLE "samlrequest" (
    "id" serial NOT NULL PRIMARY KEY,
    "name" varchar(50) NOT NULL UNIQUE,
    "version" varchar(10) NOT NULL,
    "operation_id" integer NOT NULL REFERENCES "operation" ("id") DEFERRABLE INITIALLY DEFERRED
)
;
ALTER TABLE "samlrequest_testclasses" ADD CONSTRAINT "samlrequest_id_refs_id_bc3e380" FOREIGN KEY ("samlrequest_id") REFERENCES "samlrequest" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE TABLE "posttest_testclasses" (
    "id" serial NOT NULL PRIMARY KEY,
    "posttest_id" integer NOT NULL,
    "testclass_id" integer NOT NULL REFERENCES "testclass" ("id") DEFERRABLE INITIALLY DEFERRED,
    UNIQUE ("posttest_id", "testclass_id")
)
;
CREATE TABLE "posttest" (
    "id" serial NOT NULL PRIMARY KEY,
    "version" varchar(10) NOT NULL
)
;
ALTER TABLE "posttest_testclasses" ADD CONSTRAINT "posttest_id_refs_id_5b10b1e2" FOREIGN KEY ("posttest_id") REFERENCES "posttest" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE TABLE "repmgr_userprofile_profiletestplan" (
    "id" serial NOT NULL PRIMARY KEY,
    "userprofile_id" integer NOT NULL,
    "testplan_id" integer NOT NULL REFERENCES "testplan" ("id") DEFERRABLE INITIALLY DEFERRED,
    UNIQUE ("userprofile_id", "testplan_id")
)
;
CREATE TABLE "repmgr_userprofile" (
    "id" serial NOT NULL PRIMARY KEY,
    "user_id" integer NOT NULL UNIQUE REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED,
    "test_flag" boolean NOT NULL
)
;
ALTER TABLE "repmgr_userprofile_profiletestplan" ADD CONSTRAINT "userprofile_id_refs_id_7b774054" FOREIGN KEY ("userprofile_id") REFERENCES "repmgr_userprofile" ("id") DEFERRABLE INITIALLY DEFERRED;
SELECT 'FeatureGroup.sql: load data';

INSERT INTO featuregroup (id, fg_id, name) VALUES (0, 'AssrQ', 'Assertion Query');

INSERT INTO featuregroup (id, fg_id, name) VALUES (1, 'AttrQ', 'Attribute Query');

INSERT INTO featuregroup (id, fg_id, name) VALUES (2, 'Attr', 'Attributes');

INSERT INTO featuregroup (id, fg_id, name) VALUES (3, 'ECP', 'ECP');

INSERT INTO featuregroup (id, fg_id, name) VALUES (4, 'MD', 'Metadata');

INSERT INTO featuregroup (id, fg_id, name) VALUES (5, 'Multi', 'Multiple');

INSERT INTO featuregroup (id, fg_id, name) VALUES (6, 'NamId', 'NameID Mapping');

INSERT INTO featuregroup (id, fg_id, name) VALUES (7, 'Net', 'Network');

INSERT INTO featuregroup (id, fg_id, name) VALUES (8, 'SLO', 'SLO');

INSERT INTO featuregroup (id, fg_id, name) VALUES (9, 'SSO', 'SSO');
SELECT 'Feature.sql: load data';

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (1, 'AssrQ',  'Assertion Query', 0);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (2, 'Attr!',  'Attribute Query', 1);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (3, 'ATeGov',  'Attribute Bundle/eGovToken', 2);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (4, 'NameFmt',  'Attribute name formats', 2);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (5, 'NamIdFmt',  'Name Identifier Formats', 2);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (6, 'MsgFlow',  'Message Flow', 3);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (7, 'AuthZ',  'MD authoritative', 4);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (8, 'CertEx',  'MD Certificate Exchange', 4);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (9, 'Cont',  'MD Contents', 4);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (10, 'MsgFlow',  'Message Flow', 5);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (11, 'NamIdMap',  'NameID Mapping', 6);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (12, 'Connect',  'Connectivity', 7);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (13, 'TLS',  'Endpoints MUST use TLS', 7);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (14, 'MsgFlow',  'Message Flow', 8);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (15, 'Requ',  'Request', 8);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (16, 'Resp',  'Response', 8);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (17, 'AuthnReq',  'Authn Request', 9);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (18, 'Disco',  'IDP Discovery Service Protocol Profile', 9);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (19, 'MsgFlow',  'Message Flow', 9);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (20, 'NamIdFmt',  'Name Identifier Formats', 9);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (21, 'Resp',  'Response', 9);

INSERT INTO feature (id, f_id, name, featuregroup_id) VALUES (22, 'Session',  'Session', 9);
SELECT 'Requirement.sql: load data';

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (1, 'serve assertion query', 1, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (2, 'serve attribute query', 2, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (3, 'MUST understand minimum set', 3, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (4, 'SHOULD understand "chained token" (delegator''s attributes)', 3, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (5, 'SHOULD understand optional attributes', 3, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (6, 'SHOULD use uri, basic or X500 attribute name formats', 4, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (7, 'MUST support persistent Nameid format', 5, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (8, 'SAML2 AuthnRequest using ECP and PAOS', 6, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (9, 'MD freshness', 7, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (10, 'MD Signature valid', 7, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (11, 'Load signature and TLS certificates from MD', 8, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (12, 'Valid roledescriptior exists', 9, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (13, 'Absolute basic SAML2 log in and out', 10, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (14, 'AuthnRequest and then an AssertionIDRequest', 10, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (15, 'AuthnRequest and then an AuthnQuery', 10, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (16, 'AssertionID Request', 11, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (17, 'ManageNameID Request', 11, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (18, 'NameIDMapping Request', 11, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (19, 'Setting the SP provided ID by using ManageNameID', 11, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (20, 'Simple NameID Mapping request', 11, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (21, 'TCP connectivity', 12, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (22, 'Endpoints MUST only accept TLS connectons', 13, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (23, 'TLS certificated MUST be derived from signed metadata', 13, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (24, 'TLS certificates MUST be valid', 13, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (25, 'TLS ciphers must be admitted for ECRYPT Level 5 or better', 13, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (26, 'handle IdP-initiated LogoutRequest to SP before the authn Response', 14, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (27, 'IDP-first SLO Request ', 14, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (28, 'SP MUST accept an LogoutRequest with no sessionindex (sent in separate session, no session-cookies)', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (29, 'SP MUST accept an LogoutRequest with two sesionindexes (first valid) (sent in separate session, no session-cookies)', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (30, 'SP MUST accept an LogoutRequest with two sesionindexes (second valid) (sent in separate session, no session-cookies)', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (31, 'SP MUST accept LogoutRequest with sessionindex in a separate session, not relying on the session-cookie.', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (32, 'SP MUST NOT logout user when invalid SessionIndex is sent', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (33, 'SP MUST reject LogoutRequest when Destination is wrong', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (34, 'SP MUST reject LogoutRequest when Issuer is wrong', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (35, 'SP MUST reject LogoutRequest when NameID content is wrong', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (36, 'SP MUST reject LogoutRequest when NameID@Format is wrong', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (37, 'SP MUST reject LogoutRequest when NameID@SPNameQualifier is wrong', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (38, 'IDP must understand SP-first LogOutRequest', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (39, 'IDP must understand SP-first LogOutRequest and logout 2nd SP', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (40, 'LogoutRequest from IDP MUST be signed', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (41, 'SP-first SLO Request with Redirect binding', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (42, 'The <LogoutRequest> MUST be signed', 15, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (43, 'The <Response> MUST be signed for the HTTP POST binding', 16, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (45, 'MUST support ForceAuthn', 17, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (46, 'MUST support POST binding of request', 17, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (47, 'MUST support Redirect binding of request', 17, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (48, 'SP MUST issue conformant AuthnRequest', 17, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (49, 'Metadata contains <idpdisc:DiscoveryResponse> ', 18, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (50, 'remember selected IDP', 18, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (51, 'use non-SP discovery service', 18, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (52, 'use SP-side discovery service', 18, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (53, 'Absolute basic SAML2 AuthnRequest', 19, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (54, 'Basic SAML2 AuthnRequest using HTTP POST', 19, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (55, 'previous session: Reuse existing IdP session to authenticate at second SP', 19, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (56, 'SAML2 AuthnRequest with specific NameIDPolicy', 19, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (57, 'Timeout at SP  after <nnn> s', 19, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (58, 'Timeout session at IdP after <nnn> s', 19, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (59, 'AuthnRequest using HTTP POST expecting transient NameID', 20, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (60, 'Basic SAML2 AuthnRequest, transient name ID', 20, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (61, 'accept a Response with a Condition with an additional Audience appended', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (62, 'accept a Response with a Condition with an additional Audience prepended', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (63, 'accept a Response with a SubjectConfirmationData elements with a correct @Address attribute', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (64, 'accept a Response with multiple SubjectConfirmation elements with /SubjectConfirmationData/@Address-es, where only the first one is correct', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (65, 'accept a Response with multiple SubjectConfirmation elements with /SubjectConfirmationData/@Address-es, where only the last one is correct', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (66, 'accept a Response with multiple SubjectConfirmationData elements with /SubjectConfirmationData/@Address-es, where only the first one is correct', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (67, 'accept a Response with multiple SubjectConfirmationData elements with /SubjectConfirmationData/@Address-es,where only the last one is correct', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (68, 'accept a Response with two SubjectConfirmation elements representing two recipients (test 1 of 2, correct one first) ', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (69, 'accept a Response with two SubjectConfirmation elements representing two recipients (test 1 of 2, correct one last)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (70, 'accept a Response with two SubjectConfirmationData elements representing two recipients (test 1 of 2, correct one first)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (71, 'accept a Response with two SubjectConfirmationData elements representing two recipients (test 1 of 2, correct one last)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (72, 'accept multiple AudienceRestrictions where the intersection includes the correct audience.', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (73, 'accept that both the Response and the Assertion is signed', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (74, 'accept that only the Assertion is signed instead of the Response', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (75, 'accept that only the Response is signed instead of the Assertion', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (76, 'accept xs:datetime with microsecond precision http://www.w3.org/TR/xmlschema-2/#dateTime', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (77, 'accept xs:datetime with millisecond precision http://www.w3.org/TR/xmlschema-2/#dateTime', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (78, 'Does the SP allow the InResponseTo attribute to be missing from the Response element?', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (79, 'Does the SP allow the InResponseTo attribute to be missing from the SubjectConfirmationData element?', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (80, 'find attributes in a second Assertion/AttributeStatement, not only in one of them (attributes in last)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (81, 'find attributes in a second Assertion/AttributeStatement, not only in one of them attributes in first)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (82, 'find attributes in a second AttributeStatement, (attributes in first and second statement)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (83, 'reject a broken DestinationURL attribute', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (84, 'reject a broken DestinationURL attribute in response', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (85, 'reject a broken Recipient attribute in assertion SubjectConfirmationData/@Recipient', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (86, 'reject a InResponseTo which is chosen randomly', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (87, 'reject a InResponseTo which is chosen randomly (in assertion only)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (88, 'reject a Response with a AuthnStatement missing', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (89, 'reject a Response with a AuthnStatement where SessionNotOnOrAfter is set in the past', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (90, 'reject a Response with a Condition with a empty set of Audience.', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (91, 'reject a Response with a Condition with a NotBefore in the future.', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (92, 'reject a Response with a Condition with a NotOnOrAfter in the past.', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (93, 'reject a Response with a Condition with a wrong Audience.', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (94, 'reject a Response with a SubjectConfirmationData elements with an incorrect @Address attribute', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (95, 'reject a Response with a SubjectConfirmationData@NotOnOrAfter in the past', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (96, 'reject an assertion containing an unknown Condition', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (97, 'reject an IssueInstant far (24 hours) into the future', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (98, 'reject an IssueInstant far (24 hours) into the past', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (99, 'reject an signed assertion embedded in an AttributeValue inside an unsigned assertion.', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (100, 'reject an signed assertion embedded in an AttributeValue inside an unsigned assertion. (Signature moved out...)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (101, 'reject an signed assertion, where the signature is referring to another assertion.', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (102, 'reject attributes in unsigned 2nd assertion', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (103, 'reject authnstatement in unsigned 2nd assertion', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (104, 'reject multiple AudienceRestrictions where the intersection is zero', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (105, 'SP MUST reject a replayed Response. [Profiles]: 4.1.4.5 POST-Specific Processing Rules (test 1 of 2: inresponseto)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (106, 'SP MUST reject a replayed Response. [Profiles]: 4.1.4.5 POST-Specific Processing Rules (test 2 of 2: unsolicited response)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (107, 'SP MUST reject an ID used in previous request', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (108, 'SP MUST reject response when the saml-namespace is invalid', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (109, 'Accept unknown extension element (?)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (110, 'MUST include valid AuthnContextClassRef in assertion', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (112, 'MUST understand AuthnContextClassRef in assertion', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (113, 'NameID format: e-mail', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (114, 'NameID format: other than defined', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (115, 'NameID format: persistent', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (116, 'Replayed Assertions MUST NOT be accepted', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (117, 'SP should observe the response status', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (118, 'SubjectConfirmationData missing', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (119, 'The <Response> MUST be signed for the HTTP POST binding', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (120, 'Tolerate lost RelayState (?)', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (121, 'Unsolicited response messages SHOULD be accepted', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (122, 'Unsolicited response messages SHOULD NOT be accepted', 21, 0);

INSERT INTO requirement (id, name, feature_id, operation_count) VALUES (123, 'resistance against session fixation attack', 22, 0);


SET statement_timeout = 0;

SET client_encoding = 'UTF8';

SET standard_conforming_strings = on;

SET check_function_bodies = false;

SET client_min_messages = warning;


SET search_path = public, pg_catalog;



SELECT pg_catalog.setval('samlprofile_id_seq', 2, true);



INSERT INTO samlprofile VALUES (1, 'PVP2-S 2.1', 'Austrian eGov SAML Profile', NULL, 0);

INSERT INTO samlprofile VALUES (2, 'saml2int', 'saml2int.org', NULL, 0);
ALTER TABLE testplan
  DROP CONSTRAINT IF EXISTS testplan_check_targettype;

ALTER TABLE testplan
  ADD CONSTRAINT testplan_check_targettype CHECK (target_type IN ('DS', 'IDP', 'SP'));

SELECT pg_catalog.setval('testplan_id_seq', 1, true);



CREATE OR REPLACE FUNCTION update_testplan_count() RETURNS TRIGGER AS $update_testplan_count$
BEGIN
	IF TG_OP = 'INSERT' THEN
		UPDATE samlprofile SET testplan_count = testplan_count + 1 WHERE id = NEW.samlprofile_id; 	ELSIF TG_OP = 'DELETE' THEN
		UPDATE samlprofile SET testplan_count = testplan_count - 1 WHERE id = OLD.samlprofile_id; 	END IF;   RETURN NULL; END; $update_testplan_count$ LANGUAGE plpgsql;



DROP TRIGGER IF EXISTS  update_testplan_count_on_samlprofile ON testplan;

CREATE TRIGGER update_testplan_count_on_samlprofile
AFTER INSERT OR DELETE ON testplan FOR EACH ROW
	EXECUTE PROCEDURE update_testplan_count();


SELECT 'FeaPlan.sql: load data';

INSERT INTO testplan(id, name, version, target_type, samlprofile_id, owner)
            VALUES (1, 'PVP2-S 2.1 Basis IDP', '0.1', 'IDP', 1, 'rhoerbe');

INSERT INTO testplan(id, name, version, target_type, samlprofile_id, owner)
            VALUES (2, 'PVP2-S 2.1 Basis SP', '0.1', 'SP', 1, 'rhoerbe');
SELECT 'Operation.sql: additional DDL';

CREATE OR REPLACE FUNCTION update_operation_count() RETURNS TRIGGER AS $$ BEGIN  IF TG_OP = 'INSERT' THEN		UPDATE requirement SET operation_count = operation_count + 1 WHERE id = NEW.requirement_id; ELSIF TG_OP = 'DELETE' THEN 	UPDATE requirement SET operation_count = operation_count - 1 WHERE id = OLD.requirement_id;	END IF;  RETURN NULL; END;$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS update_operation_count_on_requirement ON operation;


CREATE TRIGGER update_operation_count_on_requirement
AFTER INSERT OR DELETE ON operation FOR EACH ROW
	EXECUTE PROCEDURE update_operation_count();


ALTER TABLE operation
  DROP CONSTRAINT IF EXISTS operation_check_targettype;

ALTER TABLE operation
  ADD CONSTRAINT operation_check_targettype CHECK (target_type IN ('DS', 'IDP', 'SP'));


SELECT 'Operation.sql: load data';

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (1, 'S2c-1', 'test assertion query basic request/response', 'IDP', 1, 'send valid Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (2, 'S2c-2', 'test attribute query basic request/response', 'IDP', 2, 'send valid Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (3, 'PVP-2', 'provide minimum data set', 'SP', 3, 'returns attributes as key-value pairs', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (4, 'PVP-3', 'provide chained token', 'SP', 4, 'returns attributes as key-value pairs', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (5, 'PVP-4', 'provide optional attributes', 'SP', 5, 'returns attributes as key-value pairs', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (6, 'PVP-5', 'Check if attribute name formats are in the preferred set', 'IDP', 6, 'returns attributes as key-value pairs', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (7, 'PVP-6', 'AuthnRequest/Response exchange. NameID format configured in IDP', 'IDP', 7, 'Assertion contains nameID in required format', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (8, 'PVP-7', 'AuthnRequest/Response exchange. NameID Policy in request specifies format', 'SP', 7, 'Assertion contains nameID in required format', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (9, 'PVP-8', 'Issue AuthnRequest from 2 SPs to single IdP for same subject.', 'IDP', 7, 'NameID is unlinkable between SPs', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (10, 'S2c-3', 'test basic message flow', 'IDP', 8, 'send valid Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (11, 'MD-1', 'Provide expired MD (IDP)', 'IDP', 9, 'MD loading rejected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (12, 'MD-5', 'Provide expired MD (SP)', 'SP', 9, 'MD loading rejected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (13, 'MD-2', 'Provide invalid Signature  (IDP)', 'IDP', 10, 'MD loading rejected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (14, 'MD-6', 'Provide invalid Signature (SP)', 'SP', 10, 'MD loading rejected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (15, 'MD-3', 'required certificates missing in MD  (IDP)', 'IDP', 11, 'MD loading rejected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (16, 'MD-7', 'required certificates missing in MD (SP)', 'SP', 11, 'MD loading rejected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (17, 'MD-4', 'provide entity without roledescriptor in correct namespace (IDP)', 'IDP', 12, 'MD loading rejected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (18, 'MD-8', 'provide entity without roledescriptor in correct namespace (SP)', 'SP', 12, 'MD loading rejected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (19, 'S2c-16', 'S2c-17 + SLO-2', 'IDP', 13, 'IDP and SP sessions created and destroyed', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (20, 'S2c-12', 'S2c-17 + S2c-1', 'IDP', 14, '?', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (21, 'S2c-15', 'S2c-15?', 'IDP', 15, '?', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (22, 'S2c-5', 'S2c-5', 'IDP', 16, 'S2c-5', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (23, 'S2c-9', 'S2c-9', 'IDP', 17, 'S2c-9', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (24, 'S2c-7', 'S2c-7', 'IDP', 18, 'S2c-7', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (25, 'S2c-4', 'S2c-4', 'IDP', 19, 'S2c-4', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (26, 'S2c-8', 'S2c-8', 'IDP', 19, 'S2c-8', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (27, 'S2c-6', 'S2c-6', 'IDP', 20, 'S2c-6', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (28, 'S2c-10', 'Verify TCP connectivity  (IDP)', 'IDP', 21, 'accept TCP connection', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (29, 'NET-9', 'Verify TCP connectivity (SP)', 'SP', 21, 'accept TCP connection', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (30, 'NET-1', 'connect without TLS  (IDP)', 'IDP', 22, 'reject connection', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (31, 'NET-5', 'connect without TLS (SP)', 'SP', 22, 'reject connection', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (32, 'NET-2', 'use unauthorized certificate  (IDP)', 'IDP', 23, 'reject connection', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (33, 'NET-6', 'use unauthorized certificate (SP)', 'SP', 23, 'reject connection', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (34, 'NET-3', 'use invalid certificate  (IDP)', 'IDP', 24, 'reject connection', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (35, 'NET-7', 'use invalid certificate (SP)', 'SP', 24, 'reject connection', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (36, 'NET-4', 'use weak certificate (on different levels of validation path) (IDP)', 'IDP', 25, 'reject connection', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (37, 'NET-8', 'use weak certificate (on different levels of validation path) (SP)', 'SP', 25, 'reject connection', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (38, 'FL75', 'send IdP-initiated LogoutRequest to SP before the authn Response.', 'SP', 26, '?', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (39, 'SLO-1', 'Basic IdP-initated Logout Test', 'SP', 27, 'User session terminated', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (40, 'FL71', 'send LogoutRequest with no sessionindex (sent in separate session, no session-cookies)', 'SP', 28, 'accept LougoutRequest', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (41, 'FL72', 'send LogoutRequest with two sesionindexes (first valid) (sent in separate session, no session-cookies)', 'SP', 29, 'accept LougoutRequest', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (42, 'FL73', 'send LogoutRequest with two sesionindexes (second valid) (sent in separate session, no session-cookies)', 'SP', 30, 'accept LougoutRequest', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (43, 'FL70', 'send LogoutRequest with sessionindex in a separate session, not relying on the session-cookie.', 'SP', 31, 'accept LougoutRequest', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (44, 'FL66', 'send invalid LogoutRequest without SessionIndex ', 'SP', 32, 'reject LougoutRequest', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (45, 'FL68', 'send LogoutRequest where Destination is wrong', 'SP', 33, 'reject LougoutRequest', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (46, 'FL67', 'send LogoutRequest where Issuer is wrong', 'SP', 34, 'reject LougoutRequest', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (47, 'FL63', 'send LogoutRequest where NameID content is wrong', 'SP', 35, 'reject LougoutRequest', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (48, 'FL64', 'send LogoutRequest where NameID@Format is wrong', 'SP', 36, 'reject LougoutRequest', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (49, 'FL65', 'send LogoutRequest where NameID@SPNameQualifier is wrong', 'SP', 37, 'reject LougoutRequest', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (50, 'S2c-11', 'send LogoutRequest, front-channel binding, one SP', 'IDP', 38, 'IDP and SP sessions destroyed', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (51, 'SLO-5', 'send LogoutRequest, front-channel binding, two SP', 'IDP', 39, 'IDP, SP(1) and SP(2) sessions destroyed', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (52, 'FL69', 'IDP sends unsigned LogoutRequest', 'SP', 40, 'reject response because of missing signature', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (53, 'FL61', 'SP sends logout request', 'SP', 41, 'User session terminated', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (54, 'SLO-2', 'initiate Logout at the IDP - Request signature', 'IDP', 42, 'expect Request with valid signature', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (55, 'SLO-3', 'initiate Logout at the IDP - Response signature', 'IDP', 43, 'reject if Response is not signed', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (56, 'SLO-4', 'Check on missing signature', 'SP', 43, 'reject LougoutResponse', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (57, 'SSO-1', 'Send AuthnRequest with ForceAuthn=true during valid IDP-Session', 'IDP', 45, 'IdP requests re-authentication during message flow', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (58, 'PVP-9', 'Send AuthnRequest using POST binding', 'IDP', 46, 'IdP returns valid Reponse', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (59, 'SSO-2', 'Send AuthnRequest using Redirect binding', 'SP', 47, 'SP sends valid Request', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (60, 'SSO-3', 'Understand AuthnRequest using Redirect binding', 'IDP', 47, 'IdP returns valid Reponse', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (61, 'FL2', 'Verify various aspects of the generated AuthnRequest message', 'SP', 48, '?', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (62, 'DS-1', 'Check if  <idpdisc:DiscoveryResponse> exists', 'SP', 49, 'Element found', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (63, 'DS-3', 'request IDP-selection from discovery service after a previous selection', 'SP', 50, 'SP knows IDP for re-visting user', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (64, 'DS-2', 'request IDP-selection from discovery service', 'SP', 51, 'IDP selected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (65, 'DS-4', 'provide IDP-selection at the SP', 'SP', 52, 'IDP selected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (66, 'S2c-17', 'Basic AuthnRequest with Redirect Binding for Request and Response ', 'IDP', 53, 'valid Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (67, 'S2c-14', 'Basic AuthnRequest with Redirect binding for Request and POST Binding for Response', 'IDP', 54, '', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (68, '', 'Reuse existing IdP session to authenticate at second SP', 'IDP', 55, 'No re-authenitcation at second IDP', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (69, 'S2c-13', 'S2c-17 + ?', 'IDP', 56, '', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (70, 'PVP-13', 'check if timeout intervals as specified by policy are honored (SP)', 'SP', 57, 'SP session expired after policy-defined interval', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (71, 'PVP-14', 'check if timeout intervals as specified by policy are honored (IDP)', 'IDP', 58, 'IDP session expired after policy-defined interval', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (72, 'S2c-18', 'Basic AuthnRequest with Redirect binding for Request and POST Binding for Response;I42', 'IDP', 59, 'Response contains transient NameID', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (73, 'S2c-19', 'Difference to S2c-18?', 'IDP', 60, 'Response contains transient NameID', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (74, 'FL39', 'send Response with a Condition with an additional Audience appended', 'SP', 61, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (75, 'FL38', 'send Response with a Condition with an additional Audience prepended', 'SP', 62, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (76, 'FL20', 'send Response with a SubjectConfirmationData elements with a correct @Address attribute', 'SP', 63, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (77, 'FL23', 'send Response with multiple SubjectConfirmation elements with /SubjectConfirmationData/@Address-es, where only the first one is correct', 'SP', 64, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (78, 'FL22', 'send Response with multiple SubjectConfirmation elements with /SubjectConfirmationData/@Address-es, where only the last one is correct', 'SP', 65, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (79, 'FL25', 'SP should accept a Response with multiple SubjectConfirmationData elements with /SubjectConfirmationData/@Address-es, where only the first one is correct', 'SP', 66, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (80, 'FL24', 'SP should accept a Response with multiple SubjectConfirmationData elements with /SubjectConfirmationData/@Address-es,where only the last one is correct', 'SP', 67, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (81, 'FL19', 'FL19?', 'SP', 68, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (82, 'FL18', 'FL20?', 'SP', 69, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (83, 'FL17', 'FL21?', 'SP', 70, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (84, 'FL16', 'FL22?', 'SP', 71, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (85, 'FL42', 'send Response with multiple AudienceRestrictions where the intersection includes the correct audience', 'SP', 72, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (86, 'FL44', 'send Response with both Response and Assertion signed', 'SP', 73, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (87, 'FL43', 'send Response with only the Assertion signed', 'SP', 74, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (88, 'FL76', 'send Response with only the Response signed', 'SP', 75, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (89, 'FL35', 'send Response with xs:datetime with microsecond precision http://www.w3.org/TR/xmlschema-2/#dateTime', 'SP', 76, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (90, 'FL34', 'send Response with xs:datetime with millisecond precision http://www.w3.org/TR/xmlschema-2/#dateTime', 'SP', 77, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (91, 'FL11', 'Send Reponse without InResponseTo attribute', 'SP', 78, '', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (92, 'FL12', 'Send Reponse without InResponseTo attribute in the SubjectConfirmationData element', 'SP', 79, '', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (93, 'FL56', 'Include second Assertion/AttributeStatement in Response with attributes in second', 'SP', 80, 'returns attributes as key-value pairs', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (94, 'FL55', 'Include second Assertion/AttributeStatement in Response with attributes in first', 'SP', 81, 'returns attributes as key-value pairs', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (95, 'FL51', 'Include second Assertion/AttributeStatement in Response with attributes in both', 'SP', 82, 'returns attributes as key-value pairs', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (96, 'FL13', 'send Response with a broken DestinationURL attribute', 'SP', 83, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (97, 'FL15', 'send Response with a broken DestinationURL attribute in response', 'SP', 84, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (98, 'FL14', 'send Response with a broken Recipient attribute in assertion SubjectConfirmationData/@Recipient', 'SP', 85, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (99, 'FL9', 'send Response with a InResponseTo which is chosen randomly', 'SP', 86, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (100, 'FL10', 'send Response with a InResponseTo which is chosen randomly (in assertion only)', 'SP', 87, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (101, 'FL31', 'send Response with a AuthnStatement missing', 'SP', 88, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (102, 'FL30', 'send Response with a AuthnStatement where SessionNotOnOrAfter is set in the past', 'SP', 89, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (103, 'FL36', 'send Response with a Condition with a empty set of Audience.', 'SP', 90, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (104, 'FL27', 'send Response with a Condition with a NotBefore in the future.', 'SP', 91, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (105, 'FL28', 'send Response with a Condition with a NotOnOrAfter in the past.', 'SP', 92, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (106, 'FL37', 'send Response with a Condition with a wrong Audience.', 'SP', 93, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (107, 'FL21', 'send Response with a SubjectConfirmationData elements with an incorrect @Address attribute', 'SP', 94, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (108, 'FL29', 'send Response with a SubjectConfirmationData@NotOnOrAfter in the past', 'SP', 95, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (109, 'FL26', 'send Response with an assertion containing an unknown Condition', 'SP', 96, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (110, 'FL32', 'send Response with an IssueInstant far (24 hours) into the future', 'SP', 97, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (111, 'FL33', 'send Response with an IssueInstant far (24 hours) into the past', 'SP', 98, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (112, 'FL52', 'send Response with an signed assertion embedded in an AttributeValue inside an unsigned assertion.', 'SP', 99, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (113, 'FL53', 'send Response with an signed assertion embedded in an AttributeValue inside an unsigned assertion. (Signature moved out...)', 'SP', 100, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (114, 'FL54', 'send Response with an signed assertion, where the signature is referring to another assertion.', 'SP', 101, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (115, 'FL58', 'send Response with attributes in unsigned 2nd assertion. (test 2 of 2)', 'SP', 102, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (116, 'FL59', 'send Response with authnstatement in unsigned 2nd assertion. (test 1 of 2)', 'SP', 103, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (117, 'FL40', 'send Response with multiple AudienceRestrictions where the intersection is zero. (test 1 of 2)', 'SP', 104, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (118, 'FL49', 'An identical Assertion used a second time (POST-Specific Processing Rules: inresponseto)', 'SP', 105, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (119, 'FL50', 'An identical Assertion used a second time (unsolicited response)', 'SP', 106, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (120, 'FL48', 'send ID used in previous request', 'SP', 107, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (121, 'FL47', 'send Response with invalid SAML namespace', 'SP', 108, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (122, 'FL46', 'Send unknown Extensions element in Response', 'SP', 109, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (123, 'PVP-10', 'send response with (1) no and (2) an invalid value', 'SP', 110, 'Assertion rejected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (124, 'PVP-11', 'send response with each of defined  values (1 per Reponse); ', 'SP', 110, 'accept Response', 'send response with each of following values (1 per Reponse); http://www.ref.gv.at/ns/names/agiz/pvp/secclass/0; http://www.ref.gv.at/ns/names/agiz/pvp/secclass/0-1; http://www.ref.gv.at/ns/names/agiz/pvp/secclass/0-2; http://www.ref.gv.at/ns/names/agiz/pvp/secclass/0-3');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (125, 'PVP-12', 'send insufficient LoA for defined Test URL', 'SP', 112, 'Assertion rejected. User may be informed about the reason.', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (126, 'FL5', 'SP should accept a NameID with Format: e-mail', 'SP', 113, 'understands Response with eMail NameID', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (127, 'FL6', 'Does SP work with unknown NameID Format, such as: foo', 'SP', 114, '?', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (128, 'FL4', 'SP should accept a NameID with Format: persistent', 'SP', 115, 'understands Response with persistent NameID', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (129, 'SSO-4', 'replay Response message', 'SP', 116, 'Assertion rejected', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (130, 'FL3', 'SP should reject a Response when the StatusCode is not success', 'SP', 117, '', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (131, 'FL7', 'SP should accept a Response without a SubjectConfirmationData element', 'SP', 118, '', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (132, 'SSO-5', 'Send AuthnRequest', 'IDP', 119, 'Response carries valid signature', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (133, 'SSO-6', 'Send Response with broken signature', 'SP', 119, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (134, 'SSO-7', 'Send Response with missing signature', 'SP', 119, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (135, 'SSO-8', 'Send Response with valid signature but invalid key', 'SP', 119, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (136, 'FL45', 'Send Reponse without RelayState information', 'SP', 120, 'return to SP root context', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (137, 'FL8', 'Test Harness sends an unsolicited SAML Response message containing a valid assertion (no inresponseto attribute) - OK', 'SP', 121, 'accept Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (138, 'PVP-15', 'Test Harness sends an unsolicited SAML Response message containing a valid assertion (no inresponseto attribute) - NOK', 'SP', 122, 'reject Response', '');

INSERT INTO operation(id, operation_id, name, target_type, requirement_id, expected_behavior, description) VALUES (139, 'FL74', 'extract session from URL etc. to hijack session', 'SP', 123, 'resistant against attack', '');
CREATE INDEX "feature_featuregroup_id" ON "feature" ("featuregroup_id");
CREATE INDEX "requirement_feature_id" ON "requirement" ("feature_id");
CREATE INDEX "requirement_reference_id" ON "requirement" ("reference_id");
CREATE INDEX "samlprofile_samlprofileid" ON "samlprofile" ("samlprofileid");
CREATE INDEX "testplan_samlprofile_id" ON "testplan" ("samlprofile_id");
CREATE INDEX "operation_requirement_id" ON "operation" ("requirement_id");
CREATE INDEX "testplancaseassignment_profiletestplan_id" ON "testplancaseassignment" ("profiletestplan_id");
CREATE INDEX "testplancaseassignment_operation_id" ON "testplancaseassignment" ("operation_id");
CREATE INDEX "testclass_testtargetinterface_id" ON "testclass" ("testtargetinterface_id");
CREATE INDEX "pretest_operation_id" ON "pretest" ("operation_id");
CREATE INDEX "samlrequest_operation_id" ON "samlrequest" ("operation_id");
COMMIT;
