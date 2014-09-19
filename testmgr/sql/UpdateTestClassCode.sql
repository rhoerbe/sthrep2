--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.4
-- Dumped by pg_dump version 9.1.5
-- Started on 2013-04-17 14:37:58 CEST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- TOC entry 2256 (class 0 OID 0)
-- Dependencies: 210
-- Name: testmgr_testclass_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rhoerbe
--

SELECT pg_catalog.setval('testmgr_testclass_id_seq', 28, true);


--
-- TOC entry 2251 (class 0 OID 104333)
-- Dependencies: 211 2252
-- Data for Name: testmgr_testclass; Type: TABLE DATA; Schema: public; Owner: rhoerbe
--

INSERT INTO testmgr_testclass VALUES (11, 'CheckSaml2IntAttributes', NULL, NULL, NULL);
INSERT INTO testmgr_testclass VALUES (12, 'CheckSaml2IntMetaData', NULL, NULL, NULL);
INSERT INTO testmgr_testclass VALUES (18, 'VerifyAttributeNameFormat', NULL, NULL, NULL);
INSERT INTO testmgr_testclass VALUES (19, 'VerifyFunctionality', NULL, NULL, NULL);
INSERT INTO testmgr_testclass VALUES (20, 'VerifySignatureAlgorithm', NULL, NULL, NULL);
INSERT INTO testmgr_testclass VALUES (21, 'VerifySignedPart', NULL, NULL, NULL);
INSERT INTO testmgr_testclass VALUES (9, 'AuthnRequest_NameIDPolicy1', '', 'class AuthnRequest_NameIDPolicy1(AuthnRequest):
    def __init__(self, conv):
        AuthnRequest.__init__(self, conv)
        self.args["name_id_policy"] = NameIDPolicy(
            format=NAMEID_FORMAT_PERSISTENT, sp_name_qualifier="Group1",
            allow_create="true")
        self.tests["post"].append(VerifyNameIDPolicyUsage)
', NULL);
INSERT INTO testmgr_testclass VALUES (0, 'AssertionIDRequest', '', 'class AssertionIDRequest(Request):
    request = "assertion_id_request"
    _args = {"request_binding": BINDING_URI}
    tests = {"pre": [VerifyFunctionality]}

    def setup(self):
        resp = self.conv.saml_response[-1].response
        assertion = resp.assertion[0]
        self.args["assertion_id_refs"] = [assertion.id]', NULL);
INSERT INTO testmgr_testclass VALUES (3, 'AuthnRequest', '', 'class AuthnRequest(Request):
    _class = samlp.AuthnRequest
    request = "authn_request"
    _args = {"response_binding": BINDING_HTTP_POST,
             "request_binding": BINDING_HTTP_REDIRECT,
             "nameid_format": NAMEID_FORMAT_PERSISTENT,
             "allow_create": True}
    tests = {"pre": [VerifyFunctionality],
             "post": [CheckSaml2IntAttributes,
                      VerifyAttributeNameFormat,
                      VerifySignedPart,
                      VerifySignatureAlgorithm]}
', NULL);
INSERT INTO testmgr_testclass VALUES (8, 'AuthnRequestTransient', '', 'class AuthnRequestTransient(AuthnRequest):
    def __init__(self, conv):
        AuthnRequest.__init__(self, conv)
        self.args["nameid_format"] = NAMEID_FORMAT_TRANSIENT

    def setup(self):
        cnf = self.conv.client.config
        endps = cnf.getattr("endpoints", "sp")
        url = ""
        for url, binding in endps["assertion_consumer_service"]:
            if binding == BINDING_HTTP_POST:
                self.args["assertion_consumer_service_url"] = url
                break

        self.tests["post"].append((VerifyEndpoint, url))
', NULL);
INSERT INTO testmgr_testclass VALUES (4, 'AuthnRequestEndpointIndex', '', 'class AuthnRequestEndpointIndex(AuthnRequest):
    def __init__(self, conv):
        AuthnRequest.__init__(self, conv)
        self.args["attribute_consuming_service_index"] = 3

    def setup(self):
        cnf = self.conv.client.config
        endps = cnf.getattr("endpoints", "sp")
        acs3 = endps["assertion_consumer_service"][3]
        self.tests["post"].append((VerifyEndpoint, acs3[0]))
', NULL);
INSERT INTO testmgr_testclass VALUES (7, 'AuthnRequestSpecEndpoint', '', 'class AuthnRequestSpecEndpoint(AuthnRequest):
    def setup(self):
        cnf = self.conv.client.config
        endps = cnf.getattr("endpoints", "sp")
        acs3 = endps["assertion_consumer_service"][3]
        self.args["assertion_consumer_service_url"] = acs3[0]
        self.tests["post"].append((VerifyEndpoint, acs3[0]))
', NULL);
INSERT INTO testmgr_testclass VALUES (13, 'DynAuthnRequest', '', 'class DynAuthnRequest(Request):
    _class = samlp.AuthnRequest
    request = "authn_request"
    _args = {"response_binding": BINDING_HTTP_POST}
    tests = {}
    name_id_formats = [NAMEID_FORMAT_TRANSIENT, NAMEID_FORMAT_PERSISTENT]
    bindings = [BINDING_HTTP_REDIRECT, BINDING_HTTP_POST]

    def setup(self):
        metadata = self.conv.client.metadata
        entity = metadata[self.conv.entity_id]
        self.args.update({"nameid_format": "", "request_binding": ""})
        for idp in entity["idpsso_descriptor"]:
            for nformat in self.name_id_formats:
                if self.args["nameid_format"]:
                    break
                for nif in idp["name_id_format"]:
                    if nif["text"] == nformat:
                        self.args["nameid_format"] = nformat
                        break
            for bind in self.bindings:
                if self.args["request_binding"]:
                    break
                for sso in idp["single_sign_on_service"]:
                    if sso["binding"] == bind:
                        self.args["request_binding"] = bind
                        break
', NULL);
INSERT INTO testmgr_testclass VALUES (5, 'AuthnRequestPost', '', 'class AuthnRequestPost(AuthnRequest):
    def __init__(self, conv):
        AuthnRequest.__init__(self, conv)
        self.args["request_binding"] = BINDING_HTTP_POST
', NULL);
INSERT INTO testmgr_testclass VALUES (10, 'AuthnRequest_using_Artifact', '', 'class AuthnRequest_using_Artifact(AuthnRequest):
    def __init__(self, conv):
        AuthnRequest.__init__(self, conv)
        self.use_artifact = True
', NULL);
INSERT INTO testmgr_testclass VALUES (6, 'AuthnRequestPostTransient', '', 'class AuthnRequestPostTransient(AuthnRequestPost):
    def __init__(self, conv):
        AuthnRequest.__init__(self, conv)
        self.args["nameid_format"] = NAMEID_FORMAT_TRANSIENT
', NULL);
INSERT INTO testmgr_testclass VALUES (15, 'LogOutRequest', '', 'class LogOutRequest(Request):
    request = "logout_request"
    _args = {"request_binding": BINDING_SOAP}
    tests = {"pre": [VerifyFunctionality], "post": []}

    def __init__(self, conv):
        Request.__init__(self, conv)
        self.tests["pre"].append(CheckLogoutSupport)
        self.tests["post"].append(VerifyLogout)

    def setup(self):
        resp = self.conv.saml_response[-1].response
        assertion = resp.assertion[0]
        subj = assertion.subject
        self.args["name_id"] = subj.name_id
        self.args["issuer_entity_id"] = assertion.issuer.text
', NULL);
INSERT INTO testmgr_testclass VALUES (2, 'AuthnQuery', '', 'class AuthnQuery(Request):
    request = "authn_query"
    _args = {"request_binding": BINDING_SOAP}
    tests = {"pre": [VerifyFunctionality], "post": []}

    def __init__(self, conv):
        Request.__init__(self, conv)
        self.tests["post"].append(VerifySuccessStatus)

    def setup(self):
        resp = self.conv.saml_response[-1].response
        assertion = resp.assertion[0]
        self.args["subject"] = assertion.subject
', NULL);
INSERT INTO testmgr_testclass VALUES (17, 'NameIDMappingRequest', '', 'class NameIDMappingRequest(Request):
    request = "name_id_mapping_request"
    _args = {"request_binding": BINDING_SOAP,
             "name_id_policy": NameIDPolicy(format=NAMEID_FORMAT_PERSISTENT,
                                            sp_name_qualifier="GroupOn",
                                            allow_create="true")}

    def __init__(self, conv):
        Request.__init__(self, conv)
        self.tests["post"].append(VerifyNameIDMapping)

    def setup(self):
        resp = self.conv.saml_response[-1].response
        assertion = resp.assertion[0]
        self.args["name_id"] = assertion.subject.name_id
', NULL);
INSERT INTO testmgr_testclass VALUES (23, 'AuthnRequest_TransientNameID', '', 'class AuthnRequest_TransientNameID(AuthnRequest):
    def __init__(self, conv):
        AuthnRequest.__init__(self, conv)
        self.args["name_id_policy"] = NameIDPolicy(
            format=NAMEID_FORMAT_TRANSIENT, sp_name_qualifier="Group",
            allow_create="true")
        self.tests["post"].append(VerifyNameIDPolicyUsage)
', NULL);
INSERT INTO testmgr_testclass VALUES (14, 'ECP_AuthnRequest', '', 'class ECP_AuthnRequest(AuthnRequest):

    def __init__(self, conv):
        AuthnRequest.__init__(self, conv)
        self.args["request_binding"] = BINDING_SOAP
        self.args["service_url_binding"] = BINDING_PAOS

    def setup(self):
        _client = self.conv.client
        _client.user = "babs"
        _client.passwd = "howes"
', NULL);
INSERT INTO testmgr_testclass VALUES (16, 'ManageNameIDRequest', '', 'class ManageNameIDRequest(Request):
    request = "manage_name_id_request"
    _args = {"request_binding": BINDING_SOAP,
             "new_id": samlp.NewID("New identifier")}

    def __init__(self, conv):
        Request.__init__(self, conv)
        self.tests["post"].append(VerifySuccessStatus)

    def setup(self):
        resp = self.conv.saml_response[-1].response
        assertion = resp.assertion[0]
        self.args["name_id"] = assertion.subject.name_id
', NULL);
INSERT INTO testmgr_testclass VALUES (1, 'AttributeQuery', '', 'class AttributeQuery(Request):
    request = "attribute_query"
    _args = {"request_binding": BINDING_SOAP}
    tests = {"pre": [VerifyFunctionality],
             "post": [CheckSaml2IntAttributes, VerifyAttributeNameFormat]}

    def setup(self):
        resp = self.conv.saml_response[-1].response
        assertion = resp.assertion[0]
        self.args["name_id"] = assertion.subject.name_id', NULL);


-- Completed on 2013-04-17 14:37:58 CEST

--
-- PostgreSQL database dump complete
--

