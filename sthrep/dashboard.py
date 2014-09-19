from django.utils.translation import ugettext_lazy as _
from django.core.urlresolvers import reverse
from admin_tools.dashboard import modules, Dashboard, AppIndexDashboard
from admin_tools.utils import get_admin_site_name


class CustomIndexDashboard(Dashboard):
    """
    Custom index dashboard for sthrep.
    """
    columns = 1
    title = ''

    def init_with_context(self, context):
        site_name = get_admin_site_name(context)
        # append a link list module for "quick links"
        # self.children.append(modules.LinkList(
        #     title=_('Quick links'),
        #     layout='inline',
        #     draggable=False,
        #     deletable=False,
        #     collapsible=False,
        #     children=[
        #         [_('Change password'),
        #          reverse('%s:password_change' % site_name)],
        #         [_('Log out'), reverse('%s:logout' % site_name)],
        #     ]
        # ))


        # append another link list module for "documentation and support".
        self.children.append(modules.LinkList(
            _('Documentation and Support'),
            draggable=False,
            deletable=False,
            collapsible=False,
            column=1,
            children=[
                {
                    'title': _('SAML Test Harness'),
                    'url': '/doc/',
                    'external': False,
                },
            ]
        ))

        # append an app list module for "Applications"
        self.children.append(modules.AppList(
            title=_('Requirements'),
            draggable=False,
            deletable=False,
            collapsible=False,
            models=('requmgr.models.FeatureGroup',
                    'requmgr.models.Requirement',
            ),
        ))

        self.children.append(modules.AppList(
            title=_('Test Manager'),
            draggable=False,
            deletable=False,
            collapsible=False,
            models=['testmgr.models.SamlProfile',
                    'testmgr.models.TestPlan',
                    'testmgr.models.Operation',
                    'testmgr.models.TestConfig',
            ],
        ))

        # append an app list module for "Administration"
        self.children.append(modules.AppList(
            title=_('User Administration'),
            models=('django.contrib.*',),
        ))



    class Media:
        css = ('sthrep/sthrep_dashboard.css',)


class CustomAppIndexDashboard(AppIndexDashboard):
    """
    Custom app index dashboard for sthrep.
    """

    # we disable title because its redundant with the model list module
    title = ''

    def __init__(self, *args, **kwargs):
        AppIndexDashboard.__init__(self, *args, **kwargs)

        # append a model list module and a recent actions module
        self.children += [
            #modules.ModelList(self.app_title, self.models),
            modules.ModelList(
                title='Repository Manager',
                models=('requmgr.models.FeatureGroup',
                        'requmgr.models.Requirement',
                        'testmgr.models.SamlProfile',
                        'testmgr.models.TestPlan',
                        'testmgr.models.Operation',
                        'testmgr.models.TestConfig',
                ),
            )
        ]

    def init_with_context(self, context):
        """
        Use this method if you need to access the request context.
        """
        return super(CustomAppIndexDashboard, self).init_with_context(context)
