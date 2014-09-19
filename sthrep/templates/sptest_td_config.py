#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Configuration of the test driver which has the IdP role

from saml2 import BINDING_HTTP_REDIRECT, BINDING_URI
from saml2 import BINDING_HTTP_POST
from saml2.saml import NAME_FORMAT_URI
from saml2.saml import NAMEID_FORMAT_TRANSIENT
from saml2.saml import NAMEID_FORMAT_PERSISTENT

try:
    from saml2.sigver import get_xmlsec_binary
except ImportError:
    get_xmlsec_binary = None

if get_xmlsec_binary:
    xmlsec_path = get_xmlsec_binary(["/opt/local/bin", "/usr/local/bin", "/usr/bin"])
else:
    xmlsec_path = "/usr/bin/xmlsec1"

# This configures the Test Driver, including its metadata
BASE = "{{ td_base_url }}"
ENTITYID = "{{ td_entityid }}"

CONFIG = {
    "entityid": ENTITYID,
    "description": "Test Driver's embedded IDP",
    "service": {
        "idp": {
            "name": "{{ td_name }}",
            "endpoints": {
                "single_sign_on_service": [
                    ("%s/sso/redirect" % BASE, BINDING_HTTP_REDIRECT),
                    ("%s/sso/post" % BASE, BINDING_HTTP_POST),
                ],
                "single_logout_service": [
                    ("%s/slo/post" % BASE, BINDING_HTTP_POST),
                    ("%s/slo/redirect" % BASE, BINDING_HTTP_REDIRECT)
                ],
                "assertion_id_request_service": [
                    ("%s/airs" % BASE, BINDING_URI)
                ],
                "manage_name_id_service": [
                    ("%s/mni/post" % BASE, BINDING_HTTP_POST),
                    ("%s/mni/redirect" % BASE, BINDING_HTTP_REDIRECT),
                ],
            },
            "policy": {
                "default": {
                    "lifetime": {"minutes": {{ service_idp_policy_lifetime }}},
                    "attribute_restrictions": {{ service_idp_policy_attribute_restrictions }},
                    "name_form": "{{ service_idp_policy_name_form }}",
                },
            },
            "subject_data": ("dict", None),
            "name_id_format": "{{ service_idp_name_id_format }}",
        },
    },
    "debug": 1,
    "key_file": "{{ td_key_pem }}",
    "cert_file": "{{ td_cert_pem }}",
    "metadata": {},
    "organization": {
        "display_name": "Test Dummy",
        "name": "Test Dummy",
        "url": "http://www.example.com",
    },
    "contact_person": [
        {
            "contact_type": "technical",
            "given_name": "Test",
            "sur_name": "Dummy",
            "email_address": "technical.dummy@example.com"
        }, {
            "contact_type": "support",
            "given_name": "Support",
            "sur_name": "Dummy",
            "email_address": "support.dummy@example.com"
        },
    ],
    # This database holds the map between a subjects local identifier and
    # the identifier returned to a SP
    "xmlsec_binary": xmlsec_path,
    "attribute_map_dir": "{{ attributemaps }}",
    "logger": {
        "rotating": {
            "filename": "idp_testdrv.log",
            "maxBytes": 500000,
            "backupCount": 5,
        },
        "loglevel": "debug",
    }
}
