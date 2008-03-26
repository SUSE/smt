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
# Required-Start:		$local_fs $remote_fs $network mysql apache2 cron
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
: ${smt_apache_plugindir=/etc/apache2/conf.d/}
: ${smt_apache_vhostdir=/etc/apache2/vhosts.d/}
: ${smt_crondir=/etc/cron.d/}

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

# apache2	- NCC itself
# mysql		- database
# cron		- NCC scripts
services="apache2 mysql cron"
apache_plugins="nu_server.conf smt_mod_perl.conf"
apache_vhosts="vhost-ssl.conf"
smt_cronfiles="novell.com-smt"

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
	${dbcommand} init
    fi
}

#
# Links the apache2 plugins stored in smt.d
# from the acpache2 conf.d directory
#
function link_smt_plugins () {
    mkdir -p ${smt_apache_plugindir}

    for filename in ${apache_plugins}; do
	if [ ! -e ${smt_apache_plugindir}${filename} ]; then
	    if [ -e ${smt_d}${filename} ]; then
		echo "Adding apache2 plugin ${smt_apache_plugindir}${filename}"
		ln -s ${smt_d}${filename} ${smt_apache_plugindir}${filename}

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

    mkdir -p ${smt_apache_vhostdir}

    for filename in ${apache_vhosts}; do
	if [ ! -e ${smt_apache_vhostdir}${filename} ]; then
	    if [ -e ${smt_d}${filename} ]; then
		echo "Adding apache2 plugin ${smt_apache_vhostdir}${filename}"
		ln -s ${smt_d}${filename} ${smt_apache_vhostdir}${filename}

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

    mkdir -p ${smt_crondir}

    for filename in ${smt_cronfiles}; do
	if [ ! -e ${smt_crondir}${filename} ]; then
	    if [ -e ${smt_d}${filename} ]; then
		echo "Adding cron plugin ${smt_crondir}${filename}"
		ln -s ${smt_d}${filename} ${smt_crondir}${filename}

		# SMT should be started, 'reload' will reload apache
		# if more configuration files are added
		if [ "$action" == "start" ]; then
		    action="reload"
		fi
	    else
		# Linked file doesn't exist
		echo "Error: Not adding cron plugin ${smt_d}${filename} (missing)"
	    fi
	fi
    done
}

#
# Unlinks the apache2 plugins
#
function unlink_smt_plugins () {
    # Removing all links
    for filename in ${apache_plugins}; do
	filename="${smt_apache_plugindir}${filename}"

	if [ -e ${filename} ]; then
	    echo "Removing apache2 conf plugin ${filename}"
	    rm ${filename}
	fi
    done

    for filename in ${apache_vhosts}; do
	filename="${smt_apache_vhostdir}${filename}"

	if [ -e ${filename} ]; then
	    echo "Removing apache2 vhosts plugin ${filename}"
	    rm ${filename}
	fi
    done

    for filename in ${smt_cronfiles}; do
	filename="${smt_crondir}${filename}"

	if [ -e ${filename} ]; then
	    echo "Removing cron plugin ${filename}"
	    rm ${filename}
	fi
    done
}

#
# Checks whether the apache2 plugins exist
#
function check_smt_plugins () {
    cd ${smt_apache_plugindir}

    # Checking all links
    for filename in ${apache_plugins}; do
	filename="${smt_apache_plugindir}${filename}"

	if [ -e ${filename} ]; then
	    echo "Using apache2 conf plugin ${filename}"
	else
	    echo "Not using apache2 conf plugin ${filename} (SMT not enabled)"
	    exit_code=1
	fi
    done

    for filename in ${apache_vhosts}; do
	filename="${smt_apache_vhostdir}${filename}"

	if [ -e ${filename} ]; then
	    echo "Using apache2 vhosts plugin ${filename}"
	else
	    echo "Not using apache2 vhosts plugin ${filename} (SMT not enabled)"
	    exit_code=1
	fi
    done

    for filename in ${smt_cronfiles}; do
	filename="${smt_crondir}${filename}"

	if [ -e ${filename} ]; then
	    echo "Using cron plugin ${filename}"
	else
	    echo "Not using cron plugin ${filename} (SMT not enabled)"
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
	action="reload"
	link_smt_plugins
	adjust_services
	init_or_upgrade_database
	;;
    # removes symlinks and reloads services
    stop)
	action="reload"
	unlink_smt_plugins
	adjust_services
	;;
    # restarts services (symlinks apache configuration)
    restart)
	action="restart"
	link_smt_plugins
	adjust_services
	init_or_upgrade_database
	;;
    # returns status of both services at once
    status)
	action="status"
	check_smt_plugins
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
