#!/bin/bash

SVER=0.0.5
SDATE="2009 04 24"

##############################################################################
#  smt-support - Maintains supportconfig archives uploaded to the SMT server.
#  Copyright (C) 2009 Novell, Inc.
#
##############################################################################
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#  Authors/Contributors:
#     Jason Record (jrecord@novell.com)
#
##############################################################################
# Global Variables
##############################################################################

CURRENT_SCRIPT=$(basename $0)
INCOMING=/home/jrecord/smt-support/incoming
UPLOAD_TARGET='https://secure-www.novell.com/upload?appname=supportconfig&file={tarball}'
LOG=/home/jrecord/smt-support/${CURRENT_SCRIPT}.log
ACTION=0
RCODE=0

##############################################################################
# Local Functions
##############################################################################

title() {
	echo "============================================================================="
	echo "                          SMT Utilities - Support"
	echo "                           Script Version: $SVER"
	echo "                          Script Date: $SDATE"
	echo "============================================================================="
	echo
}

checkIncoming() {
	echo "Directory: $INCOMING" | tee -a $LOG
	if [ ! -d $INCOMING ]; then
		showStatus "ERROR: Invalid or missing directory"
		echo
		exit 1;
	fi
}

startLogEntry() {
	echo "--------------------------" >> $LOG
	echo "Date:      $(date)" | tee -a $LOG
}

showArchive() {
	echo "Archive:   $ARCH_FILE" | tee -a $LOG
}

# Requires checkIncoming
countArchives() {
	#ARCHS=$(\ls -l ${INCOMING}/*{t?z,gpg} 2>/dev/null | wc -l)
	ARCHS=$(\ls -l ${INCOMING}/*t[b,g]z 2>/dev/null | wc -l)
	echo "Archives:  $ARCHS" | tee -a $LOG
	return $ARCHS
}

showStatus() {
	SVALUE=$1
	echo "Status:    $1" | tee -a $LOG
}

setAction() {
	SACTION=$1
	echo "Action:    $1" | tee -a $LOG
}

listIncoming() {
	startLogEntry
	checkIncoming
	setAction "List"
	countArchives
	echo
	cd $INCOMING
	#\ls -1 *{t?z,gpg} 2>> $LOG | tee -a $LOG
	\ls -1 *t[b,g]z 2>> $LOG | tee -a $LOG
}

removeArchive() {
	startLogEntry
	checkIncoming
	setAction "Remove"
	showArchive
	FILEPATH=${INCOMING}/${ARCH_FILE}
	if [ -e $FILEPATH ]; then
		rm -f ${FILEPATH}*
		showStatus Removed
	else
		showStatus "ERROR, File not found"
	fi
}

emptyIncoming() {
	startLogEntry
	checkIncoming
	setAction "Remove All"
	countArchives
	if [ $? -gt 0 ]; then
		rm -f $INCOMING/*
		showStatus Removed
	else
		showStatus Empty
	fi
}

secureUpload() {
	FILE=$1
	BASEFILE=$(basename ${FILE})
	unset UPLOAD_URL
	UPLOAD_URL=$(echo $UPLOAD_TARGET | sed -e "s/{[Tt][Aa][Rr][Bb][Aa][Ll][Ll]}/${BASEFILE}/g")
	echo "Command: curl -v -s -L -A SupportConfig -T \"${FILE}\" \"${UPLOAD_URL}\"" >> $LOG
	echo "Output:" >> $LOG
	curl -v -s -L -A SupportConfig -T "${FILE}" "${UPLOAD_URL}" >> $LOG 2>&1
	RC=$?
	echo >> $LOG
	return $RC
}

uploadArchive() {
	startLogEntry
	checkIncoming
	setAction "Upload"
	showArchive
	COMPLETED=0
	FILEPATH=${INCOMING}/${ARCH_FILE}
	if [ -e ${FILEPATH} ]; then
		echo "Uploading: $FILEPATH" | tee -a $LOG
		if [ -f ${FILEPATH}.md5 ]; then
			secureUpload ${FILEPATH}.md5
			if [ $? -eq 0 ]; then
				((COMPLETED++))
			fi
		fi
		secureUpload ${FILEPATH}
		if [ $? -eq 0 ]; then
			((COMPLETED++))
		fi
		if [ $COMPLETED -gt 0 ]; then
			showStatus Uploaded
		else
			showStatus "Upload Incomplete"
		fi
	else
		showStatus "ERROR, File not found"
	fi
}

uploadIncoming() {
	startLogEntry
	checkIncoming
	setAction "Upload All"
	countArchives
	if [ $? -gt 0 ]; then
		cd $INCOMING
		COMPLETED=0
		for ARCH_FILE in *t[b,g]z
		do
			FILEPATH=${INCOMING}/${ARCH_FILE}
			echo "Uploading: $FILEPATH" | tee -a $LOG
			test -f ${FILEPATH}.md5 && secureUpload ${FILEPATH}.md5
			secureUpload ${FILEPATH}
			if [ $? -eq 0 ]; then
				((COMPLETED++))
			fi
		done
		showStatus "Uploaded: $COMPLETED"
	else
		showStatus Empty
	fi
}

show_help() {
	echo " Usage: $CURRENT_SCRIPT [OPTION [OPTION ...]]"
	echo
	echo "  -h This screen"
	echo "  -i <directory>"
	echo "     Sets the incoming directory where supportconfig archives are"
	echo "     uploaded."
	echo "  -s <SR number>"
	echo "     The Novell Service Request 11 digit number"
	echo "  -n <Name>"
	echo "     Contact's first and last name"
	echo "  -c <Company>"
	echo "     Company name"
	echo "  -p <Phone>"
	echo "     The contact phone number"
	echo "  -e <Email>"
	echo "     Contact email address"
	echo "  -l Lists the uploaded supportconfig archives"
	echo "  -r <archive>"
	echo "     Deletes the specified archive"
	echo "  -R Deletes all archives in the incoming directory"
	echo "  -u <archive>"
	echo "     Uploads the specified archive to Novell"
	echo "  -U Uploads all archives in the incoming directory to Novell"
}

##############################################################################
# Main
##############################################################################

while getopts :hlr:Ru:Ui:s:n:c:p:e: TMPOPT
do
	case $TMPOPT in
	\:)	clear; title
			case $OPTARG in
			*) echo "ERROR: Missing Argument -$OPTARG"
				;;
			esac
			echo; show_help; echo; exit 0 ;;
	\?)	clear; title
			case $OPTARG in
			*) echo "ERROR: Invalid Option -$OPTARG"
				;;
			esac
			echo; show_help; echo; exit 0 ;;
	i) INCOMING="$OPTARG" ;;
	s) SRNUM="$OPTARG" ;;
	n) CONTACT_NAME="$OPTARG" ;;
	c) CONTACT_COMPANY="$OPTARG" ;;
	p) CONTACT_PHONE="$OPTARG" ;;
	e) CONTACT_EMAIL="$OPTARG" ;;

	h) ACTION=0 ;;
	l) ACTION=1 ;;
	r) ACTION=2; ARCH_FILE="$OPTARG" ;;
	R) ACTION=3 ;;
	u) ACTION=4; ARCH_FILE="$OPTARG" ;;
	U) ACTION=5 ;;
	esac
done

clear
title
case $ACTION in
	0) show_help ;;
	1) listIncoming ;;
	2) removeArchive ;;
	3) emptyIncoming ;;
	4) uploadArchive ;;
	5) uploadIncoming ;;
esac
echo
exit $RCODE;

