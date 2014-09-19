# Django settings for sthrep project.
# Structure: import default settings as created with django-admin.py startproject, then overwrite and extend
# This script contains only settings common to both devl and prod environment
# Rainer Hoerbe, 22-05-2013

import os
from idp_test.saml2base import OPERATIONS as IDP_TEST_OPERATIONS_DICT
from sp_test.tests import OPERATIONS as SP_TEST_OPERATIONS_DICT
from saml2test.check import STATUSCODE as OPER_STATUSCODE
from unipath import Path
from os.path import abspath, dirname
PROJECT_ROOT = Path(abspath(dirname(__file__))).ancestor(2)

import django.conf.global_settings as DEFAULT_SETTINGS
from .default import *

TIME_ZONE = 'Europe/Vienna'
ROOT_URLCONF = 'sthrep.urls'

MEDIA_ROOT = PROJECT_ROOT.child("media")
STATICFILES_DIRS += (PROJECT_ROOT.child("static"), )
STATIC_URL = '/static/'
ADMIN_MEDIA_PREFIX = '/static/admin/' # to include admin meida in collectstatic command
TEMPLATE_DIRS = (PROJECT_ROOT.child("sthrep").child("templates"),
                 # following line is required to allow an admin template to be extended. See http://stackoverflow.com/questions/4901546/difficulty-overriding-django-admin-template
                 # thus {% extends "admin/index.html" %} can be changed to {% extends "contrib/admin/templates/admin/index.html" %}
                 #'/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/django/'
)

# Extend default settings
import django.conf.global_settings as DEFAULT_SETTINGS
TEMPLATE_CONTEXT_PROCESSORS = DEFAULT_SETTINGS.TEMPLATE_CONTEXT_PROCESSORS + (
    "django.core.context_processors.request",  # required for admin_tools
)

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'admin_tools',
    #'adminplus',
    #'admin_tools.theming',
    #'admin_tools.menu',
    'admin_tools.dashboard',
    'django.contrib.admin',
    'django.contrib.admindocs',
    'registration',
    'requmgr',
    'testmgr',
    'multiselectfield',
    #'south',   # enable south after installing the db and running syncdb
)

ADMIN_TOOLS_INDEX_DASHBOARD = 'sthrep.dashboard.CustomIndexDashboard'
ADMIN_TOOLS_APP_INDEX_DASHBOARD = 'sthrep.dashboard.CustomAppIndexDashboard'

# This is the number of days users will have to activate their accounts after registering. If a user does not activate within that period, the account will remain permanently inactive and may be deleted by maintenance scripts provided in django-registration.
ACCOUNT_ACTIVATION_DAYS = 3
# True is indicating that registration of new accounts is currently permitted
REGISTRATION_OPEN=True

# db-connection reuse (new with django 1.6)
CONN_MAX_AGE = 30
CSRF_COOKIE_HTTPONLY = True

# import available operations from saml2test (used in models)

IDP_TEST_OPERATIONS = []
IDP_TEST_OPER_LOOKUP = {}
for o in sorted(IDP_TEST_OPERATIONS_DICT):
    tc_id = IDP_TEST_OPERATIONS_DICT[o]['tc_id']
    tc_name = IDP_TEST_OPERATIONS_DICT[o]['name']
    tc_id_name = "%s: %s" % (tc_id, tc_name)
    IDP_TEST_OPERATIONS.append((tc_id,tc_id_name))
    IDP_TEST_OPER_LOOKUP[tc_id] = tc_name
SP_TEST_OPERATIONS = []
SP_TEST_OPER_LOOKUP = {}
for tc_id in sorted(SP_TEST_OPERATIONS_DICT):
    tc_name = SP_TEST_OPERATIONS_DICT[tc_id]['name']
    tc_id_name = "%s: %s" % (tc_id, tc_name)
    SP_TEST_OPERATIONS.append((tc_id,tc_id_name))
    SP_TEST_OPER_LOOKUP[tc_id] = tc_name

OPER_STATUSCODE_EXT = OPER_STATUSCODE + ['INCOMPLETE', 'STHREP EXCEPTION']
OPER_STATUSCODE_INCOMPLETE = 6
OPER_STATUSCODE_STHREP_EXCEPTION = 7

TESTMGR_EXPORT = PROJECT_ROOT.child("testmgr").child("export")
INVALID_KEYS =  TESTMGR_EXPORT.child("keys")

try:
    PYTHONEXE = os.environ['PYTHONEXE']
except KeyError:
    PYTHONEXE = '/Users/admin/.virtualenvs/sthrep/bin/python'  # pychar does not pass env?
    #PYTHONEXE = '/var/virtualenv/sthrep/bin/python'  # remote debug netcup7.hoerbe.at

