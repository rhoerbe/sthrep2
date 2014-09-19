import copy, datetime, fcntl, glob, json, os, pprint, logging
import shlex, sys, subprocess, time, traceback
from django.contrib import admin
from django.contrib.messages import ERROR, SUCCESS
from django.core.urlresolvers import reverse
from django.db import transaction
from django.db.models import Count, Max
from django.forms import ModelForm, CharField, TextInput
from django.template import TemplateDoesNotExist
from sthrep.settings.common import OPER_STATUSCODE_EXT, OPER_STATUSCODE_INCOMPLETE
from sthrep.settings.common import TESTMGR_EXPORT, INVALID_KEYS, PYTHONEXE
from .testplanoperation import *
from .testplanconfiguration import *
from testmgr.models import *
from testmgr.testconf_default import *


logger = logging.getLogger(__name__)

class StopAction(Exception):
    """This action failed - see self.message_user"""
    pass


class TestPlanAdmin(admin.ModelAdmin):
    list_display = ('tp_name', 'tp_description', 'tt_type', 'samlprofile', 'show_num_opers', 'show_max_status', 'show_last_time')
    inlines = (TestPlanOperationResultInline,
               TestPlanOperationInline,
               TestPlanConfigInline, )
    fields = (('tp_name', 'tp_description', 'samlprofile'),
              ('tt_type', 'td_options'))
    class Media:
        css = { "all" : ("css/hide_admin_inline_original.css",) }

    def queryset(self, request):
        qs = super(TestPlanAdmin, self).queryset(request)
        qs1 = qs.annotate(max_status=Max('testplanoperation__last_run_status'),
                          last_time=Max('testplanoperation__last_run_time'))
        return qs1.annotate(num_opers=Count('testplanoperation'))

    # display number of samlprofiles and link to the list
    def show_num_opers(self, inst):
        return inst.num_opers
    show_num_opers.short_description = '# Operations'

    def show_max_status(self, inst):
        if inst.max_status:
            return OPER_STATUSCODE_EXT[inst.max_status]
        else:
            return None
    show_max_status.short_description = 'Result'

    def show_last_time(self, inst):
        return str(inst.last_time)[:19]
    show_last_time.short_description = 'Result'

