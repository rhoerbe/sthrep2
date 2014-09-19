# Django settings for sthrep project/development environment
# Structure: import, extend and overwirte common settings,
# Rainer Hoerbe, 22-05-2013

from unipath import Path
from os.path import abspath, dirname
from .common import *


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2', # Add 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'NAME': 'sthrep',                      # Or path to database file if using sqlite3.
        'USER': 'rhoerbe',                      # Not used with sqlite3.
        'PASSWORD': 'rhoerbe',                  # Not used with sqlite3.
        'HOST': 'localhost',                      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '',                      # Set to empty string for default. Not used with sqlite3.
    }
}

# Python dotted path to the WSGI application used by Django's runserver.
WSGI_APPLICATION = 'sthrep.wsgi.application'


STATIC_ROOT = PROJECT_ROOT.child("_deploy_outside").child("html").child("static")

MIDDLEWARE_CLASSES = DEFAULT_SETTINGS.MIDDLEWARE_CLASSES + (
    'debug_toolbar.middleware.DebugToolbarMiddleware',
)

# import django.conf.global_settings as DEFAULT_SETTINGS
TEMPLATE_CONTEXT_PROCESSORS = DEFAULT_SETTINGS.TEMPLATE_CONTEXT_PROCESSORS + (
    'django.core.context_processors.request',
    'django.core.context_processors.static',
    #"sthrep.context_processor.session",
)

INSTALLED_APPS += (
    'django.contrib.admin',
    'debug_toolbar',
)

INTERNAL_IPS = ('127.0.0.1',)  # required by debug_toolbar

DEBUG_TOOLBAR_PANELS = [
    #'debug_toolbar.panels.versions.VersionsPanel',
    #'debug_toolbar.panels.timer.TimerPanel',
    'debug_toolbar.panels.settings.SettingsPanel',
    'debug_toolbar.panels.headers.HeadersPanel',
    'debug_toolbar.panels.request.RequestPanel',
    'debug_toolbar.panels.sql.SQLPanel',
    'debug_toolbar.panels.staticfiles.StaticFilesPanel',
    'debug_toolbar.panels.templates.TemplatesPanel',
    'debug_toolbar.panels.cache.CachePanel',
    #'debug_toolbar.panels.signals.SignalsPanel',
    'debug_toolbar.panels.logging.LoggingPanel',
    'debug_toolbar.panels.redirects.RedirectsPanel',
]

DEBUG_TOOLBAR_CONFIG = {
    #'SHOW_TOOLBAR_CALLBACK': custom_show_toolbar,
    #'EXTRA_SIGNALS': ['myproject.signals.MySignal'],
    'INSERT_BEFORE': 'body',
    'ENABLE_STACKTRACES': True,
    }

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
            'filename': (PROJECT_ROOT.child('log').child('app.log')),
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
    }
}

#import logging
#logger = logging.getLogger(__name__)
#logger.debug("devl settings loaded")
