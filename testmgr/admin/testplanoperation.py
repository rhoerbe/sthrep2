import json
from django.contrib import admin
from django.core.urlresolvers import reverse
from django.forms import ModelForm
from django.forms import CharField, TextInput
from django.utils.html import format_html
from sthrep.settings.common import OPER_STATUSCODE_EXT
from sthrep.settings.common import IDP_TEST_OPER_LOOKUP, SP_TEST_OPER_LOOKUP
from testmgr.models import *

def prettyTable(listofdict):
    ''' pretty prints summary list of dictionaries into an HTML table '''
    s = ['<table>'
         '<tr><th>#</th><th>Status</th><th>Operation</th>'
         '<th>Description</th><th>Message</th></tr>']
    o = 1
    for i in listofdict:
        id = i.get("id")
        status = i.get("status")
        name = i.get("name")
        message = i.get("message", "")
        s.append('<td valign="top">%s</td>' % str(o))
        s.append('<td valign="top">%s</td>' % str(OPER_STATUSCODE_EXT[status]))
        s.append('<td valign="top">%s</td>' % str(id))
        s.append('<td valign="top">%s</td>' % str(name))
        s.append('<td valign="top">%s</td>' % str(message))
        s.append('</tr>')
        o += 1
    s.append('</table>')
    return ''.join(s)


class TestPlanConfigInline(admin.TabularInline):
    model = TestPlan.testconfig.through
    extra = 1
    readonly_fields = ('tt_type', )
    ordering = ('sequ', )
    verbose_name = "Configuration"
    verbose_name_plural = "Configurations of test drivers and targets"


class TestPlanOperationAdminForm(ModelForm):
    """ help to dynamically hide sp_test resp. idp_test fields
        depending on tt_tpye. possibly aa more elegant solution could be based on:
        https://stackoverflow.com/questions/2235503/django-admin-different-inlines-for-change-and-add-view
    """
    class Meta:
        widgets = {}
#       idp_test_operations.widget = idp_test_operations.hidden_widget()
        model = TestPlanOperation

    def __init__(self, *args, **kwargs):
        from django.forms.widgets import HiddenInput
        super(TestPlanOperationAdminForm, self).__init__(*args, **kwargs)
        if 'instance' in kwargs:
            if kwargs['instance'].testplan.tt_type == "SP":
                self.fields['idp_test_operation'].widget = HiddenInput()
            elif kwargs['instance'].testplan.tt_type == "IDP":
                self.fields['sp_test_operation'].widget = HiddenInput()


class TestPlanOperationInline(admin.TabularInline):
    model = TestPlanOperation
    extra = 1
    form = TestPlanOperationAdminForm
    ordering = ('sequ', )
    fields = ('sequ', 'idp_test_operation', 'sp_test_operation', 'status')
    verbose_name = "Operation"
    verbose_name_plural = "Operations"


class TestPlanOperationResultInline(admin.TabularInline):
    model = TestPlanOperation
    extra = 1
    ordering = ('sequ', )
    fields = ('admin_link', 'show_test_op', 'show_last_run_time', 'show_last_run_status', )
    readonly_fields = fields
    can_delete = False
    verbose_name = "Operation result"
    verbose_name_plural = "Results by operation"

    def show_test_op(self, inst):
        try:
            if inst.idp_test_operation:
                return "%s %s" % (inst.idp_test_operation,
                                  IDP_TEST_OPER_LOOKUP[inst.idp_test_operation])
            else:
                return "%s %s" % (inst.sp_test_operation,
                                  SP_TEST_OPER_LOOKUP[inst.sp_test_operation])
        except KeyError:
            return inst.idp_test_operation or inst.sp_test_operation
    show_test_op.short_description = "Operation"

    def show_last_run_time(self, inst):
        return str(inst.last_run_time)[:19]
    show_test_op.show_test_run_time = "Last run"

    def show_last_run_status(self, inst):
        if inst.last_run_status:
            return OPER_STATUSCODE_EXT[inst.last_run_status]
        else:
            return None
    show_last_run_status.short_description = "Result"

    def admin_link(self, instance):
        url = reverse('admin:%s_%s_change' % (instance._meta.app_label,
                                              instance._meta.module_name),
                      args=(instance.id,))
        #return format_html(u'<a href="{}">Detail</a>', url)
        return u'<a href="%s">Detail</a>' % url
    admin_link.short_description = ""
    admin_link.allow_tags = True

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj):
        return False


class TestPlanOperationResultForm(ModelForm):
    show_last_run_time = CharField(max_length = 3, label='l. run')
    show_test_op = CharField(label='op')

    class Meta:
        widgets = {'sequ': TextInput(attrs={'size': 7})
        }



class TestPlanOperationResultAdmin(admin.ModelAdmin):
    "Show the result of a test run with summary and detail log (no add/change/delete)"
    form = TestPlanOperationResultForm
    fields = ('testplan',
              ('show_test_op', 'sequ', 'show_last_run_time', 'show_last_run_status'),
              'show_last_run_summary',
              'last_run_log',
              'last_run_response0',
              'last_run_response1',
              'last_run_response2',
    )
    readonly_fields = ('testplan',
              'show_test_op', 'sequ', 'show_last_run_time', 'show_last_run_status',
              'show_last_run_summary',
              'last_run_log',
              'last_run_response0',
              'last_run_response1',
              'last_run_response2',
    )

    def get_fieldsets(self, request, obj=None):
        fieldsets = super(TestPlanOperationResultAdmin, self).get_fieldsets(request, obj)
        fieldsets[0][1]['fields'] += ('show_last_run_time', 'show_test_op', )
        return fieldsets

    def show_last_run_time(self, inst):
        return str(inst.last_run_time)[:19]
    show_last_run_time.short_description = "Last run"

    def show_test_op(self, inst):
        return inst.idp_test_operation or inst.sp_test_operation;
    show_test_op.short_description = "Operation"

    def show_content_dumps(self, inst):
        'iterate content log dir and reder links to th'
        return "";
    show_content_dumps.short_description = "Response content"

    def show_last_run_status(self, inst):
        return OPER_STATUSCODE_EXT[inst.last_run_status]
    show_last_run_status.short_description = "Result"

    def show_last_run_summary(self, inst):
        sum = json.loads(inst.last_run_summary)
        x = prettyTable(sum["tests"])
        return prettyTable(sum["tests"])
    show_last_run_summary.allow_tags = True
    show_last_run_summary.short_description = "Summary log"

    def has_add_permission(self, request):
        return False

    #def has_change_permission(self, request, obj=None):
    #    return False

    def has_delete_permission(self, request, obj=None):
        return False

admin.site.register(TestPlanOperation, TestPlanOperationResultAdmin)