import re
from django.core.exceptions import ValidationError
from django.core.validators import RegexValidator, URLValidator
from django.db import models
from multiselectfield import MultiSelectField
from requmgr.models import Requirement
from testmgr.lib.get_teaser import get_teaser
from xmldsig import DIGEST_AVAIL_ALG, SIG_AVAIL_ALG
from saml2.saml import NAMEID_FORMATS_SAML2, NAME_FORMATS_SAML2
from sthrep.settings.common import IDP_TEST_OPERATIONS, SP_TEST_OPERATIONS

STATUS_ACTIVE = 'active'
STATUS_CHOICES = ((STATUS_ACTIVE, STATUS_ACTIVE),('inactive', 'inactive'))
TT_TYPE_CHOICES = (('IDP', 'IDP Test'),('SP', 'SP Test'))


class SamlProfile(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=20, unique=True)
    description = models.TextField(null=True, blank=True)
    samlprofiles = models.ForeignKey('self', null=True, blank=True, help_text='Select a SAML Profile that serves as a base profile')
    requirements = models.ManyToManyField(Requirement)
    testplan_count = models.IntegerField(default=0)  # maintained by Postgres Triggers as stored count (TestPlan)

    class Meta:
        verbose_name = 'SAML Profile'
        ordering = ['name']

    def __unicode__(self):
        return self.name


TARGET_TYPE_CHOICES = (
        ('DS', 'DS'),
        ('IDP', 'IDP'),
        ('SP', 'SP'),
    )




class Operation(models.Model):
    id = models.AutoField(primary_key=True)
    operation_id = models.CharField(max_length=10, unique=True, help_text='Abbreviated and/or numbered id of operation')
    operation = models.CharField(max_length=30, unique=True, help_text='name to execute this operation in the backend')
    name = models.CharField(max_length=250, unique=True, help_text='Human readable unique name of operation')
    version = models.CharField(max_length=10, null=True, blank=True)
    description = models.TextField(null=True, blank=True, help_text='If name and structure are not sufficient to describe the operation, add some text here')
    target_type = models.CharField(max_length=3, choices=TARGET_TYPE_CHOICES)
    expected_behavior = models.TextField(blank=True, help_text='Textual description of the prescribed test result')
    requirement = models.ForeignKey(Requirement)
    todo = models.TextField(null=True, blank=True, help_text='note of issues to be resoved or tasks to be done for this piece of code')
    AVAILABILITY_CHOICES = (
        ('plan', 'planned'),
        ('devl', 'in development'),
        ('rel', 'released'),
    )

    class Meta:
        verbose_name = 'Operation'
        ordering = ['operation_id']

    def __unicode__(self):
        return self.operation_id + ': ' + self.name + ' (' + self.target_type + ')'

    def todo_teaser(self):
        return get_teaser(self.todo, 40)
    todo_teaser.short_description = 'To Do'


# db-based redefinition of intermediary table with addtional column "relevance"
# rationale: allow additional field without sacrifying the filter_horizontal widget
#class VTestPlanOperationAssignment(models.Model):
#    id = models.AutoField(primary_key=True)
#    testplan = models.ForeignKey(TestPlan)
#    operation = models.ForeignKey(Operation)
#    RELEVANCE_CHOICES = (
#        ('MUST', 'MUST'),
#        ('SHOULD', 'SHOULD'),
#        ('MAY', 'MAY'),
#        ('N/A', 'N/A'), )
#    relevance = models.CharField(max_length=6, choices=RELEVANCE_CHOICES, help_text='specify if the operation MUST/SHOULD/MAY succeed in this profile, or if it is n/a')
#
#    class Meta:
#        verbose_name = 'Test Plan - Use Case Assignment'
#        db_table = 'v_testmgr_testplan_operation'


def trail_slash_validator(val):
     """regexvalidator did not work as expected, using this instead
         problem: RegexValidator(regex=r'.*/$', message='trailing / not allowed')
         in variations does not match at all or always matches
     """
     if re.match('.*/$', val):
         raise ValidationError("Must not have trailing '/'")

