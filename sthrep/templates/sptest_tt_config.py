#!/usr/bin/env python

# Configuration of the test target which has the SP role

from saml2.saml import AUTHN_PASSWORD
from saml2.saml import NAME_FORMAT_UNSPECIFIED, NAME_FORMAT_URI, NAME_FORMAT_BASIC
from xmldsig import *
from utility.metadata import fetch_metadata
import json, os.path

ENTITYID = "{{ tt_entityid }}"
metadata_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "metadata.xml")
fetch_metadata("{{ metadata_url }}",
               metadata_path,
               maxage={{ metadata_cache_duration }})
metadata = open(metadata_path).read()

AUTHN = {"class_ref": AUTHN_PASSWORD,
         "authn_auth": "http://lingon.catalogix.se/login"}


info = {
    "start_page": "{{ start_page }}",
    "entity_id": ENTITYID,  # the test target's EntityID
    "result": {  # info tries to match the SP's result page, so the test driver may see that the desired result was delivered
        "matches": {
            "content": "<li>PHP_SELF = /secure/echo.php</li>"
        },
    },
    "metadata": metadata,  # the SP metadata
    "args":
    {
        "AuthnResponse": {
            "sign_assertion": "{{ args_AuthnResponse_sign_assertion }}",
            "sign_response": "{{ args_AuthnResponse_sign_response }}",
            "authn": AUTHN
        }
    },
    # This is the set of attributes and values that are returned in the
    # SAML Assertion
    "identity": {
        {{ identity }}
    },
    # This is the value of the NameID that is return in the Subject in the
    # Assertion
    "userid": "{{ userid }}",
    # regex pattern that must be contained in the resulting echo page to validate
    # that the SP returned the right page after Login.
    "echopageIdPattern": {{  echopageIdPattern }},
    # list of regex patterns that must be contained in the resulting echo page to validate
    # that the SP's echo page returns expected SAMLe response values (e.g. attribute values)
    "echopageContentPattern": [
        {{ echopageContentPattern }}
                              ],
    "constraints": {
        "authnRequest_signature_required": {{ constraints_authnRequest_signature_required }},
        # allowed for assertion & response signature:
        "digest_algorithm": {{ args_AuthnResponse_sign_digest_alg }},
        "signature_algorithm": {{ args_AuthnResponse_sign_signature_alg }},
    },
}

print json.dumps(info)
