#
# This module holds software that's mostly simple to install.
# Rule of thumb: if the software requires configuration per host 
# or per website, it shouldn't be in this module.
#

class software {
	include software::git
	include software::rsyslog
	include software::vim
}



