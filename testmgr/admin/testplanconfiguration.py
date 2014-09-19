from django.contrib import admin
from testmgr.models import TestPlan

class TestPlanConfigInline(admin.TabularInline):
    model = TestPlan.testconfig.through
    extra = 1
    readonly_fields = ('tt_type', )
    ordering = ('sequ', )
    verbose_name = "Configuration"
    verbose_name_plural = "Configurations of test drivers and targets"