class TestConfig(models.Model):
    # section C:  fields common to all test cases
    CONSTR_SIG_CHOICES = (('always', 'always'),('never', 'never'))
    id = models.AutoField(primary_key=True)
    tc_name = models.CharField(unique=True, max_length=20, verbose_name="TC name", help_text="Short descriptive name of this test configuration")
    tc_description = models.CharField(max_length=100, verbose_name="Description", help_text="Short narrative describing this test configuration")
    tt_type = models.CharField(max_length=3, choices=TT_TYPE_CHOICES,
                               verbose_name="TT Type", help_text="Entity type of test target")
    # All fields below have to be optional to allow easy extension by stacking test configurations
    td_entityid = models.CharField(null=True, blank=True, max_length=100, verbose_name="entityID", help_text="The test driver's entityID")
    td_name = models.CharField(null=True, blank=True, max_length=50, verbose_name="Name", help_text="The test driver's short name (e.g. FQHN, used for the test UI)")
    tt_entityid = models.CharField(null=True, blank=True, max_length=100, verbose_name="entityID", help_text="The test target's entityID")
    tt_name =  models.CharField(null=True, blank=True, max_length=50, verbose_name="Name", help_text="The test target's The test driver's short name (e.g. FQHN, used for the test UI)")
    metadata_url = models.CharField(null=True, blank=True, max_length=200,
        validators=[URLValidator()],
        verbose_name="Metadata URL",
        help_text="URL of the metadata feed containing the target's EntityDescriptor")
    metadata_cache_duration = models.IntegerField(null=True, blank=True, verbose_name="MD cache duration", help_text="Interval in minutes that the test runner will cache downloaded metadata")
    constraints_signature_algorithm = MultiSelectField(max_length=1000, null=True, blank=True,
        verbose_name="Allowed sign. alg",
        choices=SIG_AVAIL_ALG)
    constraints_digest_algorithm = MultiSelectField(max_length=1000, null=True, blank=True,
        choices=DIGEST_AVAIL_ALG,
        verbose_name="Allowed digest alg")
    # section D/all: common TD fields for all test cases
    td_key_pem = models.TextField(null=True, blank=True, verbose_name="TD private key", help_text="Paste the PEM-coded private key of the test driver here")
    td_cert_pem = models.TextField(null=True, blank=True, verbose_name="TD certificate", help_text="Paste the PEM-coded certificate of the test driver here")
    attribute_map = models.TextField(null=True, blank=True, verbose_name="Attribute map", help_text="Pysaml2 attribute map as python source code. If empty the pysaml2 default will be used.")
    td_organization = models.TextField(null=True, blank=True, verbose_name="TD organization", help_text="TD EntityDescriptor's organization attribute, in python source code for pysaml2")
    td_contact = models.TextField(null=True, blank=True, verbose_name="TD contact", help_text="TD EntityDescriptor's contact attribute, in python source code for pysaml2")
    # section D/IDP: common TD fields for IDP test cases
    # p = re.compile("/$")  ### RegexValidator([p, "Must not have trailing '/'"])
    td_base_url = models.CharField(null=True, blank=True, max_length=100,
        validators=[URLValidator(message='correct URL without trailing / required'),
                    trail_slash_validator,],
        verbose_name="TD IDP base URL",
        help_text="Base URL to be used a prefix for the IDP's endpoint paths (not trailing / allowed)")
    only_use_keys_in_metadata = models.NullBooleanField(null=True, blank=True, verbose_name="MD key validation only", help_text="If true it ignore the validation path of signing keys")
    accepted_time_diff = models.IntegerField(null=True, blank=True, verbose_name="Max time slack", help_text="Max. accepted time slack between test driver and target in seconds")
    # section D/SP: common TD fields for SP test cases
    service_idp_policy_lifetime = models.IntegerField(null=True, blank=True, verbose_name="Assertion life time", help_text="Assertion lifetime in minutes")
    service_idp_policy_attribute_restrictions = models.TextField(null=True, blank=True, verbose_name="ARP", help_text="Attribute release policy as python source code for pysaml2. If empty all available attributes will be released.")
    service_idp_policy_name_form = models.CharField(null=True, blank=True, max_length=60,
        choices=NAME_FORMATS_SAML2,
        verbose_name="Name format",
        help_text="Attribute name-format to be used when sending assertions")
    service_idp_name_id_format = MultiSelectField(max_length=500, null=True, blank=True,
      verbose_name="Allowed NameID Formats",
      choices=NAMEID_FORMATS_SAML2)
    # section T/all: common TD fields for all test cases
    td_metadata_update_url = models.URLField(null=True, blank=True,
        validators=[URLValidator()],
        verbose_name="Metadata update service URL",
        help_text="Location to PUT an updated version of the driver's EntityDescriptor that will immediately appear on the feed")
    # section T/IDP: common TD fields for IDP test cases
    interaction_json = models.TextField(null=True, blank=True, verbose_name="Interaction", help_text="Saml2test interaction configuration fragment as python source code")
    constraints_name_format = models.CharField(null=True, blank=True, max_length=60, verbose_name="Name format", help_text="Attribute name-format required when validating assertions")
    # section T/SP: common TD fields for SP test cases
    start_page = models.URLField(null=True, blank=True,
        validators=[URLValidator()], help_text="URL to start the test interaction")
    request_init = models.NullBooleanField(help_text="Use request initiation protocol")
    args_AuthnResponse_sign_assertion = models.CharField(null=True, blank=True, max_length=6,
        choices=CONSTR_SIG_CHOICES, verbose_name="Sign assertion")
    args_AuthnResponse_sign_response = models.CharField(null=True, blank=True, max_length=6,
        choices=CONSTR_SIG_CHOICES, verbose_name="Sign response")
    args_AuthnResponse_sign_digest_alg = MultiSelectField(null=True, blank=True, max_length=1000,
        choices=DIGEST_AVAIL_ALG, verbose_name="Allowed digest algs")
    args_AuthnResponse_sign_signature_alg = MultiSelectField(null=True, blank=True, max_length=1000,
        choices=SIG_AVAIL_ALG, verbose_name="Allowed sign. algs")
    args_AuthnResponse_authn = models.TextField(null=True, blank=True, verbose_name="Authn configuration", help_text="Saml2test authn configuration fragment as python source code")
    identity = models.TextField(null=True, blank=True, verbose_name="Identity configuration", help_text="Saml2test user identity configuration fragment")
    userid = models.CharField(null=True, blank=True, max_length=40, help_text="userid to be issued in the assertion")
    echopageIdPattern = models.TextField(null=True, blank=True, verbose_name="Response page identifier", help_text="string to be found in the target SP's result page")
    echopageContentPattern = models.TextField(null=True, blank=True, verbose_name="Reponse content patterns", help_text="list of petterns to be found in the target SP's result page (as saml2test configuration fragment")
    constraints_authnRequest_signature_required = models.NullBooleanField(verbose_name="Want authnRequest signed", help_text="Signature required on authnRequest")

    class Meta:
        ordering = ['tc_name',]

    def __unicode__(self):
        return "%s: %s" % (self.tc_name, self.tc_description)


