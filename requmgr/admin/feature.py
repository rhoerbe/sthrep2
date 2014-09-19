from django.db.models import Count
from django.forms import ModelForm, TextInput
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


class FeatureForm(ModelForm):
    class Meta:
        model = Feature
        fields = ('f_id', 'name',)
        widgets = {
            'f_id': TextInput(attrs={'size': 8,}),
            'name': TextInput(attrs={'size': 50}),
        }


class FeatureAdmin(admin.ModelAdmin):
    list_display = ('link_list', 'featuregroup', 'f_id', 'name', 'show_num_req',)
    actions = None
    form = FeatureForm

    def queryset(self, request):
        qs = super(FeatureAdmin, self).queryset(request)
        return qs.annotate(num_req=Count('requirement'))

    #Suppress the link in the first column
    def __init__(self, *args, **kwargs):
        super(FeatureAdmin, self).__init__(*args, **kwargs)
        self.list_display_links = [None, ]

    # display number of requirments and link to the list
    def link_list(self, inst):
        ll_html = '<a href="' + str(inst.id) + '/"><img class="resize34h" src="/static/sthrep/admin/doc-detail.png" alt="edit" title="edit"></a>'
        if inst.num_req > 0:
            ll_html += '<a href="/requmgr/requirement/?feature=' + str(inst.id) + '"><img class="resize34h" src="/static/sthrep/admin/doc-rq.png" alt="requirements" title="list requirements"></a>' # TODO fix abs URL (get_absolute_url)
        return ll_html
    link_list.short_description = ''
    link_list.allow_tags = True

    # display number of samlprofiles and link to the list
    def show_num_req(self, inst):
            return inst.num_req
    show_num_req.short_description = '# Requirements'
    show_num_req.allow_tags = True


class FeatureSubset(Feature):  # useful to support a second ModelAdmin instance in admin
    class Meta:
        proxy = True

    def get_model_perms(self, request):
        """
        Return empty perms dict thus hiding the model from admin index.
        """
        return {}


# Model to display features for a single feature group
class FeatureSubsetAdmin(admin.ModelAdmin):
    list_display = ('f_id', 'name',)
    list_display_links = list_display




admin.site.register(Feature, FeatureAdmin)
admin.site.register(FeatureSubset, FeatureSubsetAdmin)
