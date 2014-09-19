from django.contrib import admin
from django.db.models import Count
from django.forms import ModelForm
from django.forms.widgets import Textarea
from testmgr.models import *
from .common import *


class SamlProfileAdminForm(ModelForm):
    class Meta:
        model = SamlProfile
        widgets = {'description': Textarea(attrs={'cols': 120, 'rows': 3,}),}
    class Media:
        css = {"all": ("/static/sthrep/admin/requmgr/SamlProfileAdminForm.css",)}


class SamlProfileAdmin(admin.ModelAdmin):
    list_display = ('link_list', 'name', 'show_num_testplans', 'show_num_req', )  # 'samlprofiles'
    actions = None
    list_per_page = PAGING_SIZE
    form = SamlProfileAdminForm
    filter_horizontal = ('requirements',)
    readonly_fields = ['testplan_count',]

    def queryset(self, request):
        qs = super(SamlProfileAdmin, self).queryset(request)
        return qs.annotate(num_req=Count('requirements'))  # add requ count

    #Suppress the link in the first column
    def __init__(self, *args, **kwargs):
        super(SamlProfileAdmin, self).__init__(*args, **kwargs)
        self.list_display_links = [None, ]

    # display links as icons
    def link_list(self, inst):
        ll_html = '<a href="' + str(inst.id) + '/"><img class="resize34h" src="/static/sthrep/admin/doc-detail.png" alt="edit" title="edit"></a>'
        if inst.testplan_count > 0:
            ll_html += '<a href="/testmgr/testplan/?samlprofile=' + str(inst.id) + '"><img class="resize34h" src="/static/sthrep/admin/doc-tp.png" alt="test plans" title="list test plans"></a>' # TODO fix abs URL (get_absolute_url)
        if inst.num_req > 0:
            ll_html += '<a href="/requmgr/requirement/?samlprofile=' + str(inst.id) + '"><img class="resize34h" src="/static/sthrep/admin/doc-rq.png" alt="requirements" title="list requirements"></a>' # TODO fix abs URL (get_absolute_url)
        return ll_html
    link_list.short_description = ''
    link_list.allow_tags = True

    def show_num_req(self, inst):
        return inst.num_req
    show_num_req.short_description = '# Requirements'

    def show_num_testplans(self, inst):
        return inst.testplan_count
    show_num_testplans.short_description = '# Test Plans'

    # pass return URL in extra context to detail form (to save state)
    def change_view(self, request, object_id, form_url='', extra_context=None):
        extra_context = extra_context or {}
        extra_context['retURL'] = request.get_full_path()
        return super(SamlProfileAdmin, self).change_view(request, object_id, form_url=form_url, extra_context=extra_context)


admin.site.register(SamlProfile, SamlProfileAdmin)
