from django.db.models import Count
from django.forms import ModelForm, TextInput
from django.contrib import admin
#import reversion
from requmgr.models import *

# set default not to show an action with delete items as action.
# caution!! erratic behavior - after some changes meodels disappear from Amin's app_index
# disable and re-enable did fix this so far
if 'delete_selected' in admin.site.actions:
    admin.site.disable_action('delete_selected')
# it can be re-enabled for a specific changelist with
# actions = ['delete_selected',]

class FeatureGroupForm(ModelForm):
    class Meta:
        model = FeatureGroup
        fields = ('fg_id', 'name',)
        widgets = {
            'fg_id': TextInput(attrs={'size': 6,}),
            'name': TextInput(attrs={'size': 50}),
        }


class FeatureGroupAdmin(admin.ModelAdmin):
    list_display = ('link_list', 'fg_id', 'name', 'show_num_feat', )
    actions = None
    form = FeatureGroupForm

    def queryset(self, request):
        qs = super(FeatureGroupAdmin, self).queryset(request)
        return qs.annotate(num_feat=Count('feature'))

    #Suppress the link in the first column
    def __init__(self, *args, **kwargs):
        super(FeatureGroupAdmin, self).__init__(*args, **kwargs)
        self.list_display_links = [None, ]

    # display number of requirments and link to the list
    def link_list(self, inst):
        ll_html = '<a href="' + str(inst.id) + '/"><img class="resize34h" src="/static/sthrep/admin/doc-detail.png" alt="edit" title="edit"></a>'
        if inst.num_feat > 0:
            ll_html += '<a href="/requmgr/feature/?featuregroup=' + str(inst.id) + '"><img class="resize34h" src="/static/sthrep/admin/doc-f.png" alt="test plans" title="list test plans"></a>' # TODO fix abs URL (get_absolute_url)
        return ll_html
    link_list.short_description = ''
    link_list.allow_tags = True

    # display number of samlprofiles and link to the list
    def show_num_feat(self, inst):
        return inst.num_feat
    show_num_feat.short_description = '# Features'
    show_num_feat.allow_tags = True


admin.site.register(FeatureGroup, FeatureGroupAdmin)
