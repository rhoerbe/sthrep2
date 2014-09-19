from django.forms import ModelForm, Textarea, TextInput, ModelChoiceField
from django.contrib import admin
from testmgr.models import *
from .common import *
#from sthrep.settings.common import IDP_TEST_OPERATIONS, SP_TEST_OPERATIONS


class OperationAdminForm(ModelForm):
    class Media:
        fields = ('operation_id', 'name', 'target_type', 'requirement', 'operation', )
        #widgets = { # was ignored -> set in ModelAdmin.formfield_for_dbfield()
        #    'name': Textarea(attrs={'cols': 82, 'rows': 4}), }
        css = {"all": ("/static/sthrep/admin/testmgr/OperationAdminForm.css", )}
    # tell the requirements dropdown list not to fetch features per requirement:
    class Meta:
        model = Operation
    requirement = ModelChoiceField(queryset=Requirement.objects.select_related().all())



class OperationAdmin(admin.ModelAdmin):
    list_per_page = 1000
    list_display = ('link_list', 'show_operation_id', 'name',
                    'show_target_type', 'requirement', 'todo_teaser')
    list_filter = ('target_type', )
    search_fields = ('operation_id', 'name', 'target_type', 'description', 'todo', 'expected_behavior')
    #form = OperationAdminForm

    def get_query_set(self):
        qs = super(Operation, self).get_query_set().select_related('requirement', )  # db performance++
        return qs

    # computed columns -------------------------------------------------------------------------------------------------
    def __init__(self, *args, **kwargs):  # suppress auto list_display_links
        super(OperationAdmin, self).__init__(*args, **kwargs)
        self.list_display_links = [None, ]

    def link_list(self, inst):  # compute link column with icons
        return '<a href="#" onclick="location.href=location.pathname+\'' + \
               str(inst.id) + \
               '/?ret=\'+encodeURIComponent(location.pathname+location.search); return false;">' + \
               '<img class="resize34h" src="/static/sthrep/admin/doc-detail.png" alt="edit" title="edit"></a>'
        ll_html = '<a href="' + str(inst. id) + '/"></a>'
        return ll_html
    link_list.short_description = ''
    link_list.allow_tags = True

    def show_operation_id(self, inst): # shorten column heading, leaving form field label intact
        return inst.operation_id
    show_operation_id.short_description = 'UCase Id'
    show_operation_id.allow_tags = True

    def show_target_type(self, inst):  # shorten column heading, leaving form field label intact
        return inst.target_type
    show_target_type.short_description = 'Target'

    # pass return URL in extra context to detail form (to save state)
    def change_view(self, request, object_id, form_url='', extra_context=None):
        extra_context = extra_context or {}
        extra_context['retURL'] = request.get_full_path()
        return super(OperationAdmin, self).change_view(request, object_id, form_url=form_url, extra_context=extra_context)

    # detail form customization ----------------------------------------------------------------------------------------
    formfield_overrides = {
        models.TextField: {'widget': Textarea(attrs={'rows': 3, 'cols': 120})},
    }
    fields = (('operation_id', 'target_type', 'version'),
              'name',
              'description',
              #('operation', 'target_type'),
              'requirement',
              'todo',
    )
    save_on_top = False  # buttons on top would be nice, but must have same layout (including back button) as on bottom

    # field formatting
    def formfield_for_dbfield(self, db_field, **kwargs):
        formfield = super(OperationAdmin, self).formfield_for_dbfield(db_field, **kwargs)
        if db_field.name in ('name', 'description'):
            formfield.widget = Textarea(attrs={'cols': 115, 'rows': 2})
        if db_field.name in ('operation_id', 'version'):
            formfield.widget = TextInput(attrs={'size': 10})
        if db_field.name == 'todo':
            formfield.widget = Textarea(attrs={'cols': 80, 'rows': 2})
        return formfield


admin.site.register(Operation, OperationAdmin)
