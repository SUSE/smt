#!/bin/bash

SVER=0.0.11
SDATE="2009 04 29"

##############################################################################
#  smt-support - Maintains incoming SMT server archives to be uploaded
#                to Novell.
##############################################################################
# Global Variables
##############################################################################

CURRENT_SCRIPT=$(basename $0)
SMT_UPLOAD_TARGET='https://secure-www.novell.com/upload?appname=supportconfig&file={tarball}'
SMT_LOG=/var/log/smt/${CURRENT_SCRIPT}.log
SMT_CONTACT_FILE=contact-smt-support.txt
echo ${SMT_INCOMING:=/home/jrecord/smt-support/incoming} &> /dev/null
UPLOAD_FILEPATH=""
ACTION=0
REPACKAGE=0
RCODE=0
unset SRNUM

##############################################################################
# Local Functions
##############################################################################

title() {
	echo "============================================================================="
	echo "                      SMT Utilities - Archive Support"
	echo "                           Script Version: $SVER"
	echo "                          Script Date: $SDATE"
	echo "============================================================================="
	echo
}

checkIncoming() {
	logEntry Directory $SMT_INCOMING
	if [ ! -d $SMT_INCOMING ]; then
		showStatus "ERROR: Invalid or missing directory"
		echo
		exit 1;
	fi
}

logEntry() {
	printf "%-12s %s\n" "$1" "$2" | tee -a $SMT_LOG
}

logFileEntry() {
	printf "%-12s %s\n" "$1" "$2" >> $SMT_LOG
}

startLogEntry() {
	echo "--------------------------" >> $SMT_LOG
	logEntry Date "$(date)"
}


showArchive() {
	logEntry Archive $ARCH_FILE
}

