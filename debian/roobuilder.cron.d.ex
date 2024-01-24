#
# Regular cron jobs for the roobuilder package.
#
0 4	* * *	root	[ -x /usr/bin/roobuilder_maintenance ] && /usr/bin/roobuilder_maintenance
