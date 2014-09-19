import csv
from repairfmt import repair_fmt

leftonline = 'INSERT INTO requmgr_requirement (id, name, feature_id, operation_count) VALUES ('
pk_index = 4
fk_index = 2
eliminate_dups = {} # TODO need to make uniquy by name, f_id

with open('../../db/PVP2S_tests.csv', 'rb') as f:
    next(f) # header row1 not used
    next(f) # header row2 not used
    reader = csv.reader(f, delimiter=';')
    for row in reader:
        #print row[pk_index] + ' :: ' + str(row)
    	eliminate_dups[int(row[pk_index])] = row

for k, row in sorted(eliminate_dups.iteritems()):
    print leftonline + str(k) + ", '" + repair_fmt(row[5]) + "', " + row[fk_index] + ", 0);"