# Requires checkIncoming
countArchives() {
	ARCHS=$(\ls -l ${SMT_INCOMING}/*t[b,g]z 2>/dev/null | wc -l)
	logEntry Archives $ARCHS
	return $ARCHS
}

showStatus() {
	logEntry Status "$1"
}

setAction() {
	logEntry Action "$1"
}

listIncoming() {
	echo
	cd $SMT_INCOMING
	\ls -1 *t[b,g]z 2>> $SMT_LOG | tee -a $SMT_LOG
}

validateSR() {
	if [ $SRNUM ]; then
		startLogEntry
		INVALID=0
		if [ ${#SRNUM} -eq 11 ]; then
			if echo $SRNUM | grep '[[:alpha:]]' &> /dev/null; then
				((INVALID++))
			fi
		else
			((INVALID++))
		fi
		if [ $INVALID -gt 0 ]; then
			showStatus "ERROR, Invalid SR number ($SRNUM); Must be 11 digits"
			echo
			exit 5
		fi
	fi
}

secureUpload() {
	FILE=$1
	UPLOAD_ARCHIVE=$(basename ${FILE})
	unset UPLOAD_URL
	UPLOAD_URL=$(echo $SMT_UPLOAD_TARGET | sed -e "s/{[Tt][Aa][Rr][Bb][Aa][Ll][Ll]}/${UPLOAD_ARCHIVE}/g")
	logFileEntry ' [Command]' "curl -v -s -L -A SupportConfig -T \"${FILE}\" \"${UPLOAD_URL}\""
	logFileEntry ' [Output]'
#	curl -v -s -L -A SupportConfig -T "${FILE}" "${UPLOAD_URL}" >> $SMT_LOG 2>&1
	RC=$?
	echo >> $SMT_LOG
	return $RC
}

# Requires checkIncoming
# Sets ARCH_FILE
repackageArchive() {
	if [ $SRNUM ]; then
		if echo $ARCH_FILE | grep 'nts_SR[[:digit:]]' &> /dev/null; then
			NEW_ARCH_FILE=$(echo $ARCH_FILE | sed -e "s/_SR[[:digit:]]*_/_SR${SRNUM}_/")
		else
			NEW_ARCH_FILE=$(echo $ARCH_FILE | sed -e "s/nts_/nts_SR${SRNUM}_/")
		fi
	fi
	logEntry Repackaging "${NEW_ARCH_FILE}"
	cd $SMT_INCOMING
	if echo $ARCH_FILE | grep 'tgz$' &> /dev/null; then
		TARCMP='z'
	else
		TARCMP='j'
	fi
	logEntry ' Extracting' 'In Progress'
	ARCH_DIR=$(echo $ARCH_FILE | sed -e 's/\.t[b,g]z$//')
	NEW_ARCH_DIR=$(echo $NEW_ARCH_FILE | sed -e 's/\.t[b,g]z$//')
	tar ${TARCMP}xf $ARCH_FILE >> $SMT_LOG 2>&1
	if [ $? -gt 0 ]; then
		showStatus "FAILED: ${INCOMING}/${ARCH_FILE}"
		rm	-rf $ARCH_DIR
	else
		mv $ARCH_DIR $NEW_ARCH_DIR >> $SMT_LOG 2>&1
		if [ ! -d $NEW_ARCH_DIR ]; then
			showStatus "ERROR, Directory conversion failed"
			exit 6
		fi
		LOGCONTACT="${NEW_ARCH_DIR}/${SMT_CONTACT_FILE}"
		echo "Information Added by SMT Server" >> $LOGCONTACT
		echo "Date:                 $(date)" >> $LOGCONTACT
		echo "-------------------------------------------------------" >> $LOGCONTACT
		test -n "$SRNUM"           && echo "Service Request:      $SRNUM" >> $LOGCONTACT
		test -n "$CONTACT_NAME"    && echo "Contact Name:         $CONTACT_NAME" >> $LOGCONTACT
		test -n "$CONTACT_COMPANY" && echo "Company Name:         $CONTACT_COMPANY" >> $LOGCONTACT
		test -n "$CONTACT_STOREID" && echo "Store ID:             $CONTACT_STOREID" >> $LOGCONTACT
		test -n "$CONTACT_TERMID"  && echo "Terminal ID:          $CONTACT_TERMID" >> $LOGCONTACT
		test -n "$CONTACT_PHONE"   && echo "Contact Phone:        $CONTACT_PHONE" >> $LOGCONTACT
		test -n "$CONTACT_EMAIL"   && echo "Contact EMail:        $CONTACT_EMAIL" >> $LOGCONTACT
		printf "\n\n" >> $LOGCONTACT
		logEntry ' Details' Added

		logEntry ' Archiving' 'In Progress'
		tar ${TARCMP}cf ${NEW_ARCH_FILE} ${NEW_ARCH_DIR}/* >> $SMT_LOG 2>&1
		if [ $? -gt 0 ]; then
			showStatus "FAILED: ${INCOMING}/${NEW_ARCH_DIR}"
			ARCH_FILE="Failed"
		else
			md5sum ${NEW_ARCH_FILE} | cut -d' ' -f1 > ${NEW_ARCH_FILE}.md5
			rm -f ${ARCH_FILE}
			test -f ${ARCH_FILE}.md5 && rm -f ${ARCH_FILE}.md5
			rm -rf ${NEW_ARCH_DIR}
			ARCH_FILE=$NEW_ARCH_FILE
		fi
	fi
}

showIncoming() {
	startLogEntry
	checkIncoming
	setAction "List"
	countArchives
	listIncoming
}

removeArchive() {
	startLogEntry
	checkIncoming
	setAction "Remove One"
	showArchive
	FILEPATH=${SMT_INCOMING}/${ARCH_FILE}
	if [ -e $FILEPATH ]; then
		rm -f ${FILEPATH}*
		showStatus Removed
	else
		showStatus "ERROR, File not found"
		RCODE=2
	fi
}

emptyIncoming() {
	startLogEntry
	checkIncoming
	setAction "Remove All"
	countArchives
	RC=$?
	listIncoming
	if [ $RC -gt 0 ]; then
		rm -f ${SMT_INCOMING}/*
		showStatus Removed
	else
		showStatus Empty
		RCODE=1
	fi
}

uploadArchive() {
	startLogEntry
	checkIncoming
	setAction "Upload One"
	showArchive
	COMPLETED=0
	if (( REPACKAGE )); then
		repackageArchive
	fi
	UPLOAD_FILEPATH=${SMT_INCOMING}/${ARCH_FILE}
	if [ -e ${UPLOAD_FILEPATH} ]; then
		logEntry Uploading $UPLOAD_FILEPATH
		test -s ${UPLOAD_FILEPATH}.md5 && secureUpload ${UPLOAD_FILEPATH}.md5
		secureUpload ${UPLOAD_FILEPATH}
		if [ $? -eq 0 ]; then
			((COMPLETED++))
		fi
		if [ $COMPLETED -gt 0 ]; then
			showStatus Uploaded
		else
			showStatus "Upload Incomplete"
		fi
	else
		showStatus "ERROR, File not found: $UPLOAD_FILEPATH"
		RCODE=2
	fi
}

uploadIncoming() {
	startLogEntry
	checkIncoming
	setAction "Upload All"
	countArchives
	if [ $? -gt 0 ]; then
		cd $SMT_INCOMING
		COMPLETED=0
		for ARCH_FILE in *t[b,g]z
		do
			UPLOAD_FILEPATH=${SMT_INCOMING}/${ARCH_FILE}
			logEntry Uploading $UPLOAD_FILEPATH
			test -s ${UPLOAD_FILEPATH}.md5 && secureUpload ${UPLOAD_FILEPATH}.md5
			secureUpload ${UPLOAD_FILEPATH}
			if [ $? -eq 0 ]; then
				((COMPLETED++))
			fi
		done
		showStatus "Uploaded: $COMPLETED"
	else
		showStatus Empty
		RCODE=1
	fi
}

show_help() {
	echo " Usage: $CURRENT_SCRIPT [OPTION [OPTION ...]]"
	echo
	echo "  -h This screen"
	echo "  -i <directory>"
	echo "     Sets the incoming directory where supportconfig archives are"
	echo "     uploaded. Also set with SMT_INCOMING environment variable."
	echo "  -s <SR number>"
	echo "     The Novell Service Request 11 digit number"
	echo "  -n <Name>"
	echo "     Contact's first and last name in quotes"
	echo "  -c <Company>"
	echo "     Company name"
	echo "  -d <id>"
	echo "     Enter the store ID if applicable"
	echo "  -t <id>"
	echo "     Enter the Terminal ID if applicable"
	echo "  -p <Phone>"
	echo "     The contact phone number"
	echo "  -e <Email>"
	echo "     Contact email address"
	echo "  -l Lists the uploaded supportconfig archives"
	echo "  -r <archive>"
	echo "     Deletes the specified archive"
	echo "  -R Deletes all archives in the incoming directory"
	echo "  -u <archive>"
	echo "     Uploads the specified archive to Novell, and repackages archive with"
	echo "     contact information if options -sncpe are given"
	echo "  -U Uploads all archives in the incoming directory to Novell"
}

##############################################################################
# Main
##############################################################################

while getopts :hlr:Ru:Ui:s:n:c:p:e:d:t: TMPOPT
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
	i) SMT_INCOMING="$OPTARG" ;;
	s) REPACKAGE=1; SRNUM="$OPTARG" ;;
	n) REPACKAGE=1; CONTACT_NAME="$OPTARG" ;;
	c) REPACKAGE=1; CONTACT_COMPANY="$OPTARG" ;;
	d) REPACKAGE=1; CONTACT_STOREID="$OPTARG" ;;
	t) REPACKAGE=1; CONTACT_TERMID="$OPTARG" ;;
	p) REPACKAGE=1; CONTACT_PHONE="$OPTARG" ;;
	e) REPACKAGE=1; CONTACT_EMAIL="$OPTARG" ;;

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
validateSR
case $ACTION in
	0) show_help ;;
	1) showIncoming ;;
	2) removeArchive ;;
	3) emptyIncoming ;;
	4) uploadArchive ;;
	5) uploadIncoming ;;
esac
echo
exit $RCODE;

