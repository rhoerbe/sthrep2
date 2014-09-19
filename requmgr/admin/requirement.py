from django.db.models import Count
from django.forms import ModelForm, TextInput, Textarea
from django.contrib import admin
#import reversion
from requmgr.models import *
from requmgr.admin.common import *

# set default not to show an action with delete items as action.
# caution!! erratic behavior - after some changes meodels disappear from Amin's app_index
# disable and re-enable did fix this so far
if 'delete_selected' in admin.site.actions:
    admin.site.disable_action('delete_selected')
# it can be re-enabled for a specific changelist with
# actions = ['delete_selected',]

class RequirementForm(ModelForm):
    class Meta:
        model = Requirement
        widgets = {
            'name': Textarea(attrs={'cols': 82, 'rows': 4}),
            'reference_location': TextInput(attrs={'size': 40,}),
        }


# TODO: add filter, and subclass for master/detail display from SAML-profiles and features
class RequirementAdmin(admin.ModelAdmin):
    list_per_page = 1000
    list_display = ('link_list', 'get_fg_id', 'get_f_id', 'id', 'name', 'operation_count', 'show_num_prof',)
    actions = None
    search_fields = ('feature__name', 'name', )
    form = RequirementForm
    fields = ('name',
              'feature',
              ('reference', 'reference_location'),
    )
    readonly_fields = ['operation_count',]
    save_on_top = True


    def queryset(self, request):
        qs = super(RequirementAdmin, self).queryset(request)
        return qs.annotate(num_prof=Count('samlprofile'))

    #Suppress the link in the first column
    def __init__(self, *args, **kwargs):
        super(RequirementAdmin, self).__init__(*args, **kwargs)
        self.list_display_links = [None, ]

    # display number of requirments and link to the list
    def link_list(self, inst):
        ll_html = '<a href="' + str(inst.id) + '/"><img class="resize34h" src="/static/sthrep/admin/doc-detail.png" alt="edit" title="edit"></a>'
        if inst.operation_count > 0:
            ll_html += '<a href="/testmgr/operation/?requirement=' + str(inst.id) + '"><img class="resize34h" src="/static/sthrep/admin/doc-op.png" alt="RQ" title="list related use cases"></a>' # TODO fix abs URL (get_absolute_url)
        if inst.num_prof > 0:
            ll_html += '<a href="/testmgr/samlprofile/?requirements=' + str(inst.id) + '"><img class="resize34h" src="/static/sthrep/admin/doc-pr.png" alt="SP" title="list related SAML profiles"></a>' # TODO fix abs URL (get_absolute_url)
        return ll_html
    link_list.short_description = ''
    link_list.allow_tags = True

    # display number of samlprofiles and link to the list
    def show_num_prof(self, inst):
        return inst.num_prof
    show_num_prof.short_description = '# used in SAML profiles'
    show_num_prof.allow_tags = True

    def get_f_id(self, inst):
        return inst.feature.f_id
    get_f_id.short_description = 'FeatId'

    def get_fg_id(self, inst):
        return inst.feature.featuregroup.fg_id
    get_fg_id.short_description = 'FeatGrp'

    def get_query_set(self):
        return super(Requirement, self).get_query_set().select_related('feature', )  # improve performance by joining related tables


admin.site.register(Requirement, RequirementAdmin)
