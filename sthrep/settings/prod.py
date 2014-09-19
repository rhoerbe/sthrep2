# Django settings for sthrep project.
# Structure: import default settings as created with django-admin.py startproject, then overwrite and extend
# Rainer Hoerbe, 15-04-2013

from unipath import Path
from os.path import abspath, dirname
from .common import *

DEBUG = True
TEMPLATE_DEBUG = DEBUG

# database connect string and and SECRET_KEY are priveate and not to be included in git
import sys
securesettingspath = PROJECT_ROOT.parent.child("local")
sys.path.insert(0, securesettingspath)
from prod_security import *

ALLOWED_HOSTS = ['sthrep.test.portalverbund.gv.at']

# Python dotted path to the WSGI application used by Django's runserver.
WSGI_APPLICATION = 'sthrep.wsgi.application'


#MIDDLEWARE_CLASSES = DEFAULT_SETTINGS.MIDDLEWARE_CLASSES + (
#    'debug_toolbar.middleware.DebugToolbarMiddleware',
#)

#INSTALLED_APPS += (
    #'debug_toolbar',
#)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '%(module)s %(levelname)s %(asctime)s %(pathname)s %(message)s'
        }
    },
    'handlers': {
        'debuglog': {
            'level': 'DEBUG',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/sthrep/app.log',
            'maxBytes': 50000,
            'backupCount': 1,
            'formatter': 'verbose'
        }
    },
    'loggers': {
        # root logger
        '': {
            'handlers': ['debuglog'],
            'level': 'DEBUG',
            'propagate': True,
        },
        'django': {
            'handlers': ['debuglog'],
        },
        'django.db.backends': {
            'level': 'ERROR',
            'handers': ['debuglog'],
        },
    }
}

# required to start saml2test scripts with correct virtualenv - this
# cannot b derived from mod_wsgi and is specific for the target system
