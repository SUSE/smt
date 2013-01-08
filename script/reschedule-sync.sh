#!/bin/bash

# find out if a reschedule is needed
# cron job hour is 0 or 1: than it is needed

JOBNAME="smt-daily"
REPORT="smt-gen-report"
CRONPATH="/etc/smt.d/novell.com-smt"

if [ ! -r "$CRONPATH" ]; then
    exit 1
fi

LINES=`grep $JOBNAME $CRONPATH | wc -l`
CURRENT_HOUR=`grep $JOBNAME $CRONPATH | awk '{print $2}'`

if [ "$LINES" != "1" -o "$CURRENT_HOUR" != "0" -a "$CURRENT_HOUR" != "1" -a "$CURRENT_HOUR" != "*" ]; then
    # no need to reschedule
    echo "no reschedule needed"
    exit 0
fi

# reschedule - calc new time

# HOUR between 20 - 2 (59)
NEW_HOUR=`echo "$RANDOM % 7 - 4" | bc`
if [ $NEW_HOUR -lt 0 ]; then
    NEW_HOUR=`echo "24 + $NEW_HOUR" | bc`
fi

# MINUTE between 0 - 59
NEW_MINUTE=`echo "$RANDOM % 60" | bc`

# Report between 4 - 7 am
REPORT_HOUR=`echo "$RANDOM % 3 + 4" | bc`
REPORT_MINUTE=`echo "$RANDOM % 60" | bc`

TMP_FILE=`mktemp "${CRONPATH}.XXXXXX" 2>/dev/null`
if [ ! -e $TMP_FILE ]; then
    echo "unable to create tmp file" >&2
    exit 1
fi
grep -v -E "$JOBNAME|$REPORT" $CRONPATH > $TMP_FILE
echo "$NEW_MINUTE $NEW_HOUR * * * root /usr/lib/SMT/bin/smt-daily" >> $TMP_FILE
echo "$REPORT_MINUTE $REPORT_HOUR * * 1 root /usr/lib/SMT/bin/smt-gen-report" >> $TMP_FILE

STAMP=`date +%Y%m%d%H%M%S`
mv "$CRONPATH" "$CRONPATH.$STAMP"
mv "$TMP_FILE" "$CRONPATH"

rccron reload
