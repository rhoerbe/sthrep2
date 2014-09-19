from django.conf.urls import patterns, include, url
from django.views.generic import RedirectView
from django.contrib import admin
#from adminplus.sites import AdminSitePlus
import admin_tools.urls
from requmgr import views
#import registration.backends.default

#admin.site = AdminSitePlus()
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^requmgr/$', RedirectView.as_view(url='/')), # avoid navigation to app index dashboards, e.g. via breadcrumb links
    url(r'^testmgr/$', RedirectView.as_view(url='/')), # avoid navigation to app index dashboards, e.g. via breadcrumb links
    #url(r'^accounts/', include('registration.urls')), # deprecated in django-regsitration v0.8
    url(r'^accounts/', include('registration.backends.default.urls')),
    url(r'^admin_tools/', include(admin_tools.urls)),
    url(r'^doc/$', views.doc),
    url(r'^doc/workflow/$', views.workflow),
    url(r'^doc/structure/testplan/$', views.testplan),
    url(r'^doc/structure/operation/$', views.operation),
    url(r'^logout/$', 'django.contrib.auth.views.logout', {'next_page': '/bye/'}),
    url(r'^bye/$', views.bye),
    url(r'', include(admin.site.urls)),
    url(r'^sthrep/admin/doc/', include('django.contrib.admindocs.urls')),
    #url(r'', RedirectView.as_view(url='/sthrep/')),
)
