#!/bin/bash

# find out if a reschedule is needed
# cron job hour is 0 or 1: than it is needed

JOBNAME="smt-daily"
REPORT="smt-gen-report"
CRON_SRC_PATH="/etc/cron.d/novell.com-smt"
CRON_DST_PATH="/etc/cron.d/novell.com-smt-randomized"
CRON_RPMSAVE_PATH="/etc/cron.d/novell.com-smt.rpmsave" # needs to be cleaned up if exists from older versions

if [ -e "$CRON_RPMSAVE_PATH" ]; then
    rm $CRON_RPMSAVE_PATH
fi

if [ ! -r "$CRON_SRC_PATH" ]; then
    exit 1
fi

if [ -e "$CRON_DST_PATH" ]; then
    # no need to reschedule
    echo "no reschedule needed"
    exit 0
fi

TMP_FILE=`mktemp "${CRON_DST_PATH}.XXXXXX" 2>/dev/null`
if [ ! -e $TMP_FILE ]; then
    echo "unable to create tmp file" >&2
    exit 1
fi

# reschedule - calc new time

# HOUR between 20 - 2 (59)
DAILY_HOUR=`echo "($RANDOM % 7 + 20) % 24" | bc`
DAILY_MINUTE=`echo "$RANDOM % 60" | bc`

# Report between 4 - 7 am
REPORT_HOUR=`echo "$RANDOM % 3 + 4" | bc`
REPORT_MINUTE=`echo "$RANDOM % 60" | bc`

grep -v -E "$JOBNAME|$REPORT" $CRON_SRC_PATH | sed s/^###\\s*// > $TMP_FILE
echo "$DAILY_MINUTE $DAILY_HOUR * * * root /usr/lib/SMT/bin/smt-daily" >> $TMP_FILE
echo "$REPORT_MINUTE $REPORT_HOUR * * 1 root /usr/lib/SMT/bin/smt-gen-report" >> $TMP_FILE

STAMP=`date +%Y%m%d%H%M%S`
mv "$TMP_FILE" "$CRON_DST_PATH"

rccron reload
