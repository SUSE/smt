FROM registry.suse.com/suse/ltss/sle12.5/sles12sp5:latest

ARG INTERNAL_REPO

RUN zypper ar "${INTERNAL_REPO}" sle-updates && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install -y suseconnect-ng

RUN --mount=type=secret,id=regcode \
    SUSEConnect -r "$(cat /run/secrets/regcode)" && \
    SUSEConnect -p sle-sdk/12.5/x86_64

RUN zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install -y -t pattern smt
RUN zypper --non-interactive install -y curl wget make vim gcc swig gettext-tools mariadb-client && \
    zypper clean --all

RUN mkdir -p \
        /var/lib/smt \
        /var/log/smt/schema-upgrade \
        /var/cache/smt \
        /var/run/smt \
        /var/spool/smt-support \
        /etc/smt.d && \
    chown smt:www \
        /var/lib/smt \
        /var/log/smt \
        /var/cache/smt \
        /var/run/smt \
        /var/spool/smt-support && \
    chmod 775 /var/spool/smt-support

COPY docker/entrypoint.sh /entrypoint.sh
COPY docker/smt.conf.template /etc/smt.conf.template
COPY docker/vhost.conf /etc/apache2/vhosts.d/smt-http.conf

RUN chmod +x /entrypoint.sh && \
    echo "ServerName localhost" > /etc/apache2/conf.d/servername.conf

WORKDIR /usr/src/smt
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
