# Achtung - Datenformat erweitert aktueller Stand in .sql
import csv

leftonline = 'INSERT INTO requmgr_feature (id, name, featuregroup_id) VALUES ('
pk_index = 2
fk_index = 0
eliminate_dups = {}

with open('../../testmgr/sql/PVP2S_tests.csv', 'rb') as f:
    next(f) # header row not used
    next(f) # header row not used
    reader = csv.reader(f, delimiter=';')
    for row in reader:
        #print row[pk_index] + ' :: ' + str(row)
    	eliminate_dups[int(row[pk_index])] = row

for k, row in sorted(eliminate_dups.iteritems()):
    print leftonline + str(k) + ", '" + row[3] + "', " + row[0] + ");"