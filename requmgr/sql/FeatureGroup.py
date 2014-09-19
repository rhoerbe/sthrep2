# Achtung - Datenformat erweitert aktueller Stand in .sql
#
# import csv
#
# leftonline = 'INSERT INTO requmgr_featuregroup (id, name) VALUES ('
# rowdata = {}
#
# with open('../../testmgr/sql/PVP2S_tests.csv', 'rb') as f:
#     next(f) # header row 1 not used
#     next(f) # header row 2 not used
#     reader = csv.reader(f, delimiter=';')
#     for row in reader:
#     	rowdata[row[0]] = row[1]
#
# for k, v in sorted(rowdata.iteritems()):
#     print leftonline + k + ', \'' + v + '\');'