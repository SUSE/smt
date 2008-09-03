#! /bin/sh

WGET=/usr/bin/wget
CURL=/usr/bin/curl
OPENSSL=/usr/bin/openssl
CREHASH=/usr/bin/c_rehash
ZMDINIT=/etc/init.d/novell-zmd
SRCONF=/etc/suseRegister.conf
CP=/bin/cp
CAT=/bin/cat
CHMOD=/bin/chmod
GREP=/usr/bin/grep
RM=/bin/rm

SSLDIR=/etc/ssl/certs/
ZMDSSLDIR=/etc/zmd/trusted-certs/

function usage()
{
    if [ -n "$1" ] ; then
        echo "$1" >&2
        echo ""
    fi

    cat << EOT >&2

  Usage: $0 <registration URL> [--regcert <url>]
  Usage: $0 --host <hostname of the SMT server> [--regcert <url>]
         configures a SLE10 client to register against a different registration server

  Example: $0 https://smt.example.com/center/regsvc
  Example: $0 --host smt.example.com
  Example: $0 --host smt.example.com --regcert http://smt.example.com/certs/smt.crt
EOT

exit 1
}

REGURL=""
VARIABLE=""
while true ; do
    case "$1" in
        --host) VARIABLE=S_HOSTNAME;;
        --regcert) VARIABLE=REGCERT;;
        "") break ;;
        -h|--help) usage;;
        https*) REGURL=$1;;
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

if [ `id -u` != 0 ]; then
    echo "You must be root. Abort."
    exit 1;
fi

if [ -n "$S_HOSTNAME" ]; then
    REGURL="https://$S_HOSTNAME/center/regsvc"
fi

if [ -z "$REGURL" ]; then
    echo "Missing registration URL. Abort."
    usage
fi

if ! echo $REGURL | grep "^https" > /dev/null ; then
    echo "The registration URL must be a HTTPS URL. Abort."
    exit 1
fi

if [ -z "$REGCERT" ]; then
    CERTURL=`echo "$REGURL" | awk -F/ '{print "https://" $3 "/smt.crt"}'`
else
    CERTURL="$REGCERT"
fi

if [ ! -x $OPENSSL ]; then
	echo "openssl command not found. Abort.";
	exit 1;
fi

if [ ! -x $CREHASH ]; then
	echo "c_rehash command not found. Abort.";
	exit 1;
fi

if [ ! -x $CP ]; then
	echo "cp command not found. Abort.";
	exit 1;
fi

if [ ! -x $CAT ]; then
	echo "cat command not found. Abort.";
	exit 1;
fi

if [ ! -x $GREP ]; then
	echo "grep command not found. Abort.";
	exit 1;
fi

if [ ! -x $RM ]; then
	echo "rm command not found. Abort.";
	exit 1;
fi

if [ ! -x $CHMOD ]; then
	echo "chmod command not found. Abort.";
	exit 1;
fi

TEMPFILE=`mktemp /tmp/smt.crt.XXXXXX`

if [ -x $WGET ]; then
	$WGET  --no-verbose -q --no-check-certificate --output-document $TEMPFILE $CERTURL
	if [ $? -ne 0 ]; then
		echo "Download failed. Abort.";
		exit 1;
	fi
elif [ -x $CURL ]; then
	$CURL  -s -S --insecure --output $TEMPFILE $CERTURL 
        if [ $? -ne 0 ]; then
                echo "Download failed. Abort.";
                exit 1;
        fi
else
	echo "Binary to download the certificate not found. Please install curl or wget. Abort."
	exit 1;
fi

$OPENSSL x509 -in $TEMPFILE -text -noout

read -p "Do you accept this certificate? [y/n] " -n 1 YN

echo "";
if [ "$YN" != "Y" -a "$YN" != "y" ]; then
	echo "Abort.";
	exit 1;
fi

$CP $TEMPFILE $SSLDIR/registration-server.pem
$CHMOD 0644 $SSLDIR/registration-server.pem
$CP $TEMPFILE $ZMDSSLDIR/registration-server.cer
$CHMOD 0644 $ZMDSSLDIR/registration-server.cer

$CREHASH $SSLDIR > /dev/null

if [ -x $ZMDINIT ]; then
	$ZMDINIT restart > /dev/null
fi

SRCTMP=`mktemp /tmp/suseRegister.conf.XXXXXX`


$CAT $SRCONF | $GREP -v "^url" > $SRCTMP
$CP $SRCONF ${SRCONF}-`date '+%F'` 
echo "url=$REGURL" > $SRCONF
$CAT $SRCTMP >> $SRCONF
$RM $SRCTMP

echo "Client setup finished."
