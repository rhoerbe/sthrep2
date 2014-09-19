# Generate Use Case, Test Class and the intermediate tables for the PreTest, SamlRequest and PostTest relationships
# Use Case has id sequence numbers from the input, TestClass does not and it has to be generated here
# Rainer Hoerbe 2013-04-12

import csv
from repairfmt import repair_fmt  # fix quotes and excel export bugs


TCase_template = "INSERT INTO testmgr_usecase(id, usecase_id, name, target_type, requirement_id, expected_behavior, description) VALUES ({}, '{}', '{}', '{}', {}, '{}', '{}');"

#Column indices from input data
TCase_fk_index = 4
TCase_shortid_index = 6
TCase_pk_index = 7
TCase_operation_index = 15
TCase_samlrequ_index = 18
TCase_pretest_index = 19
TCase_posttest_index = 20

TCase_without_dups = {}


with open('../../data/PVP2S_tests.csv', 'rb') as f:
    next(f) # header row1 not used
    next(f) # header row2 not used
    reader = csv.reader(f, delimiter=';')
    for row in reader:
        #(debug) print row[pk_index] + ' :: ' + str(row)
        TCase_without_dups[int(row[TCase_pk_index])] = row

# create usecase INSERTs
for k, row in sorted(TCase_without_dups.iteritems()):
    print TCase_template.format(k, row[6], repair_fmt(row[8]), row[9], row[TCase_fk_index], repair_fmt(row[10]), repair_fmt(row[13]))
    pass


print "SELECT pg_catalog.setval('testmgr_testclass_id_seq', " + str(k + 1) + ", true);"


# create TestClass INSERTs  (all words from columns 18-20, which is SAML_Requests, PreTest, PostTest)
TClass_without_dups = set()
for k, row in sorted(TCase_without_dups.iteritems()):
    tclasses = row[TCase_samlrequ_index]
    if row[TCase_pretest_index]: tclasses += ', ' + row[TCase_pretest_index]
    if row[TCase_posttest_index]: tclasses += ', ' + row[TCase_posttest_index]
    tclasses = tclasses.replace(" ","")
    # create list of unique class names
    for n in tclasses.split(","):
        if n:
            TClass_without_dups.add(n)
    # assign primary key values (needed later for reference in child tables)
    class_data_by_pk = {}
    class_data_by_name = {}
    for i, classname in enumerate(sorted(TClass_without_dups)):
        class_data_by_pk[i] = classname  # for generating INSERTs sorted by PK
        class_data_by_name[classname] = i  # for referencing classes to obtain FK

TCase_template = "INSERT INTO testmgr_testclass(id, name, operation) VALUES ({}, '{}', '{}');"
for pk in class_data_by_pk:
    print TCase_template.format(pk, class_data_by_pk[pk], class_data_by_pk[TCase_operation_index])
    pass

# create PreTest, PostTest, SamlRequest INSERTs
SamlRequ_template = "INSERT INTO testmgr_usecase_samlrequest_testclasses(usecase_id, testclass_id) VALUES ({}, {});"
PreTest_template = "INSERT INTO testmgr_usecase_pre_testclasses(usecase_id, testclass_id) VALUES ({}, {});"
PostTest_template = "INSERT INTO testmgr_usecase_post_testclasses(usecase_id, testclass_id) VALUES ({}, {});"


# convert list of comma separated names into set
import re
def string2set(name_list):
    name_list = re.sub(r'\s+', '', name_list)
    name_list = re.sub(r'\,$', '', name_list)
    if name_list:
        return set(name_list.split(","))
    else:
        return set()


for k, row in sorted(TCase_without_dups.iteritems()):
    tc_pretest = string2set(row[TCase_pretest_index])
    tc_samlrequ = string2set(row[TCase_samlrequ_index])
    tc_posttest = string2set(row[TCase_posttest_index])


    if (len(tc_pretest) + len(tc_samlrequ) + len(tc_posttest)) > 0:
        print "-- usecase " + str(row[TCase_pk_index]) + ', ' + row[TCase_shortid_index] + ' /' + row[TCase_samlrequ_index] + '/' + row[TCase_pretest_index] + '/' + row[TCase_posttest_index]
        for i, n in enumerate(tc_samlrequ):
            print SamlRequ_template.format(row[TCase_pk_index], class_data_by_name[n])
        for i, n in enumerate(tc_pretest):
            print PreTest_template.format(row[TCase_pk_index], class_data_by_name[n])
        for i, n in enumerate(tc_posttest):
            print PostTest_template.format(row[TCase_pk_index], class_data_by_name[n])
