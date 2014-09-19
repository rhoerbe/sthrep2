#!/usr/bin/env python
# -*- coding: utf-8 -*-

# System-level defaults for td_config

from saml2.saml import NAME_FORMAT_URI
from saml2.saml import NAMEID_FORMAT_PERSISTENT, NAMEID_FORMAT_TRANSIENT
from xmldsig import DIGEST_ALLOWED_ALG, SIG_ALLOWED_ALG

__author__ = 'rhoerbe'

conf_default = {}
# test driver config
conf_default["td_entityid"] = None
conf_default["td_name"] = None
conf_default["td_base_url"] = None
conf_default["service_idp_policy_lifetime"] = 15
conf_default["service_idp_policy_attribute_restrictions"] = None
conf_default["service_idp_name_id_format"] = NAMEID_FORMAT_TRANSIENT
conf_default["td_key_pem"] = "keys/mykey.pem"
conf_default["td_cert_pem"] = "keys/mycert.pem"
conf_default["interaction_json"] = None
conf_default["constraints_name_format"] = None

# test target config
conf_default["tt_entityid"] = None
conf_default["td_name"] = None
conf_default["metadata_url"] = None
conf_default["metadata_cache_duration"] = 10
conf_default["service_idp_policy_lifetime"] = 60
conf_default["service_idp_policy_attribute_restrictions"] = None
conf_default["service_idp_policy_name_form"] = NAME_FORMAT_URI
conf_default["service_idp_name_id_format"] = [NAMEID_FORMAT_PERSISTENT, NAMEID_FORMAT_TRANSIENT]
conf_default["attributesmaps"] = "/Users/admin/devl/pycharm/rhoerbe/pysaml2.fork/src/saml2/attributemaps/"
conf_default["start_page"] = None
conf_default["request_init"] = None
conf_default["args_AuthnResponse_sign_assertion"] = "never"
conf_default["args_AuthnResponse_sign_response"] = "never"
conf_default["args_AuthnResponse_sign_digest_alg"] = DIGEST_ALLOWED_ALG
conf_default["args_AuthnResponse_sign_signature_alg"] = SIG_ALLOWED_ALG
conf_default["args_AuthnResponse_authn"] = None
conf_default["identity"] = None
conf_default["userid"] = None
conf_default["echopageIdPattern"] = None
conf_default["echopageContentPattern"] = None
conf_default["constraints_authnRequest_signature_required"] = None
