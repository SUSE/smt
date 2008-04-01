#! /bin/sh

WGET=/usr/bin/wget
CURL=/usr/bin/curl
OPENSSL=/usr/bin/openssl
CREHASH=/usr/bin/c_rehash
ZMDINIT=/etc/init.d/novell-zmd
CP=/bin/cp

SSLDIR=/etc/ssl/certs/
ZMDSSLDIR=/etc/zmd/trusted-certs/

REGURL=$1

if [ -z "$REGURL" ]; then
	echo "Missing registration URL. Abort."
	exit 1;
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

CERTURL=`echo "$REGURL" | awk -F/ '{print $1 "//" $3 "/smt.crt"}'`
TEMPFILE=`mktemp /tmp/smt.crt.XXXXXX`

if [ -x $WGET ]; then
	$WGET --output-document $TEMPFILE $CERTURL;
	if [ $? -ne 0 ]; then
		echo "Download failed. Abort.";
		exit 1;
	fi
elif [ -x $CURL ]; then
	$CURL --output $TEMPFILE $CERTURL;
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

$CP $TEMPFILE $SSLDIR/smt.pem
$CP $TEMPFILE $ZMDSSLDIR/smt.cer

$CREHASH $SSLDIR

if [ -x $ZMDINIT ]; then
	$ZMDINIT restart
fi

cat /etc/suseRegister.conf | grep -v "^url" > /etc/suseRegister.conf.NEW
$CP /etc/suseRegister.conf /etc/suseRegister.conf-`date '+%x'`
echo "url=$REGURL" > /etc/suseRegister.conf
cat /etc/suseRegister.conf.NEW >> /etc/suseRegister.conf
 
