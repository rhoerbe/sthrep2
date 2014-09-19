import csv
from repairfmt import repair_fmt

template = "INSERT INTO testmgr_testplancaseassignment(testplan_id, usecase_id, relevance) VALUES ({}, {}, '{}');"
pk_index = 7
eliminate_dups = {}

with open('PVP2S_tests.csv', 'rb') as f:
    next(f) # header row1 not used
    next(f) # header row2 not used
    reader = csv.reader(f, delimiter=';')
    for row in reader:
        #print row[pk_index] + ' :: ' + str(row)
    	eliminate_dups[int(row[pk_index])] = row

for k, row in sorted(eliminate_dups.iteritems()):
    if row[11] not in ('', 'n/a'):
        print template.format(1, k, row[11])

