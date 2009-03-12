#! /bin/bash

CHMOD=/bin/chmod
CHOWN=/bin/chown
ID=/usr/bin/id

SMT_WWW_DIRS=("/var/log/smt" "/var/run/smt")
SMT_ROOT_FILES=("/etc/zypp/credentials.d/NCCcredentials")

SMTCONF="/etc/smt.conf"

function usage()
{
    if [ -n "$1" ] ; then
        echo "$1" >&2
        echo ""
    fi

    cat << EOT >&2

  Usage: $0 [--dryrun] [--yes] --user <username> 

  Change the permissions on files and directories used by a user which 
  should run the smt commands.

  --dryrun (-n) show the commands but do not execute them
  --yes    (-y) answer all questions with 'yes'

  Example: $0 smt
EOT

exit 1
}


USER=""
GROUP=""
DRYRUN=0
YES=0
while true ; do
    case "$1" in
        "") break ;;
        -h|--help) usage;;
        -n|--dryrun) DRYRUN=1 ;;
        -y|--yes) YES=1 ;;
        --user) VARIABLE=USER;;
        *) usage "Unknown option $1";;
    esac
    if [ -n "$VARIABLE" ] ; then
        test -z "$2" && usage "Option $1 needs an argument"
        eval $VARIABLE=\$2
        shift
        VARIABLE=""
    fi
    shift
done

if [ ! -x $ID ]; then
    echo "id command not found. Abort.";
    exit 1;
fi

if [ `$ID -u` != 0 ]; then
    echo "You must be root. Abort."
    exit 1;
fi

if [ -z "$USER" ]; then
    echo "Missing username. Abort."
    usage
fi

if ! $ID "$USER" > /dev/null 2>&1; then
    echo "User '$USER' does not exists. Abort."
    exit 1
fi

GROUP=`$ID -gn $USER`

if [ -z "$GROUP" ]; then
    echo "Cannot find groupname of user $USER. Abort."
    exit 1
fi

if [ ! -x $CHMOD ]; then
    echo "chmod command not found. Abort.";
    exit 1;
fi

if [ ! -x $CHOWN ]; then
    echo "chown command not found. Abort.";
    exit 1;
fi

INLOCAL=0
while IFS== read -sr key val ; do 
    #echo "KEY=VAL: '$key' '$val'"
    
    case "$key" in
        \[LOCAL\]) 
            INLOCAL=1; 
            #echo "inlocal = 1"
            ;;
        \[*) 
            INLOCAL=0;
            # echo "inlocal = 0"
            ;;
        MirrorTo*) 
            #echo "found mirrorTO"
            if [ $INLOCAL -eq 1 -a -n "$val" ]; then
                val=`echo -n $val`;
                if [ -d "$val/repo" ]; then
                    SMT_WWW_DIRS=(${SMT_WWW_DIRS[@]} "$val/repo")
                fi
                if [ -d "$val/testing/repo" ]; then
                    SMT_WWW_DIRS=(${SMT_WWW_DIRS[@]} "$val/testing/repo")
                fi
                if [ -d "$val/full/repo" ]; then
                    SMT_WWW_DIRS=(${SMT_WWW_DIRS[@]} "$val/full/repo")
                fi
            fi
            ;;
        *) ;;
    esac
    
done < $SMTCONF

for dir in ${SMT_WWW_DIRS[@]}; do
    echo -n "$CHOWN -R $USER.$GROUP $dir"
    if [ $DRYRUN -eq 1 ]; then
        echo
        continue
    else
        if [ $YES -ne 1 ]; then
            read -p " Execute? [y/n] " -n 1 YN
            echo
            if [ "$YN" != "Y" -a "$YN" != "y" ]; then
                echo "Skipped."
                continue
            fi
        else
            echo
        fi
        $CHOWN -R $USER.$GROUP $dir
    fi
done

for file in ${SMT_ROOT_FILES[@]}; do
    echo -n "$CHOWN $USER.root $file"
    if [ $DRYRUN -eq 1 ]; then
        echo
        continue
    else
        if [ $YES -ne 1 ]; then
            read -p " Execute? [y/n] " -n 1 YN
            echo
            if [ "$YN" != "Y" -a "$YN" != "y" ]; then
                echo "Skipped."
                continue
            fi
        else
            echo
        fi
        $CHOWN $USER.root $file
    fi
done

exit 0;
