#! /bin/sh

WGET=/usr/bin/wget
OPENSSL=/usr/bin/openssl
CREHASH=/usr/bin/c_rehash
ZMDINIT=/etc/init.d/novell-zmd
SRCONF=/etc/suseRegister.conf
CP=/bin/cp
CAT=/bin/cat
CHMOD=/bin/chmod
GREP=/usr/bin/grep
RM=/bin/rm
SUSEREGISTER=/usr/bin/suse_register
GPG=/usr/bin/gpg
SSLDIR=/etc/ssl/certs/
CAFILE=("/etc/pki/tls/cert.pem" "/usr/share/ssl/cert.pem")
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

if [ ! -x $CP ]; then
	echo "cp command not found. Abort.";
	exit 1;
fi

if [ ! -x $CAT ]; then
	echo "cat command not found. Abort.";
	exit 1;
fi

if [ ! -x $GREP ]; then
    if [ -x "/bin/grep" ]; then
        GREP=/bin/grep
    else
        echo "grep command not found. Abort.";
        exit 1;
    fi
fi

if [ ! -x $RM ]; then
	echo "rm command not found. Abort.";
	exit 1;
fi

if [ ! -x $CHMOD ]; then
	echo "chmod command not found. Abort.";
	exit 1;
fi

if [ ! -x $SUSEREGISTER ]; then
    echo "suse_register command not found. Abort."
    exit 1
fi

if [ ! -x $GPG ]; then
    echo "gpg command not found. Abort."
    exit 1
fi


TEMPFILE=`mktemp /tmp/smt.crt.XXXXXX`

if [ -x $WGET ]; then
	$WGET  --no-verbose -q --no-check-certificate --output-document $TEMPFILE $CERTURL
	if [ $? -ne 0 ]; then
		echo "Download failed. Abort.";
		exit 1;
	fi
else
	echo "Binary to download the certificate not found. Please install wget. Abort."
	exit 1;
fi

$OPENSSL x509 -in $TEMPFILE -text -noout

read -p "Do you accept this certificate? [y/n] " YN

if [ "$YN" != "Y" -a "$YN" != "y" ]; then
	echo "Abort.";
	exit 1;
fi

ISRES=0

if [ -d $SSLDIR ]; then
    $CP $TEMPFILE $SSLDIR/registration-server.pem
    $CHMOD 0644 $SSLDIR/registration-server.pem

    if [ ! -x $CREHASH ]; then
        echo "c_rehash command not found.";
    else
        $CREHASH $SSLDIR > /dev/null
    fi
else
    for f in "${CAFILE[@]}"; do
        if [ -e $f ]; then
            $CAT $TEMPFILE >> $f;
            ISRES=1
            break;
        fi
    done
fi

if [ -d $ZMDSSLDIR ]; then
    $CP $TEMPFILE $ZMDSSLDIR/registration-server.cer
    $CHMOD 0644 $ZMDSSLDIR/registration-server.cer
    if [ -x $ZMDINIT ]; then
        $ZMDINIT restart > /dev/null
    fi
fi

SRCTMP=`mktemp /tmp/suseRegister.conf.XXXXXX`


$CAT $SRCONF | $GREP -v "^url" > $SRCTMP
$CP $SRCONF ${SRCONF}-`date '+%F'` 
echo "url=$REGURL" > $SRCONF
$CAT $SRCTMP >> $SRCONF
$RM $SRCTMP

#
# check for keys on the smt server to import
#
TMPDIR=`mktemp -d /tmp/smtsetup-XXXXXXXX`;

KEYSURL=`echo "$REGURL" | awk -F/ '{print "https://" $3 "/repo/keys/"}'`

if [ -z $TMPDIR ]; then
    echo "Cannot create tmpdir. Abort."
    exit 1
fi

$WGET --quiet --mirror --no-parent --no-host-directories --directory-prefix $TMPDIR --cut-dirs 2 $KEYSURL 

for key in `ls $TMPDIR/*.key 2>/dev/null`; do

    if [ -z $key ]; then
        continue
    fi

    if [ "$key" == "$TMPDIR/res-signingkeys.key" -a $ISRES -eq 0 ]; then
        # this is no RES system, so we do not need this key
        continue
    fi

    mkdir $TMPDIR/.gnupg

    $GPG --no-default-keyring --quiet --no-greeting --no-permission-warning --homedir  $TMPDIR/.gnupg --import $key

    $GPG --no-default-keyring --no-greeting --no-permission-warning --homedir $TMPDIR/.gnupg --list-public-keys --with-fingerprint

    read -p "Trust and import this key? [y/n] " YN
    rm -rf $TMPDIR/.gnupg/
    if [ "$YN" != "Y" -a "$YN" != "y" ]; then
        continue ;
    fi
   
    rpm --import $key
done

rm -rf $TMPDIR/

echo "Client setup finished."

read -p "Start the registration now? [y/n] " YN

if [ "$YN" != "Y" -a "$YN" != "y" ]; then
	exit 0;
fi

echo "$SUSEREGISTER -i -L /root/.suse_register.log"
$SUSEREGISTER -i -L /root/.suse_register.log