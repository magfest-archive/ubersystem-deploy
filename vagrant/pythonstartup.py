import os
import sys
import atexit
import readline
import rlcompleter
from pprint import pprint

readline.parse_and_bind('tab: complete')

history_path = os.path.expanduser('~/.pyhistory')

@atexit.register
def save_history():
    readline.write_history_file(history_path)

if os.path.exists(history_path):
    readline.read_history_file(history_path)

try:
    import sideboard
    from uber.common import *
    session = Session().session  # make it easier to do session stuff at the command line
    cherrypy.session = {'account_id': session.query(AdminAccount).first().id}  # make it easier to do site section testing at the command line
except:
    pass