class TestPlan(models.Model):
    id = models.AutoField(primary_key=True)
    tp_name = models.SlugField(max_length=20, verbose_name="Name", help_text="Short descriptive name of this test run; will be sued as prefix in exports directory.")
    tp_description = models.CharField(max_length=100, verbose_name="Description", help_text="Short narrative describing this test run")
    testconfig = models.ManyToManyField(TestConfig,
        related_name='test_runs', through='TestPlanConfig')
    tt_type = models.CharField(blank=False, max_length=3,
        choices=TT_TYPE_CHOICES,
        verbose_name="TT Type",
        help_text="Entity type of test target")
    TD_OPTIONS = (
         ("-Y", "Print PySAML2 debug information"),
         ("-i", "insecure - do not check SSL certificates"),
    )    # ("-H", "pretty print summary output"), # sthrep requires JSON output!
    td_options = MultiSelectField(max_length=20, null=True, blank=True,
        verbose_name="test driver command line options",
        choices=TD_OPTIONS)
    samlprofile = models.ForeignKey(SamlProfile, null=True, blank=True)

    class Meta:
        ordering = ['tp_name',]


    def __unicode__(self):
        return self.tp_name


class TestPlanConfig(models.Model):
    sequ = models.PositiveIntegerField()
    testplan = models.ForeignKey(TestPlan)
    testconfig = models.ForeignKey(TestConfig)

    class Meta:
        ordering = ['sequ',]

    def _get_tt_type(self):
        return self.testconfig.tt_type
    tt_type = property(_get_tt_type)

    def __unicode__(self):
        return "%d|%s|%s|%s" % (self.sequ, self.testconfig.tc_description, self.testconfig.tt_type, self.testplan.tp_name)



class TestPlanOperation(models.Model):
    sequ = models.PositiveIntegerField()
    testplan = models.ForeignKey(TestPlan)
    idp_test_operation = models.CharField(max_length=50, null=True, blank=True, verbose_name="IDP test operations", choices=IDP_TEST_OPERATIONS)
    sp_test_operation = models.CharField(max_length=50, null=True, blank=True, verbose_name="SP test operations", choices=SP_TEST_OPERATIONS)
    status = models.CharField(max_length=8, default="active", choices=STATUS_CHOICES)
    last_run_time = models.DateTimeField(null=True, verbose_name="Start time", help_text="Time when the test run was started")
    last_run_status = models.PositiveIntegerField(null=True, verbose_name="Result", help_text="Result of the last test run")
    last_run_summary = models.TextField(null=True, default="", verbose_name="Summary log", help_text="The operation's result from the last excution")
    last_run_log = models.TextField(null=True, blank=True, default="", verbose_name="Detail log", help_text="Log output of the last test run")
    last_run_response0 = models.TextField(null=True, blank=True, default="", verbose_name="Response 1 contents")
    last_run_response1 = models.TextField(null=True, blank=True, default="", verbose_name="Response 1 contents")
    last_run_response2 = models.TextField(null=True, blank=True, default="", verbose_name="Response 2 contents")

    class Meta:
        ordering = ['sequ',]

    def __unicode__(self):
        return "%d, tr_id: %s|%s" % (self.sequ, self.testplan.id, self.status)
