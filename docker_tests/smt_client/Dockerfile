FROM registry.scc.suse.de/connect_sp2

ADD files/smt_current.rpm /root/smt_current.rpm

RUN zypper ref && zypper --non-interactive install --no-recommend \
    timezone patch

RUN zypper --non-interactive in --no-recommend /root/smt_current.rpm

ADD files/run.sh /root/run.sh
ADD files/p1.patch /root/p1.patch
RUN cd / && patch -p0 < /root/p1.patch

ENTRYPOINT ["/root/run.sh"]
CMD ["tail", "-f", "/dev/null"]
