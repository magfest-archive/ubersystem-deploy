import os
import sys
import atexit
import readline
import rlcompleter
import traceback
from pprint import pprint


readline.parse_and_bind('tab: complete')
history_path = os.path.expanduser('~/.pyhistory')


@atexit.register
def save_history():
    readline.write_history_file(history_path)


if os.path.exists(history_path):
    readline.read_history_file(history_path)

try:
    import cherrypy
    import sideboard
    from uber.config import c
    from uber.models import AdminAccount, Attendee, initialize_db, Session

    initialize_db()

    # Make it easier to do session stuff at the command line
    session = Session().session

    admin = session.query(AdminAccount).filter(
        AdminAccount.attendee_id == Attendee.id,
        Attendee.email == 'magfest@example.com'
    ).order_by(AdminAccount.id).first()

    if not admin:
        admin = session.query(AdminAccount).filter(
            AdminAccount.access.like('%{}%'.format(c.ADMIN))
        ).order_by(AdminAccount.id).first()

    if not admin:
        admin = session.query(AdminAccount).order_by(AdminAccount.id).first()

    if admin:
        # Make it easier to do site section testing at the command line
        cherrypy.session = {'account_id': admin.id}
        print('Logged in as {} <{}>'.format(admin.attendee.full_name, admin.attendee.email))
    else:
        print('WARNING: Could not find any admin accounts')

except Exception as ex:
    print('ERROR: Could not initialize ubersystem environment')
    traceback.print_exc()