# --------------------------------------------------------------------------------------------------
# action functions
# --------------------------------------------------------------------------------------------------

    def _copy_dict_val(self, _conf, key_name, val):
        "copy values from dictionary if key does exist in source"
        if isinstance(val, bool):
            if val is not None:
                if val is True:
                    _conf[key_name] = "True"
                else:
                    _conf[key_name] = "False"
        elif isinstance(val, (basestring, int)):
            if val:
                _conf[key_name] = val
        elif isinstance(val, (list, tuple)):
                if len(val) > 0 and val[0]:
                    _conf[key_name] = "[" + ', '.join(val) +  "]"
        elif not val:
            pass  # do not overwrite previous values if source value is empty or None
        else:
            self.message_user(request, "Unexpected type %s in config element" % \
                              val.__class__.__name__, level=ERROR)
            raise TypeError

    def _get_and_make_dirs(self, tr):
        """ create the export directories if tehy do not exist

        result: self._dir, self._logdir
        """
        self._dir = os.path.join(TESTMGR_EXPORT, tr.tp_name)
        self._logdir = os.path.join(TESTMGR_EXPORT, tr.tp_name, "log")
        try:
            if not os.path.exists(self._dir):
                os.makedirs(self._dir)
            if not os.path.exists(self._logdir):
                os.makedirs(self._logdir)
        except Exception as e:
            self.message_user(request, "creating export directories failed - see detail log", level=ERROR)
            raise StopAction

    def _write_config(self, template, _conf, output):
        """ create and write config file"""
        from django.template.loader import render_to_string
        from django.template import Context
        try:
            plaintext_context = Context(autoescape=False)  # no HTML escaping in plaintext
            f = open(output, 'w')
            f.write(render_to_string(template, _conf, plaintext_context))
            f.close()
        except TemplateDoesNotExist:
            self.message_user(request, "Template not found", level=ERROR)
            raise StopAction

    @transaction.atomic
    def duplicate(self, request, tr_qs):
        "action to duplicate a test run including related configs and operations"
        try:
            assert tr_qs.count() == 1
        except AssertionError:
            self.message_user(request, "'Duplicate' must have selected exactly one single test run", level=ERROR)
            raise
        try:
            tr_old = tr_qs[0]
            tr = copy.deepcopy(tr_old)
            tr.id = None
            l = tr.tp_name[-1:]
            if l in ('0', '1', '2', '3', '4', '5', '6', '7', '8'):
                tr.tp_name = tr.tp_name[:-1] + str(int(l) + 1)
            elif len(tr.tp_name) < (TestPlan._meta.get_field('tp_name').max_length - 1):
                tr.tp_name = tr.tp_name + '0'
            else:
                self.message_user(request, "Shorten name before duplicating", level=ERROR)
            tr.save()
            #copy relationships to test config and test operation
            for trc in TestPlanConfig.objects.filter(testplan=tr_old):
                trc.id = None
                trc.testplan = tr  # create new item with new foreign key
                trc.save()
            for tro in TestPlanOperation.objects.filter(testplan=tr_old):
                tro.id = None
                tro.testplan = tr  # create new item with new foreign key
                tro.last_run_time = None
                tro.last_run_status = None
                tro.last_run_summary = None
                tro.last_run_log = None
                tro.save()
            self.message_user(request, "%s created" % tr.tp_name, level=ERROR)
        except Exception as e:
            self.message_user(request, "Exception: %s" % str(e), level=ERROR)
            raise

    def export_single_testplanconfig(self, request, tr):
        """ Action to create td_config.py, tt_config.py

        (1) load the default values
        (2) iterate thru the test config values, overwriting the previous ones
        (3) write the file to the export directory
        """
        # starting with default values, loop over configurations, with latter
        # values overwriteing the former ones
        conf = conf_default.copy()
        trc_qs = TestPlanConfig.objects.filter(testplan=tr)
        if trc_qs.count() == 0:
            self.message_user(request, "Test run s% requires at least 1 test configuration", level=ERROR) % tr.tp_name
            raise StopAction
        for trc in trc_qs:
            if trc.testplan.tt_type != trc.tt_type:
                self.message_user(request, "Test target type must be same for test run and config", level=ERROR)
                raise StopAction
            # test-driver related parameters
            self._copy_dict_val(conf, "td_entityid", trc.testconfig.td_entityid)
            self._copy_dict_val(conf, "td_name", trc.testconfig.td_name)
            self._copy_dict_val(conf, "td_base_url", trc.testconfig.td_base_url)
            self._copy_dict_val(conf, "service_idp_policy_lifetime", trc.testconfig.service_idp_policy_lifetime)
            self._copy_dict_val(conf, "service_idp_policy_attribute_restrictions", trc.testconfig.service_idp_policy_attribute_restrictions)
            self._copy_dict_val(conf, "service_idp_name_id_format", trc.testconfig.service_idp_name_id_format)
            self._copy_dict_val(conf, "td_key_pem", trc.testconfig.td_key_pem)
            self._copy_dict_val(conf, "td_cert_pem", trc.testconfig.td_cert_pem)
            self._copy_dict_val(conf, "interaction_json", trc.testconfig.interaction_json)
            self._copy_dict_val(conf, "constraints_name_format", trc.testconfig.constraints_name_format)
            # test-target related parameters
            self._copy_dict_val(conf, "tt_entityid", trc.testconfig.tt_entityid)
            self._copy_dict_val(conf, "tt_name", trc.testconfig.tt_name)
            self._copy_dict_val(conf, "metadata_url", trc.testconfig.metadata_url)
            self._copy_dict_val(conf, "metadata_cache_duration", trc.testconfig.metadata_cache_duration)
            self._copy_dict_val(conf, "start_page", trc.testconfig.start_page)
            self._copy_dict_val(conf, "request_init", trc.testconfig.request_init)
            self._copy_dict_val(conf, "args_AuthnResponse_sign_assertion", trc.testconfig.args_AuthnResponse_sign_assertion)
            self._copy_dict_val(conf, "args_AuthnResponse_sign_response", trc.testconfig.args_AuthnResponse_sign_response)
            self._copy_dict_val(conf, "args_AuthnResponse_sign_digest_alg", trc.testconfig.args_AuthnResponse_sign_digest_alg)
            #self._copy_dict_val(conf, "args_AuthnResponse_sign_signature_alg", trc.testconfig.args_AuthnResponse_sign_signature_alg)
            self._copy_dict_val(conf, "args_AuthnResponse_authn", trc.testconfig.args_AuthnResponse_authn)
            self._copy_dict_val(conf, "identity", trc.testconfig.identity)
            self._copy_dict_val(conf, "userid", trc.testconfig.userid)
            self._copy_dict_val(conf, "echopageIdPattern", trc.testconfig.echopageIdPattern)
            self._copy_dict_val(conf, "echopageContentPattern", trc.testconfig.echopageContentPattern)
            self._copy_dict_val(conf, "constraints_authnRequest_signature_required", trc.testconfig.constraints_authnRequest_signature_required)
        # write td_config.py
        self._get_and_make_dirs(tr)
        self._tdconfig = os.path.join(self._dir, 'td_config.py')
        self._tdconfig_module = 'td_config'
        self._write_config('sptest_td_config.py', conf, self._tdconfig)
        # write tt_config.py
        self._ttconfig = os.path.join(self._dir, 'tt_config.py')
        self._write_config('sptest_tt_config.py', conf, self._ttconfig)
        # self.message_user(request, "export completed", level=SUCCESS)

    def export_testplanconfigs(self, request, tr_qs):
        "Action to loop over test runs and export configs"
        try:
            for tr in tr_qs:
                self.export_single_testplanconfig(request, tr)
        except TemplateDoesNotExist:
            return
        except Exception as e:
            self.message_user(request, traceback.format_exception(*sys.exc_info()), level=ERROR)
            return

    def run_single_test(self, request, tr):
        """Action to execute all active operations of a test run

        execute test:
            loop over the test run's operations:
                execute each on and save the result in the database
        """
        tro_qs_all = TestPlanOperation.objects.filter(testplan=tr)
        tro_qs = tro_qs_all.filter(status=STATUS_ACTIVE)
        if tro_qs.count() == 0:
            self.message_user(request, "Test run requires at least 1 active test operation", level=ERROR)
            raise StopAction
        for tro in tro_qs:
            tro.last_run_status = OPER_STATUSCODE_INCOMPLETE
            tro.last_run_time = datetime.datetime.now()
            tro.last_run_summary = ""
            tro.last_run_log = ""
            tro.save()
        self._get_and_make_dirs(tr)
        # lock test run
        self.pid_file = os.path.join(self._dir, 'testplan.pid')
        self.fp = open(self.pid_file, 'w')
        try:
            fcntl.lockf(self.fp, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except IOError:
            self.message_user(request, "only a single process can execute the selected testplan at a time", level=ERROR)
            raise
        # export config
        self.export_single_testplanconfig(request, tr)
        env = {}
        env.update(os.environ)
        #pythonexe = PYTHONEXE if PYTHONEXE else sys.executable # configure manually for subprocess in mod_wsgi environment
        pythonexe = PYTHONEXE
        # create tt_config.json
        tt_config_json = os.path.join(self._dir, "tt_config.json")
        tt_config_json_f = open(tt_config_json, "w")
        tt_config_err = tt_config_json + ".err"
        tt_config_err_f = open(tt_config_err, "w")
        cmd = "{py} {script}".format(py = pythonexe, script = self._ttconfig)
        logger.debug("executing config script: %s" % cmd)
        rc = subprocess.call(shlex.split(cmd), shell=False, env=env,
                             stdout=tt_config_json_f, stderr=tt_config_err_f)
        if os.path.getsize(tt_config_err) > 0:
            if not re.match('pydev debugger: process \d+ is connecting\s',
                            open(tt_config_err, 'r').read()):
                self.message_user(request, "execution of tt_config.py failed, see %s" % tt_config_err, level=ERROR)
                raise StopAction
        # prep command line
        bin = os.path.dirname(pythonexe)
        if tr.tt_type == 'IDP':
            td_script = os.path.join(bin, 'idp_testdrv.py')
        else:
            td_script = os.path.join(bin, 'sp_testdrv.py')
        options = ' '.join(tr.td_options)
        # execute operations
        for tro in tro_qs:
            tro.last_run_status = OPER_STATUSCODE_INCOMPLETE
            tro.last_run_time = datetime.datetime.now()
            tro.save()
            if tro.testplan.tt_type == 'IDP':
                oper = tro.idp_test_operation
            else:
                oper = tro.sp_test_operation
            cmd = "{py} {script} {opt} -I {invkeysdir} -P {tdconfpath} -k -L {logdir} -c {tdconf} -J {ttconf} {operation}".format(
                  py = pythonexe,
                  script = td_script,
                  opt = options,
                  invkeysdir = INVALID_KEYS,
                  tdconfpath = self._dir,
                  logdir = self._logdir,
                  tdconf = self._tdconfig_module,
                  ttconf = tt_config_json,
                  operation = oper)
            logsum_fn = os.path.join(self._logdir, oper + ".sum")
            logsum = open(logsum_fn, "w")
            logdetail_fn = os.path.join(self._logdir, oper + ".log")
            logdetail = open(logdetail_fn, "w")
            logger.debug("executing operation: %s" % cmd)
            rc = subprocess.call(shlex.split(cmd), shell=False, env=env,
                                 stdout=logsum, stderr=logdetail)
            tro.last_run_time = datetime.datetime.now()
            tro.last_run_status = 0
            if os.path.getsize(logsum_fn) > 0:
                tro.last_run_log = open(logdetail_fn, "r").read()
                try:
                    _x = tro.last_run_log.decode("utf_8")
                except UnicodeDecodeError as e:
                    self.message_user(request, "Operation %s producted logfile %s that is not well-formed Unicode: %s" %
                                      (tro.sequ, logdetail_fn, str(e)), level=WARNING)
                    tro.last_run_log = tro.last_run_log.decode("utf_8", 'ignore')
                tro.last_run_summary = open(logsum_fn, "r").read()
                try:
                    op_summary = json.loads(tro.last_run_summary)
                    tro.last_run_status = op_summary["status"]
                except Exception as e:
                    self.message_user(request, "Operation # %d did not return a JSON-formatted summary" % tro.sequ, level=ERROR)
                    tro.last_run_status = 0
                res_content_fn = glob.glob(os.path.join(self._logdir, oper, "response_*"))
                for n in range(0, len(res_content_fn)):
                    setattr(tro, 'last_run_response%d' % n, open(res_content_fn[n], 'r').read().decode("utf_8", 'ignore'))
                if len(res_content_fn) > 3:
                    self.message_user(request, "More than 3 response contents files; some not displayed" % tro.sequ, level=ERROR)
            else:
                tro.last_run_summary = "<empty>"
                tro.last_run_status = 0
                self.message_user(request, "Test Run Operation # %d failed - see detail log" % tro.sequ, level=ERROR)
                raise StopAction
            tro.save()
        # unlock the test run
        fcntl.lockf(self.fp, fcntl.LOCK_UN)
        self.fp.close()
        os.remove(self.pid_file)
        self.message_user(request, "test run s% completed" % tr.tp_name, level=SUCCESS)

    def run_tests(self, request, tr_qs):
        "Action to loop over test runs"
        try:
            for tr in tr_qs:
                self.run_single_test(request, tr)
        except StopAction:
            return
        except TypeError:
            return
        except TemplateDoesNotExist:
            return
        except Exception as e:
            self.message_user(request, traceback.format_exception(*sys.exc_info()), level=ERROR)
            return


    admin.site.disable_action("delete_selected")
    actions = [duplicate, export_testplanconfigs, run_tests, ]
    duplicate.short_description = "Duplicate test run including operations/configurations"
    export_testplanconfigs.short_description = "Export test configuration only"
    run_tests.short_description = "Run Test (including export config)"

admin.site.register(TestPlan, TestPlanAdmin)
