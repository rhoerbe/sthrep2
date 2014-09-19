from django.contrib import admin
from django.db.models import Count
from django.forms import ModelForm, Textarea, TextInput, ModelMultipleChoiceField
from django.forms.widgets import CheckboxSelectMultiple
from testmgr.models import *
from .common import *


class TestConfigAdminForm(ModelForm):
    class Meta:
        model = TestConfig
        widgets = {
            'tc_name': TextInput(attrs={'size': 20,}),
            'tc_description': TextInput(attrs={'size': 100,}),
            'tt_entityid': TextInput(attrs={'size': 60,}),
            'td_entityid': TextInput(attrs={'size': 60,}),
            'start_page': TextInput(attrs={'size': 60,}),
            'metadata_url': TextInput(attrs={'size': 60,}),
            'echopageIdPattern': Textarea(attrs={'cols': 82, 'rows': 1}),
            'echopageContentPattern': Textarea(attrs={'cols': 82, 'rows': 2}),
        }


class TestConfigAdmin(admin.ModelAdmin):
    form = TestConfigAdminForm
    list_per_page = PAGING_SIZE
    list_display = (
        # section C:  fields common to all test cases
        'tc_name',
        'tc_description',
        'tt_type',
        'td_name',
        'tt_name',
    )
    order = 'tc_name',
    verbose_name = "Configuration"
    verbose_name_plural = "Configurations"
    fieldsets = (
        ('Test Configuration', {
            'fields': ('tc_name', 'tc_description', 'tt_type', )}),
        ('Test Target', {
            'fields': (
                'tt_entityid',
                'tt_name',
                'start_page',
                ('metadata_url', 'metadata_cache_duration'),
                'constraints_signature_algorithm',
                'constraints_digest_algorithm',
            )}),
        ('Test Driver', {
            'fields': (
                'td_entityid',
                'td_name',
                'td_key_pem',
                'td_cert_pem',
                #'attribute_map',
                #'td_organization',
                #'td_contact',
            )}),
        #('IDP Test', { 'classes': ('collapse',),
        #    'fields': (
                #'only_use_keys_in_metadata',
                #'accepted_time_diff',
                #'interaction_json',
                #'constraints_name_format',
        #    )}),
        ('SP Test', {
            'fields': (
                'td_base_url',
                'service_idp_policy_lifetime',
                'service_idp_policy_attribute_restrictions',
                'service_idp_policy_name_form',
                'service_idp_name_id_format',
                #'request_init',
                ('args_AuthnResponse_sign_assertion', 'args_AuthnResponse_sign_response'),
                #('args_AuthnResponse_sign_digest_alg', 'args_AuthnResponse_sign_signature_alg'),
                #'args_AuthnResponse_authn',
                'identity',
                'userid',
                'echopageIdPattern',
                'echopageContentPattern',
                'constraints_authnRequest_signature_required',
            )}),
        )


admin.site.register(TestConfig, TestConfigAdmin)
