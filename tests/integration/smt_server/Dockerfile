FROM registry.scc.suse.de/connect_sp2

RUN [[ \
-z "$SCC_REGSERVER_URL" || \
-z "SCC_USERNAME" || \
-z "$SCC_PASSWORD" || \
-z "$SMT_DB_USER"  || \
-z "$SMT_DB_PASSWORD"  || \
-z "$MYSQL_ROOT_PASSWORD" \
]] && echo "ERROR: Please set variables in .env file" && exit 1

RUN zypper ref && zypper --non-interactive install --no-recommend \
    timezone patch mariadb-client libopenssl-devel

ADD files/smt_current.rpm /root/smt_current.rpm
RUN zypper --non-interactive --no-gpg-checks in --no-recommend /root/smt_current.rpm

ADD files/run.sh /root/run.sh
ADD files/p1.patch /root/p1.patch
RUN touch /etc/zypp/credentials.d/SCCcredentials
RUN cd / && patch -p0 < /root/p1.patch

ENTRYPOINT ["/root/run.sh"]
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
