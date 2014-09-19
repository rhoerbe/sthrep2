def repair_fmt(s):
    if s[0:1] == '_':
        s = s[1:]     # remove unexpectedly inserted underscore from excel export
    return s.replace("'","''")  # escape single quotes in SQL-style