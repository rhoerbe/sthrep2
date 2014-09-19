# Generate Operation, Test Class and the intermediate tables for the PreTest, SamlRequest and PostTest relationships
# Operation has id sequence numbers from the input, TestClass does not and it has to be generated here
# Rainer Hoerbe 2013-04-12

import csv
from repairfmt import repair_fmt  # fix quotes and excel export bugs



#Column indices from input data
Oper_fk_index = 4
Oper_shortid_index = 6
Oper_pk_index = 7
Oper_operation_index = 15
Oper_samlrequ_index = 18
Oper_pretest_index = 19
Oper_posttest_index = 20

Oper_without_dups = {}


with open('../../data/PVP2S_tests.csv', 'rb') as f:
    next(f) # header row1 not used
    next(f) # header row2 not used
    reader = csv.reader(f, delimiter=';')
    for row in reader:
        #(debug) print row[pk_index] + ' :: ' + str(row)
        Oper_without_dups[int(row[Oper_pk_index])] = row

Oper_template = "UPDATE testmgr_usecase SET operation = '{}' WHERE id = {}; -- {}"

# create Operation INSERTs
for k, row in sorted(Oper_without_dups.iteritems()):
    if row[Oper_operation_index] != '':
        print Oper_template.format(row[Oper_operation_index], k, repair_fmt(row[16]))

