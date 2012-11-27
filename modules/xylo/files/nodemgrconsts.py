# This is what separates a client variable client-name from the
# variable-name.
USER_VAR_CHAR = '.' # possible values are ".$#" for instance, but not ":"

# Set this to None to force user to specify nodemgr.ini.
DEFAULT_INI_FILE = '/stored_builds/nodemgr/nodemgr.ini'

# Set this to None to base specs file path on INI file path.
# If DEFAULT_INI_FILE is not None, the default SPECS file will
# be the same as the default INI file but with "specs" inserted,
# e.g., if DEFAULT_INI_FILE = /a/b/c.ini, we will use /a/b/specs/c.ini
# here.
#
# Note: if DEFAULT_INI_FILE is also None, the default
# specs file will come from the user's specified ini-file path,
# ie: ./node_manager_rpc -i /some/where.ini will set the specs
# file to /some/specs/where.ini.  However, if DEFAULT_INI_FILE
# is not None, the default specs file will be based on DEFAULT_INI_FILE.
# (The idea here is that you can set both to None for testing.
# Or, of course, you can just use the -i and -s arguments...)
DEFAULT_SPECS_FILE = None
