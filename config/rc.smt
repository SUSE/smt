#!/bin/sh
#
# Copyright (c) 2008 SUSE Linux Products GmbH
#
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
#
# /etc/init.d/smt
#
### BEGIN INIT INFO
# Provides:			smt
# Required-Start:		$local_fs $remote_fs $network mysql apache2
# X-UnitedLinux-Should-Start:	$named $time mysql ypclient
# Required-Stop:		$local_fs $remote_fs $network
# X-UnitedLinux-Should-Stop:	
# Default-Start:		3 5
# Default-Stop:			0 1 2 6
# Short-Description:		SMT - Subscription Management Tool for SLE
# Description:			Handles apache2 and mysql
### END INIT INFO

pname=smt
: ${smt_conf:=/etc/$pname.conf}
: ${logdir:=/var/log/$pname/}
: ${smt_d:=/etc/$pname.d/}
: ${smt_apachedir=/etc/apache2/conf.d/}

#
## load functions
#
test -s /etc/rc.status && . /etc/rc.status && rc_reset

#
# check the configuration
#
if ! [ -e $smt_conf ]; then
	echo >&2 ${warn}SMT not configured
	rc_failed 5
	rc_status -v1
	rc_exit
fi

services="apache2 mysql"
apache_plugins="nu_server.conf smt_mod_perl.conf"

action="$1"
exit_code=0

function adjust_services () {
    for service in ${services}; do
        rc${service} ${action}
	tmp_exitcode=$?
	if [ "${tmp_exitcode}" != "0" ]; then
	    exitcode=${tmp_exitcode}
	fi
    done
}

function init_or_upgrade_database () {
    dbcommand="/usr/lib/SMT/bin/smt-db"
    if [ ! -e ${dbcommand} ]; then
	echo "Error: ${dbcommand} does not exist, database connection might not work"
    else
	${dbcommand}
    fi
}

#
# Links the apache2 plugins stored in smt.d
# from the acpache2 conf.d directory
#
function link_apache_plugins () {
    cd ${smt_apachedir}

    for filename in ${apache_plugins}; do
	if [ ! -e ${filename} ]; then
	    if [ -e ${smt_d}${filename} ]; then
		echo "Adding apache2 plugin ${smt_apachedir}${filename}"
		ln -s ${smt_d}${filename} ${smt_apachedir}${filename}

		# SMT should be started, 'reload' will reload apache
		# if more configuration files are added
		if [ "$action" == "start" ]; then
		    action="reload"
		fi
	    else
		# Linked file doesn't exist
		echo "Error: Not adding apache2 plugin ${smt_d}${filename} (missing)"
	    fi
	fi
    done
}

#
# Unlinks the apache2 plugins
#
function unlink_apache_plugins () {
    cd ${smt_apachedir}

    # Removing all links
    for filename in ${apache_plugins}; do
	if [ -e ${smt_apachedir}${filename} ]; then
	    echo "Removing apache2 plugin ${smt_apachedir}${filename}"
	    rm ${smt_apachedir}${filename}
	fi
    done
}

#
# Checks whether the apache2 plugins exist
#
function check_apache_plugins () {
    cd ${smt_apachedir}

    # Checking all links
    for filename in ${apache_plugins}; do
	if [ -e ${smt_apachedir}${filename} ]; then
	    echo "Using apache2 plugin ${smt_apachedir}${filename}"
	else
	    echo "Error: Missing apache2 plugin ${smt_apachedir}${filename}!"
	    exit_code=1
	fi
    done
}

#
# main part 
#
case "$action" in
    # starts the SMT service (symlinks apache configuration)
    start*)
	action="start"
	link_apache_plugins
	adjust_services
	init_or_upgrade_database
	;;
    # removes symlinks and reloads services
    stop)
	action="reload"
	unlink_apache_plugins
	adjust_services
	;;
    # restarts services (symlinks apache configuration)
    restart)
	action="restart"
	link_apache_plugins
	adjust_services
	init_or_upgrade_database
	;;
    # returns status of both services at once
    status)
	action="status"
	check_apache_plugins
	adjust_services
	;;
    *)
    cat >&2 <<-EOF 
	Usage: $0 <command> <server flags>

	where <command> is one of:
	        start              - start smt
	        stop               - stop smt (removes SMT apache plugins and reloads services)
	        status             - check whether httpd is running
	        restart            - stops smt if running, and starts it again
	        help               - this screen
	
	EOF
    exit_code=1
esac


# Inform the caller not only verbosely and set an exit status.
exit ${exit_code}
